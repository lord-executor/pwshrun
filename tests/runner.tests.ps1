Describe -name "Testing runner initialization with configuration" {
    # Scope Describe

    $settings = @{
        "prtest" = @{
            "load" = @();
            "settings" = @{
            };
        };
    }
    Import-Module ..\pwshrun.psd1 -ArgumentList $settings

    Context "Basics" {

        It "creates a task runner with alias 'prtest'" {
            Get-Alias "prtest" | Should -Not -BeNullOrEmpty
            (Get-Alias "prtest").Definition | Should -Be "Invoke-PwshRunTaskOfPrtest"
        }

    }
}
