---
external help file: PSSAToJunit-help.xml
Module Name: PSSAToJunit
online version: https://github.com/tonylea/PSSAToJunit/blob/main/docs/ConvertTo-PSSAJunitXml.md
schema: 2.0.0
---

# ConvertTo-PSSAJunitXml

## SYNOPSIS
Converts PSScriptAnalyzer results to JUnit XML format.

## SYNTAX

<!-- markdownlint-disable MD040 -->
```
ConvertTo-PSSAJunitXml [-PSScriptAnalyzerResult] <DiagnosticRecord[]> [[-TestName] <String>]
 [[-Severity] <String[]>] [<CommonParameters>]
```
<!-- markdownlint-enable MD040 -->

## DESCRIPTION
The `ConvertTo-PSSAJunitXml` function converts the results of PSScriptAnalyzer to JUnit XML format.
The conversion is exported as a `[System.Xml.XmlDocument]` object.

The input object must be a collection of `[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]` objects.
This is normally the output of `Invoke-ScriptAnalyzer` captured a variable or passed through the pipeline.

## EXAMPLES

### Example 1: Capture PSScriptAnalyzer results to a variable and pass to ConvertTo-PSSAJunitXml as a argument
```powershell
PS C:\> $Result = Invoke-ScriptAnalyzer -Path .\MyScript.ps1
PS C:\> $JunitXml = ConvertTo-PSSAJunitXml -PSScriptAnalyzerResult $Result
```

This example captures the results of `Invoke-ScriptAnalyzer` to a variable and passes it to `ConvertTo-PSSAJunitXml` as an argument.

### Example 2: Pass PSScriptAnalyzer results to ConvertTo-PSSAJunitXml through the pipeline
```powershell
PS C:\> $JunitXml = Invoke-ScriptAnalyzer -Path .\MyScript.ps1 | ConvertTo-PSSAJunitXml
```

This example passes the results of `Invoke-ScriptAnalyzer` to `ConvertTo-PSSAJunitXml` through the pipeline.

## PARAMETERS

### -PSScriptAnalyzerResult
The results of `Invoke-ScriptAnalyzer` command.

```yaml
Type: DiagnosticRecord[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Severity
The severity of the diagnostic records to include in the JUnit XML output.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Information, Warning, Error

Required: False
Position: 2
Default value: [Warning, Error]
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestName
The name of the test suite.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: PSScriptAnalyzer
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]
## OUTPUTS

### System.Xml.XmlDocument
## NOTES

## RELATED LINKS
