Param(
    [string] $apiKey
)

$ErrorActionPreference = "Stop"

dotnet build .\cmdlets\PwshRunCmdlets.sln -c Release

$modulePath = $env:PSModulePath -split ";" | Select-String -Pattern "Users" | Select-Object -First 1

$exclude = @(
    "publish.ps1",
    "cmdlets"
)
Remove-Item -Recurse "$modulePath\pwshrun"
New-Item -ItemType Directory "$modulePath\pwshrun"
Copy-Item -Recurse -Exclude $exclude -Path "$PSScriptRoot\*" -Destination "$modulePath\pwshrun"


#Publish-Module -Name "PwshRun" -NuGetApiKey $apiKey
