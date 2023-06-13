Properties {
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) { $ProjectRoot = $PSScriptRoot }

    $ManifestPath = $env:BHPSModuleManifest
    if (-not $ManifestPath) { $ManifestPath = Join-Path -Path $ProjectRoot -ChildPath src -AdditionalChildPath "PSSAToJunti.psd1" }

    $DocsHelpFolder = $env:DOCS_FOLDER
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

Task UpdateMarkdownHelpFiles -Depends Init {
    Write-Host "`n$Lines`n"

    Update-MarkdownHelpModule -Path $DocsHelpFolder -RefreshModulePage
}
