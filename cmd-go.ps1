
$locations = @{
    "dev" = "H:\development";
    "home" = "C:\Users\executor";
}

function CmdGo {
    param(
        [string] $location
    )

    # Set-Location $locations[$location]
    Write-Host "changing to $($locations[$location])"
}
