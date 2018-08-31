

function Management-Reload {
    $module = "$($pwshrunConf.moduleRoot)/pwshrun.psm1"
    Write-Output "Reloading $module"
    # Import-Module $module -Force
}

PwshRun-RegisterTask "reload" "Management-Reload"
