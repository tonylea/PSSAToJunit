[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [System.IO.FileInfo]
    $DependencyConfigPath,

    [Parameter()]
    [Switch]
    $ResolveDependency,

    [Parameter()]
    [Switch]
    $ImportProjectModule,

    [Parameter(Mandatory)]
    [System.String]
    $Task,

    [Parameter()]
    [System.String]
    $OperatingSystem
)

if ($ResolveDependency.IsPresent) {
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
}
else {
    Write-Host "`nSKIPPED TASK: Install dependencies" -ForegroundColor Blue
}

# Init BuildHelpers
Write-Host "`nSTARTED TASK: Set environmental variables" -ForegroundColor Blue
Set-BuildEnvironment -Force

# Load Ansi Colours Write-Host
Write-Host "`nSTARTED TASK: Overload Write-Host with Ansi colours" -ForegroundColor Blue
$AnsiWriteHostOverloadPath = Join-Path -Path $ENV:BHProjectPath -ChildPath "utils" -AdditionalChildPath "AnsiWriteHostOverload.ps1"
. $AnsiWriteHostOverloadPath

if ($ImportProjectModule.IsPresent) {
    Write-Host "`nSTARTED TASK: Importing project module into scope" -ForegroundColor Blue
    Import-Module -Name $ENV:BHPSModuleManifest -Force
}

# Execute psake tasks
Write-Host -AnsiColors "`nSTARTED TASK: $Task" -ForegroundColor Green

$InvokePsakeArgs = @{
    buildFile = Join-Path -Path $ENV:BHProjectPath -ChildPath "build" -AdditionalChildPath "build.psake.ps1"
    nologo    = $true
    taskList  = $Task
}
Invoke-Psake @InvokePsakeArgs

exit ( [int](-not $psake.build_success) )
