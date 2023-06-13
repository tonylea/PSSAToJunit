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

# Init BuildHelpers
Write-Host "`nSTARTED TASK: Set environmental variables" -ForegroundColor Blue
Set-BuildEnvironment -Force

if ($ImportProjectModule.IsPresent) {
    Write-Host "`nSTARTED TASK: Importing project module into scope" -ForegroundColor Blue
    Import-Module -Name $ENV:BHPSModuleManifest -Force
}

# Execute psake tasks
# Write-Host -AnsiColors "`nSTARTED TASK: $Task" -ForegroundColor Green
Write-Host "`nSTARTED TASK: $Task" -ForegroundColor Green

$InvokePsakeArgs = @{
    buildFile = Join-Path -Path $ENV:BHProjectPath -ChildPath ".ci" -AdditionalChildPath "scripts", "build.psake.ps1"
    nologo    = $true
    taskList  = $Task
}
Invoke-Psake @InvokePsakeArgs

exit ( [int](-not $psake.build_success) )
