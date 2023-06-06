Describe "ConvertTo-PSSAJunitXml" {
    BeforeAll {
        Set-BuildEnvironment -Path ($PSScriptRoot -replace "tests.+") -Force

        $FunctionName = "ConvertTo-PSSAJunitXml"

        $FunctionPath = $PSCommandPath -replace ".+unit-tests", $ENV:BHPSModulePath -replace "\.tests"
        . $FunctionPath

        $FunctionDependencies = @{
            private = @(
                "Get-TestSuite"
                "ConvertTo-JunitXml"
            )
            public  = @()
            classes = @()
        }
        foreach ($Scope in $FunctionDependencies.Keys) {
            foreach ($Function in $FunctionDependencies.$Scope) {
                $FunctionPath = Join-Path -Path $ENV:BHPSModulePath -ChildPath $Scope -AdditionalChildPath "$Function.ps1"
                . $FunctionPath
            }
        }
    }

    Context "Parameters" {
        BeforeAll {
            $Function = Get-Command $FunctionName
        }

        It "Does not contain untested parameters" {
            $ParameterInfo = $Function.Parameters
            $ParameterInfo.Count - 11 | Should -Be 3
        }

        It "Has a mandatory 'PSScriptAnalyzerResult' parameter" {
            $Function | Should -HaveParameter PSScriptAnalyzerResult -Type Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[] -Mandatory
        }

        It "Has a 'TestName' parameter" {
            $Function | Should -HaveParameter TestName -Type System.String
        }
    }
}
