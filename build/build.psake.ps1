# PSake makes variables declared here available in other scriptblocks
Properties {
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) { $ProjectRoot = $PSScriptRoot }

    $TestResultsFolder = $ENV:TestResultsFolder
    if (-not $TestResultsFolder) { $TestResultsFolder = Join-Path -Path $ProjectRoot -ChildPath "test-results" }

    $ModulePath = $ENV:BHPSModulePath
    if (-not $ModulePath) { $ModulePath = Join-Path -Path $ProjectRoot -ChildPath src }

    $OperatingSystem
    if (-not $OperatingSystem) {
        if ($IsLinux) {
            $OperatingSystem = "Linux"
        }
        elseif ($IsMacOS) {
            $OperatingSystem = "macOS"
        }
        elseif ($IsWindows) {
            $OperatingSystem = "Windows"
        }
    }

    If (-not $UnitTestsFolder) {
        $UnitTestsFolder = Join-Path -Path $ProjectRoot -ChildPath "tests" -AdditionalChildPath "unit-tests"
    }

    if (-not $IntegrationTestsFolder) {
        $IntegrationTestsFolder = Join-Path -Path $ProjectRoot -ChildPath "tests" -AdditionalChildPath "integration-tests"
    }

    if (-not $ExternalHelpFolder) {
        $ExternalHelpFolder = Join-Path -Path $ProjectRoot -ChildPath "docs"
    }

    $Lines
    if (-not $Lines) {
        $Lines = '----------------------------------------------------------------------'
    }
}

Task Init {
    Write-Host "$Lines`n"

    Set-ErrorAction -ErrorAction Stop

    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*

    Write-Host "`n"
}

Task UnitTests -Depends Init {
    Write-Host "`n$Lines`n"

    $Config = [PesterConfiguration]@{
        Run          = @{
            Path     = $UnitTestsFolder
            PassThru = $true
        }
        TestResult   = @{
            Enabled       = $true
            OutputFormat  = "JUnitXml"
            OutputPath    = Join-Path -Path $TestResultsFolder -ChildPath "$OperatingSystem-unit-tests.xml"
            TestSuiteName = "Unit_Tests_$OperatingSystem" # default
        }
        CodeCoverage = @{
            Enabled      = $true
            OutputFormat = "JaCoCo" # default
            OutputPath   = Join-Path -Path $TestResultsFolder -ChildPath "$OperatingSystem-code-coverage.xml"
            Path         = @(
                (Join-Path -Path $ModulePath -ChildPath classes)
                (Join-Path -Path $ModulePath -ChildPath private)
                (Join-Path -Path $ModulePath -ChildPath public)
            )
        }
        Output       = @{
            Verbosity = "Normal"
        }
    }
    Invoke-Pester -Configuration $Config

    Write-Host "`n"
}

Task IntegrationTests -Depends Init {
    Write-Host "`n$Lines`n"

    $Config = [PesterConfiguration]@{
        Run        = @{
            Path     = $UnitTestsFolder
            PassThru = $true
        }
        TestResult = @{
            Enabled       = $true
            OutputFormat  = "JUnitXml"
            OutputPath    = Join-Path -Path $TestResultsFolder -ChildPath "$OperatingSystem-integration-tests.xml"
            TestSuiteName = "Integration_$OperatingSystem" # default
        }
        Output     = @{
            Verbosity = "Normal"
        }
    }
    Invoke-Pester -Configuration $Config

    Write-Host "`n"
}

Task UpdateExternalHelpFile -Depends Init {
    $lines

    Update-MarkdownHelpModule -Path $ExternalHelpFolder -RefreshModulePage
}

Task GetVersion -depends Init {
    $lines

    npm install
    npm run release -- --skip

}
