
function Task-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Task-RunElevated {
    param(
        [scriptblock]$block,
        [object[]]$blockArguments,
        [switch]$noExit
    )

    $command = New-PwshRunCommand $block -Arguments $blockArguments -WorkDir $PWD

    if (Task-IsElevated) {
        Invoke-PwshRunCommand $command
    } else {
        $file = Push-PwshRunCommand $command
        $cmd = Task-CreateReEntryCommand -CommandFile $file -NoExit:$noExit
        $cmd.StartProcess($true)
    }
}

function Task-CreateReEntryCommand {
    param(
        [string]$commandFile,
        [switch]$noExit
    )

    $module = (Get-Module pwshrun).Path
    $arguments = New-Object System.Collections.ArrayList

    if ($noExit) {
        $arguments.Add("-NoExit") | Out-Null
    }

    $arguments.Add("-Command") | Out-Null
    $arguments.Add("""& { Import-Module '$module'; Pop-PwshRunCommand '$commandFile' }""") | Out-Null

    Write-Host $arguments

    return New-PwshRunCommand (Get-Process -Id $pid).Path -Arguments $arguments
}
