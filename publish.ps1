
$ErrorActionPreference = "Stop"

dotnet build .\cmdlets\PwshRunCmdlets.sln -c Release

$modulePath = $env:PSModulePath -split ";" | Select-String -Pattern "Users" | Select-Object -First 1

$exclude = @(
    "publish.ps1",
    "test.ps1",
    "cmdlets",
    "tests"
)
Remove-Item -Recurse "$modulePath\pwshrun"
New-Item -ItemType Directory "$modulePath\pwshrun"
Copy-Item -Recurse -Exclude $exclude -Path "$PSScriptRoot\*" -Destination "$modulePath\pwshrun"

$apiKey = (Read-CredentialsStore "PwshRun-PSGallery").GetNetworkCredential().Password
Publish-Module -Name "PwshRun" -NuGetApiKey $apiKey
