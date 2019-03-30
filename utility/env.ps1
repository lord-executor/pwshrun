
$environment = PwshRun-GetSettings "environment"

$currentEnv = @{
    "location" = $null
    "reverse" = $null
    "current" = $null
}

function Env-LocateConfig {
    $path = $pwd.ProviderPath
    while ($path) {
        $file = Join-Path $path ".env"
        if (Test-Path $file) {
            if ($currentEnv.location -ne $file) {
                Env-Reset
                Env-Update $file
            }
            return
        }

        $path = Split-Path $path
    }

    Env-Reset
}

function Env-Log {
    Param(
        [string] $message
    )

    if ($environment.logUpdate) {
        Write-Host $message
    }
}

function Env-Set {
    Param(
        [Parameter(Mandatory=$true)]
        [hashtable] $vars
    )

    Env-Log "Updating environment..."
    $vars.Keys | ForEach-Object {
        if ($null -eq $vars[$_]) {
            Env-Log "remove $_"
            Remove-Item -Path "env:$_"
        } else {
            Env-Log "$_ => $($vars[$_])"
            Set-Item -Path "env:$_" -Value $vars[$_]
        }
    }
}

function Env-Update {
    Param(
        [Parameter(Mandatory=$true)]
        [string] $envFile
    )

    $vars = Get-Content $file | ConvertFrom-Json -AsHashtable
    $currentEnv.location = $file
    $currentEnv.reverse = @{}
    $currentEnv.current = @{}
    $vars.Keys | ForEach-Object {
        $currentEnv.reverse[$_] = if (Test-Path "env:$_") { (Get-Item -Path "env:$_").Value } else { $null }
        $currentEnv.current[$_] = PwshRun-ExpandVariables $vars[$_]
    }

    Env-Set $currentEnv.current
}

function Env-Reset {
    if ($currentEnv.reverse) {
        Env-Set $currentEnv.reverse
    }

    $currentEnv.location = $null
    $currentEnv.reverse = $null
    $currentEnv.current = $null
}

function Env-Show {
    if ($currentEnv.current) {
        $currentEnv.current | Out-String | Write-Output
    } else {
        Write-Output "no custom environment"
    }
}

function Env-Reload {
    Env-Reset
    Env-LocateConfig
}

PwshRun-RegisterPromptHook "env" { Env-LocateConfig }

PwshRun-RegisterTasks "env" @(
    @{
        Alias = "env:show";
        Command = "Env-Show";
        Description = "Shows the current custom environment variables";
        Example = "`$RUNNER env:show";
    },
    @{
        Alias = "env:reload";
        Command = "Env-Reload";
        Description = "Reloads the custom environment from the '.env' file";
        Example = "`$RUNNER env:reload";
    }
)
