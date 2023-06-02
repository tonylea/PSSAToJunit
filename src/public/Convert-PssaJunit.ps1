function Convert-PssaJunit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $TestName,

        [Parameter(Mandatory)]
        [AllowNull()]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
        $PSScriptAnalyzerResult,

        [Parameter(Mandatory)]
        [ValidateSet("Information", "Warning", "Error")]
        [System.String[]]
        $Severity,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]
        $OutputFolder
    )

    $ScriptAnalyzerRules = Get-ScriptAnalyzerRule -Severity $Severity

    if (!$PSScriptAnalyzerResult) {
        $JunitTests = Get-PassingTestsReport -IncludeRule $ScriptAnalyzerRules -TestName $TestName
    }
    else {
        $JunitTests = Get-FailingTestsReport -IncludeRule $ScriptAnalyzerRules -TestName $TestName -Result $PSScriptAnalyzerResult
    }

    Write-Host "Linting error"

    $JunitTests.Save($OutputFolder)
}
