
$locations = @{
    "dev" = "H:\development";
    "home" = "C:\Users\executor";
}

function CmdGo {
    Param(
        [string] $location
    )

    # Set-Location $locations[$location]
    Write-Host "changing to $($locations[$location])"
}

PwshRun-RegisterTask "go" "CmdGo"
PwshRun-RegisterSettings "go" $locations
