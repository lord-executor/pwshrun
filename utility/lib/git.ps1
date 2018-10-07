
$settings = PwshRun-GetSettings "git"

function Git-GetRoot {
    return $(git rev-parse --show-toplevel) -replace "/","\"
}

function Git-GetBranchName {
    return git rev-parse --abbrev-ref HEAD
}

function Git-CheckBranch {
    Param(
        [string] $branch
    )

    if ($branch -eq "HEAD") {
        Write-Error "Cannot determine branch name - you may be in a detached head state"
        return $false
    }

    return $true
}

function Git-FindMerge {
    Param(
        [string] $commit,
        [string] $targetBranch = $null,
        [switch] $show = $false
    )

    $targetBranch = if ($targetBranch -eq $null) { $settings.defaultBranch } else { $targetBranch }
    $merge = git rev-list $targetBranch ^$commit --ancestry-path --merges --reverse | Select-Object -First 1

    Write-Host $args

    if ($show) {
        git show $merge
    } else {
        $merge
    }
}

function Git-BranchCleanup {
    Write-Host "Removing fully merged and deleted (on remote) branches"
    git fetch --prune
    Write-Host "The following local branches are fully merged"
    git branch --list --format "%(refname:short)" --merge
    Write-Host "The following remote branches have not been updated in a month"

    $min = Get-Date -Format "s" -Date (Get-Date).AddDays(-30)
    git branch -r --format "%(refname:short)" | ForEach-Object {
        $cDate = git show -s --format=%cI $_
        if ($cDate -lt $min) {
            Write-Output $_
            Write-Output $(git show -s --format="%cI %ce <%cn>")
            Write-Output ""
        }
    }
}
