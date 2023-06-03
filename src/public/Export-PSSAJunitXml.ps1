function Export-PSSAJunitXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter(Mandatory, ValueFromPipeline = $true)]
        [System.Xml.XmlDocument]
        $InputXml,

        [Parameter()]
        [System.IO.FileInfo]
        $FilePath
    )

    begin {
        if (!$FilePath) {
            $FilePath = Join-Path -Path $PWD -ChildPath "PSScriptAnalyzer.xml"
        }
    }

    process {
        $InputXml.Save($FilePath)
    }

    end {
        Write-Debug "File created at: $FilePath"
    }
}
