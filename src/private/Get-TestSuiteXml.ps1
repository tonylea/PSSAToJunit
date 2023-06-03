function Get-TestSuiteXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter(Mandatory)]
        [String]
        $TestSuiteName
    )

    return [System.Xml.XmlDocument]@"
<testsuite name="$TestSuiteName" tests="0" errors="0" failures="0" hostname="" id="0" skipped="0" disabled="0" package="" time="0">
</testsuite>
"@
}

