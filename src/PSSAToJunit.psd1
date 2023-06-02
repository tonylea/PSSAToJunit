@{
    RootModule           = "PSSAToJunit.psm1"
    ModuleVersion        = "1.0.0"
    CompatiblePSEditions = @("Core")
    GUID                 = "fa5b675c-f181-4571-bda8-2b24da71d04b"
    Author               = "Tony Lea"
    CompanyName          = ""
    Copyright            = "(c) Tony Lea. All rights reserved."
    Description          = "A simple PowerShell module to convert PSScriptAnalyzer results to jUnit"
    PowerShellVersion    = "7.0.0"
    # PowerShellHostName = ""
    # PowerShellHostVersion = ""
    # DotNetFrameworkVersion = ""
    # ClrVersion = ""
    # ProcessorArchitecture = ""
    RequiredModules      = @(
        @{ ModuleName = "PSScriptAnalyzer"; ModuleVersion = "1.19.1" }
    )
    # RequiredAssemblies = @()
    # ScriptsToProcess = @()
    # TypesToProcess = @()
    # FormatsToProcess = @()
    # NestedModules = @()
    FunctionsToExport    = @("Convert-PssaJunit")
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    # DscResourcesToExport = @()
    # ModuleList = @()
    # FileList = @()
    PrivateData          = @{
        PSData = @{
            Tags       = @("PSScriptAnalyzer", "PSSA", "junit")
            LicenseUri = "https://mit-license.org"
            ProjectUri = "https://github.com/tonylea/PSSAToJunit"
            # IconUri = ""
            # ReleaseNotes = ""
            # Prerelease = ""
            # RequireLicenseAcceptance = $false
            # ExternalModuleDependencies = @()
        }
    }
    # HelpInfoURI = ""
    # DefaultCommandPrefix = ""
}
