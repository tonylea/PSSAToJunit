function Get-ParentXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter(Mandatory)]
        [String]
        $TestRunName
    )

    return [System.Xml.XmlDocument]@"
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="$TestRunName" tests="0" errors="0" failures="0" disabled="0" time="0">
</testsuites>
"@
}
