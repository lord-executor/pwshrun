Param(
    [string] $apiKey
)

$modulePath = $env:PSModulePath -split ";" | Select-String -Pattern "Users" | Select-Object -First 1

$exclude = @(
    "publish.ps1"
)
Remove-Item -Recurse "$modulePath\pwshrun"
Copy-Item -Exclude $exclude -Path "$PSScriptRoot\*" -Destination "$modulePath\pwshrun"
Copy-Item -Recurse -Exclude $exclude -Path "$PSScriptRoot\utility" -Destination "$modulePath\pwshrun"


Publish-Module -Name "PwshRun" -NuGetApiKey $apiKey
