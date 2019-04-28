
function Task-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Task-RunElevated {
    param(
        [scriptblock]$block,
        [object[]]$blockArguments,
        [switch]$noExit
    )

    $command = New-PwshRunCommand $block -Arguments $blockArguments -WorkDir $PWD

    if (Task-IsElevated) {
        Invoke-PwshRunCommand $command
    } else {
        $file = Push-PwshRunCommand $command
        $cmd = Task-CreateReEntryCommand -CommandFile $file -NoExit:$noExit
        $cmd.StartProcess($true)
    }
}

function Task-CreateReEntryCommand {
    param(
        [string]$commandFile,
        [switch]$noExit
    )

    $module = (Get-Module pwshrun).Path
    $arguments = New-Object System.Collections.ArrayList

    if ($noExit) {
        $arguments.Add("-NoExit") | Out-Null
    }

    $arguments.Add("-Command") | Out-Null
    $arguments.Add("""& { Import-Module '$module'; Pop-PwshRunCommand '$commandFile' }""") | Out-Null

    Write-Host $arguments

    return New-PwshRunCommand (Get-Process -Id $pid).Path -Arguments $arguments
}

function Task-List {
    Param(
        [string] $bundle
    )

    $bundles = if ($bundle) { @($bundle) } else { $config.bundles.Keys }

    $bundles | Sort-Object | ForEach-Object {
        $bundleName = "[$_]".PadRight(15)
        
        $config.bundles[$_] | Sort-Object -Property Alias | ForEach-Object {
            $task = $_
            $description = PwshRun-ExpandVariables $task.Description
            $example = PwshRun-ExpandVariables $task.Example
            Write-Output "$bundleName $($task.Alias) - $description"
            Write-Output "                  > $example"
        }
    }
}

function Task-Metadata {
    $config.tasks
}

function Task-ShowVars {
    $config.vars
}

function Task-ShowSettings {
    $config.settings
}

PwshRun-RegisterTasks "core" @(
    @{
        Alias = "task:list";
        Command = "Task-List";
        Description = "List all available tasks and their descriptions";
        Example = "`$RUNNER task:list";
    },
    @{
        Alias = "task:metadata";
        Command = "Task-Metadata";
        Description = "Get metadata of all available tasks";
        Example = "`$RUNNER task:metadata";
    },
    @{
        Alias = "task:vars";
        Command = "Task-ShowVars";
        Description = "Show all task variables";
        Example = "`$RUNNER task:vars";
    },
    @{
        Alias = "task:settings";
        Command = "Task-ShowSettings";
        Description = "Show all task settings";
        Example = "`$RUNNER task:settings";
    }
)
