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
        if (!$TestName) {
            $TestName = "PSScriptAnalyzer"
        }
        if (!$Severity) {
            $Severity = @("Warning", "Error")
        }

        $TestSuites = Get-TestSuite -Severity $Severity
    }

    process {
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

    end {

        [System.Xml.XmlDocument]$JunitXml = ConvertTo-JunitXml -TestSuites $TestSuites -TestName $TestName

        Return $JunitXml
    }
}
