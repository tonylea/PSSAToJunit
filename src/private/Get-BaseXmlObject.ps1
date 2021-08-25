function Get-BaseXmlObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Int32]
        $TestCount,

        [Parameter(Mandatory)]
        [System.String]
        $TestName
    )

    $Xml = Get-TemplateXml

    $Xml.testsuites.SetAttribute("tests", $TestCount)

    $Xml.testsuites.testsuite.SetAttribute("name", $TestName)
    $Xml.testsuites.testsuite.SetAttribute("tests", $TestCount)
    $Xml.testsuites.testsuite.SetAttribute("hostname", [System.Net.DNS]::GetHostByName($Null).HostName)
    $Xml.testsuites.testsuite.SetAttribute("package", $TestName)

    $OS = [System.Environment]::OSVersion

    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="user"]').SetAttribute("value", [System.Environment]::UserName)
    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="cwd"]').SetAttribute("value", $pwd.Path)
    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="platform"]').SetAttribute("value", $OS.Platform)
    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="clr-version"]').SetAttribute("value", "unknown")
    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="user-domain"]').SetAttribute("value", [System.Environment]::DomainName)
    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="os-version"]').SetAttribute("value", $OS.Version)
    $Xml.testsuites.testsuite.properties.SelectSingleNode('//property[@name="machine-name"]').SetAttribute("value", [System.Net.DNS]::GetHostByName($Null).HostName)

    return $Xml
}
