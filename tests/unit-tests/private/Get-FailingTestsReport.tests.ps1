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
            Private = @("Get-TemplateXml")
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
            $parameterInfo.Count - 11| Should -Be 3
        }

        It "Has a mandatory string 'TestCount' parameter" {
            $parameterInfo = (Get-Command $FunctionName).Parameters['TestName']
            $parameterInfo | Should -Not -BeNullOrEmpty
            $parameterInfo.ParameterType.ToString() | Should -Be "System.String"
            $parameterInfo.Attributes.Mandatory | Should -Be $true
        }

        It "Has a mandatory string 'TestName' parameter" {
            $parameterInfo = (Get-Command $FunctionName).Parameters['Result']
            $parameterInfo | Should -Not -BeNullOrEmpty
            $parameterInfo.ParameterType.ToString() | Should -Be "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]"
            $parameterInfo.Attributes.Mandatory | Should -Be $true
        }

        It "Has a mandatory string 'TestName' parameter" {
            $parameterInfo = (Get-Command $FunctionName).Parameters['IncludeRule']
            $parameterInfo | Should -Not -BeNullOrEmpty
            $parameterInfo.ParameterType.ToString() | Should -Be "System.Array"
            $parameterInfo.Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Core Functionality" {
        BeforeEach {
            Mock Get-BaseXmlObject {return [System.Xml.XmlDocument]@"
                <?xml version="1.0" encoding="utf-8" standalone="no"?>
                <testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="PSScriptAnalyzer" tests="0" errors="0" failures="0" disabled="0" time="0">
                    <testsuite name="" tests="0" errors="0" failures="0" hostname="" id="0" skipped="0" disabled="0" package="" time="0">
                    <properties>
                        <property name="user" value="" />
                        <property name="cwd" value="" />
                        <property name="platform" value="" />
                        <property name="clr-version" value="" />
                        <property name="user-domain" value="" />
                        <property name="os-version" value="" />
                        <property name="junit-version" value="4" />
                        <property name="machine-name" value="" />
                    </properties>
                    </testsuite>
                </testsuites>
"@
                $Xml = Get-FailingTestsReport
            }

            It "Returns an XML object" {
                $Xml | Should -BeOfType System.Xml.XmlDocument
            }

            It "Calls Get-BaseXmlObject" {
                Should -InvokeVerifiable
            }
        }
    }
}
