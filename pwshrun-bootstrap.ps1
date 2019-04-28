<#
    The bootstrapper is receiving implicit arguments from pwshrun.psm1 New-Module script block
    - $alias : the alias to use for this task runner
    - $options : the options for the task runner
#>

. "$PSScriptRoot/command.ps1"

if ($options.ContainsKey("settings")) {
    $settingsPath = $options.settings
} else {
    $settingsPath = "~\.pwshrun.$alias.json"
}
$config = @{
    "vars" = @{
        "PWSHRUN_HOME" = $PSScriptRoot;
        "RUNNER" = $alias;
    };
    "bundles" = @{};
    "tasks" = @{};
    "settings" = @{};
}

function PwshRun-LoadSettings {
    Param(
        [string] $settingsPath
    )

    $combined = @{}
    $data = Get-Content $(PwshRun-ExpandVariables $settingsPath) | ConvertFrom-Json -AsHashtable
    if ($data._vars) {
        $config.vars = PwshRun-MergeHashtables $config.vars $data._vars
        $data.Remove("_vars")
    }
    if ($data._include) {
        foreach ($file in $data._include) {
            $combined = PwshRun-MergeHashtables $combined $(PwshRun-LoadSettings $file)
        }
        $data.Remove("_include")
    }

    $combined = PwshRun-MergeHashtables $combined $data

    $combined
}

<#
 .Synopsis
    Registers runnable tasks with this runner
#>
function PwshRun-RegisterTasks {
    Param(
        [string] $bundle,
        [hashtable[]] $tasks
    )

    if ($config.bundles.ContainsKey($bundle)) {
        $config.bundles[$bundle] += $tasks
    } else {
        $config.bundles[$bundle] = $tasks
    }

    $tasks | ForEach-Object {
        $config.tasks[$_.Alias] = $_;
    }
}

<#
 .Synopsis
    Gets the settings for a specific task bundle
#>
function PwshRun-GetSettings {
    Param(
        [string] $taskBundle
    )

    return $config.settings[$taskBundle]
}

<#
 .Synopsis
    Creates local variables from all elements in the given hashtable in the parent
    (caller) scope.
#>
function PwshRun-CreateVariables {
    Param(
        [hashtable] $vars
    )

    $vars.GetEnumerator() | ForEach-Object {
        New-Variable -Force -Scope 1 -Name $_.Key -Value $_.Value
    }
}

<#
 .Synopsis
    Performs string expansion with a defined set of variables
#>
function PwshRun-ExpandVariables {
    Param(
        [string] $str,
        [hashtable] $vars = $config.vars
    )

    PwshRun-CreateVariables $vars

    return $ExecutionContext.InvokeCommand.ExpandString($str)
}

function PwshRun-MergeHashtables {
    $output = @{}
    # $input is an enumerator, so we have to get the enumerator of $tables in order
    # to combine the two
    foreach ($table in ($input + $args.GetEnumerator())) {
        if ($table -is [hashtable]) {
            foreach ($key in $table.Keys) {
                if ($table.$key -is [hashtable] -and $output.$key -is [hashtable]) {
                    $output.$key = PwshRun-MergeHashtables $output.$key $table.$key
                } else {
                    $output.$key = $table.$key
                }
            }
        }
    }
    $output
}

function PwshRun-RegisterPromptHook {
    Param(
        [string] $name,
        [ScriptBlock] $block
    )

    $global:PwshRunPrompt.hooks[$name] = $block
}

function PwshRun-RemovePromptHook {
    Param(
        [string] $name
    )

    $global:PwshRunPrompt.hooks.Remove($name)
}

if (!(Test-Path -Path $settingsPath)) {
    Write-Warning "Missing settings file $settingsPath"
} else {
    $config.settings = PwshRun-LoadSettings $settingsPath
}

$invokeInName = "Invoke-PwshRunCommandIn$((Get-Culture).TextInfo.ToTitleCase($alias))"
Set-Item -Path "function:$invokeInName" -Value {
    param(
        [Parameter(Mandatory=$true)]
        [PSObject] $command
    )

    Invoke-PwshRunCommandInternal $command
}


<#
 .Synopsis
    Invokes a PwshRun task with the given arguments
#>
$invokeName = "Invoke-PwshRunTaskOf$((Get-Culture).TextInfo.ToTitleCase($alias))"
Set-Item -Path "function:$invokeName" -Value {
    Param(
        [string] $taskName,
        [switch] $splat = $false,
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] $taskArgs
    )

    $env:PWSHRUN_RUNNER = $alias

    $task = $config.tasks[$taskName]
    if (!$task) {
        Write-Error "Unknown task $taskName"
        $env:PWSHRUN_RUNNER = $null
        return
    }

    if ($taskArgs.Length -eq 0) {
        # short circuit for 0 arguments case
        & $task.Command
        $env:PWSHRUN_RUNNER = $null
        return
    }

    # PowerShell dynamic argument handling is weird ...
    if ($splat) {
        $processedArgs = $taskArgs | Select-Object -First 1
        & $task.Command @processedArgs
    } else {
        $namedArgs = @{}
        $positionalArgs = New-Object System.Collections.ArrayList
        $name = $null
        # building named and positional arguments by "guessing"
        $taskArgs | ForEach-Object {
            if ($_ -is [string] -and $_ -match "^-\w+$") {
                $name = $_.Substring(1)
            } elseif ($_ -is [string] -and $_ -match "^\+\w+$") {
                $namedArgs.Add($_.Substring(1), $true)
            } else {
                # allow _escaping_ of arguments that would normally be interpreted as the name for a
                # named argument ("-Foo") => "`-Foo" will be converted to "-Foo" as an argument _value_
                $value = if ($_ -match "^``[-+]") { $_.Substring(1) } else { $_ }

                if ($name -eq $null) {
                    $positionalArgs.Add($value) > $null
                } else {
                    $namedArgs.Add($name, $value)
                    $name = $null
                }
            }
        }
        & $task.Command @namedArgs @positionalArgs
    }

    $env:PWSHRUN_RUNNER = $null
}

. "$PSScriptRoot/core-bundle.ps1"

Set-Alias $alias $invokeName
Export-ModuleMember -Function $invokeName,$invokeInName -Alias $alias

<#
 Load runner scripts / tasks
#>
$options.load | ForEach-Object {
    $path = PwshRun-ExpandVariables $_

    if (Test-Path $path -PathType Container) {
        Get-ChildItem $path -Filter "*.ps1" | ForEach-Object {
            . $_.FullName
        }
    } else {
        . $path
    }
}
