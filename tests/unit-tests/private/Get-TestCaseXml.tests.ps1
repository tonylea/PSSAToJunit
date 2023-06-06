Describe "Get-TestCaseXml" {
    BeforeAll {
        Set-BuildEnvironment -Path ($PSScriptRoot -replace "tests.+") -Force

        $FunctionName = "Get-TestCaseXml"

        $FunctionPath = $PSCommandPath -replace ".+unit-tests", $ENV:BHPSModulePath -replace "\.tests"
        . $FunctionPath


        $FunctionDependencies = @{
            private = @()
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
            $ParameterInfo.Count - 11 | Should -Be 5
        }

        It "Has a 'TestCaseName' parameter" {
            $Function | Should -HaveParameter TestCaseName -Type System.String
        }

        It "Has a 'Severity' parameter" {
            $Function | Should -HaveParameter Severity -Type System.String
        }

        It "Has a 'TestCaseMessage' parameter" {
            $Function | Should -HaveParameter TestCaseMessage -Type System.String
        }

        It "Has a 'TestCasePath' parameter" {
            $Function | Should -HaveParameter TestCasePath -Type System.String
        }

        It "Has a 'Line' parameter" {
            $Function | Should -HaveParameter Line -Type System.Int32
        }
    }
}
