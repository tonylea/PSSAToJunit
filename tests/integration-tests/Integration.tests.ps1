Describe "Integration Tests" {
    BeforeAll {
        Set-BuildEnvironment -Path ($PSScriptRoot -replace "tests.+") -Force

        Import-Module -Name $env:BHPSModuleManifest
    }

    Context "Module Importation" {
        It "Should import the module" {
            {
                $null = Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -WarningAction SilentlyContinue
            } | Should -Not -Throw
        }
    }

    Context "ConvertTo-PSSAJunitXml" {
        BeforeAll {
            $SampleScriptFolder = $PSScriptRoot -replace "integration-tests", "sample-powershell"
            $SampleGoodScript = Join-Path -Path $SampleScriptFolder -ChildPath "SampleGoodScript.ps1"
            $SampleBadScript = Join-Path -Path $SampleScriptFolder -ChildPath "SampleBadScript.ps1"

            Import-Module -Name $env:BHPSModuleManifest
        }
        It "Should convert PSScriptAnalyzer results to Junit XML" {
            $PSScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path $SampleBadScript
            ConvertTo-PSSAJunitXml -PSScriptAnalyzerResult $PSScriptAnalyzerResults | Should -Not -BeNullOrEmpty
        }

        It "Should convert PSScriptAnalyzer results to Junit XML with a custom test name" {
            $PSScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path $SampleBadScript
            ConvertTo-PSSAJunitXml -PSScriptAnalyzerResult $PSScriptAnalyzerResults -TestName "CustomTestName" | Should -Not -BeNullOrEmpty
        }

        # It "Should convert PSScriptAnalyzer null results to Junit XML" {}
    }

    Context "Export-PSSAJunitXml" {
        BeforeAll {
            # Create a piece of sample data
        }
        # It "Should export the sample data to a file" {}
        # It "Should export the results of the pipeline to a file" {}

    }

    Context "Pipeline Inputs" {
        # ConvertTo-PSSAJunitXml accepts pipeline input from Invoke-PSScriptAnalyzer
        # Export-PSSAJunitXml accepts pipeline input from ConvertTo-PSSAJunitXml
        # Chain them together and make sure they work
    }
}
