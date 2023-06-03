# PSSAToJunit powershell module

![maintenance-status](https://img.shields.io/badge/maintenance-actively--developed-brightgreen.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/tonylea/PSSAToJunit)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tonylea/PSSAToJunit)
![GitHub Release Date](https://img.shields.io/github/release-date/tonylea/PSSAToJunit)

![GitHub](https://img.shields.io/github/license/tonylea/PSSAToJunit)
![GitHub contributors](https://img.shields.io/github/contributors/tonylea/PSSAToJunit)
![GitHub commit activity](https://img.shields.io/github/commit-activity/t/tonylea/PSSAToJunit)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/tonylea/PSSAToJunit)

A simple PowerShell module to convert PSScriptAnalyzer results to jUnit.
Intended to be used in GitHub or Azure DevOps pipelines.

This was created because I couldn't find a simple way to publish PSScriptAnalyzer results in Azure DevOps.

## Installation

```powershell
Install-Module -Name PSSAToJunit
```

## How to use

This is intended for use in a pipeline.
The following example is for Azure DevOps.

```yaml
- task: PowerShell@2
  displayName: 'Run PSScriptAnalyzer'
  inputs:
    targetType: 'inline'
    script: |
      Invoke-ScriptAnalyzer -Path ./src/ -Recurse -Severity Warning, Error | ConvertTo-PSSAJunitXml | Export-PSSAJunitXml -FilePath "./test.xml"

- task: PublishTestResults@2
  displayName: 'Publish PSScriptAnalyzer results'
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test.xml'
    testRunTitle: 'PSScriptAnalyzer'
```

## Support

## Roadmap

This is a simple module.
At the moment, there are no plans to add any new features.
If you have a feature request, please open an issue.

I would like to:

- Improve the tests and add more tests
- Improve the documentation
- Add better error handling

## Contributors

See the [Contributing](CONTRIBUTING.md) file for more information on how to contribute.

Below are the contributors to this project.

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
