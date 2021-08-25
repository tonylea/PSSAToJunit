function Get-TemplateXml {
    [CmdletBinding()]
    param ()

    return [System.Xml.XmlDocument]@"
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
}
