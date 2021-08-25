function Get-PassingTestsReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Array]
        $IncludeRule,

        [Parameter(Mandatory)]
        [string]
        $TestName
    )

    $Xml = Get-BaseXmlObject -TestCount $IncludeRule.Count -TestName $TestName

    foreach ($Rule in $IncludeRule) {
        $TestCase = $Xml.CreateElement("testcase")

        $TestCase.SetAttribute("name", $Rule.CommonName)
        $TestCase.SetAttribute("status", "Passed")
        $TestCase.SetAttribute("classname", $TestName)
        $TestCase.SetAttribute("assertions", "0")
        $TestCase.SetAttribute("time", "0")

        $Xml.testsuites.testsuite.AppendChild($TestCase)
    }

    return $Xml
}
