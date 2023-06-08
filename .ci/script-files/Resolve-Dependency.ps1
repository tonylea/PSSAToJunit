[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$DependencyConfigPath
)

Write-Host "`nSTARTED TASK: Install dependencies" -ForegroundColor Blue

if (-not ((Get-PSRepository PSGallery).InstallationPolicy -like "Trusted")) {
    Write-Host "`n  Set PSGallery as trusted source"
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

Get-PackageProvider -Name "NuGet" -ForceBootstrap | Out-Null

# Install PSDepend module if it is not already installed
if (-not (Get-Module -Name "PSDepend" -ListAvailable)) {
    Write-Host "`n  Installing PSDepend"
    Install-Module -Name "PSDepend" -Scope "CurrentUser" -Force
}
else {
    Write-Host "`n  PSDepend already installed"
}

# Install build dependencies
Write-Host "`n  Resolving module dependencies from $DependencyConfigPath"
Import-Module -Name "PSDepend"
$InvokePSDependArgs = @{
    Path    = $DependencyConfigPath
    Import  = $true
    Confirm = $false
    Install = $true
}
Invoke-PSDepend @InvokePSDependArgs
