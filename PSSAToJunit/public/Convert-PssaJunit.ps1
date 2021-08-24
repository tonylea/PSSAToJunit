function Convert-PssaJunit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $TestName,

        [Parameter(Mandatory)]
        [AllowNull()]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
        $Result,

        [Parameter(Mandatory)]
        [ValidateSet("Information", "Warning", "Error")]
        [System.String[]]
        $Severity,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]
        $OutPath
    )

    begin {
        $ScriptAnalyzerRules = Get-ScriptAnalyzerRule -Severity $Severity
    }

    process {
        if (!$Result) {
            $JunitTests = Get-PassingTestsReport -IncludeRule $ScriptAnalyzerRules -TestName $TestName
        } else {
            $JunitTests = Get-FailingTestsReport -IncludeRule $ScriptAnalyzerRules -TestName $TestName -Result $Result
        }
    }

    end {
        $JunitTests.Save($OutPath)
    }
}
