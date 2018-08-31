
function Task-List {
    $pwshrunConf.tasks.Keys
}

PwshRun-RegisterTask "task:list" "Task-List"
