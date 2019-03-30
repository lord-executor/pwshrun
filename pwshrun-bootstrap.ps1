<#
    The bootstrapper is receiving implicit arguments from pwshrun.psm1 New-Module script block
    - $alias : the alias to use for this task runner
    - $options : the options for the task runner
#>

if ($options.ContainsKey("settings")) {
    $settingsPath = $options.settings
} else {
    $settingsPath = "~\.pwshrun.$alias.json"
}
$settings = @{}
if (!(Test-Path -Path $settingsPath)) {
    Write-Warning "Missing settings file $settingsPath"
} else {
    $settings = Get-Content $settingsPath | ConvertFrom-Json -AsHashtable
}

$config = @{
    "vars" = @{
        "PWSHRUN_HOME" = $PSScriptRoot;
        "RUNNER" = $alias;
    };
    "bundles" = @{};
    "tasks" = @{};
    "settings" = $settings;
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
    Performs string expansion with a defined set of variables
#>
function PwshRun-ExpandVariables {
    Param(
        [string] $str,
        $vars = $config.vars
    )

    $vars.GetEnumerator() | ForEach-Object {
        New-Variable -Name $_.Key -Value $_.Value
    }

    return $ExecutionContext.InvokeCommand.ExpandString($str)
}

function PwshRun-RegisterPromptHook {
    Param(
        [string] $name,
        [ScriptBlock] $block
    )

    $global:PwshRunPrompt.hooks[$name] = $block
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

    $task = $config.tasks[$taskName]
    if (!$task) {
        Write-Error "Unknown task $taskName"
        return
    }

    if ($taskArgs.Length -eq 0) {
        Invoke-Expression "$($task.Command)"
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
}

. "$PSScriptRoot/core-bundle.ps1"

Set-Alias $alias $invokeName
Export-ModuleMember -Function $invokeName -Alias $alias

<#
 Load runner scripts / tasks
#>
$options.load | ForEach-Object {
    $path = PwshRun-ExpandVariables $_ $config.vars

    if (Test-Path $path -PathType Container) {
        Get-ChildItem $path -Filter "*.ps1" | ForEach-Object {
            . $_.FullName
        }
    } else {
        . $path
    }
}
