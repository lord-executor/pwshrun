
$modules = @{}
$settingsPath = "~\.pwshrun.json"

if (!(Test-Path $settingsPath)) {
    Write-Host "PwshRun: Initializing..."
    Write-Host "PwshRun: Creating $settingsPath"
    @{} | ConvertTo-Json | Set-Content $settingsPath
}

<#
 .Synopsis
    Loads the PwshRun settings file that contains all the runner definitions
#>
function Load-Settings {
    $settings = @{}
    if (!(Test-Path -Path $settingsPath)) {
        Write-Error "Missing settings file $settingsPath"
    } else {
        $settings = Get-Content $settingsPath | ConvertFrom-Json -AsHashtable
    }
    return $settings
}

<#
 .Synopsis
    Creates dynamic runner modules - one module for each runner - with the pwshrun-bootstrap.ps1 script
    loading the runner tasks.
#>
function Create-Modules {
    $settings = Load-Settings

    $settings.Keys | ForEach-Object {
        $alias = $_
        $options = $settings[$alias]
        $moduleName = "pwshrun-$alias"
        $module = New-Module -Name $moduleName -ArgumentList @($alias, $options) -ScriptBlock {
            Param(
                [string] $alias,
                $options
            )

            . "$PSScriptRoot/pwshrun-bootstrap.ps1"
        }
        Import-Module -Global -Force $module
        $modules[$moduleName] = $module
    }
}

<#
 .Synopsis
    Creates a new PwshRun runner with the given name by adding a new runner definition to the settings file.
#>
function New-PwshRunner {
    Param(
        [string] $alias
    )

    $settings = Load-Settings
    $settings[$alias] = @{
        "load" = @("`$PWSHRUN_HOME\utility")
    }
    $settings | ConvertTo-Json | Set-Content $settingsPath
    
    $runnerSettingsPath = "~/.pwshrun.$alias.json"
    @{
        "locations" = @{
            "windir" = $env:WINDIR
        }
    } | ConvertTo-Json | Set-Content $runnerSettingsPath
    Invoke-Expression $runnerSettingsPath

    Reset-PwshRunModules
}

<#
 .Synopsis
    Removes all runner modules from the current session.
#>
function Uninstall-PwshRunModules {
    $modules.Keys | ForEach-Object {
        Remove-Module $_
    }
}

<#
 .Synopsis
    Reloads all runner modules, refreshing the settings for each.
#>
function Reset-PwshRunModules {
    Uninstall-PwshRunModules
    Create-Modules
}

Export-ModuleMember -Function Uninstall-PwshRunModules,Reset-PwshRunModules,New-PwshRunner

Create-Modules
