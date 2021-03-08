
# Analogous to Microsoft.Extensions.Logging.LogLevel
# Trace = 0, Debug = 1, Information = 2, Warning = 3, Error = 4, Critical = 5, None = 6
enum LogLevel {
    Trace = 0
    Debug = 1
    Information = 2
    Warning = 3
    Error = 4
    Critical = 5
    None = 6
}

function Task-Log {
    Param(
        [LogLevel] $level = [LogLevel]::Information,
        [string] $message
    )

    $threshold = [LogLevel]::Warning
    if ($env:PWSHRUN_LOGLEVEL) {
        $threshold = [LogLevel]$env:PWSHRUN_LOGLEVEL
    }

    if ([int]$level -ge [int]$threshold) {
        Write-Host $message
    }
}
