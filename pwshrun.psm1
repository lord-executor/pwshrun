Write-Output "Loading module PwshRun from $PSScriptRoot"

. "$PSScriptRoot/cmd-go.ps1"

function DynamicCall {
    param(
        [string] $cmd,
        [object[]] $cmdArgs = @()
    )

    $mappedArgs = $cmdArgs | %{ "`"$_`""}
    Invoke-Expression "$cmd $mappedArgs"
}

function Run-Task {
    Write-Output "Run-Task"
}

Set-Alias prun Run-Task
Export-ModuleMember -Function Run-Task -Alias prun
