function Get-TestSuite {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter()]
        [ValidateSet("Information", "Warning", "Error")]
        [System.String[]]
        $Severity
    )

    try {
        $ScriptAnalyzerRules = Get-ScriptAnalyzerRule -Severity $Severity
    }
    catch {
        Write-Error "Failed to retrieve ScriptAnalyzer rules: $_"
        return
    }

    $TestSuites = @{}
    foreach ($Rule in $ScriptAnalyzerRules) {
        $TestSuites[$Rule.RuleName] = @{
            Name        = $Rule.RuleName
            Severity    = $Rule.Severity
            Description = $Rule.Description
            FailedTests = @()
        }
    }

    return $TestSuites
}
