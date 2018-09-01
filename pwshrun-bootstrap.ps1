<#
    receiving implicit arguments (from pwshrun.psm1)
    $alias
    $options
#>

$settingsPath = "~\.$alias.json"
$settings = @{}
if (!(Test-Path -Path $settingsPath)) {
    Write-Warning "Missing settings file $settingsPath"
} else {
    $settings = Get-Content $settingsPath | ConvertFrom-Json -AsHashtable
}

$config = @{
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

    $config.tasks.add($alias, $function)
}

<#
 .Synopsis
    Registers settings for a task-set
#>
function PwshRun-GetSettings {
    Param(
        [string] $taskSet
    )

    return $config.settings[$taskSet]
}

<#
 .Synopsis
    Invokes a PwshRun task with the given arguments
#>
$invokeName = "Invoke-PwshRunTaskOf$((Get-Culture).TextInfo.ToTitleCase($alias))"
Set-Item -Path "function:$invokeName" -Value {
    Param(
        [string] $taskName,
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] $taskArgs
    )

    $task = $config.tasks[$taskName]
    if ($task) {
        Invoke-Expression "$task @taskArgs"
    } else {
        Write-Error "Unknown task $taskName"
    }
}

. "$PSScriptRoot/core-tasks.ps1"
. "$PSScriptRoot/core-management.ps1"
. "$PSScriptRoot/core-utility.ps1"

Set-Alias $alias $invokeName
Export-ModuleMember -Function $invokeName -Alias $alias
