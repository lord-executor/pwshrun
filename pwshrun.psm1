
$settingsPath = "~\.pwshrun.json"
$settings = @{}
if (!(Test-Path -Path $settingsPath)) {
    Write-Warning "Missing settings file $settingsPath"
} else {
    $settings = Get-Content $settingsPath | ConvertFrom-Json -AsHashtable
}

$pwshrunConf = @{
    "moduleRoot" = $PSScriptRoot;
    "tasks" = @{};
    "settings" = $settings;
}

<#
 .Synopsis
    Registers a runnable task in the PwshRun taskset
#>
function PwshRun-RegisterTask {
    Param(
        [string] $alias,
        [string] $function
    )

    $pwshrunConf.tasks.add($alias, $function)
}

<#
 .Synopsis
    Registers settings for a task-set
#>
function PwshRun-GetSettings {
    Param(
        [string] $taskSet
    )

    return $pwshrunConf.settings[$taskSet]
}

<#
 .Synopsis
    Invokes a PwshRun task with the given argumetns
#>
function Invoke-PwshRunTask {
    Param(
        [string] $taskName,
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] $taskArgs
    )

    $task = $pwshrunConf.tasks[$taskName]
    if ($task) {
        Invoke-Expression "$task @taskArgs"
    } else {
        Write-Error "Unknown task $taskName"
    }
}

. "$PSScriptRoot/core-tasks.ps1"
. "$PSScriptRoot/core-management.ps1"
. "$PSScriptRoot/core-utility.ps1"

Set-Alias prun Invoke-PwshRunTask
Export-ModuleMember -Function Invoke-PwshRunTask -Alias prun
Export-ModuleMember -Variable "pwshrunConf"
