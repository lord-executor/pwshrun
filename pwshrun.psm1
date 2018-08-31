Write-Output "Loading module PwshRun from $PSScriptRoot"

$pwshrunConf = @{
    "tasks" = @{};
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
    Invokes a PwshRun task with the given argumetns
#>
function Invoke-PwshRunTask {
    Param(
        [string] $task,
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] $taskArgs
    )

    Write-Output "Invoke-PwshRunTask"

    PwshRun-DynamicCall $pwshrunConf.tasks[$task] $taskArgs
}

. "$PSScriptRoot/cmd-go.ps1"

Set-Alias prun Invoke-PwshRunTask
Export-ModuleMember -Function Invoke-PwshRunTask -Alias prun
Export-ModuleMember -Variable "pwshrunConf"
