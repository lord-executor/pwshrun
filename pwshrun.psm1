
$settingsPath = "$env:HOME\.pwshrun.json"
if (!(Test-Path -Path $settingsPath)) {
    Write-Warning "Missing settings file $settingsPath"
}

$pwshrunConf = @{
    "moduleRoot" = $PSScriptRoot;
    "tasks" = @{};
    "taskSets" = @{};
}

<#
 .Synopsis
    Dynamically calls the given command with the given array of arguments (with proper argument escaping)
#>
function PwshRun-DynamicCall {
    Param(
        [string] $cmd,
        [object[]] $cmdArgs = @()
    )

    $mappedArgs = $cmdArgs | %{ "`"$_`""}
    Invoke-Expression "$cmd $mappedArgs"
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
function PwshRun-RegisterSettings {
    Param(
        [string] $taskSet,
        [object] $settings
    )

    $pwshrunConf.taskSets.add($taskSet, $settings)
}

<#
 .Synopsis
    Invokes a PwshRun task with the given argumetns
#>
function Invoke-PwshRunTask {
    Param(
        [string] $task,
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] $taskArgs
    )

    $command = $pwshrunConf.tasks[$task]
    if ($command) {
        PwshRun-DynamicCall $pwshrunConf.tasks[$task] $taskArgs
    } else {
        Write-Error "Unknown task $task"
    }
}

. "$PSScriptRoot/core-tasks.ps1"
. "$PSScriptRoot/core-management.ps1"
. "$PSScriptRoot/core-utility.ps1"

Set-Alias prun Invoke-PwshRunTask
Export-ModuleMember -Function Invoke-PwshRunTask -Alias prun
Export-ModuleMember -Variable "pwshrunConf"
