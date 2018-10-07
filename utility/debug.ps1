
function Debug-Args {
    for ($i = 0; $i -lt $args.Length; $i++) {
        $v = $args[$i]
        Write-Output "[$i]: ($($v.GetType().FullName))"
        $v
    }
}

function Expand-Vars {
    Param(
        [string] $str,
        $vars = @{}
    )
    PwshRun-ExpandVariables $str $vars
}

PwshRun-RegisterTasks "debug" @(
    @{
        Alias = "args";
        Command = "Debug-Args";
        Description = "Lists all the arguments given to the task with type information";
        Example = "`$RUNNER args [a1] [a2]";
    },
    @{
        Alias = "expand";
        Command = "Expand-Vars";
        Description = "Lists all the arguments given to the task with type information";
        Example = "`$RUNNER expand 'some ```$x of string with ```$variables' @{'x' = 'type';'variables' = 'VARS'}";
    }
)
