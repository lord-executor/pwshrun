
function Debug-Args {
    for ($i = 0; $i -lt $args.Length; $i++) {
        $v = $args[$i]
        Write-Output "[$i]: $v ($($v.GetType().FullName))"
    }
}

PwshRun-RegisterTask "args" "Debug-Args"
