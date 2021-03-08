Describe -name "Testing runner initialization with configuration" {
    # Scope Describe

    $settings = @{
        "prtest" = @{
            "load" = @();
            "settings" = @{
                "testSettings" = @{
                    "testKey" = "testValue";
                }
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

    Context "Configuration" {

        It "contains tasks defined in the core-bundles" {
            $metadata = prtest task:metadata
            $metadata.Count | Should -Be 6
            $metadata.GetEnumerator() | ForEach-Object {
                $_.Value.Bundle | Should -Be "core"
            }
        }

        It "contains runner variables" {
            $variables = prtest task:vars
            $variables["RUNNER"] | Should -Be "prtest"
            $variables["PWSHRUN_HOME"] | Should -Be $(Resolve-Path "..").ToString()
        }

        It "contains runner settings from configuration" {
            $runnerSettings = prtest task:settings
            $runnerSettings["testSettings"] | Should -Not -Be $null
            $runnerSettings["testSettings"]["testKey"] | Should -Be "testValue"
        }

        It "exposes well-known types" {
            $types = prtest task:types
            $types["LogLevel"].IsEnum | Should -BeTrue
            $types["PwshRunCommand"].IsClass | Should -BeTrue
        }

    }
}
