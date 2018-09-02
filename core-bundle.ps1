
function Task-List {
    $config.bundles.Keys | Sort-Object | ForEach-Object {
        $bundleName = "[$_]".PadRight(15)
        
        $config.bundles[$_] | Sort-Object -Property Alias | ForEach-Object {
            $task = $_
            $bundle = 
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
    }
)
