
$modules = @{}
$settingsPath = "~\.pwshrun.json"

if (!(Test-Path $settingsPath)) {
    Write-Host "PwshRun: Initializing..."
    Write-Host "PwshRun: Creating $settingsPath"
    @{} | ConvertTo-Json | Set-Content $settingsPath
}

function PrePromptWithHooks {
    $global:PwshRunPrompt.hooks.Values | ForEach-Object { & $_ }
}

function PromptWithHooks {
    PrePromptWithHooks
    & $global:PwshRunPrompt.oldPrompt
}

function Create-PromptHooks {
    $promptConfig = Get-Variable -Name "PwshRunPrompt" -Scope Global -ValueOnly -ErrorAction SilentlyContinue
    if (!$promptConfig) {
        $promptConfig = @{
            "hooks" = @{}
        }
        Set-Variable -Name "PwshRunPrompt" -Value $promptConfig -Scope Global
        if (Test-Path "variable:PrePrompt") {
            # Cmder sets up its own prompt with a "PrePrompt" script block that we can use
            $global:PrePrompt = { PrePromptWithHooks }
        } else {
            $promptConfig.oldPrompt = (Get-Item -Path "function:prompt").ScriptBlock
            Set-Item -Path "function:prompt" -Value PromptWithHooks
        }
    }
}

function Reset-PromptHooks {
    if ($global:PwshRunPrompt) {
        if ($global:PwshRunPrompt.oldPrompt) {
            Set-Item -Path "function:prompt" -Value $global:PwshRunPrompt.oldPrompt
        }
        Remove-Variable -Name "PwshRunPrompt" -Scope Global
    }
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
    Create-PromptHooks
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
    $modules = @{}
    Reset-PromptHooks
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
