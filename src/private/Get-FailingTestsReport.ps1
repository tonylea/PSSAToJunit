function Get-FailingTestsReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $TestName,

        [Parameter(Mandatory)]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
        $Result,

        [Parameter(Mandatory)]
        [System.Array]
        $IncludeRule
    )

    $TestCount = 0
    $Xml = Get-BaseXmlObject -TestCount 0 -TestName $TestName

    foreach ($Rule in $IncludeRule) {
        $RuleName = $Rule.RuleName
        $FoundError = $false
        foreach ($R in $Result) {
            if ($Rule.RuleName -like $R.RuleName) {
                $FoundError = $true

                $TestCount ++
                $Xml.testsuites.SetAttribute("tests", $TestCount)
                $Xml.testsuites.testsuite.SetAttribute("tests", $TestCount)

                $TestCase = $Xml.CreateElement("testcase")

                $TestCase.SetAttribute("name", $RuleName)
                $TestCase.SetAttribute("status", "Failed")
                $TestCase.SetAttribute("classname", $TestName)
                $TestCase.SetAttribute("assertions", "0")
                $TestCase.SetAttribute("time", "0")

                $Failure = $Xml.CreateElement("failure")
                $Failure.SetAttribute("message", $Rule.CommonName)
                $Message = $R.Message
                $ScriptName = $R.ScriptName
                $Line = $R.Line
                $Failure.InnerText = "$($Message)&#xA$($ScriptName):$Line"
                $TestCase.AppendChild($Failure) | Out-Null

                $Xml.testsuites.testsuite.AppendChild($TestCase) | Out-Null
            }
        }

        if (!$FoundError) {
            $TestCount ++
            $Xml.testsuites.SetAttribute("tests", $TestCount)
            $Xml.testsuites.testsuite.SetAttribute("tests", $TestCount)

            $TestCase = $Xml.CreateElement("testcase")

            $TestCase.SetAttribute("name", $RuleName)
            $TestCase.SetAttribute("status", "Passed")
            $TestCase.SetAttribute("classname", $TestName)
            $TestCase.SetAttribute("assertions", "0")
            $TestCase.SetAttribute("time", "0")

            $Xml.testsuites.testsuite.AppendChild($TestCase) | Out-Null
        }
    }

    return $Xml
}
