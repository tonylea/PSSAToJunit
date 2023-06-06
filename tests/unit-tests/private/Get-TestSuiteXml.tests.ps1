Describe "Get-TestSuiteXml" {
    BeforeAll {
        Set-BuildEnvironment -Path ($PSScriptRoot -replace "tests.+") -Force

        $FunctionName = "Get-TestSuiteXml"

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
            $ParameterInfo.Count - 11 | Should -Be 1
        }

        It "Has a mandatory 'TestSuiteName' parameter" {
            $Function | Should -HaveParameter TestSuiteName -Type System.String -Mandatory
        }
    }
}
