
<#
 .Synopsis
   Useful git utilities

 .Configuration
    "git": {
        "defaultBranch": "develop"
    }
#>

. "$PSScriptRoot/lib/git.ps1"

PwshRun-RegisterTasks "git" @(
    @{
        Alias = "git:clean";
        Command = "Git-Clean";
        Description = "git clean wrapper that takes a specific gitignore file as its first argument";
        Example = "`$RUNNER git:clean custom.gitignore -xdn";
        ArgMode = "Raw"
    },
    @{
        Alias = "git:find-merge";
        Command = "Git-FindMerge";
        Description = "Find the first merge commit in the [targetBranch] that contains the target [commit]";
        Example = "`$RUNNER git:find-merge e986ed12f28471";
    }
    @{
        Alias = "git:branch-cleanup";
        Command = "Git-BranchCleanup";
        Description = "Cleanup of local and remote branches";
        Example = "`$RUNNER git:branch-cleanup";
    }
)
