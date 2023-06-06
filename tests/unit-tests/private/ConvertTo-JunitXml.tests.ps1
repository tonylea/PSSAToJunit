Describe "ConvertTo-JunitXml" {
    BeforeAll {
        Set-BuildEnvironment -Path ($PSScriptRoot -replace "tests.+") -Force

        $FunctionName = "ConvertTo-JunitXml"

        $FunctionPath = $PSCommandPath -replace ".+unit-tests", $ENV:BHPSModulePath -replace "\.tests"
        . $FunctionPath


        $FunctionDependencies = @{
            private = @(
                "Get-ParentXml"
                "Get-TestSuiteXml"
                "Get-TestCaseXml"
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
            $ParameterInfo.Count - 11 | Should -Be 2
        }

        It "Has a mandatory 'TestSuites' parameter" {
            $Function | Should -HaveParameter TestSuites -Type System.Collections.Hashtable -Mandatory
        }

        It "Has a mandatory 'TestName' parameter" {
            $Function | Should -HaveParameter TestName -Type System.String -Mandatory
        }
    }
}
