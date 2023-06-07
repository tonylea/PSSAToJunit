---
external help file: PSSAToJunit-help.xml
Module Name: PSSAToJunit
online version: https://github.com/tonylea/PSSAToJunit/blob/main/docs/Export-PSSAJunitXml.md
schema: 2.0.0
---

# Export-PSSAJunitXml

## SYNOPSIS
The `Export-PSSAJunitXml` function exports the results of `ConvertTo-PSSAJunitXml` to a file.

## SYNTAX

<!-- markdownlint-disable MD040 -->
```
Export-PSSAJunitXml [-InputXml] <XmlDocument> [[-FilePath] <FileInfo>] [<CommonParameters>]
```
<!-- markdownlint-enable MD040 -->

## DESCRIPTION
The `Export-PSSAJunitXml` function exports the results of `ConvertTo-PSSAJunitXml` to a file.
It accepts the JunitXml object as either a specified parameter or throuigh the pipeline.

If no filepath is specified, the function will export the JunitXml object to the current directory with the name `PSScriptAnalyzerResults.xml`.

## EXAMPLES

### Example 1: Capture PSScriptAnalyzer results to a variable and pass to ConvertTo-PSSAJunitXml as a argument
```powershell
PS C:\> $Result = Invoke-ScriptAnalyzer -Path .\MyScript.ps1
PS C:\> $JunitXml = ConvertTo-PSSAJunitXml -PSScriptAnalyzerResult $Result
PS C:\> Export-PSSAJunitXml -InputXml $JunitXml -FilePath .\MyScriptResults.xml
```

This example captures the results of `Invoke-ScriptAnalyzer` to a variable and passes it to `ConvertTo-PSSAJunitXml` as an argument.
The results are then passed to `Export-PSSAJunitXml` to be exported to a file.

### Example 2: Pass PSScriptAnalyzer results to ConvertTo-PSSAJunitXml through the pipeline
```powershell
PS C:\> Invoke-ScriptAnalyzer -Path .\MyScript.ps1 | ConvertTo-PSSAJunitXml | Export-PSSAJunitXml -FilePath .\MyScriptResults.xml
```

This example passes the results of `Invoke-ScriptAnalyzer` to `ConvertTo-PSSAJunitXml` through the pipeline, and then passes the results to `Export-PSSAJunitXml` to be exported to a file.

## PARAMETERS

### -FilePath
The path to the file to export the JunitXml object to.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputXml
The JunitXml object to export.

```yaml
Type: XmlDocument
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Xml.XmlDocument
## OUTPUTS

<!-- markdownlint-disable MD024 -->
### System.Xml.XmlDocument
<!-- markdownlint-enable MD024 -->
## NOTES

## RELATED LINKS
