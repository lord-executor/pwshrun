
$locations = PwshRun-GetSettings "locations"

function Utility-Go {
    Param(
        [string] $location
    )

    if ($location -eq "-") {
        Pop-Location
    } else {
        Push-Location $locations[$location]
    }
}

PwshRun-RegisterTask "go" "Utility-Go"
