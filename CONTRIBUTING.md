# Contributing to PSSAToJunit

Thank you for considering contributing to PSSAToJunit!
We appreciate your time and effort in helping us improve the module.
This document outlines the guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Development Setup](#development-setup)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Testing](#testing)
- [Linting and Spell Checking](#linting-and-spell-checking)
- [Continuous Integration and Delivery (CI/CD)](#continuous-integration-and-delivery-cicd)
- [License](#license)

## Code of Conduct

Please note that this project follows the guidelines outlined in the [Code of Conduct](CODE_OF_CONDUCT.md).
We expect all contributors to follow the code of conduct in all interactions related to the project.

## How Can I Contribute?

You can contribute to PSSAToJunit by:

- Updating/adding tests
- Adding error handling
- Fixing bugs
- Adding new features
- Updating the documentation

### Reporting Bugs

If you encounter any bugs while using PSSAToJunit, please help us by [opening a GitHub issue](.github/ISSUE_TEMPLATE/Bug_Report.yaml) and providing detailed information about the bug. Include steps to reproduce it, error messages if applicable, and any relevant environment details.

### Suggesting Enhancements

We welcome suggestions for new features or enhancements to PSSAToJunit.
Please [open a GitHub issue](.github/ISSUE_TEMPLATE/Feature_Request.yaml) and describe your idea or improvement in detail.
We appreciate well-defined feature requests that include context and potential use cases.

### Submitting Pull Requests

We appreciate your contributions through pull requests.
Before submitting a pull request, please ensure the following:

1. Fork the repository and create a new branch from the `main` branch.
2. Make your changes in the new branch while following the code style and guidelines.
3. Write meaningful commit messages adhering to the [Angular Conventional Commit specifications](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#-commit-message-guidelines).
4. Include tests if applicable and ensure all existing tests pass.
5. Update the documentation as necessary.
6. Submit your pull request, linking it to the relevant GitHub issue.

Once your pull request is submitted, it will be reviewed by the maintainers.
Feedback or suggestions for improvement may be provided.
After addressing any requested changes, your pull request will be merged.

## Development Setup

To set up the development environment for PSSAToJunit, follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/your-powershell-module.git`
2. Make sure you have PowerShell 7.0 or later installed.
3. Run `npm install` to install the required dependencies.
4. Start coding!

## Commit Message Guidelines

We use the [angular commit convention](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#-commit-message-guidelines) for commit messages.
Please ensure that your commit messages have a clear and descriptive title and include any necessary context in the body of the message.

## Testing

PSSAToJunit includes Pester unit tests to maintain code quality and functionality.
When contributing, ensure that all existing tests pass and add new tests if necessary.
To run the tests, execute the appropriate command:

```powershell
Invoke-Pester
```

## Linting and Spell Checking

We utilize **PSScriptAnalyzer** for linting PowerShell functions and **markdownlint** for linting markdown documents.
Additionally, we use **markdown-spellcheck** to check the spelling of markdown documentation files.

To run the linting and spell checking tasks, execute the following commands:

```powershell
Invoke-PSScriptAnalyzer -Path <project_root>/src/*
markdownlint <markdown-file-or-directory>
markdown-spellcheck <markdown-file-or-directory>
```

Make sure all linting and spell checking rules are followed before submitting a pull request.

## Continuous Integration and Delivery (CI/CD)

The CI/CD process for PSSAToJunit is hosted on Azure DevOps.
This process includes linting, spell checks, unit tests, package builds, automatic versioning, and publishing to the PowerShell Gallery.
All changes are automatically validated through these pipelines.

## License

By contributing to PSSAToJunit, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for your interest in contributing to PSSAToJunit! We appreciate your support and look forward to your contributions.

Please note that all contributions are subject to review and acceptance by the maintainers of this project.
