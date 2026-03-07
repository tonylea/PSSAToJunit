<#
.SYNOPSIS
    Runs lint and tests locally, mirroring the GitHub Actions CI pipeline.

.DESCRIPTION
    Runs the same checks as CI: markdownlint, cspell, PSScriptAnalyzer, and Pester tests.
    Requires PowerShell 7+, Node.js, and npm.

.PARAMETER Stage
    Which stage to run. Valid values: All, Lint, Test, Unit, Integration.
    Defaults to All.

.EXAMPLE
    ./scripts/Invoke-LocalCI.ps1

.EXAMPLE
    ./scripts/Invoke-LocalCI.ps1 -Stage Lint

.EXAMPLE
    ./scripts/Invoke-LocalCI.ps1 -Stage Unit
#>
[CmdletBinding()]
param (
    [ValidateSet('All', 'Lint', 'Test', 'Unit', 'Integration')]
    [string]$Stage = 'All'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot | Split-Path -Parent

function Write-Header {
    param([string]$Title)
    Write-Host "`n=== $Title ===" -ForegroundColor Cyan
}

function Invoke-LintStage {
    Write-Header 'Lint'

    Push-Location $RepoRoot
    try {
        if (-not (Test-Path './node_modules')) {
            Write-Host 'Installing Node.js dependencies...'
            npm ci
        }

        Write-Host 'Running markdownlint...'
        npx markdownlint-cli2
        if ($LASTEXITCODE -ne 0) { throw 'markdownlint failed' }

        Write-Host 'Running cspell...'
        npx cspell lint '**'
        if ($LASTEXITCODE -ne 0) { throw 'cspell failed' }
    }
    finally {
        Pop-Location
    }

    if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable)) {
        Write-Host 'Installing PSScriptAnalyzer...'
        Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
    }

    Write-Host 'Running PSScriptAnalyzer...'
    $Results = Invoke-ScriptAnalyzer -Path "$RepoRoot/src" -Recurse -Severity Error, Warning
    if ($Results) {
        $Results | Format-Table -AutoSize
        throw 'PSScriptAnalyzer found issues'
    }

    Write-Host 'Lint passed.' -ForegroundColor Green
}

function Invoke-TestStage {
    param(
        [bool]$RunUnit = $true,
        [bool]$RunIntegration = $true
    )

    Write-Header 'Test'

    $RequiredModules = @(
        @{ Name = 'Pester'; MinimumVersion = '5.0.0'; SkipPublisherCheck = $true }
        @{ Name = 'PSScriptAnalyzer' }
        @{ Name = 'BuildHelpers' }
    )
    foreach ($Module in $RequiredModules) {
        if (-not (Get-Module -Name $Module.Name -ListAvailable)) {
            Write-Host "Installing $($Module.Name)..."
            $Params = @{ Name = $Module.Name; Force = $true; Scope = 'CurrentUser' }
            if ($Module.MinimumVersion) { $Params.MinimumVersion = $Module.MinimumVersion }
            if ($Module.SkipPublisherCheck) { $Params.SkipPublisherCheck = $true }
            Install-Module @Params
        }
    }

    if ($RunUnit) {
        Write-Host 'Running unit tests...'
        $Config = New-PesterConfiguration
        $Config.Run.Path = "$RepoRoot/tests/unit-tests"
        $Config.Run.Exit = $true
        $Config.TestResult.Enabled = $true
        $Config.TestResult.OutputPath = "$RepoRoot/test-results-unit.xml"
        $Config.CodeCoverage.Enabled = $true
        $Config.CodeCoverage.OutputFormat = 'JaCoCo'
        $Config.CodeCoverage.OutputPath = "$RepoRoot/code-coverage.xml"
        $Config.CodeCoverage.Path = @("$RepoRoot/src/classes", "$RepoRoot/src/private", "$RepoRoot/src/public")
        Invoke-Pester -Configuration $Config
    }

    if ($RunIntegration) {
        Write-Host 'Running integration tests...'
        $Config = New-PesterConfiguration
        $Config.Run.Path = "$RepoRoot/tests/integration-tests"
        $Config.Run.Exit = $true
        $Config.TestResult.Enabled = $true
        $Config.TestResult.OutputPath = "$RepoRoot/test-results-integration.xml"
        Invoke-Pester -Configuration $Config
    }
}

switch ($Stage) {
    'All' {
        Invoke-LintStage
        Invoke-TestStage -RunUnit $true -RunIntegration $true
    }
    'Lint' { Invoke-LintStage }
    'Test' { Invoke-TestStage -RunUnit $true -RunIntegration $true }
    'Unit' { Invoke-TestStage -RunUnit $true -RunIntegration $false }
    'Integration' { Invoke-TestStage -RunUnit $false -RunIntegration $true }
}
