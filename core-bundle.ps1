
function Task-List {
    Param(
        [string] $bundle
    )

    $bundles = if ($bundle) { @($bundle) } else { $config.bundles.Keys }

    $bundles | Sort-Object | ForEach-Object {
        $bundleName = "[$_]".PadRight(15)
        
        $config.bundles[$_] | Sort-Object -Property Alias | ForEach-Object {
            $task = $_
            $description = PwshRun-ExpandVariables $task.Description $config.vars
            $example = PwshRun-ExpandVariables $task.Example $config.vars
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
