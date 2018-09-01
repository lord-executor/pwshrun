
$settingsPath = "~\.pwshrun.json"
$settings = @{}
if (!(Test-Path -Path $settingsPath)) {
    Write-Error "Missing settings file $settingsPath"
    return
} else {
    $settings = Get-Content $settingsPath | ConvertFrom-Json -AsHashtable
}

$modules = @{}

function Create-Modules {
    $settings.Keys | % {
        $alias = $_
        $options = $settings[$alias]
        $moduleName = "pwshrun-$alias"
        $module = New-Module -Name $moduleName -ArgumentList @($alias, $options) -ScriptBlock {
            Param(
                [string] $alias,
                $options
            )
            Write-Warning "got alias $alias"
            . "$PSScriptRoot/pwshrun-bootstrap.ps1"
        }
        Import-Module -Global -Force $module
        $modules[$moduleName] = $module
    }
}

function Uninstall-PwshRunModules {
    $modules.Keys | % {
        Remove-Module $_
    }
}

function Reset-PwshRunModules {
    Uninstall-PwshRunModules
    Create-Modules
}

Export-ModuleMember -Function Uninstall-PwshRunModules,Reset-PwshRunModules

Create-Modules