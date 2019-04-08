
$tasks = PwshRun-GetSettings "alias"

function Alias-List {
    $tasks.Keys
}

function Alias-RunCommands {
    Param(
        [string] $alias
    )

    $ErrorActionPreference = "Stop"
    $tasks[$alias].cmd | ForEach-Object {
        Invoke-Expression $_
    }
}

PwshRun-RegisterTasks "alias" @(
    @{
        Alias = "alias:list";
        Command = "Alias-List";
        Description = "Lists all user defined aliases";
        Example = "`$RUNNER alias:list";
    }
)

$pwshrunTasks = @()
$tasks.GetEnumerator() | Foreach-Object {
    $pwshrunTasks = $pwshrunTasks + @{
        Alias = $_.Key;
        Command = [scriptblock]::Create("Alias-RunCommands $($_.Key)");
        Description = "";
        Example = "`$RUNNER $_";
    }
}

PwshRun-RegisterTasks "alias" $pwshrunTasks