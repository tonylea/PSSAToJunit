Properties {
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) { $ProjectRoot = $PSScriptRoot }

    $TestResultsFolder = $ENV:TEST_RESULTS_PATH
    if (-not $TestResultsFolder) { $TestResultsFolder = Join-Path -Path $ProjectRoot -ChildPath "test-results" }

    $ModulePath = $env:SOURCE_BRANCH_NAME
    if (-not $ModulePath) { $ModulePath = Join-Path -Path $ProjectRoot -ChildPath src }

    $ModuleName = $env:BHProjectName
    if (-not $ModuleName) { $ModuleName = "PSSAToJunit" }

    $ManifestPath = $env:BHPSModuleManifest
    if (-not $ManifestPath) { $ManifestPath = Join-Path -Path $ProjectRoot -ChildPath src -AdditionalChildPath "PSSAToJunti.psd1" }

    $OperatingSystem = $env:OPERATING_SYSTEM
    if (-not $OperatingSystem) {
        if ($IsLinux) { $OperatingSystem = "Linux" }
        elseif ($IsMacOS) { $OperatingSystem = "macOS" }
        elseif ($IsWindows) { $OperatingSystem = "Windows" }
    }

    $UnitTestsFolder = $env:UNIT_TESTS_FOLDER
    If (-not $UnitTestsFolder) { $UnitTestsFolder = Join-Path -Path $ProjectRoot -ChildPath "tests" -AdditionalChildPath "unit-tests" }

    $IntegrationTestsFolder = $env:INTEGRATION_TESTS_FOLDER
    if (-not $IntegrationTestsFolder) { $IntegrationTestsFolder = Join-Path -Path $ProjectRoot -ChildPath "tests" -AdditionalChildPath "integration-tests" }

    $DocsHelpFolder = $env:DOCS_FOLDER
    if (-not $DocsHelpFolder) { $DocsHelpFolder = Join-Path -Path $ProjectRoot -ChildPath "docs" }

    $Lines
    if (-not $Lines) { $Lines = '----------------------------------------------------------------------' }

    $SourceBranchName = $env:SOURCE_BRANCH_NAME
    if (-not $SourceBranchName) { $SourceBranchName = "main" }

    $StagingFolder = $env:STAGING_FOLDER
    if (-not $StagingFolder) { $StagingFolder = Join-Path -Path $ProjectRoot -ChildPath "PSSAToJunit" }
}

Task Init {
    Write-Host "$Lines`n"

    $ErrorActionPreference = "Stop"

    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*

    Write-Host "`n"
}

Task ImportDependantModules -depends Init {
    Write-Host "`n$Lines`n"

    $ModuleDependencies = (Import-PowerShellDataFile -Path $ManifestPath).RequiredModules
    foreach ($Module in $ModuleDependencies) {
        Import-Module -Name $Module -Force
    }

    Write-Host "`n"
}

Task UnitTests -depends Init, ImportDependantModules {
    Write-Host "`n$Lines`n"

    Import-Module -Name Pester -Force

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

Task IntegrationTests -depends Init, ImportDependantModules {
    Write-Host "`n$Lines`n"

    Import-Module -Name Pester -Force

    $Config = [PesterConfiguration]@{
        Run        = @{
            Path     = $IntegrationTestsFolder
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

Task UpdateMarkdownHelpFiles -depends Init {
    Write-Host "`n$Lines`n"

    Update-MarkdownHelpModule -Path $DocsHelpFolder -RefreshModulePage -AlphabeticParamsOrder -Force -UpdateInputOutput
}

Task UpdateManifest -depends Init {
    Write-Host "`n$Lines`n"

    $PackageJsonPath = Join-Path -Path $ProjectRoot -ChildPath "package.json"
    $PackageJson = Get-Content -Path $PackageJsonPath | ConvertFrom-Json

    $UpdateModuleManifestArgs = @{
        Path = $ManifestPath
    }
    if ($PackageJson.manifestProperties.author) {
        $UpdateModuleManifestArgs.Author = $PackageJson.manifestProperties.author
    }
    if ($PackageJson.manifestProperties.companyName) {
        $UpdateModuleManifestArgs.CompanyName = $PackageJson.manifestProperties.companyName
    }
    if ($PackageJson.manifestProperties.compatiblePSEditions) {
        $UpdateModuleManifestArgs.CompatiblePSEditions = $PackageJson.manifestProperties.compatiblePSEditions
    }
    if ($PackageJson.manifestProperties.copyright) {
        $UpdateModuleManifestArgs.Copyright = $PackageJson.manifestProperties.copyright
    }
    if ($PackageJson.description) {
        $UpdateModuleManifestArgs.Description = $PackageJson.description
    }
    if ($PackageJson.manifestProperties.requiredModules) {
        $UpdateModuleManifestArgs.ExternalModuleDependencies = $PackageJson.manifestProperties.requiredModules
    }
    if ($PackageJson.manifestProperties.guid) {
        $UpdateModuleManifestArgs.Guid = $PackageJson.manifestProperties.guid
    }
    if ($PackageJson.manifestProperties.licenseUri) {
        $UpdateModuleManifestArgs.LicenseUri = $PackageJson.manifestProperties.licenseUri
    }
    if ($PackageJson.manifestProperties.powerShellVersion) {
        $UpdateModuleManifestArgs.PowerShellVersion = $PackageJson.manifestProperties.powerShellVersion
    }
    if ($PackageJson.manifestProperties.projectUri) {
        $UpdateModuleManifestArgs.ProjectUri = $PackageJson.manifestProperties.projectUri
    }
    if ($PackageJson.manifestProperties.requiredModules) {
        $UpdateModuleManifestArgs.RequiredModules = $PackageJson.manifestProperties.requiredModules
    }
    if ($PackageJson.manifestProperties.tags) {
        $UpdateModuleManifestArgs.Tags = $PackageJson.manifestProperties.tags
    }

    Update-ModuleManifest @UpdateModuleManifestArgs
}

Task BumpVersion -depends Init {
    Write-Host "`n$Lines`n"

    npm install
    npm run version-bump

    $PackageJsonPath = Join-Path -Path $ProjectRoot -ChildPath "package.json"
    $PackageJson = Get-Content -Path $PackageJsonPath | ConvertFrom-Json
    $Version = $PackageJson.version
    Write-Host "Version: $Version"

    Update-ModuleManifest -Path $ManifestPath -ModuleVersion $Version
}

Task GitCommit -depends Init {
    git config --global user.email "bot@dev.azure.com"
    git config --global user.name "Build Agent"

    git add .

    $PackageJsonPath = Join-Path -Path $ProjectRoot -ChildPath "package.json"
    $PackageJson = Get-Content -Path $PackageJsonPath | ConvertFrom-Json
    $Version = $PackageJson.version

    git commit -m "chore(release): $Version [skip ci]"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "An error occurred while running the 'git commit -m "chore(release): $Version [skip ci]"' command."
    }

    git tag -a v$Version -m $GitMessage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "An error occurred while running the 'git tag -a v$Version -m $GitMessage' command."
    }

    git push --follow-tags origin HEAD:$SourceBranchName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "An error occurred while running the  the 'git push --follow-tags origin HEAD:$SourceBranchName' command."
    }
}

Task CreateStagingFolder -depends Init {
    Write-Host "`n$Lines`n"

    New-Item -Path $StagingFolder -ItemType 'Directory' -Force
}

Task CreateNuspecFile -depends CreateStagingFolder {
    Write-Host "`n$Lines`n"

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

Task CreateExternalHelp -depends CreateStagingFolder {
    Write-Host "`n$Lines`n"

    $ExternalHelpFolder = Join-Path -Path $StagingFolder -ChildPath "en-GB"
    New-ExternalHelp -Path $DocsHelpFolder -OutputPath $ExternalHelpFolder
}

Task MinimiseScriptFiles -depends CreateStagingFolder {
    Write-Host "`n$Lines`n"

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
