function ConvertTo-PSSAJunitXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter( Mandatory, ValueFromPipeline = $true )]
        [AllowNull()]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
        $PSScriptAnalyzerResult,

        [Parameter()]
        [String]
        $TestName,

        [Parameter()]
        [ValidateSet("Information", "Warning", "Error")]
        [System.String[]]
        $Severity
    )

    begin {
        try {
            if (!$TestName) {
                $TestName = "PSScriptAnalyzer"
            }
            if (!$Severity) {
                $Severity = @("Warning", "Error")
            }

            $TestSuites = Get-TestSuite -Severity $Severity
        }
        catch {
            Write-Error "Error occurred while initializing variables: $_"
            return
        }
    }

    process {
        try {
            if ($PSScriptAnalyzerResult) {
                foreach ($Result in $PSScriptAnalyzerResult) {
                    if ($Result.RuleName -in $TestSuites.Keys) {
                        $TestSuites[$Result.RuleName].FailedTests += @{
                            ScriptName = $Result.ScriptName
                            Message    = $Result.Message
                            Line       = $Result.Line
                            ScriptPath = $Result.ScriptPath
                        }
                    }
                }
            }
        }
        catch {
            Write-Error "Error occurred while processing results: $_"
            return
        }
    }

    end {
        try {
            [System.Xml.XmlDocument]$JunitXml = ConvertTo-JunitXml -TestSuites $TestSuites -TestName $TestName
            Return $JunitXml
        }
        catch {
            Write-Error "Error occurred while converting to JUnit XML: $_"
            return
        }
    }
}
