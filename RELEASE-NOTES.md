# 1.3.2 (2021-05-24)
* New cmdlets to interact with the credentails store `Write-CredentialsStore` and `Remove-CredentialsStore`
* Improved logging
* Improved prompt initialization and self-check command

# 1.3.1 (2019-04-26)
* Bugfix for alias bundle initialization error

# 1.3.0 (2019-04-08)
* Alias bundle for user defined tasks in runner configuration
* Custom CmdLet assembly for retreiving credentials from Windows Credentials Manager (credui.dll)
  * Exported `Read-CredentialsStore` CmdLet

# 1.2.0 (2019-04-02)
* Added prompt-hook capabilities
* New per-directory subtree environment variables customization

# 1.1.0 (2018-10-06)
* Improved task invokation and argument handling
* Customizable task runner settings location

# 1.0.0 (2018-09-02)
Initial release
