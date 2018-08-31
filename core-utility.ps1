
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

function Utility-Args {
    for ($i = 0; $i -lt $args.Length; $i++) {
        $v = $args[$i]
        Write-Output "[$i]: $v ($($v.GetType().FullName))"
    }
}

PwshRun-RegisterTask "go" "Utility-Go"
PwshRun-RegisterTask "args" "Utility-Args"
