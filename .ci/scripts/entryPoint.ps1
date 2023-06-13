[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet(
        "InstallDependencies",
        "UnitTests",
        "IntegrationTests",
        "UpdateMarkdownHelpFiles",
        "UpdateManifest",
        "BumpVersion",
        "GitCommit",
        "CreateNuspecFile",
        "CreateExternalHelp",
        "MinimiseScriptFiles"
    )]
    [System.String]
    $Task,

    [System.IO.FileInfo]
    $DependencyConfigPath,

    [System.IO.FileInfo]
    $PSakeFilepath
)

Write-Host "`nSTARTED TASK: $Task" -ForegroundColor Blue

if ($Task -eq "InstallDependencies") {
    if (-not $DependencyConfigPath) {
        Write-Error "DependencyConfigPath is required when Task is InstallDependencies"
        exit 1
    }
    elseif (-not $DependencyConfigPath.Exists) {
        Write-Error "DependencyConfigPath does not exist: $DependencyConfigPath"
        exit 1
    }

    if (-not ((Get-PSRepository PSGallery).InstallationPolicy -like "Trusted")) {
        Write-Host "`n  Set PSGallery as trusted source"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    Get-PackageProvider -Name "NuGet" -ForceBootstrap | Out-Null

    if (-not (Get-Module -Name "PSDepend" -ListAvailable)) {
        Write-Host "`n  Installing PSDepend"
        Install-Module -Name "PSDepend" -Scope "CurrentUser" -Force
    }
    else {
        Write-Host "`n  PSDepend already installed"
    }

    Write-Host "`n  Resolving module dependencies from: $DependencyConfigPath"
    Import-Module -Name "PSDepend"
    $InvokePSDependArgs = @{
        Path    = $DependencyConfigPath
        Import  = $true
        Confirm = $false
        Install = $true
    }
    Invoke-PSDepend @InvokePSDependArgs
}
else {
    if (-not $PSakeFilepath) {
        Write-Error "PSakeFilepath is required when Task is not InstallDependencies"
        exit 1
    }
    elseif (-not $PSakeFilepath.Exists) {
        Write-Error "PSakeFile does not exist: $PSakeFilepath"
        exit 1
    }

    Write-Host "`nSTARTED TASK: Set environmental variables" -ForegroundColor Blue
    Set-BuildEnvironment -Force

    if ($Task -like "UpdateMarkdownHelpFiles") {
        Write-Host "`nSTARTED TASK: Importing project module into scope" -ForegroundColor Blue
        Import-Module -Name $ENV:BHPSModuleManifest -Force -Verbose
        Write-Host "Imported Functions:`n"
        (Get-Module -Name pssatojunit).exportedcommands.Values.Name
    }

    Write-Host "`nSTARTED TASK: $Task" -ForegroundColor Green

    $InvokePsakeArgs = @{
        buildFile = $PSakeFilepath
        nologo    = $true
        taskList  = $Task
    }
    Invoke-Psake @InvokePsakeArgs

    exit ( [int](-not $psake.build_success) )
}
