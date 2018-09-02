# PwshRun
PwshRun is a very simple task runner / productivity tool for PowerShell Core

* It makes running tasks more linux-y by eliminating the whole PowerShell Verb-Something notation in favor of easy to type aliases
* It can manage multiple isolated _runners_, each with its own custom alias and loaded task bundles (using New-Module internally)
* It manages its configuration in the form of JSON files in the user's home directory



# Installation
```
> Install-Module PwshRun
```

Or you can download and install it by hand - http://www.powertheshell.com/installpsmodule/



# Getting Started
Once the module is loaded, you have to create a runner.

```
> New-PwshRunner pr
```

This creates a new runner with the alias "pr" and a default configuration for you. The new configuration file (located under `~/.pwshrun.ps.json`) is automatically opened for editing.

The default configuration loads the utility bundle and configures a sample location for the `go` task. With that you can now do the following:
```
> pr go windir
# you are now in your windows directory
> pr go -
# you are now back where you started
```

You can now change the configuration of your runner and after saving the changes, run
```
> Reset-PwshRunModules
```
to reload all of your runners.

You can get an overview over your runner's tasks with
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



# Configuration
The main configuration file is `~/.pwshrun.json` and it defines the runners and the locations where their task bundles will be loaded from

```json
{
    "pr": {
        "load": [
            "$PWSHRUN_HOME\\utility"
        ]
    }
}
```

This configuration file will be created the first time the PwshRun module is loaded unless the file already exists.

Load paths can either be a **directory** in which case all `*.ps1` files contained in that directory will be included, or it can be a path to a **file** which will load exactly that file.


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

## Core
The core bundle is always loaded.

### task:list
Lists all tasks known to the runner with their bundle name, description and example invokation.

### task:metadata
Returns the PwshRun task configuration objects.

```
> (pr task:metadata).GetEnumerator() | % { $_.Value | Format-Table }
```

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
Simple task argument debugging tool. It just prints its arguments with some additional information.

#### Configuration
None
