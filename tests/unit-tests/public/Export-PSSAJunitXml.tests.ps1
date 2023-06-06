Describe "Export-PSSAJunitXml" {
    BeforeAll {
        Set-BuildEnvironment -Path ($PSScriptRoot -replace "tests.+") -Force

        $FunctionName = "Export-PSSAJunitXml"

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
            $ParameterInfo.Count - 11 | Should -Be 2
        }

        It "Has a mandatory 'InputXml' parameter" {
            $Function | Should -HaveParameter InputXml -Type System.Xml.XmlDocument -Mandatory
        }

        It "Has a 'FilePath' parameter" {
            $Function | Should -HaveParameter FilePath -Type System.IO.FileInfo
        }
    }
}
