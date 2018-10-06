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
        $vars
    )

    $vars.GetEnumerator() | ForEach-Object {
        New-Variable -Name $_.Key -Value $_.Value
    }

    return $ExecutionContext.InvokeCommand.ExpandString($str)
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
        Invoke-Expression "$($task.Command) @processedArgs"
    } else {
        $processedArgs = $taskArgs | ForEach-Object {
            if ($_ -match "^-\w+$") { $_ } else { "`"$_`"" }
        }
        Invoke-Expression "$($task.Command) $processedArgs"
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
