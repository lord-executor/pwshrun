
<#
 .Synopsis
   Simple navigation helper with configurable named locations

 .Description
   Uses Push-Location and Pop-Location to change the current working directory

 .Configuration
    "locations": {
        "dev": "C:\\dev\\directory",
        "home": "C:\\Users\\me"
    }

 .Example
    alias go dev

 .Example
    alias go -
#>

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

PwshRun-RegisterTasks "navigation" @(
    @{
        Alias = "go";
        Command = "Utility-Go";
        Description = "Change to the directory identified by the given [location] name";
        Example = "`$RUNNER go [location]";
    }
)
