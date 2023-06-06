function Write-Host {
    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=113426', RemotingCapability = 'None')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [System.Object] ${Object},

        [Alias('nnl')] [switch] ${NoNewline},

        [switch] ${AnsiColors},

        [System.Object] ${Separator},

        [Alias('fg')] [System.ConsoleColor] ${ForegroundColor},

        [Alias('bg')] [System.ConsoleColor] ${BackgroundColor}
    )

    begin {
        $Code = @'
        using System;
        using System.Collections.Generic;
        using System.Management.Automation;
        using System.Text;

        public static class AnsiHelper
        {
            public static string GetCode(this ConsoleColor? color, bool forBackground = false)
            {
                string colorCode = color == null ? "Clear" : color.ToString();
                return forBackground ? Background[colorCode] : Foreground[colorCode];
            }

            public static Dictionary<string, string> Foreground = new Dictionary<string, string>
            {
                {"Clear",       "\u001B[39m"},
                {"Black",       "\u001B[30m"}, { "DarkGray", "\u001B[90m"},
                {"DarkRed",     "\u001B[31m"}, { "Red",      "\u001B[91m"},
                {"DarkGreen",   "\u001B[32m"}, { "Green",    "\u001B[92m"},
                {"DarkYellow",  "\u001B[33m"}, { "Yellow",   "\u001B[93m"},
                {"DarkBlue",    "\u001B[34m"}, { "Blue",     "\u001B[94m"},
                {"DarkMagenta", "\u001B[35m"}, { "Magenta",  "\u001B[95m"},
                {"DarkCyan",    "\u001B[36m"}, { "Cyan",     "\u001B[96m"},
                {"Gray",        "\u001B[37m"}, { "White",    "\u001B[97m"}
            };

            public static Dictionary<string, string> Background = new Dictionary<string, string>
            {
                {"Clear",       "\u001B[49m"},
                {"Black",       "\u001B[40m"}, {"DarkGray", "\u001B[100m"},
                {"DarkRed",     "\u001B[41m"}, {"Red",      "\u001B[101m"},
                {"DarkGreen",   "\u001B[42m"}, {"Green",    "\u001B[102m"},
                {"DarkYellow",  "\u001B[43m"}, {"Yellow",   "\u001B[103m"},
                {"DarkBlue",    "\u001B[44m"}, {"Blue",     "\u001B[104m"},
                {"DarkMagenta", "\u001B[45m"}, {"Magenta",  "\u001B[105m"},
                {"DarkCyan",    "\u001B[46m"}, {"Cyan",     "\u001B[106m"},
                {"Gray",        "\u001B[47m"}, {"White",    "\u001B[107m"},
            };

            public static string WriteAnsi(ConsoleColor? foreground, ConsoleColor? background, object value, bool clear = false)
            {
                var output = new StringBuilder();

                output.Append(background.GetCode(true));
                output.Append(foreground.GetCode());
                output.Append(LanguagePrimitives.ConvertTo(value, typeof(string)));
                if (clear)
                {
                    output.Append(AnsiHelper.Background["Clear"]);
                    output.Append(AnsiHelper.Foreground["Clear"]);
                }
                return output.ToString();
            }
        }
'@
        try { [AnsiHelper] | Out-Null } catch { if ($_ -like '*Unable to find type*') { Add-Type -TypeDefinition $Code } else { throw $_ } }

        if ( $AnsiColors ) {
            $PSBoundParameters.Remove('AnsiColors') | Out-Null
            $Start = [AnsiHelper]::WriteAnsi( $PSBoundParameters.ForegroundColor, $PSBoundParameters.BackgroundColor, $null)
            $Clear = [AnsiHelper]::WriteAnsi( $null, $null, $null )
            Microsoft.PowerShell.Utility\Write-Host $start -NoNewline

            $HadNoNewLine = $PSBoundParameters.ContainsKey('NoNewline')
            $PSBoundParameters.NoNewline = $true
        }

        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = { & $wrappedCmd @PSBoundParameters }
        $SteppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $SteppablePipeline.Begin($PSCmdlet)
    }

    process {
        $SteppablePipeline.Process($_)
    }

    end {
        $SteppablePipeline.End()

        if ( $AnsiColors ) {
            $Params = @{ NoNewLine = $HadNoNewLine }
            Microsoft.PowerShell.Utility\Write-Host $Clear @Params
        }
    }
}
