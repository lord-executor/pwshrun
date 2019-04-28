class PwshRunCommand {
    [object]$Cmd
    [object[]]$Arguments
    [string]$WorkDir
    [string]$Runner
    [boolean]$IsBlock = $false

    PwshRunCommand([object] $cmd) {
        $this.Cmd = $cmd
        $this.IsBlock = $cmd -is [scriptblock]
    }

    [void] StartProcess([switch]$runAs) {
        $processArgs = @{};
        if ($runAs) {
            $processArgs["Verb"] = "RunAs"
        }
        if ($this.WorkDir) {
            $processArgs["WorkingDirectory"] = $this.WorkDir
        }
        $processArgs["ArgumentList"] = $this.Arguments
        $processArgs["FilePath"] = $this.Cmd

        & "Start-Process" @processArgs
    }

    [string] Serialize() {
        $original = $this.Cmd
        $this.Cmd = $original.ToString()
        $result = ConvertTo-Json -Compress $this
        $this.Cmd = $original
        return $result
    }

    static [PwshRunCommand] Deserialize([string]$serialized) {
        $obj = ConvertFrom-Json -AsHashtable $serialized

        if ($obj.IsBlock) {
            $obj.Cmd = [scriptblock]::Create($obj.Cmd)
        }

        return New-PwshRunCommand $obj.Cmd -Arguments $obj.Arguments -WorkDir $obj.WorkDir -Runner $obj.Runner
    }
}

function New-PwshRunCommand {
    param(
        [Parameter(Position=0)]
        [object]$cmd,
        [object[]]$arguments = $null,
        [string]$workDir = $null,
        [string]$runner = $env:PWSHRUN_RUNNER
    )

    $command = [PwshRunCommand]::new($cmd)
    $command.Arguments = $arguments
    $command.WorkDir = $workDir
    $command.Runner = $runner

    return $command
}

function Invoke-PwshRunCommandInternal {
    param(
        [Parameter(Mandatory=$true)]
        [PSObject] $command
    )

    if ($command.WorkDir) {
        Push-Location $command.WorkDir
    }

    $a = $command.Arguments
    & $command.Cmd @a

    if ($this.WorkDir) {
        Pop-Location
    }
}

function Push-PwshRunCommand {
    param(
        [Parameter(Mandatory=$true)]
        [PSObject] $command
    )

    $file = New-TemporaryFile
    $command.Serialize() | Out-File $file.FullName

    return $file.FullName
}

function Pop-PwshRunCommand {
    param(
        [string]$commandFile
    )

    $command = [PwshRunCommand]::Deserialize($(Get-Content $commandFile))
    Remove-Item $commandFile
    Invoke-PwshRunCommand $command
}
