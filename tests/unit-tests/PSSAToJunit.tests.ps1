Describe "$($ENV:BHProjectName) Manifest" {
    BeforeAll {
        $BuildVarModulePath = Join-Path -Path ($PSScriptRoot -replace "tests.+") -ChildPath "helpers" -AdditionalChildPath "Set-TestHelperEnvVars.psm1"
        Import-Module -Name $BuildVarModulePath -Force
        Set-TestHelperEnvVars -Path $PSScriptRoot

        $ManifestPath = $ENV:BHPSModuleManifest
        $ModuleName = $ENV:BHProjectName
        $ModulePath = $ENV:BHModulePath

        $ManifestHash = Import-PowerShellDataFile -Path $ManifestPath
    }

    if (!$IsLinux) {
        It "Has a valid manifest" {
            {
                $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
            } | Should -Not -Throw
        }
    }

    It "Has a valid root module" {
        $ManifestHash.RootModule | Should -Be "$ModuleName.psm1"
    }

    It "has a valid Description" {
        $ManifestHash.Description | Should -Not -BeNullOrEmpty
    }

    It "has a valid guid" {
        $ManifestHash.Guid | Should -Be "fa5b675c-f181-4571-bda8-2b24da71d04b"
    }

    It "has a valid copyright" {
        $ManifestHash.CopyRight | Should -Not -BeNullOrEmpty
    }

    It "exports all public functions" {
        $FunctionFiles = Get-ChildItem "$ModulePath/public" -Filter *.ps1 | Select-Object -ExpandProperty BaseName
        $ExportedFunctions = $ManifestHash.FunctionsToExport
        if ($FunctionFiles) {
            $ModulePath = (Get-Item -Path $ManifestPath).DirectoryName
            $FunctionNames = $FunctionFiles
            foreach ($Function in $FunctionNames) {
                $ExportedFunctions -contains $Function | Should -Be $true
            }
        }
        else {
            $ExportedFunctions | Should -BeNullOrEmpty
        }
    }

    It "Version number that matches Semantic Versioning Specification" {
        $VersionNumber = $ManifestHash.ModuleVersion
        $VersionNumber -match "^\d+.\d+.\d+$" | Should -Be $true
    }
}
