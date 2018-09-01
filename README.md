# PwshRun
PwshRun is a very simple task runner / productivity tool for PowerShell Core

* It makes running tasks more linux-y by eliminating the whole PowerShell Verb-Something notation in favor of easy to type aliases
* It can manage multiple isolated _runners_, each with its own custom alias and loaded task bundles
* It manages its configuration in the form of JSON files in the user's home directory

# Installation
TODO

# Basic Usage
TODO

# Configuration
The main configuration file is `~/.pwshrun.json` and it defines the runners and the locations where their task bundles will be loaded from

```json
{
    "pr": {
        "taskSets": [
            "$PWSHRUN_HOME\\utility"
        ]
    }
}
```

This configuration file will be created the first time the PwshRun module is loaded unless the file already exists.

With this configuration in place, you can get started with:

```ps
> pr task:list

[core]          task:list - List all available tasks and their descriptions
                  > pr task:list
[core]          task:metadata - Get metadata of all available tasks
                  > pr task:metadata
[debug]         args - Lists all the arguments given to the task with type information
                  > pr args [a1] [a2]
[navigation]    go - Change to the directory identified by the given [location] name
                  > pr go [location]
```

## Runner Configuration
For each runner, you can (and should) create its own task configuration file. Many tasks will have some configuration options that can be used to customize the task behavior - this should be part of the task / bundle documentation. The runner configuration file has to be created manually with the path `~/.[runnerName].json` where "[runnerName]" is the alias of the runner you are configuring (e.g. `~/.pr.json`).

```json
{
    "locations": {
        "dev": "C:\\development",
        "home": "C:\\Users\\me",
        "tools": "D:\\path\\to\\tools\\directory"
    }
}
```

# Built-In Bundles

## Utility

### go
The `go` task allows you to quickly navigate to a set of well-defined (configured) locations on your system.

```
> pr go tools
# working directory is now D:\path\to\tools\directory
> pr go -
# working directory is now what it was before
```

#### Configuration
```json
"locations": {
    "dev": "C:\\development",
    "home": "C:\\Users\\me",
    "tools": "D:\\path\\to\\tools\\directory"
}
```

### args
This is a helper task to debug argument handling.
