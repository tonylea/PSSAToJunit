function Get-TestCaseXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter()]
        [String]
        $TestCaseName,

        [Parameter()]
        [String]
        $Severity,

        [Parameter()]
        [String]
        $TestCaseMessage,

        [Parameter()]
        [String]
        $TestCasePath,

        [Parameter()]
        [Int]
        $Line
    )

    return [System.Xml.XmlDocument]@"
<testcase id="" name="$TestCaseName" time="0.001">
    <failure message="$TestCasePath">
$($Severity.ToUpper()): $TestCaseMessage
File: $TestCasePath
Line: $Line
    </failure>
</testcase>
"@
}

