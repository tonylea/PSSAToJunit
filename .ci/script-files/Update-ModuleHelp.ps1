[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath,

    [Parameter(Mandatory = $true)]
    [string]$DocsPath,

    [Parameter(Mandatory = $true)]
    [string]$ModuleName
)

Write-Output "Importing module from '$ManifestPath'"
Import-Module -Name $ManifestPath -Force -Scope Local -ErrorAction Stop -Verbose

Write-Output "Confirming exported functions for module '$ModuleName'"
$ExportedFunctions = (Get-Module -Name $ModuleName).ExportedCommands.Values.Name
if (!$ExportedFunctions) {
    Write-Output "No exported functions found for module '$ModuleName'"
    throw "No exported functions found for module '$ModuleName'"
}
foreach ($ExportedFunction in $ExportedFunctions) {
    Write-Output "  - Function name: $ExportedFunction"
}

Write-Output "Updating external help file for module '$ModuleName'"
Update-MarkdownHelpModule -Path $DocsFolder -RefreshModulePage
