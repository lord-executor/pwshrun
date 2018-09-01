
function Debug-Args {
    for ($i = 0; $i -lt $args.Length; $i++) {
        $v = $args[$i]
        Write-Output "[$i]: $v ($($v.GetType().FullName))"
    }
}

PwshRun-RegisterTasks "debug" @(
    @{
        Alias = "args";
        Command = "Debug-Args";
        Description = "Lists all the arguments given to the task with type information";
        Example = "`$RUNNER args [a1] [a2]";
    }
)
