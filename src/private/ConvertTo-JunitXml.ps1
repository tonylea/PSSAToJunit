function ConvertTo-JunitXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter(Mandatory)]
        [System.Collections.Hashtable]
        $TestSuites,

        [Parameter(Mandatory)]
        [String]
        $TestName
    )

    [System.Xml.XmlDocument]$JunitXml = Get-ParentXml -TestRunName $TestName

    foreach ($TestSuite in $TestSuites.GetEnumerator()) {
        [System.Xml.XmlDocument]$TestSuiteXml = Get-TestSuiteXml -TestSuiteName $TestSuite.Name

        foreach ($FailedTest in $TestSuite.Value.FailedTests) {
            [Hashtable]$GetTestCaseXmlArgs = @{
                TestCaseName    = $FailedTest.ScriptName
                TestCaseMessage = $FailedTest.Message
                TestCasePath    = $FailedTest.ScriptPath
                Line            = $FailedTest.Line
            }
            [System.Xml.XmlDocument]$TestCaseXml = Get-TestCaseXml @GetTestCaseXmlArgs

            $TestCaseRoot = $TestCaseXml.DocumentElement
            $ImportedNode = $TestSuiteXml.ImportNode($TestCaseRoot, $true)
            $TestSuiteXml.DocumentElement.AppendChild($ImportedNode) | Out-Null

            $TestSuiteXml.testsuite.tests = [int]($TestSuiteXml.testsuite.tests) + 1
            $TestSuiteXml.testsuite.failures = [int]($TestSuiteXml.testsuite.failures) + 1
        }

        if (![int]$TestSuiteXml.testsuite.failures) {
            $TestSuiteXml.testsuite.tests = 1
            $TestSuiteXml.testsuite.failures = 0

        }

        $TestSuiteRoot = $TestSuiteXml.DocumentElement
        $ImportedNode = $JunitXml.ImportNode($TestSuiteRoot, $true)
        $JunitXml.DocumentElement.AppendChild($ImportedNode) | Out-Null

        $JunitXml.testsuites.tests = [int]$JunitXml.testsuites.tests + [int]($TestSuiteXml.testsuite.tests)
        $JunitXml.testsuites.failures = [int]($JunitXml.testsuites.failures) + [int]($TestSuiteXml.testsuite.failures)
    }

    Return $JunitXml
}
