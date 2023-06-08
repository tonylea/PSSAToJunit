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
            $FilePath = Join-Path -Path $PWD -ChildPath "PSScriptAnalyzerResults.xml"
        }
    }

    process {
        try {
            $InputXml.Save($FilePath)
        }
        catch {
            Write-Error "Error saving file: $_"
        }
    }

    end {
        if (Test-Path $FilePath) {
            Write-Debug "File created at: $FilePath"
        }
        else {
            Write-Error "File not created"
        }
    }
}
