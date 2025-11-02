function Test-AnsiSupport {
    <#
    .SYNOPSIS
        Detects terminal ANSI capabilities including color support levels and style features

    .DESCRIPTION
        Test-AnsiSupport performs comprehensive cross-platform detection of terminal ANSI escape
        sequence support, including color modes (TrueColor/256-color/16-color) and text styling
        capabilities (Bold, Italic, Underline, etc.).

        The function automatically detects and attempts to enable ANSI support on Windows platforms
        using Virtual Terminal Processing. It provides detailed information about terminal capabilities
        to ensure Write-ColorEX can gracefully degrade colors and styles based on what's supported.

        DETECTION FEATURES:
        - Color support levels: TrueColor (24-bit), ANSI8 (256-color), ANSI4 (16-color), None
        - Bold font rendering vs color brightening detection
        - Style support: Italic, Underline, Blink, Faint, CrossedOut, DoubleUnderline, Overline
        - Terminal-specific detection (Windows Terminal, iTerm2, GNOME Terminal, VS Code, etc.)
        - Platform detection: Windows, Linux, macOS with specific terminal identification
        - Environment variable overrides: FORCE_COLOR, NO_COLOR, COLORTERM, TERM

        TERMINAL-SPECIFIC DETECTION:
        Windows: Windows Terminal, PowerShell Console (conhost), ConEmu, VS Code, PowerShell ISE, Git Bash
        macOS: iTerm2, Terminal.app, VS Code
        Linux: GNOME Terminal, Konsole, xterm, rxvt-unicode, Kitty

        AUTOMATIC WINDOWS ENABLEMENT:
        On Windows 10+ (build 10586 or later), automatically enables Virtual Terminal Processing
        if not already enabled, allowing ANSI escape sequences to work in conhost.exe.

    .PARAMETER Silent
        Suppresses all warning messages and terminal limitation notices.
        Useful when programmatically checking terminal capabilities without user-facing output.

        Default: $false (warnings enabled)

    .INPUTS
        None
        This function does not accept pipeline input.

    .OUTPUTS
        PSCustomObject
        Returns a custom object with the following properties:

        ColorSupport (string):
            - 'TrueColor' : 24-bit RGB color support (16.7 million colors)
            - 'ANSI8'     : 256-color support
            - 'ANSI4'     : 16-color support
            - 'None'      : No ANSI support (PowerShell ISE, old terminals)

        SupportsBoldFonts (boolean):
            - $true  : Terminal renders true bold fonts
            - $false : Terminal only brightens colors when Bold SGR is used

        Details (hashtable):
            - PowerShellVersion           : PowerShell version string
            - IsConsoleHost              : Whether running in ConsoleHost
            - HasVirtualTerminalProcessing : VT processing enabled (Windows)
            - HasCompatibleTerminalEnv   : Compatible TERM environment variable
            - IsPSCore                   : PowerShell 6+ (Core)
            - OperatingSystem            : Platform (Win32NT, Unix)
            - TerminalType               : Detected terminal name
            - EnableInstructions         : How to enable ANSI support
            - StyleSupport               : Hashtable of supported styles
            - Warnings                   : Array of limitation warnings

    .EXAMPLE
        Test-AnsiSupport

        Detects ANSI support and displays warnings about terminal limitations.
        Returns full detection results object.

    .EXAMPLE
        $ansi = Test-AnsiSupport -Silent
        if ($ansi.ColorSupport -eq 'TrueColor') {
            Write-ColorEX -Text "24-bit colors available!" -Color @(0,255,128) -TrueColor
        }

        Silent detection for programmatic use. Checks if TrueColor is available.

    .EXAMPLE
        $result = Test-AnsiSupport
        $result.Details.TerminalType
        # Output: "Windows Terminal" or "iTerm2" or "GNOME Terminal 3.32+" etc.

        Get specific terminal type for conditional logic.

    .EXAMPLE
        if ((Test-AnsiSupport).SupportsBoldFonts) {
            Write-ColorEX "Bold text!" -Color Red -Bold
        } else {
            Write-ColorEX "Brightened text" -Color Red -Bold
        }

        Check if terminal renders true bold fonts or just brightens colors.

    .NOTES
        Author: MarkusMcNugen
        License: MIT
        Requires: PowerShell 5.1 or later

        ENVIRONMENT VARIABLES:
        - FORCE_COLOR : Override detection (0=None, 1=ANSI4, 2=ANSI8, 3=TrueColor)
        - NO_COLOR    : Disable all colors (any value)
        - TERM        : Terminal type identifier
        - COLORTERM   : Color capability ('truecolor', '24bit')
        - WT_SESSION  : Windows Terminal session ID
        - VTE_VERSION : GNOME Terminal (VTE) version

        PLATFORM NOTES:
        Windows - Uses P/Invoke to check/enable Virtual Terminal Processing
        Linux   - Checks TERM, COLORTERM, VTE_VERSION, terminal-specific env vars
        macOS   - Detects iTerm2, Terminal.app via TERM_PROGRAM

        This function is called automatically during PSWriteColorEX module initialization.
        Results are cached in $script:CachedANSISupport for performance.

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX

    .LINK
        https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
    #>
    [CmdletBinding()]
    [Alias('TAS', 'Test-ANSI')]
    param(
        [switch]$Silent = $False
    )

    # Initialize collection for results
    $results = [PSCustomObject]@{
        ColorSupport = 'None'  # None, ANSI4, ANSI8, TrueColor
        SupportsBoldFonts = $False  # Whether terminal supports true bold fonts (vs color lightening only)
        Details = @{
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            IsConsoleHost = $Host.Name -eq 'ConsoleHost'
            HasVirtualTerminalProcessing = $False
            HasCompatibleTerminalEnv = $False
            IsPSCore = $PSVersionTable.PSVersion.Major -ge 6
            OperatingSystem = [System.Environment]::OSVersion.Platform
            TerminalType = ''
            EnableInstructions = ''
            StyleSupport = @{
                Bold = $True
                Italic = $False
                Underline = $True
                Faint = $False
                Blink = $False
                CrossedOut = $False
                DoubleUnderline = $False
                Overline = $False
            }
            Warnings = @()
        }
    }

    # Check for forced color support first
    $forceColor = [Environment]::GetEnvironmentVariable('FORCE_COLOR')
    If ($forceColor) {
        Switch ($forceColor) {
            '0' { $results.ColorSupport = 'None'; Return $results }
            '1' { $results.ColorSupport = 'ANSI4'; Return $results }
            '2' { $results.ColorSupport = 'ANSI8'; Return $results }
            '3' { $results.ColorSupport = 'TrueColor'; $results.SupportsBoldFonts = $True; Return $results }
        }
    }

    # Check for NO_COLOR environment variable
    If ([Environment]::GetEnvironmentVariable('NO_COLOR')) {
        $results.ColorSupport = 'None'
        Return $results
    }

    # Check environment variables for color support level
    $termEnv = [Environment]::GetEnvironmentVariable('TERM')
    $colorTerm = [Environment]::GetEnvironmentVariable('COLORTERM')
    $conEmuANSI = [Environment]::GetEnvironmentVariable('ConEmuANSI')
    $wtSession = [Environment]::GetEnvironmentVariable('WT_SESSION')
    $termProgram = [Environment]::GetEnvironmentVariable('TERM_PROGRAM')
    $vte_version = [Environment]::GetEnvironmentVariable('VTE_VERSION')
    
    # Determine terminal type and color support level
    If ($colorTerm -eq 'truecolor' -or $colorTerm -eq '24bit') {
        $results.ColorSupport = 'TrueColor'
        $results.Details.HasCompatibleTerminalEnv = $True
    } ElseIf ($termEnv -like '*256color*' -or $termEnv -like '*256*') {
        $results.ColorSupport = 'ANSI8'
        $results.Details.HasCompatibleTerminalEnv = $True
    } ElseIf (-not [string]::IsNullOrEmpty($termEnv)) {
        $results.ColorSupport = 'ANSI4'
        $results.Details.HasCompatibleTerminalEnv = $True
    }

    # Platform-specific checks
    If ($results.Details.OperatingSystem -eq 'Unix') {
        # Unix/Linux/macOS generally support ANSI
        $results.Details.HasVirtualTerminalProcessing = $True

        # Detect specific terminal - macOS
        If ($termProgram -eq 'Apple_Terminal') {
            $results.Details.TerminalType = 'macOS Terminal.app'
            $results.ColorSupport = 'ANSI8'  # Terminal.app max is 256 colors
            $results.SupportsBoldFonts = $False  # Terminal.app uses color brightening for bold
            $results.Details.Warnings += 'macOS Terminal.app does not support TrueColor (24-bit). Maximum 256 colors. For TrueColor support, use iTerm2.'
            # Terminal.app has good basic style support
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
        }
        ElseIf ($termProgram -eq 'iTerm.app') {
            $results.Details.TerminalType = 'iTerm2'
            If ($results.ColorSupport -eq 'None' -or $results.ColorSupport -eq 'ANSI4' -or $results.ColorSupport -eq 'ANSI8') {
                $results.ColorSupport = 'TrueColor'
            }
            $results.SupportsBoldFonts = $True  # iTerm2 supports true bold fonts
            # iTerm2 has excellent style support (v3.5.0+)
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
            $results.Details.StyleSupport.CrossedOut = $True
        }
        ElseIf ($termProgram -eq 'vscode') {
            $results.Details.TerminalType = 'VS Code Integrated Terminal'
            If ($results.ColorSupport -eq 'None' -or $results.ColorSupport -eq 'ANSI4' -or $results.ColorSupport -eq 'ANSI8') {
                $results.ColorSupport = 'TrueColor'
            }
            $results.SupportsBoldFonts = $True  # VS Code terminal (xterm.js) supports bold fonts
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
        }
        # Detect VTE-based terminals (GNOME Terminal, Xfce Terminal, etc.)
        ElseIf (-not [string]::IsNullOrEmpty($vte_version)) {
            $vteVersionNum = [int]$vte_version
            If ($vteVersionNum -ge 5600) {
                # VTE 0.56+ (GNOME Terminal 3.32+) - default changed to bold-only (no color brightening)
                $results.Details.TerminalType = 'VTE-based Terminal (GNOME Terminal 3.32+)'
                $results.SupportsBoldFonts = $True  # VTE 0.56+ defaults to true bold fonts
                $results.Details.StyleSupport.Italic = $True
                $results.Details.StyleSupport.Underline = $True
                $results.Details.StyleSupport.Blink = $True
                $results.Details.StyleSupport.Overline = $True
                If ($vteVersionNum -ge 7600) {
                    # VTE 0.76+ (GNOME Terminal 3.52+, Ubuntu 24.04+)
                    $results.Details.StyleSupport.DoubleUnderline = $True
                }
            } ElseIf ($vteVersionNum -ge 5200) {
                # VTE 0.52-0.55 (GNOME Terminal 3.28-3.31) - bold brightens colors by default
                $results.Details.TerminalType = 'VTE-based Terminal (GNOME Terminal 3.28+)'
                $results.SupportsBoldFonts = $False  # VTE 0.52-0.55 defaults to color brightening
                $results.Details.StyleSupport.Italic = $True
                $results.Details.StyleSupport.Underline = $True
                $results.Details.StyleSupport.Blink = $True
                $results.Details.StyleSupport.Overline = $True
            } Else {
                $results.Details.TerminalType = 'VTE-based Terminal'
                $results.SupportsBoldFonts = $False  # Older VTE versions brighten colors
                $results.Details.StyleSupport.Italic = $True
                $results.Details.StyleSupport.Underline = $True
                $results.Details.Warnings += 'Older VTE version detected. Some styles (Blink, Overline) may not be supported. Consider updating to GNOME Terminal 3.28+ (VTE 0.52+).'
            }
            If ($results.ColorSupport -eq 'None' -or $results.ColorSupport -eq 'ANSI4' -or $results.ColorSupport -eq 'ANSI8') {
                $results.ColorSupport = 'TrueColor'
            }
        }
        # Detect Konsole
        ElseIf ($termEnv -like '*konsole*' -or $env:KONSOLE_VERSION) {
            $results.Details.TerminalType = 'Konsole'
            If ($results.ColorSupport -eq 'None' -or $results.ColorSupport -eq 'ANSI4' -or $results.ColorSupport -eq 'ANSI8') {
                $results.ColorSupport = 'TrueColor'
            }
            $results.SupportsBoldFonts = $True  # Konsole supports true bold fonts
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
            $results.Details.StyleSupport.Overline = $True
        }
        # Detect xterm
        ElseIf ($termEnv -eq 'xterm-256color') {
            $results.Details.TerminalType = 'xterm-256color'
            If ($results.ColorSupport -eq 'None') {
                $results.ColorSupport = 'ANSI8'
            }
            $results.SupportsBoldFonts = $False  # xterm default couples bright colors with bold
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
        }
        ElseIf ($termEnv -like 'xterm*') {
            $results.Details.TerminalType = 'xterm'
            If ($results.ColorSupport -eq 'None') {
                $results.ColorSupport = 'ANSI4'
            }
            $results.SupportsBoldFonts = $False  # xterm default couples bright colors with bold
            $results.Details.StyleSupport.Underline = $True
        }
        # Detect rxvt
        ElseIf ($termEnv -like 'rxvt*') {
            $results.Details.TerminalType = 'rxvt/urxvt'
            $results.SupportsBoldFonts = $True  # urxvt can decouple bold from bright colors
            If ($termEnv -like '*256*') {
                $results.ColorSupport = 'ANSI8'
                $results.Details.StyleSupport.Italic = $True
            } Else {
                $results.ColorSupport = 'ANSI4'
                $results.Details.Warnings += 'rxvt detected. Basic rxvt does not support 256 colors. Consider using rxvt-unicode (urxvt) or a modern terminal.'
            }
            $results.Details.StyleSupport.Underline = $True
        }
        # Generic Unix terminal
        Else {
            If ($termEnv -like '*256*') {
                $results.Details.TerminalType = 'Unix Terminal (256 color)'
                If ($results.ColorSupport -eq 'None') {
                    $results.ColorSupport = 'ANSI8'
                }
            } ElseIf (-not [string]::IsNullOrEmpty($termEnv)) {
                $results.Details.TerminalType = "Unix Terminal ($termEnv)"
                If ($results.ColorSupport -eq 'None') {
                    $results.ColorSupport = 'ANSI4'
                }
            }
        }

        $results.Details.EnableInstructions = 'ANSI colors are enabled by default on Unix/Linux/macOS. To ensure 256 colors, add "export TERM=xterm-256color" to your shell config file (~/.bashrc, ~/.zshrc, etc.). For TrueColor, add "export COLORTERM=truecolor".'
    }
    ElseIf ($results.Details.OperatingSystem -eq 'Win32NT') {
        # Windows-specific checks
        $osVersion = [System.Environment]::OSVersion.Version
        $isWin10Plus = ($osVersion.Major -gt 10) -or ($osVersion.Major -eq 10 -and $osVersion.Build -ge 10586)
        $supportsTrueColor = ($osVersion.Major -gt 10) -or ($osVersion.Major -eq 10 -and $osVersion.Build -ge 14931)

        # Windows Terminal detection
        If (-not [string]::IsNullOrEmpty($wtSession)) {
            $results.Details.TerminalType = 'Windows Terminal'
            $results.Details.HasVirtualTerminalProcessing = $True
            $results.ColorSupport = 'TrueColor'
            # Windows Terminal has excellent style support
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
            $results.Details.StyleSupport.CrossedOut = $True
            If ($results.Details.IsPSCore) {
                # PowerShell 7+ has proper bold font support in Windows Terminal
                $results.SupportsBoldFonts = $True
                $results.Details.StyleSupport.Bold = $True
            } Else {
                # PowerShell 5.1 in Windows Terminal: Bold makes colors lighter, not actual bold font
                $results.SupportsBoldFonts = $False
                $results.Details.Warnings += 'PowerShell 5.1 in Windows Terminal: Bold style makes colors lighter instead of bolding the font. Use PowerShell 7+ for proper bold support.'
            }
        }
        # ConEmu detection
        ElseIf (-not [string]::IsNullOrEmpty($conEmuANSI)) {
            $results.Details.TerminalType = 'ConEmu/Cmder'
            $results.Details.HasVirtualTerminalProcessing = $True
            $results.ColorSupport = If ($supportsTrueColor) { 'TrueColor' } Else { 'ANSI8' }
            $results.SupportsBoldFonts = $True  # ConEmu supports bold fonts
            $results.Details.Warnings += 'ConEmu/Cmder has LIMITED TrueColor support (only in the bottom buffer area, requires scrolling off). For full TrueColor support, use Windows Terminal.'
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
        }
        # mintty detection (Git Bash, Cygwin, MSYS2)
        ElseIf ($termEnv -like '*mintty*' -or $termProgram -eq 'mintty') {
            $results.Details.TerminalType = 'mintty (Git Bash/Cygwin/MSYS2)'
            $results.Details.HasVirtualTerminalProcessing = $True
            $results.ColorSupport = 'TrueColor'  # mintty 2.0.1+ supports TrueColor
            $results.SupportsBoldFonts = $True  # mintty supports true bold fonts
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
        }
        # VS Code Integrated Terminal
        ElseIf ($termProgram -eq 'vscode') {
            $results.Details.TerminalType = 'VS Code Integrated Terminal'
            $results.Details.HasVirtualTerminalProcessing = $True
            $results.ColorSupport = 'TrueColor'
            $results.SupportsBoldFonts = $True  # VS Code terminal (xterm.js) supports bold fonts
            $results.Details.StyleSupport.Italic = $True
            $results.Details.StyleSupport.Underline = $True
        }
        # PowerShell ISE detection (no ANSI support)
        ElseIf ($Host.Name -eq 'Windows PowerShell ISE Host') {
            $results.Details.TerminalType = 'PowerShell ISE'
            $results.Details.HasVirtualTerminalProcessing = $False
            $results.ColorSupport = 'None'
            $results.SupportsBoldFonts = $False  # ISE has no ANSI support at all
            $results.Details.Warnings += 'PowerShell ISE does NOT support ANSI escape sequences. Only native PowerShell colors available. Use Windows Terminal or PowerShell 7+ for ANSI support.'
        }
        # PowerShell Core/7+ has automatic ANSI support
        ElseIf ($results.Details.IsPSCore) {
            $results.Details.HasVirtualTerminalProcessing = $True
            $results.ColorSupport = If ($supportsTrueColor) { 'TrueColor' } ElseIf ($isWin10Plus) { 'ANSI8' } Else { 'ANSI4' }
            $results.Details.TerminalType = 'PowerShell Core Console'
            $results.SupportsBoldFonts = $True  # PowerShell 7+ supports true bold fonts
            If ($supportsTrueColor) {
                $results.Details.StyleSupport.Italic = $True
                $results.Details.StyleSupport.Underline = $True
            }
        }
        # Check for console host (ISE doesn't support ANSI)
        ElseIf (-not $results.Details.IsConsoleHost) {
            $results.Details.HasVirtualTerminalProcessing = $False
            $results.ColorSupport = 'None'
            $results.Details.TerminalType = $Host.Name
            $results.Details.Warnings += "Host '$($Host.Name)' does not support ANSI escape sequences. Only native PowerShell colors available."
        }
        # Use P/Invoke for Windows PowerShell to check/enable console mode
        ElseIf ($isWin10Plus) {
            try {
                # Define P/Invoke signatures if not already defined
                If (-not ('ConsoleHelper' -as [type])) {
                    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class ConsoleHelper {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);
}
"@ -ErrorAction SilentlyContinue
                }

                If ('ConsoleHelper' -as [type]) {
                    # Constants
                    $STDOUT_HANDLE = -11
                    $ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004

                    # Get console mode
                    $stdoutHandle = [ConsoleHelper]::GetStdHandle($STDOUT_HANDLE)
                    $consoleMode = 0

                    If ([ConsoleHelper]::GetConsoleMode($stdoutHandle, [ref]$consoleMode)) {
                        $results.Details.HasVirtualTerminalProcessing = ($consoleMode -band $ENABLE_VIRTUAL_TERMINAL_PROCESSING) -ne 0

                        # Try to enable VT processing if not already enabled
                        If (-not $results.Details.HasVirtualTerminalProcessing) {
                            $newMode = $consoleMode -bor $ENABLE_VIRTUAL_TERMINAL_PROCESSING
                            If ([ConsoleHelper]::SetConsoleMode($stdoutHandle, $newMode)) {
                                $results.Details.HasVirtualTerminalProcessing = $True
                                If (-not $Silent) {
                                    Write-Warning 'ANSI support has been enabled for this session only. To enable permanently, run in Admin PowerShell: Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1'
                                }
                            }
                        }

                        If ($results.Details.HasVirtualTerminalProcessing) {
                            $results.Details.TerminalType = 'Windows PowerShell Console (conhost)'
                            $results.ColorSupport = If ($supportsTrueColor) { 'TrueColor' } ElseIf ($isWin10Plus) { 'ANSI8' } Else { 'ANSI4' }
                            $results.Details.StyleSupport.Underline = $True
                            # PowerShell 5.1 conhost doesn't support true bold - it just makes colors lighter
                            If (-not $results.Details.IsPSCore) {
                                $results.SupportsBoldFonts = $False
                                $results.Details.Warnings += 'PowerShell 5.1 conhost does NOT support true bold font rendering. Bold style will make colors lighter instead of actually bolding the text. Use PowerShell 7+ or Windows Terminal for proper bold support.'
                            } Else {
                                # PowerShell 7+ in conhost still doesn't render bold fonts
                                $results.SupportsBoldFonts = $False
                                $results.Details.Warnings += 'Windows Console (conhost) does NOT support true bold font rendering regardless of PowerShell version. Bold will lighten colors. Use Windows Terminal for proper bold support.'
                            }
                        }
                    }
                }
            }
            Catch {
                # P/Invoke failed, continue with other checks
                $results.Details.HasVirtualTerminalProcessing = $False
            }
        }
        
        $results.Details.EnableInstructions = 'To enable ANSI colors permanently on Windows, run in Admin PowerShell: Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1'
        
        # Windows version warnings
        If (-not $isWin10Plus -and -not $Silent) {
            Write-Warning 'Windows versions before Windows 10 build 10586 do not support ANSI colors natively. Consider using ConEmu or Windows Terminal.'
        }
    }

    # Final determination
    If ($results.ColorSupport -eq 'None' -and $results.Details.HasVirtualTerminalProcessing) {
        # If VT processing is available but no specific color level detected, default to ANSI4
        $results.ColorSupport = 'ANSI4'
    }

    # Return warnings if not silent
    If (-not $Silent) {
        # Display color support warnings
        If ($results.ColorSupport -eq 'None') {
            If (-not $results.Details.IsConsoleHost) {
                Write-Warning 'ANSI not supported: Not running in a compatible console host (e.g., ISE does not support ANSI)'
            } ElseIf ($results.Details.OperatingSystem -eq 'Win32NT') {
                Write-Warning "ANSI not supported: Virtual terminal processing is not available. $($results.Details.EnableInstructions)"
            }
        }

        # Display terminal-specific warnings
        ForEach ($warning in $results.Details.Warnings) {
            Write-Warning $warning
        }
    }

    # Return the full results object (includes ColorSupport and SupportsBoldFonts)
    Return $results
}