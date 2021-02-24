
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

function Check-State {
    if ((Get-Item "function:prompt").Source -eq "pwshrun") {
        Write-Host -ForegroundColor Green "'function:prompt': OK"
    } else {
        Write-Host -ForegroundColor Red "'function:prompt': Seems to have been overwritten after the pwshrun module was loaded. Prompt hooks will not work in this constellation."
    }
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
    },
    @{
        Alias = "check";
        Command = "Check-State";
        Description = "Checks the configuration and reports issues";
        Example = "`$RUNNER check";
    }
)
