[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Suppress false positives in BeforeAll scriptblock')]
param()

Import-Module PSScriptAnalyzer

$BuildVarModulePath = Join-Path -Path ($PSScriptRoot -replace "tests.+") -ChildPath "Helpers" -AdditionalChildPath "Set-TestHelperEnvVars.psm1"
Import-Module -Name $BuildVarModulePath
Set-TestHelperEnvVars -Path $PSCommandPath

Describe "$ENV:THFunctionName" {
    BeforeAll {
        $FunctionName = $ENV:THFunctionName

        # Import function to test
        . $ENV:THFunctionPath

        $FuncDependancies = @{
            Private = @()
            Public = @()
            Classes = @()
        }
        foreach ($Scope in $FuncDependancies.Keys) {
            foreach ($Function in $FuncDependancies.$Scope) {
                $FuncPath = Join-Path -Path $ENV:BHPSModulePath -ChildPath $Scope -AdditionalChildPath "$Function.ps1"
                # Import dependant function into to scope
                . $FuncPath
            }
        }
    }

    Context "Parameters" {
        It "Does not contain untested parameters" {
            Write-Host $FunctionName
            $parameterInfo = (Get-Command $FunctionName).Parameters
            $parameterInfo.Count - 11| Should -Be 0
        }
    }

    Context "Core Functionality" {
        BeforeAll {
            $Xml = Get-TemplateXml
        }

        It "Returns an XML object" {
            $Xml | Should -BeOfType System.Xml.XmlDocument
        }

        It "Has 'testsuites' element" {
            $Xml.testsuites | Should -Not -BeNullOrEmpty
        }

        It "Has 'testsuite' element" {
            $Xml.testsuites.testsuite| Should -Not -BeNullOrEmpty
        }

        It "Has 'properties' element" {
            $Xml.testsuites.testsuite.properties| Should -Not -BeNullOrEmpty
        }
    }
}
