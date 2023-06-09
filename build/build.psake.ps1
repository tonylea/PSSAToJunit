Properties {
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) { $ProjectRoot = $PSScriptRoot }

    $TestResultsFolder = $ENV:TestResultsFolder
    if (-not $TestResultsFolder) { $TestResultsFolder = Join-Path -Path $ProjectRoot -ChildPath "test-results" }

    $ModulePath = $ENV:BHPSModulePath
    if (-not $ModulePath) { $ModulePath = Join-Path -Path $ProjectRoot -ChildPath src }

    $ModuleName = $ENV:BHProjectName
    if (-not $ModuleName) { $ModuleName = "PSSAToJunit" }

    $ManifestPath = $env:BHPSModuleManifest
    if (-not $ManifestPath) { $ManifestPath = Join-Path -Path $ProjectRoot -ChildPath src -AdditionalChildPath "PSSAToJunti.psd1" }

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

    if (-not $DocsHelpFolder) {
        $DocsHelpFolder = Join-Path -Path $ProjectRoot -ChildPath "docs"
    }

    $Lines
    if (-not $Lines) {
        $Lines = '----------------------------------------------------------------------'
    }
}

Task Init {
    Write-Host "$Lines`n"

    $ErrorActionPreference = "Stop"

    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*

    Write-Host "`n"
}

Task ConfigGit {
    Write-Host "$Lines`n"

    git config --global user.email "bot@dev.azure.com"
    git config --global user.name "Build Agent"
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
            TestSuiteName = "Unit_Tests_$OperatingSystem"
        }
        CodeCoverage = @{
            Enabled      = $true
            OutputFormat = "JaCoCo"
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
            TestSuiteName = "Integration_$OperatingSystem"
        }
        Output     = @{
            Verbosity = "Normal"
        }
    }
    Invoke-Pester -Configuration $Config

    Write-Host "`n"
}

Task UpdateExternalHelpFile -Depends Init {
    Write-Host "`n$Lines`n"

    Update-MarkdownHelpModule -Path $DocsHelpFolder -RefreshModulePage
}

Task UpdateChangeLog -Depends UpdateExternalHelpFile {
    Write-Host "`n$Lines`n"

    npm install
    npm run update-changelog
}

Task BumpVersion -Depends UpdateChangeLog, ConfigGit {
    Write-Host "`n$Lines`n"

    npm install
    npm run version-bump

    $PackageJsonPath = Join-Path -Path $ProjectRoot -ChildPath "package.json"
    git add $PackageJsonPath

    $PackageJson = Get-Content -Path $PackageJsonPath | ConvertFrom-Json
    $Version = $PackageJson.version
    Update-ModuleManifest -Path $ManifestPath -ModuleVersion $Version
    git add $ManifestPath

    $PackageLockJsonPath = Join-Path -Path $ProjectRoot -ChildPath "package-lock.json"
    git add $PackageLockJsonPath

    $ChangelogPath = Join-Path -Path $ProjectRoot -ChildPath "CHANGELOG.md"
    git add $ChangelogPath


    $GitMessage = "chore(release): $Version [skip ci]"

    git commit -m $GitMessage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "An error occurred while running the 'git commit -m $GitMessage' command."
    }

    git tag -a v$Version -m $GitMessage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "An error occurred while running the 'git tag -a v$Version -m $GitMessage' command."
    }
}

Task CreateNuspecFile -depends Init {
    Write-Host "`n$Lines`n"

    $StagingFolder = Join-Path -Path $ProjectRoot -ChildPath "staging"
    New-Item -Path $StagingFolder -ItemType 'Directory' -Force

    $OutputPath = Join-Path -Path $StagingFolder -ChildPath "$ModuleName.nuspec"

    $ManifestHash = Import-PowerShellDataFile -Path $ManifestPath
    $Author = $ManifestHash.Author
    $Description = $ManifestHash.Description
    $Version = $ManifestHash.ModuleVersion

    $NuSpec = [System.Xml.XmlDocument]@"
<?xml version="1.0"?>
<package>
    <metadata>
        <id>$ModuleName</id>
        <version>$Version</version>
        <authors>$Author</authors>
        <description>$Description</description>
    </metadata>
</package>
"@

    $NuSpec.Save($OutputPath)
}

Task CreateExternalHelp -Depends CreateNuspecFile {
    Write-Host "`n$Lines`n"

    $StagingFolder = Join-Path -Path $ProjectRoot -ChildPath "staging"
    New-Item -Path $StagingFolder -ItemType 'Directory' -Force

    $ExternalHelpFolder = Join-Path -Path $StagingFolder -ChildPath "en-GB"
    New-ExternalHelp -Path $DocsHelpFolder -OutputPath $ExternalHelpFolder
}

Task BuildPackage -Depends CreateExternalHelp {
    Write-Host "`n$Lines`n"

    $StagingFolder = Join-Path -Path $ProjectRoot -ChildPath "staging"
    New-Item -Path $StagingFolder -ItemType 'Directory' -Force

    $ClassesFolder = Join-Path -Path $ModulePath -ChildPath "classes" -AdditionalChildPath "*.ps1"
    $Classes = @( Get-ChildItem -Path $ClassesFolder -ErrorAction SilentlyContinue )

    $PrivateFolder = Join-Path -Path $ModulePath -ChildPath "private" -AdditionalChildPath "*.ps1"
    $Private = @( Get-ChildItem -Path $PrivateFolder -ErrorAction SilentlyContinue )

    $PublicFolder = Join-Path -Path $ModulePath -ChildPath "public" -AdditionalChildPath "*.ps1"
    $Public = @( Get-ChildItem -Path $PublicFolder -ErrorAction SilentlyContinue )

    $CombinedFunctionsPath = Join-Path -Path $StagingFolder -ChildPath "$ModuleName.psm1"
    foreach ($File in @($Public + $Private + $Classes)) {
        $File | Get-Content | Add-Content -Path $CombinedFunctionsPath
    }

    Copy-Item -Path $ManifestPath -Destination $StagingFolder
}
