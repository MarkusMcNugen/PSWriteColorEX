Function Write-ColorEX {
    <#
    .SYNOPSIS
    Writes colored and styled text to the console with extensive formatting, ANSI support, Unicode-aware padding, and logging capabilities.

    .DESCRIPTION
    Write-ColorEX is an advanced console output function that extends Write-Host with comprehensive color, styling, and formatting features.

    KEY FEATURES:
    - Multiple color modes: Native PowerShell colors, ANSI 4-bit (16 colors), ANSI 8-bit (256 colors), TrueColor 24-bit (16.7 million colors)
    - Flexible color formats: Color names, hex codes (#RRGGBB), RGB arrays @(R,G,B), ANSI integers
    - Multi-color gradients with smooth transitions between 2+ colors
    - Unicode-aware text padding with AutoPad for perfect table alignment
    - Text styling: Bold, Italic, Underline, Blink, Faint, CrossedOut, DoubleUnderline, Overline
    - Reusable style profiles with PSColorStyle objects
    - Automatic terminal capability detection and graceful color fallback
    - Cross-platform compatibility (Windows, Linux, macOS)
    - Comprehensive logging with timestamps, log levels, and retry mechanism
    - Text formatting: indentation, centering, line spacing, blank lines
    - Automatic color lightening for bold in terminals without true bold font support

    TERMINAL COMPATIBILITY:
    - Automatically detects terminal ANSI capabilities using Test-AnsiSupport
    - Gracefully degrades colors: TrueColor → ANSI8 → ANSI4 → Native PowerShell colors
    - Supports Windows Terminal, PowerShell Console, VS Code, ConEmu, iTerm2, GNOME Terminal, and more
    - PowerShell 5.1 and PowerShell 7+ compatible

    .PARAMETER Text
    Specifies the text to display and optionally log. Accepts a single string or array of strings.
    When multiple strings are provided with multiple colors, colors cycle through each text segment.

    Pipeline input is accepted by property name.

    Example: -Text 'Hello', ' ', 'World'

    .PARAMETER Color
    Specifies the foreground color(s) for the text. Supports multiple formats:

    - Color names: 'Red', 'Blue', 'DarkGreen', 'Cyan', etc. (70+ color families with Dark/Normal/Light variants)
    - Hex codes: '#FF0000', '0xFF0000', 'FF0000' (requires -TrueColor switch)
    - RGB arrays: @(255, 0, 0) for red (requires -TrueColor switch)
    - ANSI integers: 0-255 for ANSI8 mode, 0-15 for ANSI4 mode

    When providing multiple colors with multiple Text segments, colors cycle through the text segments.
    If fewer colors than text segments, colors repeat. If more colors than text, extra colors are ignored.

    Default: Uses terminal's default text color.
    Aliases: C, ForegroundColor, FGC

    Example: -Color 'Red', 'Blue' -or- -Color '#FF8000' -or- -Color @(255,128,0)

    .PARAMETER BackGroundColor
    Specifies the background color(s) for the text. Accepts the same formats as Color parameter.

    Background colors can be combined with foreground colors, gradients, and all styling options.

    Default: Uses terminal's default background color.
    Aliases: B, BGC

    Example: -BackGroundColor 'DarkRed' -or- -BackGroundColor '#2C2C2C'

    .PARAMETER Gradient
    Specifies an array of 2 or more colors to create a smooth color gradient across all text characters.
    Each character is assigned an interpolated color value between the gradient waypoints.

    Requires ANSI8 or TrueColor terminal support. Automatically enables best available color mode.

    Gradient colors override the Color parameter but can be selectively overridden per-segment using $null in Color array.

    Alias: Grad

    Example: -Gradient @('Red', 'Blue')  # 2-color gradient
    Example: -Gradient @('Red', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta')  # Rainbow gradient

    .PARAMETER ANSI4
    Forces 4-bit ANSI color mode (16 colors: 8 normal + 8 bright).
    Use when terminal supports ANSI escape sequences but not 256-color or TrueColor.

    If terminal doesn't support ANSI4, automatically falls back to native PowerShell colors.

    Alias: A4

    .PARAMETER ANSI8
    Forces 8-bit ANSI color mode (256 colors: 16 standard + 216 color cube + 24 grayscale).
    Use when terminal supports 256-color ANSI but not TrueColor.

    If terminal doesn't support ANSI8, automatically falls back to ANSI4 or native colors.

    Alias: A8

    .PARAMETER ANSI24
    Forces 24-bit TrueColor mode (16.7 million colors via RGB).
    Use for maximum color fidelity in terminals that support TrueColor.

    Required for hex codes and RGB array colors.
    If terminal doesn't support TrueColor, automatically falls back to ANSI8 or ANSI4.

    Aliases: A24, TrueColor, TC

    .PARAMETER Style
    Specifies custom ANSI styles to apply to individual text segments.
    Accepts a single style string, array of styles, or nested arrays for per-segment styling.

    Valid styles: Bold, Faint, Italic, Underline, Blink, CrossedOut, DoubleUnderline, Overline

    When using array of styles with multiple Text segments, styles apply to corresponding segments.

    Alias: S

    Example: -Style 'Bold'
    Example: -Style @('Bold', 'Italic', 'Underline')  # Different style per text segment

    .PARAMETER StyleProfile
    Specifies a PSColorStyle object containing predefined color and style settings.
    Style profiles provide reusable configuration for common output patterns.

    Built-in profiles: Default, Error, Warning, Info, Success, Critical, Debug
    Create custom profiles using New-ColorStyle.

    Parameters explicitly specified override profile settings.

    Example: -StyleProfile ([PSColorStyle]::Profiles['Error'])

    .PARAMETER Default
    Applies the default style profile set via Set-ColorDefault.
    Convenient shorthand for -StyleProfile ([PSColorStyle]::Default).

    Parameters explicitly specified override default style settings.

    .PARAMETER Bold
    Applies bold styling to the entire output.
    In terminals without true bold font support, automatically lightens colors to simulate bold effect.

    Supported by: Windows Terminal (PS7+), iTerm2, GNOME Terminal, most modern terminals
    Limited support: PowerShell Console (color brightening only)

    .PARAMETER Faint
    Applies faint/dim styling (decreased intensity) to the entire output.

    Note: In ANSI4 mode, only works on bright colors. Use ANSI8 or TrueColor for full support.

    Supported by: Windows Terminal, PowerShell Console, GNOME Terminal, modern terminals

    .PARAMETER Italic
    Applies italic styling to the entire output.

    Supported by: Windows Terminal, iTerm2, GNOME Terminal, VS Code, Git Bash (mintty)
    NOT supported: PowerShell Console (conhost.exe limitation), basic rxvt

    .PARAMETER Underline
    Applies underline styling to the entire output.

    Supported by: Nearly all ANSI-capable terminals (most compatible style after Bold)

    .PARAMETER Blink
    Applies blinking effect to the entire output.

    Note: Many modern terminals disable blink as distracting. Support varies widely.

    Supported by: Windows Terminal (blinks to bold color), GNOME Terminal 3.28+, some terminals
    NOT supported: Konsole, Terminal.app, VS Code, many modern terminals

    .PARAMETER CrossedOut
    Applies strikethrough/crossed-out styling to the entire output.

    Alias: Strikethrough

    Supported by: Windows Terminal v1.3+, iTerm2 v3.5+, GNOME Terminal (VTE 0.52+), Kitty
    NOT supported: PowerShell Console, Terminal.app, ConEmu

    .PARAMETER DoubleUnderline
    Applies double underline styling to the entire output.

    Supported by: GNOME Terminal 3.52+ (VTE 0.76+), Kitty, Git Bash (mintty)
    Limited support: Most terminals treat as single underline

    .PARAMETER Overline
    Applies overline styling (line above text) to the entire output.

    Supported by: Windows Terminal, PowerShell Console, GNOME Terminal 3.28+, Konsole, iTerm2
    NOT supported: Terminal.app, ConEmu, VS Code, xterm

    .PARAMETER StartTab
    Specifies the number of tab characters to insert before the text.
    Each tab is rendered as a tab character (not converted to spaces).

    Default: 0 (no tabs)
    Alias: Indent

    Example: -StartTab 2  # Two tabs before text

    .PARAMETER LinesBefore
    Specifies the number of blank lines to output before the text.
    Useful for vertical spacing in console output.

    Default: 0 (no blank lines)

    Example: -LinesBefore 2  # Two blank lines before text

    .PARAMETER LinesAfter
    Specifies the number of blank lines to output after the text.
    Useful for vertical spacing in console output.

    Default: 0 (no blank lines)

    Example: -LinesAfter 1  # One blank line after text

    .PARAMETER StartSpaces
    Specifies the number of space characters to insert before the text.
    Spaces are inserted after any tabs specified by StartTab.

    Default: 0 (no spaces)

    Example: -StartSpaces 4  # Four spaces before text

    .PARAMETER AutoPad
    Specifies the target display width for Unicode-aware text padding.
    Text is automatically padded to this width using Measure-DisplayWidth for accurate character-width calculation.

    - Correctly handles wide characters (emoji, CJK) that occupy 2 terminal cells
    - Correctly handles zero-width characters (combining marks)
    - Uses PadChar for padding (default: space)
    - Uses PadLeft switch to control padding direction (default: pad right for left-align)

    If text display width already equals or exceeds AutoPad width, no padding is applied (no truncation).
    Set to 0 to disable padding.

    Default: 0 (disabled)
    Aliases: PadWidth, Pad

    Example: -AutoPad 20  # Pad text to 20 cells width
    Example: 'Server ●' -AutoPad 21  # Correctly pads accounting for ● = 2 cells

    .PARAMETER PadLeft
    When AutoPad is enabled, pads on the left side of text (right-align) instead of right side (left-align).
    Only active when AutoPad is greater than 0.

    Default: $false (pad right, left-align text)
    Alias: RightAlign

    Example: -AutoPad 20 -PadLeft  # Right-align text within 20 cells

    .PARAMETER PadChar
    Specifies the character to use for padding when AutoPad is enabled.
    Can be any single character. Wide characters (2+ cells) generate a warning as they may cause alignment issues.
    Zero-width characters are rejected and replaced with space.

    Default: ' ' (space)
    Aliases: PaddingChar, FillChar

    Example: -PadChar '.'  # Pad with dots (table of contents style)
    Example: -PadChar '-'  # Pad with dashes (separator style)

    .PARAMETER LogFile
    Specifies the path or filename for log output.
    If only a filename is provided, uses LogPath for the directory.
    If a full path is provided, LogPath is ignored.

    File extension defaults to .log if not specified.
    If log file is locked, retries up to LogRetry times.

    Default: '' (no logging)
    Alias: L

    Example: -LogFile 'application.log'
    Example: -LogFile 'C:\Logs\app.log'

    .PARAMETER LogPath
    Specifies the directory path for log files when LogFile contains only a filename.
    If LogFile contains a full path, LogPath is ignored.

    Default: Current script directory ($PSScriptRoot) or current working directory ($PWD.Path)
    Alias: LP

    Example: -LogPath 'C:\Logs'

    .PARAMETER LogLevel
    Specifies the log level string to include in log file entries.
    Typically used for categorizing log entries: ERROR, WARNING, INFO, DEBUG, etc.

    When specified, appears in log file as [LOGLEVEL] prefix before text.

    Default: '' (no log level)
    Aliases: LL, LogLvl

    Example: -LogLevel 'ERROR'
    Example: -LogLevel 'INFO'

    .PARAMETER LogTime
    Includes a timestamp in log file entries.
    Timestamp format is controlled by DateTimeFormat parameter.

    When enabled, timestamp appears before log level and text.

    Default: $false (no timestamp)
    Alias: LT

    .PARAMETER DateTimeFormat
    Specifies the custom format string for timestamps in log files.
    Uses .NET DateTime format strings.

    Only applies when LogTime is enabled.

    Default: 'yyyy-MM-dd HH:mm:ss'
    Aliases: DateFormat, TimeFormat, Timestamp, TS

    Example: -DateTimeFormat 'yyyy-MM-dd HH:mm:ss.fff'  # Include milliseconds
    Example: -DateTimeFormat 'MM/dd/yyyy hh:mm:ss tt'  # US format with AM/PM

    .PARAMETER LogRetry
    Specifies the number of retry attempts when log file is locked.
    Useful in multi-threaded scenarios where log file may be temporarily unavailable.

    Waits 50ms between retries.

    Default: 2 retries

    Example: -LogRetry 5  # Retry up to 5 times

    .PARAMETER Encoding
    Specifies the character encoding for log files.

    Valid values: unknown, string, unicode, bigendianunicode, utf8, utf7, utf32, ascii, default, oem

    Default: Unicode

    Example: -Encoding 'utf8'

    .PARAMETER ShowTime
    Displays a timestamp before the console output.
    Uses DateTimeFormat parameter for the timestamp format.

    Default: $false (no console timestamp)

    .PARAMETER NoNewLine
    Suppresses the newline character at the end of the output.
    Useful for building output across multiple Write-ColorEX calls on the same line.

    Default: $false (includes newline)

    Example: Write-ColorEX 'Name: ' -NoNewLine; Write-ColorEX 'John' -Color Green

    .PARAMETER HorizontalCenter
    Centers the text horizontally within the console window width.
    Uses Unicode-aware display width calculation for accurate centering with emoji and CJK characters.

    Centering is calculated based on total text width after padding (if AutoPad is used).

    Default: $false (no centering)
    Alias: Center

    Example: -HorizontalCenter  # Center text in console

    .PARAMETER BlankLine
    Outputs a blank line spanning the full width of the console window.
    Can be combined with BackGroundColor to create colored horizontal rules.

    Default: $false (normal text output)
    Aliases: BL, Empty, Blank

    Example: -BlankLine -BackGroundColor 'DarkBlue'  # Blue horizontal line

    .PARAMETER NoConsoleOutput
    Suppresses console output and only writes to log file (if LogFile is specified).
    Useful for silent logging scenarios.

    Default: $false (output to console)
    Aliases: HideConsole, NoConsole, LogOnly, LO

    Example: -NoConsoleOutput -LogFile 'app.log'  # Log-only mode

    .PARAMETER Debugging
    Enables verbose debug output for troubleshooting.
    Shows detailed information about color processing, ANSI support detection, and internal operations.

    Debug messages are output via Write-Verbose -Verbose and appear as [DEBUG] prefix.

    Default: $false (no debug output)

    .PARAMETER Silent
    Suppresses warning messages about color validation, terminal capability limitations, and fallback behavior.

    Useful when you expect warnings (e.g., requesting TrueColor in a 256-color terminal) and don't want them displayed.

    Default: $false (warnings enabled)

    .INPUTS
    System.String[]
    You can pipe an array of strings to Write-ColorEX via the Text parameter.

    .OUTPUTS
    None
    Write-ColorEX does not generate pipeline output. It writes directly to the console and optionally to log files.

    .EXAMPLE
    Write-ColorEX -Text 'Hello World' -Color Green

    Displays "Hello World" in green using native PowerShell colors.

    .EXAMPLE
    Write-ColorEX -Text 'Error: ', 'File not found' -Color Red, Yellow -Bold

    Displays "Error: " in red and "File not found" in yellow, both bold.

    .EXAMPLE
    Write-ColorEX -Text 'Server Status' -Color '#00FF80' -TrueColor -Bold

    Displays "Server Status" in a custom TrueColor green (#00FF80) with bold styling.

    .EXAMPLE
    Write-ColorEX -Text 'RGB Color' -Color @(255, 128, 0) -TrueColor

    Displays "RGB Color" in orange using RGB values (255, 128, 0).

    .EXAMPLE
    Write-ColorEX -Text 'RAINBOW' -Gradient @('Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta')

    Displays "RAINBOW" with a smooth 7-color gradient, each character interpolated between gradient waypoints.

    .EXAMPLE
    Write-ColorEX -Text 'Test' -AutoPad 20 -Color Cyan -NoNewLine
    Write-Host '|'

    Displays "Test" padded to 20 cells width (left-aligned) in cyan, followed by "|" on the same line.
    Output: "Test                |"

    .EXAMPLE
    Write-ColorEX -Text 'Server ●' -AutoPad 21 -Color White

    Displays "Server ●" padded to 21 cells, correctly accounting for ● taking 2 terminal cells.
    Output: "Server ●             " (13 spaces added: 21 - 9 where 9 = 7 chars + 2 for ●)

    .EXAMPLE
    Write-ColorEX -Text 'CPU: 45%' -AutoPad 20 -PadLeft -Color Yellow

    Right-aligns "CPU: 45%" within 20 cells by padding on the left.
    Output: "            CPU: 45%" (12 spaces before text)

    .EXAMPLE
    Write-ColorEX -Text 'Total' -AutoPad 20 -PadChar '.' -Color White

    Pads "Total" to 20 cells using dots instead of spaces.
    Output: "Total..............."

    .EXAMPLE
    Write-ColorEX '║ ' -Color Cyan -NoNewLine
    Write-ColorEX 'Web Server' -AutoPad 21 -Color White -NoNewLine
    Write-ColorEX ' [OK] ║' -Color Green

    Creates a status dashboard row with Unicode box-drawing, properly aligned with AutoPad.
    Output: "║ Web Server           [OK] ║"

    .EXAMPLE
    Write-ColorError 'Operation failed'

    Uses the built-in Error style profile (red, bold).

    .EXAMPLE
    Set-ColorDefault -ForegroundColor Cyan -Bold
    Write-ColorEX -Text 'This uses default style' -Default

    Applies the default style configured via Set-ColorDefault.

    .EXAMPLE
    $style = New-ColorStyle -Name 'Header' -ForegroundColor Cyan -Bold -Underline -HorizontalCenter
    Write-ColorEX -Text 'SECTION HEADER' -StyleProfile $style

    Creates a custom style profile and applies it to centered, bold, underlined cyan text.

    .EXAMPLE
    Write-ColorEX -Text 'Log Entry' -LogFile 'app.log' -LogTime -LogLevel 'INFO'

    Displays "Log Entry" on console and writes to app.log with timestamp and INFO level.
    Log entry: "2025-01-02 14:30:45 [INFO] Log Entry"

    .EXAMPLE
    Write-ColorEX -Text 'Silent logging' -LogFile 'app.log' -NoConsoleOutput

    Writes to log file only, no console output.

    .EXAMPLE
    Write-ColorEX -Text 'Title' -Color White -BackGroundColor DarkBlue -Bold -HorizontalCenter -LinesBefore 1 -LinesAfter 1

    Displays centered white text on dark blue background with bold styling, surrounded by blank lines.

    .EXAMPLE
    Write-ColorEX -BlankLine -BackGroundColor DarkGray

    Creates a horizontal rule by outputting a blank line with dark gray background across full console width.

    .EXAMPLE
    foreach ($file in $files) {
        Write-ColorEX $file.Name -AutoPad 40 -NoNewLine
        Write-ColorEX $file.Length -AutoPad 12 -PadLeft -Color Cyan -NoNewLine
        Write-ColorEX ' bytes' -Color Gray
    }

    Creates a file listing table with left-aligned names and right-aligned sizes using AutoPad.

    .NOTES
    Name: Write-ColorEX
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    For full Unicode support in PowerShell 5.1, scripts must be saved with UTF-8 BOM encoding.
    PowerShell 7+ supports UTF-8 without BOM.

    Terminal ANSI support is automatically detected using Test-AnsiSupport.
    Colors gracefully degrade if requested mode is not supported by terminal.

    Performance optimizations:
    - Cached color table (~1000x faster repeated color lookups)
    - Cached ANSI support detection (runs once per module load)
    - List-based array building instead of += operator (18000x faster for large arrays)
    - Cached Get-Command results (10-100x faster)
    - PSColorStyle caching for ToWriteColorParams (36x faster)

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Test-AnsiSupport

    .LINK
    New-ColorStyle

    .LINK
    Set-ColorDefault

    .LINK
    Measure-DisplayWidth
    #>
    [CmdletBinding()]
    [Alias('Write-ColourEX', 'Write-Color', 'Write-Colour', 'WC', 'WCEX', 'wcolor', 'wcolour')]
    param (
        [alias ('T')][string[]] $Text,
        [ValidateScript({
            # Allow strings, integers, arrays of strings/integers, or arrays of arrays (for RGB)
            if ($_ -is [string] -or $_ -is [int]) { return $true }
            if ($_ -is [array]) {
                # Check if it's a flat array or array of arrays
                foreach ($item in $_) {
                    if ($item -isnot [string] -and $item -isnot [int] -and $item -isnot [array]) {
                        return $false
                    }
                }
                return $true
            }
            return $false
        })][alias ('C', 'ForegroundColor', 'FGC')][array] $Color = $null,
        [ValidateScript({
            # Allow strings, integers, arrays of strings/integers, or arrays of arrays (for RGB)
            if ($_ -is [string] -or $_ -is [int]) { return $true }
            if ($_ -is [array]) {
                # Check if it's a flat array or array of arrays
                foreach ($item in $_) {
                    if ($item -isnot [string] -and $item -isnot [int] -and $item -isnot [array]) {
                        return $false
                    }
                }
                return $true
            }
            return $false
        })][alias ('B', 'BGC')][array] $BackGroundColor = $null,
        [AllowNull()]
        [alias ('Grad')][object[]] $Gradient = $null,
        [alias ('A4')][switch] $ANSI4,
        [alias ('A8')][switch] $ANSI8,
        [alias ('A24','TrueColor','TC')][switch] $ANSI24,
        [ValidateScript({$_ -is [string] -or $_ -is [int] -or $_ -is [int[]] -or $_ -is [string[]] -or $_ -is [object[]]})][alias ('S')][object] $Style = $null,
        [PSColorStyle] $StyleProfile = $null,
        [switch] $Default,
        [switch] $Bold,
        [switch] $Faint,
        [switch] $Italic,
        [switch] $Underline,
        [switch] $Blink,
        [alias ('Strikethrough')][switch] $CrossedOut,
        [switch] $DoubleUnderline,
        [switch] $Overline,
        [alias ('Indent')][int] $StartTab = 0,
        [int] $LinesBefore = 0,
        [int] $LinesAfter = 0,
        [int] $StartSpaces = 0,
        [alias ('L')][string] $LogFile = '',
        [alias ('LP')][string] $LogPath = $(If ($PSScriptRoot) {$PSScriptRoot} Else {$PWD.Path}),
        [alias ('LL', 'LogLvl')][string] $LogLevel = '',
        [alias ('LT')][switch] $LogTime,
        [Alias('DateFormat', 'TimeFormat', 'Timestamp', 'TS')][string] $DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [int] $LogRetry = 2,
        [ValidateSet('unknown', 'string', 'unicode', 'bigendianunicode', 'utf8', 'utf7', 'utf32', 'ascii', 'default', 'oem')][string]$Encoding = 'Unicode',
        [switch] $ShowTime,
        [switch] $NoNewLine,
        [alias('Center')][switch] $HorizontalCenter,
        [alias ('BL', 'Empty', 'Blank')][switch] $BlankLine,
        [alias('HideConsole', 'NoConsole', 'LogOnly', 'LO')][switch] $NoConsoleOutput,
        [switch] $Debugging,
        [switch] $Silent,
        [alias('PadWidth', 'Pad')][int] $AutoPad = 0,
        [alias('RightAlign')][switch] $PadLeft,
        [alias('PaddingChar', 'FillChar')][char] $PadChar = ' '
    )

    # Debug logging helper
    function Write-DebugLog {
        param([string]$Message)
        if ($Debugging) {
            Write-Verbose "[DEBUG] $Message" -Verbose
        }
    }

    # Warning helper that respects Silent parameter
    function Write-ColorWarningMsg {
        param([string]$Message)
        if (-not $Silent) {
            Write-Warning $Message
        }
    }

    # Helper function to convert ANSI4 color codes to native PowerShell color names
    function ConvertANSI4ToNativeColor {
        param([int]$Code)

        switch ($Code) {
            30 { return 'Black' }
            31 { return 'DarkRed' }
            32 { return 'DarkGreen' }
            33 { return 'DarkYellow' }
            34 { return 'DarkBlue' }
            35 { return 'DarkMagenta' }
            36 { return 'DarkCyan' }
            37 { return 'Gray' }
            90 { return 'DarkGray' }
            91 { return 'Red' }
            92 { return 'Green' }
            93 { return 'Yellow' }
            94 { return 'Blue' }
            95 { return 'Magenta' }
            96 { return 'Cyan' }
            97 { return 'White' }
            default { return 'Gray' }
        }
    }

    Write-DebugLog "Starting Write-ColorEX with Text count: $($Text.Count)"

    # Validate Gradient parameter
    If ($Gradient -and $Gradient.Count -lt 2) {
        Write-ColorWarningMsg "Gradient requires at least 2 colors (received $($Gradient.Count)). Gradient disabled."
        Write-DebugLog "Gradient validation failed: Only $($Gradient.Count) color(s) provided"
        $Gradient = $null
    }

    # Safeguard against multiple color mode switches
    $colorModeCount = 0
    if ($ANSI4) { $colorModeCount++ }
    if ($ANSI8) { $colorModeCount++ }
    if ($ANSI24) { $colorModeCount++ }
    
    if ($colorModeCount -gt 1) {
        Write-Warning "Multiple color modes specified. Only one of -ANSI4, -ANSI8, or -TrueColor should be used."
        # Priority: TrueColor > ANSI8 > ANSI4
        if ($ANSI24) {
            Write-DebugLog "Using TrueColor mode (highest priority)"
            $ANSI4 = $False
            $ANSI8 = $False
        } elseif ($ANSI8) {
            Write-DebugLog "Using ANSI8 mode"
            $ANSI4 = $False
            $ANSI24 = $False
        } else {
            Write-DebugLog "Using ANSI4 mode"
            $ANSI8 = $False
            $ANSI24 = $False
        }
    }

    # Apply style profile if specified
    if ($StyleProfile) {
        Write-DebugLog "Applying style profile: $($StyleProfile.Name)"
        $profileParams = $StyleProfile.ToWriteColorParams()
        foreach ($key in $profileParams.Keys) {
            if (-not $PSBoundParameters.ContainsKey($key)) {
                Set-Variable -Name $key -Value $profileParams[$key]
            }
        }
    }

    # Apply default style if specified
    if ($Default -and [PSColorStyle]::Default) {
        Write-DebugLog "Applying default style profile"
        $defaultParams = [PSColorStyle]::Default.ToWriteColorParams()
        foreach ($key in $defaultParams.Keys) {
            if (-not $PSBoundParameters.ContainsKey($key) -and -not $StyleProfile) {
                Set-Variable -Name $key -Value $defaultParams[$key]
            }
        }
    }

    # Store original color mode intent before any fallback occurs (for validation)
    $OriginalTrueColor = $ANSI24.IsPresent
    $OriginalANSI8 = $ANSI8.IsPresent
    $OriginalANSI4 = $ANSI4.IsPresent

    # Fix: If Color appears to be a flattened RGB array (3 consecutive integers with TrueColor mode), wrap it
    if ($OriginalTrueColor -and $Color -and $Color.Count -eq 3 -and
        $Color[0] -is [int] -and $Color[1] -is [int] -and $Color[2] -is [int] -and
        $Text.Count -eq 1) {
        Write-DebugLog "Detected flattened RGB array, wrapping: @($($Color[0]),$($Color[1]),$($Color[2]))"
        $Color = ,@($Color[0], $Color[1], $Color[2])  # Wrap in comma operator to create array of array
    }

    # Same fix for BackgroundColor
    if ($OriginalTrueColor -and $BackGroundColor -and $BackGroundColor.Count -eq 3 -and
        $BackGroundColor[0] -is [int] -and $BackGroundColor[1] -is [int] -and $BackGroundColor[2] -is [int] -and
        $Text.Count -eq 1) {
        Write-DebugLog "Detected flattened RGB array for background, wrapping: @($($BackGroundColor[0]),$($BackGroundColor[1]),$($BackGroundColor[2]))"
        $BackGroundColor = ,@($BackGroundColor[0], $BackGroundColor[1], $BackGroundColor[2])
    }

    # Apply AutoPad - Unicode-aware text padding (must happen before fast path check)
    if ($AutoPad -gt 0) {
        Write-DebugLog "AutoPad processing: Target width = $AutoPad, PadLeft = $PadLeft, PadChar = '$PadChar'"

        # Step 1: Validate PadChar
        $padCharWidth = Measure-DisplayWidth -Text $PadChar.ToString()

        if ($padCharWidth -eq 0) {
            # Zero-width characters cannot be used for padding
            Write-ColorWarningMsg "PadChar '$PadChar' is a zero-width character and cannot be used for padding. Using space instead."
            $PadChar = ' '
            $padCharWidth = 1
        }

        if ($padCharWidth -gt 1) {
            # Warn about wide characters (may cause alignment issues)
            Write-ColorWarningMsg "PadChar '$PadChar' is a wide character ($padCharWidth cells). Padding alignment may be off."
        }

        # Step 2: Calculate current display width
        $combinedText = $Text -join ''
        $currentWidth = Measure-DisplayWidth -Text $combinedText

        Write-DebugLog "Current text display width: $currentWidth cells"

        # Step 3: Calculate padding needed
        if ($currentWidth -lt $AutoPad) {
            $paddingCellsNeeded = $AutoPad - $currentWidth

            # Calculate number of padding characters
            if ($padCharWidth -gt 1) {
                # For wide characters, calculate how many fit
                $padCount = [Math]::Floor($paddingCellsNeeded / $padCharWidth)
                $remainder = $paddingCellsNeeded % $padCharWidth

                if ($remainder -ne 0) {
                    Write-DebugLog "Padding width ($paddingCellsNeeded cells) not evenly divisible by PadChar width ($padCharWidth cells). Off by $remainder cell(s)."
                }
            } else {
                # Single-width character (normal case)
                $padCount = $paddingCellsNeeded
            }

            # Step 4: Generate padding string
            if ($padCount -gt 0) {
                $paddingString = $PadChar.ToString() * $padCount

                Write-DebugLog "Adding $padCount '$PadChar' character(s) = $($padCount * $padCharWidth) cells"

                # Step 5: Apply padding
                if ($PadLeft) {
                    # Right-align: prepend padding to text
                    $Text = @($paddingString) + $Text
                    Write-DebugLog "Applied left padding (right-aligned text)"
                } else {
                    # Left-align: append padding to text
                    $Text = $Text + @($paddingString)
                    Write-DebugLog "Applied right padding (left-aligned text)"
                }
            }
        } else {
            Write-DebugLog "Text width ($currentWidth) >= Target width ($AutoPad). No padding applied."
        }
    }

    # Early fast path check: If not using any ANSI features, skip expensive ANSI detection
    $UsingANSIFeatures = $ANSI4 -or $ANSI8 -or $ANSI24 -or $Bold -or $Italic -or $Underline -or
                         $Blink -or $Faint -or $CrossedOut -or $DoubleUnderline -or $Overline -or $Style

    If (-not $UsingANSIFeatures -and -not $NoConsoleOutput) {
        Write-DebugLog "Fast path detected: No ANSI features used, skipping ANSI detection"
        $ANSISupport = $False
        $ANSIColorSupport = 'None'
        # Skip ANSI detection entirely and jump to logging/output section
    } Else {
        # Check FORCE_COLOR first (it can change dynamically), then use cache
        if ($env:FORCE_COLOR) {
            Write-DebugLog "FORCE_COLOR environment variable detected: $($env:FORCE_COLOR)"
            switch ($env:FORCE_COLOR) {
                '0' { $ANSIColorSupport = 'None' }
                '1' { $ANSIColorSupport = 'ANSI4' }
                '2' { $ANSIColorSupport = 'ANSI8' }
                '3' { $ANSIColorSupport = 'TrueColor' }
                default { $ANSIColorSupport = $script:CachedANSISupport }
            }
            Write-DebugLog "FORCE_COLOR override: $ANSIColorSupport"
        } elseif ($env:NO_COLOR) {
            Write-DebugLog "NO_COLOR environment variable detected"
            $ANSIColorSupport = 'None'
        } else {
            # Use cached ANSI support level for performance (cached in module initialization)
            if ($null -eq $script:CachedANSISupport) {
                # Fallback: detect if cache not available (shouldn't happen normally)
                $script:CachedANSISupport = Test-AnsiSupport -Silent
            }
            $ANSIColorSupport = $script:CachedANSISupport
            Write-DebugLog "ANSI Color Support: $ANSIColorSupport (cached)"
        }
    $ANSISupport = $ANSIColorSupport -ne 'None'
    
    # Auto-select best color mode if not specified
    if (-not $ANSI4 -and -not $ANSI8 -and -not $ANSI24) {
        if ($ANSIColorSupport -eq 'TrueColor') {
            $AutoMode = 'TrueColor'
        } elseif ($ANSIColorSupport -eq 'ANSI8') {
            $AutoMode = 'ANSI8'
        } elseif ($ANSIColorSupport -eq 'ANSI4') {
            $AutoMode = 'ANSI4'
        } else {
            $AutoMode = 'Native'
        }
        Write-DebugLog "Auto-selected color mode: $AutoMode"
    }
    
    # Adjust ANSI mode based on detected support
    If ($ANSIColorSupport -eq 'None') {
        $Style = @()
        $ANSI4 = $False
        $ANSI8 = $False
        $ANSI24 = $False
        Write-DebugLog "ANSI support disabled - using native PowerShell colors"
    } ElseIf ($ANSI24 -and $ANSIColorSupport -ne 'TrueColor') {
        # Downgrade from TrueColor
        if ($ANSIColorSupport -eq 'ANSI8') {
            Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to ANSI8 (256 colors)."
            Write-DebugLog "Downgrading from TrueColor to ANSI8"
            $ANSI24 = $False
            $ANSI8 = $True
        } elseif ($ANSIColorSupport -eq 'ANSI4') {
            Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to ANSI4 (16 colors)."
            Write-DebugLog "Downgrading from TrueColor to ANSI4"
            $ANSI24 = $False
            $ANSI4 = $True
        } else {
            Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to native PowerShell colors."
            Write-DebugLog "Downgrading from TrueColor to Native"
            $ANSI24 = $False
        }
    } ElseIf ($ANSI8 -and $ANSIColorSupport -eq 'ANSI4') {
        # Downgrade from ANSI8 to ANSI4
        Write-ColorWarningMsg "ANSI8 (256 colors) not supported by terminal. Falling back to ANSI4 (16 colors)."
        Write-DebugLog "Downgrading from ANSI8 to ANSI4"
        $ANSI8 = $False
        $ANSI4 = $True
    }

    # Validate and configure gradient support
    If ($Gradient -and $Gradient.Count -ge 2) {
        Write-DebugLog "Gradient requested with $($Gradient.Count) colors"

        # Gradient requires ANSI8 or TrueColor support
        If ($ANSIColorSupport -eq 'None') {
            Write-ColorWarningMsg "Gradient requires ANSI 256-color or TrueColor support. Terminal supports: None. Gradient disabled."
            Write-DebugLog "Gradient disabled: No ANSI support"
            $Gradient = $null
        } ElseIf ($ANSIColorSupport -eq 'ANSI4') {
            Write-ColorWarningMsg "Gradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). Gradient disabled."
            Write-DebugLog "Gradient disabled: ANSI4 only"
            $Gradient = $null
        } Else {
            # Auto-enable appropriate color mode if not explicitly set
            If (-not $ANSI8 -and -not $ANSI24) {
                If ($ANSIColorSupport -eq 'TrueColor') {
                    Write-DebugLog "Gradient: Auto-enabling TrueColor mode"
                    $ANSI24 = $True
                } ElseIf ($ANSIColorSupport -eq 'ANSI8') {
                    Write-DebugLog "Gradient: Auto-enabling ANSI8 mode"
                    $ANSI8 = $True
                }
            }
            Write-DebugLog "Gradient enabled in $ANSIColorSupport mode"
        }
    }

        # Cache command availability checks for performance (avoid repeated Get-Command calls)
        if ($TrueColor -or $ANSI8 -or $ANSI4 -or
            ($Color -and ($Color | Where-Object { $_ -is [array] -or ($_ -is [string] -and $_ -match '^#|^0x') }))) {

            Write-DebugLog "Caching color conversion function availability"

            # Check once, use many times
            $script:HasConvertHexToRGB = $null -ne (Get-Command Convert-HexToRGB -ErrorAction SilentlyContinue)
            $script:HasConvertRGBToANSI8 = $null -ne (Get-Command Convert-RGBToANSI8 -ErrorAction SilentlyContinue)
            $script:HasConvertRGBToANSI4 = $null -ne (Get-Command Convert-RGBToANSI4 -ErrorAction SilentlyContinue)
            $script:HasGetColorTableWithRGB = $null -ne (Get-Command Get-ColorTableWithRGB -ErrorAction SilentlyContinue)

            Write-DebugLog "Command availability cached - HexToRGB: $script:HasConvertHexToRGB, RGBToANSI8: $script:HasConvertRGBToANSI8, RGBToANSI4: $script:HasConvertRGBToANSI4"
        }
    }
    # End of ANSI detection block

    # If we are not writing to console, skip console-related sections
    If (-not $NoConsoleOutput) {
        # ESC sequences to initiate ANSI styling
        $esc = [char]27

        # Hashtable of ANSI styles
        $ANSI = @{
            'Reset' = "$esc[0m"
            'Bold' = "$esc[1m"
            'Faint' = "$esc[2m"
            'Italic' = "$esc[3m"
            'Underline' = "$esc[4m"
            'Blink' = "$esc[5m"
            'CrossedOut' = "$esc[9m"
            'DoubleUnderline' = "$esc[21m"
            'Overline' = "$esc[53m"
            'None' = ""
        }

        # Get color table with RGB values (cached for performance)
        if ($null -eq $script:CachedColorTable) {
            Write-DebugLog "Initializing color table cache"
            if ($script:HasGetColorTableWithRGB) {
                $script:CachedColorTable = Get-ColorTableWithRGB
            } else {
                # Fallback to basic color table if function not available
                $script:CachedColorTable = @{
                    Black = @('Black', 30, 40, 0, @(0, 0, 0))
                    Red = @('Red', 31, 41, 1, @(255, 0, 0))
                    Green = @('Green', 32, 42, 2, @(0, 255, 0))
                    Yellow = @('Yellow', 33, 43, 220, @(255, 255, 0))
                    Blue = @('Blue', 34, 44, 4, @(0, 0, 255))
                    Magenta = @('Magenta', 35, 45, 5, @(255, 0, 255))
                    Cyan = @('Cyan', 36, 46, 6, @(0, 255, 255))
                    Gray = @('Gray', 37, 47, 7, @(192, 192, 192))
                    White = @('White', 97, 107, 15, @(255, 255, 255))
                    DarkGray = @('DarkGray', 90, 100, 8, @(128, 128, 128))
                    DarkRed = @('DarkRed', 31, 41, 52, @(139, 0, 0))
                    DarkGreen = @('DarkGreen', 32, 42, 28, @(0, 100, 0))
                    DarkYellow = @('DarkYellow', 33, 43, 136, @(204, 204, 0))
                    DarkBlue = @('DarkBlue', 34, 44, 19, @(0, 0, 139))
                    DarkMagenta = @('DarkMagenta', 35, 45, 53, @(139, 0, 139))
                    DarkCyan = @('DarkCyan', 36, 46, 30, @(0, 139, 139))
                }
            }
            Write-DebugLog "Color table cache initialized with $($script:CachedColorTable.Count) colors"
        }

        $Colors = $script:CachedColorTable
        Write-DebugLog "Using cached color table with $($Colors.Count) colors"

        # Process blank line if requested
        If ($BlankLine) {
            Write-DebugLog "Processing blank line"
            $HorizontalCenter = $False
            $StartTab = 0
            $StartSpaces = 0
            $ShowTime = $False
            $WindowWidth = $Host.UI.RawUI.BufferSize.Width
            $Text = [string[]]@(' ' * $WindowWidth)
        }

        # Process gradient if enabled
        If ($Gradient -and $Gradient.Count -ge 2) {
            Write-DebugLog "Calculating gradient for text"

            # Calculate total character count across all segments
            $totalChars = 0
            foreach ($segment in $Text) {
                $totalChars += $segment.Length
            }
            Write-DebugLog "Total characters for gradient: $totalChars"

            # Validate: gradient colors should not exceed character count
            if ($Gradient.Count -gt $totalChars) {
                Write-ColorWarningMsg "Gradient has $($Gradient.Count) colors but text only has $totalChars characters. Applying standard coloring instead."
                Write-DebugLog "Gradient disabled: More colors ($($Gradient.Count)) than characters ($totalChars)"
                $Gradient = $null
            } else {
                # Generate gradient color array
                $gradientMode = if ($ANSI24) { 'TrueColor' } else { 'ANSI8' }
                Write-DebugLog "Generating gradient in $gradientMode mode"

                # Call New-GradientColorArray function
                $gradientArray = New-GradientColorArray -Colors $Gradient -Steps $totalChars -Mode $gradientMode

                if ($gradientArray) {
                    Write-DebugLog "Gradient array generated with $($gradientArray.Count) colors"
                } else {
                    Write-DebugLog "Gradient array generation failed"
                    $Gradient = $null  # Disable gradient if generation failed
                }
            }
        }

        # Process and validate colors
        If ($Color) {
            Write-DebugLog "Processing $($Color.Count) colors"
            $ProcessedColors = [System.Collections.Generic.List[object]]::new()

            For ($i = 0; $i -lt $Text.Length; $i++) {
                $colorIndex = $i % $Color.Count
                $currentColor = $Color[$colorIndex]

                Write-DebugLog "Processing color at index $($i): $currentColor (type: $($currentColor.GetType().Name))"

                # Validate based on ORIGINAL user intent before fallback
                if ($OriginalTrueColor) {
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Validate RGB ranges (0-255)
                        $r = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[0]))
                        $g = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[1]))
                        $b = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[2]))

                        if ($r -ne $currentColor[0] -or $g -ne $currentColor[1] -or $b -ne $currentColor[2]) {
                            Write-ColorWarningMsg "RGB values out of range (0-255). Original: @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])). Clamped to: @($r,$g,$b)"
                            $currentColor = @($r, $g, $b)
                        }
                    } elseif ($currentColor -is [int]) {
                        # Type mismatch: integer code provided for TrueColor mode
                        Write-ColorWarningMsg "TrueColor mode expects RGB array @(R,G,B) or hex color, but received integer code $currentColor. Use -ANSI8 or -ANSI4 for integer codes."
                        Write-DebugLog "Type mismatch: integer $currentColor provided for TrueColor"
                    }
                } elseif ($OriginalANSI8) {
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Type mismatch: RGB array provided for ANSI8 mode
                        Write-ColorWarningMsg "ANSI8 mode expects integer code (0-255) or color name, but received RGB array. Use -TrueColor for RGB arrays."
                        Write-DebugLog "Type mismatch: RGB array provided for ANSI8"
                    } elseif ($currentColor -is [int]) {
                        # Validate ANSI8 range (0-255)
                        if ($currentColor -lt 0 -or $currentColor -gt 255) {
                            Write-ColorWarningMsg "ANSI8 color code $currentColor is out of range (0-255). Using Gray (7)."
                            $currentColor = 7  # Gray
                        }
                    }
                }

                # Auto-lighten colors if Bold is used but terminal doesn't support bold fonts
                if ($Bold -and -not $script:SupportsBoldFonts) {
                    Write-DebugLog "Bold enabled but terminal doesn't support bold fonts - auto-lightening color"

                    # Lighten based on color type
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # RGB array - multiply by lightening factor
                        $currentColor = Lighten-RGBColor -RGB $currentColor
                        Write-DebugLog "RGB color lightened to: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])"
                    } elseif ($currentColor -is [int]) {
                        # ANSI8/ANSI4 integer code - use algorithmic lightening for ANSI8
                        # For ANSI4, we let the terminal handle it (bold SGR code auto-brightens)
                        if ($ANSI8 -and $currentColor -ge 0 -and $currentColor -le 255) {
                            # Use new algorithmic lightening for ANSI8 codes
                            $originalCode = $currentColor
                            $currentColor = Lighten-ANSI8Color -ANSI8Code $currentColor
                            Write-DebugLog "ANSI8 code $originalCode algorithmically lightened to $currentColor"
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x') {
                        # Named color - shift Dark→Normal→Light
                        $lightenedName = Lighten-ColorName -ColorName $currentColor
                        if ($lightenedName -ne $currentColor) {
                            $currentColor = $lightenedName
                            Write-DebugLog "Color name lightened from $($Color[$colorIndex]) to $currentColor"
                        } else {
                            # Color name didn't change (already Light* or can't lighten further)
                            # For ANSI8/ANSI24 modes, convert to color code and apply algorithmic lightening
                            if ($ANSI8 -and $Colors.ContainsKey($currentColor)) {
                                $ansi8Code = $Colors[$currentColor][3]
                                $lightenedCode = Lighten-ANSI8Color -ANSI8Code $ansi8Code
                                $currentColor = $lightenedCode
                                Write-DebugLog "Color name $($Color[$colorIndex]) algorithmically lightened in ANSI8 from code $ansi8Code to $lightenedCode"
                            } elseif ($ANSI24 -and $Colors.ContainsKey($currentColor)) {
                                $rgb = $Colors[$currentColor][4]
                                $lightenedRGB = Lighten-RGBColor -RGB $rgb
                                $currentColor = $lightenedRGB
                                Write-DebugLog "Color name $($Color[$colorIndex]) algorithmically lightened in ANSI24 from RGB to R=$($lightenedRGB[0]) G=$($lightenedRGB[1]) B=$($lightenedRGB[2])"
                            }
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex color - convert to RGB, lighten, keep as RGB for later processing
                        if ($script:HasConvertHexToRGB) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $currentColor = Lighten-RGBColor -RGB $rgb
                            Write-DebugLog "Hex color $($Color[$colorIndex]) converted to RGB and lightened"
                        }
                    }
                }

                # Process and convert colors based on active mode (after fallback)
                if ($ANSI24) {
                    # TrueColor mode active - keep RGB arrays
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # RGB array format (already validated above or lightened)
                        $null = $ProcessedColors.Add($currentColor)
                        Write-DebugLog "RGB array color: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])"
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex format - convert to RGB
                        if ($script:HasConvertHexToRGB) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $null = $ProcessedColors.Add($rgb)
                            Write-DebugLog "Hex color $currentColor converted to RGB: R=$($rgb[0]) G=$($rgb[1]) B=$($rgb[2])"
                        } else {
                            $null = $ProcessedColors.Add(@(192, 192, 192)) # Default gray
                        }
                    } elseif ($currentColor -is [string]) {
                        # Named color - get RGB from table
                        $colorEntry = $Colors[$currentColor]
                        if ($colorEntry) {
                            $null = $ProcessedColors.Add($colorEntry[4])
                            Write-DebugLog "Named color $currentColor mapped to RGB"
                        } else {
                            $null = $ProcessedColors.Add($currentColor)
                        }
                    } else {
                        # Default or pass-through
                        $null = $ProcessedColors.Add($currentColor)
                    }
                } elseif ($ANSI8 -and $OriginalTrueColor) {
                    # TrueColor fell back to ANSI8 - convert RGB to ANSI8
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Convert RGB array to nearest ANSI8 code
                        if ($script:HasConvertRGBToANSI8) {
                            $ansi8Code = Convert-RGBToANSI8 -RGB $currentColor
                            $null = $ProcessedColors.Add($ansi8Code)
                            Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI8: $ansi8Code"
                        } else {
                            $null = $ProcessedColors.Add(7)  # Default gray
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex format - convert to RGB then to ANSI8
                        if ($script:HasConvertHexToRGB -and $script:HasConvertRGBToANSI8) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $ansi8Code = Convert-RGBToANSI8 -RGB $rgb
                            $null = $ProcessedColors.Add($ansi8Code)
                            Write-DebugLog "Hex $currentColor converted to ANSI8: $ansi8Code"
                        } else {
                            $null = $ProcessedColors.Add(7)  # Default gray
                        }
                    } else {
                        $null = $ProcessedColors.Add($currentColor)
                    }
                } elseif ($ANSI4 -and $OriginalTrueColor) {
                    # TrueColor fell back to ANSI4 - convert RGB to ANSI4
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Convert RGB array to nearest ANSI4 code
                        if ($script:HasConvertRGBToANSI4) {
                            $ansi4Code = Convert-RGBToANSI4 -RGB $currentColor
                            $null = $ProcessedColors.Add($ansi4Code)
                            Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI4: $ansi4Code"
                        } else {
                            $null = $ProcessedColors.Add(37)  # White
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex format - convert to RGB then to ANSI4
                        if ($script:HasConvertHexToRGB -and $script:HasConvertRGBToANSI4) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $ansi4Code = Convert-RGBToANSI4 -RGB $rgb
                            $null = $ProcessedColors.Add($ansi4Code)
                            Write-DebugLog "Hex $currentColor converted to ANSI4: $ansi4Code"
                        } else {
                            $null = $ProcessedColors.Add(37)  # White
                        }
                    } else {
                        $null = $ProcessedColors.Add($currentColor)
                    }
                } elseif (-not $ANSISupport -and $OriginalTrueColor) {
                    # No ANSI support - convert RGB/Hex to nearest native PowerShell color
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Convert RGB to native color name via ANSI4 code
                        if ($script:HasConvertRGBToANSI4) {
                            $ansi4Code = Convert-RGBToANSI4 -RGB $currentColor
                            # Map ANSI4 code to native color name
                            $nativeColor = ConvertANSI4ToNativeColor -Code $ansi4Code
                            $null = $ProcessedColors.Add($nativeColor)
                            Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to Native: $nativeColor"
                        } else {
                            $null = $ProcessedColors.Add('Gray')
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex to RGB to native color name
                        if ($script:HasConvertHexToRGB -and $script:HasConvertRGBToANSI4) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $ansi4Code = Convert-RGBToANSI4 -RGB $rgb
                            # Map ANSI4 code to native color name
                            $nativeColor = ConvertANSI4ToNativeColor -Code $ansi4Code
                            $null = $ProcessedColors.Add($nativeColor)
                            Write-DebugLog "Hex $currentColor converted to Native: $nativeColor"
                        } else {
                            $null = $ProcessedColors.Add('Gray')
                        }
                    } else {
                        $null = $ProcessedColors.Add($currentColor)
                    }
                } else {
                    # No conversion needed
                    $null = $ProcessedColors.Add($currentColor)
                }
            }

            # Convert List to array for compatibility
            $Color = $ProcessedColors.ToArray()
            $DefaultColor = $Color[0]
        } Else {
            $DefaultColor = 'Gray'
        }

        # Similar processing for background colors
        If ($BackGroundColor) {
            Write-DebugLog "Processing $($BackGroundColor.Count) background colors"
            $ProcessedBGColors = [System.Collections.Generic.List[object]]::new()

            For ($i = 0; $i -lt $Text.Length; $i++) {
                $colorIndex = $i % $BackGroundColor.Count
                $currentColor = $BackGroundColor[$colorIndex]

                if ($currentColor -eq "None" -or $null -eq $currentColor) {
                    $null = $ProcessedBGColors.Add($null)
                    continue
                }

                # Validate based on ORIGINAL user intent before fallback
                if ($OriginalTrueColor) {
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Validate RGB ranges (0-255)
                        $r = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[0]))
                        $g = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[1]))
                        $b = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[2]))

                        if ($r -ne $currentColor[0] -or $g -ne $currentColor[1] -or $b -ne $currentColor[2]) {
                            Write-ColorWarningMsg "Background RGB values out of range (0-255). Original: @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])). Clamped to: @($r,$g,$b)"
                            $currentColor = @($r, $g, $b)
                        }
                    } elseif ($currentColor -is [int]) {
                        # Type mismatch: integer code provided for TrueColor mode
                        Write-ColorWarningMsg "TrueColor mode expects RGB array @(R,G,B) or hex color for background, but received integer code $currentColor. Use -ANSI8 or -ANSI4 for integer codes."
                        Write-DebugLog "Type mismatch: integer $currentColor provided for TrueColor background"
                    }
                } elseif ($OriginalANSI8) {
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Type mismatch: RGB array provided for ANSI8 mode
                        Write-ColorWarningMsg "ANSI8 mode expects integer code (0-255) or color name for background, but received RGB array. Use -TrueColor for RGB arrays."
                        Write-DebugLog "Type mismatch: RGB array provided for ANSI8 background"
                    } elseif ($currentColor -is [int]) {
                        # Validate ANSI8 range (0-255)
                        if ($currentColor -lt 0 -or $currentColor -gt 255) {
                            Write-ColorWarningMsg "Background ANSI8 color code $currentColor is out of range (0-255). Using Gray (7)."
                            $currentColor = 7  # Gray
                        }
                    }
                }

                # Auto-lighten background colors if Bold is used but terminal doesn't support bold fonts
                if ($Bold -and -not $script:SupportsBoldFonts) {
                    Write-DebugLog "Bold enabled but terminal doesn't support bold fonts - auto-lightening background color"

                    # Lighten based on color type
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # RGB array - multiply by lightening factor
                        $currentColor = Lighten-RGBColor -RGB $currentColor
                        Write-DebugLog "Background RGB color lightened to: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])"
                    } elseif ($currentColor -is [int]) {
                        # ANSI8 integer code - use algorithmic lightening for ANSI8
                        # For ANSI4, we let the terminal handle it (bold SGR code auto-brightens)
                        if ($ANSI8 -and $currentColor -ge 0 -and $currentColor -le 255) {
                            # Use new algorithmic lightening for ANSI8 codes
                            $originalCode = $currentColor
                            $currentColor = Lighten-ANSI8Color -ANSI8Code $currentColor
                            Write-DebugLog "Background ANSI8 code $originalCode algorithmically lightened to $currentColor"
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x') {
                        # Named color - shift Dark→Normal→Light
                        $lightenedName = Lighten-ColorName -ColorName $currentColor
                        if ($lightenedName -ne $currentColor) {
                            $currentColor = $lightenedName
                            Write-DebugLog "Background color name lightened from $($BackGroundColor[$colorIndex]) to $currentColor"
                        } else {
                            # Color name didn't change (already Light* or can't lighten further)
                            # For ANSI8/ANSI24 modes, convert to color code and apply algorithmic lightening
                            if ($ANSI8 -and $Colors.ContainsKey($currentColor)) {
                                $ansi8Code = $Colors[$currentColor][3]
                                $lightenedCode = Lighten-ANSI8Color -ANSI8Code $ansi8Code
                                $currentColor = $lightenedCode
                                Write-DebugLog "Background color name $($BackGroundColor[$colorIndex]) algorithmically lightened in ANSI8 from code $ansi8Code to $lightenedCode"
                            } elseif ($ANSI24 -and $Colors.ContainsKey($currentColor)) {
                                $rgb = $Colors[$currentColor][4]
                                $lightenedRGB = Lighten-RGBColor -RGB $rgb
                                $currentColor = $lightenedRGB
                                Write-DebugLog "Background color name $($BackGroundColor[$colorIndex]) algorithmically lightened in ANSI24 from RGB to R=$($lightenedRGB[0]) G=$($lightenedRGB[1]) B=$($lightenedRGB[2])"
                            }
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex color - convert to RGB, lighten
                        if ($script:HasConvertHexToRGB) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $currentColor = Lighten-RGBColor -RGB $rgb
                            Write-DebugLog "Background hex color $($BackGroundColor[$colorIndex]) converted to RGB and lightened"
                        }
                    }
                }

                # Process and convert background colors based on active mode (after fallback)
                if ($ANSI24) {
                    # TrueColor mode active - keep RGB arrays
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        $null = $ProcessedBGColors.Add($currentColor)
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        if ($script:HasConvertHexToRGB) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $null = $ProcessedBGColors.Add($rgb)
                        } else {
                            $null = $ProcessedBGColors.Add($null)
                        }
                    } elseif ($currentColor -is [string]) {
                        $colorEntry = $Colors[$currentColor]
                        if ($colorEntry) {
                            $null = $ProcessedBGColors.Add($colorEntry[4])
                        } else {
                            $null = $ProcessedBGColors.Add($currentColor)
                        }
                    } else {
                        $null = $ProcessedBGColors.Add($currentColor)
                    }
                } elseif ($ANSI8 -and $OriginalTrueColor) {
                    # TrueColor fell back to ANSI8 - convert RGB to ANSI8
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Convert RGB array to nearest ANSI8 code
                        if ($script:HasConvertRGBToANSI8) {
                            $ansi8Code = Convert-RGBToANSI8 -RGB $currentColor
                            $null = $ProcessedBGColors.Add($ansi8Code)
                            Write-DebugLog "Background RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI8: $ansi8Code"
                        } else {
                            $null = $ProcessedBGColors.Add(7)  # Default gray
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex format - convert to RGB then to ANSI8
                        if ($script:HasConvertHexToRGB -and $script:HasConvertRGBToANSI8) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $ansi8Code = Convert-RGBToANSI8 -RGB $rgb
                            $null = $ProcessedBGColors.Add($ansi8Code)
                            Write-DebugLog "Background hex $currentColor converted to ANSI8: $ansi8Code"
                        } else {
                            $null = $ProcessedBGColors.Add(7)  # Default gray
                        }
                    } else {
                        $null = $ProcessedBGColors.Add($currentColor)
                    }
                } elseif ($ANSI4 -and $OriginalTrueColor) {
                    # TrueColor fell back to ANSI4 - convert RGB to ANSI4
                    if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                        # Convert RGB array to nearest ANSI4 code (background)
                        if ($script:HasConvertRGBToANSI4) {
                            $ansi4Code = Convert-RGBToANSI4 -RGB $currentColor
                            # Convert to background code (add 10 to foreground code)
                            $ansi4Code = $ansi4Code + 10
                            $null = $ProcessedBGColors.Add($ansi4Code)
                            Write-DebugLog "Background RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI4: $ansi4Code"
                        } else {
                            $null = $ProcessedBGColors.Add(47)  # White background
                        }
                    } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                        # Hex format - convert to RGB then to ANSI4
                        if ($script:HasConvertHexToRGB -and $script:HasConvertRGBToANSI4) {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $ansi4Code = Convert-RGBToANSI4 -RGB $rgb
                            # Convert to background code (add 10 to foreground code)
                            $ansi4Code = $ansi4Code + 10
                            $null = $ProcessedBGColors.Add($ansi4Code)
                            Write-DebugLog "Background hex $currentColor converted to ANSI4: $ansi4Code"
                        } else {
                            $null = $ProcessedBGColors.Add(47)  # White background
                        }
                    } else {
                        $null = $ProcessedBGColors.Add($currentColor)
                    }
                } else {
                    # No conversion needed
                    $null = $ProcessedBGColors.Add($currentColor)
                }
            }

            # Convert List to array for compatibility
            $BackGroundColor = $ProcessedBGColors.ToArray()
        }

        Write-DebugLog "Starting text output"

        # Output formatting before text
        If ($LinesBefore -gt 0) {
            Write-Host -Object ("`n" * $LinesBefore) -NoNewline
        }

        If ($HorizontalCenter) {
            # Use Measure-DisplayWidth for accurate Unicode character width calculation
            # This accounts for wide characters (CJK, emoji) that take 2 cells
            $CombinedText = $Text -join ''
            $MessageLength = Measure-DisplayWidth -Text $CombinedText
            $WindowWidth = $Host.UI.RawUI.BufferSize.Width
            $CenterPosition = [Math]::Max(0, $WindowWidth / 2 - [Math]::Floor($MessageLength / 2))

            If ($WindowWidth -ge $MessageLength) {
                Write-Host ("{0}" -f (' ' * $CenterPosition)) -NoNewline
            }
        }

        If ($StartTab -gt 0) {
            Write-Host -Object ("`t" * $StartTab) -NoNewline
        }

        If ($StartSpaces -gt 0) {
            Write-Host -Object (' ' * $StartSpaces) -NoNewline
        }

        If ($ShowTime) {
            Write-Host -Object "[$([datetime]::Now.ToString($DateTimeFormat))] " -NoNewline -ForegroundColor DarkGray
        }

        # Main text output loop
        If ($Text.Count -ne 0) {
            # Gradient mode: character-by-character processing
            If ($Gradient -and $gradientArray) {
                Write-DebugLog "Using gradient mode for output"
                $charIndex = 0  # Track position in gradient array

                # Build complete ANSI string with gradient (performance optimized)
                $outputParts = [System.Collections.Generic.List[string]]::new()

                For ($segmentIdx = 0; $segmentIdx -lt $Text.Length; $segmentIdx++) {
                    $segment = $Text[$segmentIdx]

                    # Check if this segment has an explicit color override
                    $hasExplicitColor = $false
                    $explicitColor = $null
                    if ($Color -and $segmentIdx -lt $Color.Count) {
                        $explicitColor = $Color[$segmentIdx]
                        $hasExplicitColor = $null -ne $explicitColor
                    }

                    if ($hasExplicitColor) {
                        # User override: apply same color to entire segment
                        Write-DebugLog "Segment $segmentIdx has explicit color override (skipping gradient)"

                        # Build ANSI prefix (styles + color)
                        $segmentPrefix = [System.Collections.Generic.List[string]]::new()

                        # Apply per-segment styles
                        If ($Style -and $Style[$segmentIdx]) {
                            If ($Style[$segmentIdx] -is [array]) {
                                ForEach ($TextStyle in $Style[$segmentIdx]) {
                                    $null = $segmentPrefix.Add($ANSI[$TextStyle])
                                }
                            } ElseIf ($Style[$segmentIdx] -is [string]) {
                                $null = $segmentPrefix.Add($ANSI[$Style[$segmentIdx]])
                            }
                        }

                        # Apply line-wide styles
                        If ($Bold) { $null = $segmentPrefix.Add($ANSI['Bold']) }
                        If ($Faint) { $null = $segmentPrefix.Add($ANSI['Faint']) }
                        If ($Italic) { $null = $segmentPrefix.Add($ANSI['Italic']) }
                        If ($Underline) { $null = $segmentPrefix.Add($ANSI['Underline']) }
                        If ($Blink) { $null = $segmentPrefix.Add($ANSI['Blink']) }
                        If ($CrossedOut) { $null = $segmentPrefix.Add($ANSI['CrossedOut']) }
                        If ($DoubleUnderline) { $null = $segmentPrefix.Add($ANSI['DoubleUnderline']) }
                        If ($Overline) { $null = $segmentPrefix.Add($ANSI['Overline']) }

                        # Add color
                        If ($ANSI24 -and $explicitColor -is [array] -and $explicitColor.Count -eq 3) {
                            $null = $segmentPrefix.Add("$esc[38;2;$($explicitColor[0]);$($explicitColor[1]);$($explicitColor[2])m")
                        } ElseIf ($ANSI8) {
                            if ($explicitColor -is [string]) {
                                $colorEntry = $Colors[$explicitColor]
                                if ($colorEntry) {
                                    $null = $segmentPrefix.Add("$esc[38;5;$($colorEntry[3])m")
                                }
                            } elseif ($explicitColor -is [int]) {
                                $null = $segmentPrefix.Add("$esc[38;5;${explicitColor}m")
                            }
                        }

                        # Build segment with prefix
                        if ($segmentPrefix.Count -gt 0) {
                            $null = $outputParts.Add([string]::Concat($segmentPrefix))
                        }
                        $null = $outputParts.Add($segment)
                        $null = $outputParts.Add($ANSI['Reset'])

                        # Increment charIndex (skip gradient colors for this segment)
                        $charIndex += $segment.Length
                    } else {
                        # No override: use gradient character-by-character
                        foreach ($char in $segment.ToCharArray()) {
                            $gradientColor = $gradientArray[$charIndex]

                            # Build ANSI string for this character
                            $charPrefix = [System.Collections.Generic.List[string]]::new()

                            # Apply per-segment styles (only once per segment, not per char)
                            # For performance, we apply styles to first char of segment only
                            if ($char -eq $segment[0]) {
                                If ($Style -and $Style[$segmentIdx]) {
                                    If ($Style[$segmentIdx] -is [array]) {
                                        ForEach ($TextStyle in $Style[$segmentIdx]) {
                                            $null = $charPrefix.Add($ANSI[$TextStyle])
                                        }
                                    } ElseIf ($Style[$segmentIdx] -is [string]) {
                                        $null = $charPrefix.Add($ANSI[$Style[$segmentIdx]])
                                    }
                                }

                                # Apply line-wide styles
                                If ($Bold) { $null = $charPrefix.Add($ANSI['Bold']) }
                                If ($Faint) { $null = $charPrefix.Add($ANSI['Faint']) }
                                If ($Italic) { $null = $charPrefix.Add($ANSI['Italic']) }
                                If ($Underline) { $null = $charPrefix.Add($ANSI['Underline']) }
                                If ($Blink) { $null = $charPrefix.Add($ANSI['Blink']) }
                                If ($CrossedOut) { $null = $charPrefix.Add($ANSI['CrossedOut']) }
                                If ($DoubleUnderline) { $null = $charPrefix.Add($ANSI['DoubleUnderline']) }
                                If ($Overline) { $null = $charPrefix.Add($ANSI['Overline']) }
                            }

                            # Add gradient color
                            If ($ANSI24 -and $gradientColor -is [array] -and $gradientColor.Count -eq 3) {
                                $null = $charPrefix.Add("$esc[38;2;$($gradientColor[0]);$($gradientColor[1]);$($gradientColor[2])m")
                            } ElseIf ($ANSI8 -and $gradientColor -is [int]) {
                                $null = $charPrefix.Add("$esc[38;5;${gradientColor}m")
                            }

                            # Add character
                            if ($charPrefix.Count -gt 0) {
                                $null = $outputParts.Add([string]::Concat($charPrefix))
                            }
                            $null = $outputParts.Add($char)

                            $charIndex++
                        }
                        # Reset after segment
                        $null = $outputParts.Add($ANSI['Reset'])
                    }
                }

                # Output the complete gradient string
                $finalOutput = [string]::Concat($outputParts)
                Write-Host -Object $finalOutput -NoNewline

            } Else {
                # Normal mode: segment-by-segment processing
                Write-DebugLog "Using normal mode for output"

                For ($i = 0; $i -lt $Text.Length; $i++) {
                    $Parameters = @{
                        'Object' = ''
                        'NoNewLine' = $True
                    }

                    # Build ANSI string if supported (using array and -join for performance)
                    If ($ANSISupport) {
                        $ansiParts = [System.Collections.Generic.List[string]]::new()

                    # Apply per-segment styles
                    If ($Style -and $Style[$i]) {
                        If ($Style[$i] -is [array]) {
                            ForEach ($TextStyle in $Style[$i]) {
                                $ansiParts.Add($ANSI[$TextStyle])
                            }
                        } ElseIf ($Style[$i] -is [string]) {
                            $ansiParts.Add($ANSI[$Style[$i]])
                        }
                    }

                    # Apply line-wide styles
                    If ($Bold) { $ansiParts.Add($ANSI['Bold']) }
                    If ($Faint) { $ansiParts.Add($ANSI['Faint']) }
                    If ($Italic) { $ansiParts.Add($ANSI['Italic']) }
                    If ($Underline) { $ansiParts.Add($ANSI['Underline']) }
                    If ($Blink) { $ansiParts.Add($ANSI['Blink']) }
                    If ($CrossedOut) { $ansiParts.Add($ANSI['CrossedOut']) }
                    If ($DoubleUnderline) { $ansiParts.Add($ANSI['DoubleUnderline']) }
                    If ($Overline) { $ansiParts.Add($ANSI['Overline']) }

                    # Prepend collected ANSI codes if any were added
                    If ($ansiParts.Count -gt 0) {
                        $Parameters['Object'] = [string]::Concat($ansiParts)
                    }
                }

                # Set foreground color
                $currentColor = if ($i -lt $Color.Count) { $Color[$i] } else { $DefaultColor }

                If ($ANSI24 -and $currentColor -is [array] -and $currentColor.Count -eq 3) {
                    # TrueColor RGB format (already validated in color processing)
                    $Parameters['Object'] += "$esc[38;2;$($currentColor[0]);$($currentColor[1]);$($currentColor[2])m"
                    Write-DebugLog "Applied TrueColor FG: RGB($($currentColor[0]),$($currentColor[1]),$($currentColor[2]))"
                } ElseIf ($ANSI8) {
                    if ($currentColor -is [string]) {
                        $colorEntry = $Colors[$currentColor]
                        if ($colorEntry) {
                            $Parameters['Object'] += "$esc[38;5;$($colorEntry[3])m"
                        }
                    } elseif ($currentColor -is [int]) {
                        # Already validated in color processing
                        $Parameters['Object'] += "$esc[38;5;${currentColor}m"
                    }
                } ElseIf ($ANSI4) {
                    if ($currentColor -is [string]) {
                        $colorEntry = $Colors[$currentColor]
                        if ($colorEntry) {
                            $Parameters['Object'] += "$esc[$($colorEntry[1])m"
                        }
                    } elseif ($currentColor -is [int]) {
                        $Parameters['Object'] += "$esc[${currentColor}m"
                    }
                } Else {
                    # Native PowerShell colors
                    if ($currentColor -is [string]) {
                        $colorEntry = $Colors[$currentColor]
                        if ($colorEntry) {
                            $Parameters['ForegroundColor'] = $colorEntry[0]
                        } else {
                            # Unknown color name - default to Gray
                            $Parameters['ForegroundColor'] = 'Gray'
                        }
                    } elseif ($currentColor -is [array]) {
                        # RGB array without ANSI support - default to Gray
                        $Parameters['ForegroundColor'] = 'Gray'
                    } elseif ($currentColor -is [int] -and $currentColor -ge 0 -and $currentColor -le 15) {
                        # Valid ConsoleColor enum value (0-15)
                        $Parameters['ForegroundColor'] = [System.ConsoleColor]$currentColor
                    } else {
                        # Unknown or invalid color - default to Gray
                        $Parameters['ForegroundColor'] = 'Gray'
                    }
                }

                # Set background color
                If ($BackGroundColor -and $i -lt $BackGroundColor.Count -and $null -ne $BackGroundColor[$i]) {
                    $currentBGColor = $BackGroundColor[$i]

                    If ($ANSI24 -and $currentBGColor -is [array] -and $currentBGColor.Count -eq 3) {
                        # TrueColor RGB format for background (already validated in color processing)
                        $Parameters['Object'] += "$esc[48;2;$($currentBGColor[0]);$($currentBGColor[1]);$($currentBGColor[2])m"
                        Write-DebugLog "Applied TrueColor BG: RGB($($currentBGColor[0]),$($currentBGColor[1]),$($currentBGColor[2]))"
                    } ElseIf ($ANSI8) {
                        if ($currentBGColor -is [string]) {
                            $colorEntry = $Colors[$currentBGColor]
                            if ($colorEntry) {
                                $Parameters['Object'] += "$esc[48;5;$($colorEntry[3])m"
                            }
                        } elseif ($currentBGColor -is [int]) {
                            # Already validated in color processing
                            $Parameters['Object'] += "$esc[48;5;${currentBGColor}m"
                        }
                    } ElseIf ($ANSI4) {
                        if ($currentBGColor -is [string]) {
                            $colorEntry = $Colors[$currentBGColor]
                            if ($colorEntry) {
                                $Parameters['Object'] += "$esc[$($colorEntry[2])m"
                            }
                        } elseif ($currentBGColor -is [int]) {
                            $Parameters['Object'] += "$esc[${currentBGColor}m"
                        }
                    } Else {
                        # Native PowerShell colors
                        if ($currentBGColor -is [string]) {
                            $colorEntry = $Colors[$currentBGColor]
                            if ($colorEntry) {
                                $Parameters['BackgroundColor'] = $colorEntry[0]
                            } else {
                                # Unknown color name - default to Black
                                $Parameters['BackgroundColor'] = 'Black'
                            }
                        } elseif ($currentBGColor -is [array]) {
                            # RGB array without ANSI support - default to Black
                            $Parameters['BackgroundColor'] = 'Black'
                        } elseif ($currentBGColor -is [int] -and $currentBGColor -ge 0 -and $currentBGColor -le 15) {
                            # Valid ConsoleColor enum value (0-15)
                            $Parameters['BackgroundColor'] = [System.ConsoleColor]$currentBGColor
                        } else {
                            # Unknown or invalid color - default to Black
                            $Parameters['BackgroundColor'] = 'Black'
                        }
                    }
                }

                # Add the actual text
                $Parameters['Object'] += $Text[$i]

                # Add ANSI reset if needed
                If ($ANSISupport) {
                    $Parameters['Object'] += $ANSI['Reset']
                }

                # Output to console
                Write-Host @Parameters
            }
            }  # Close Else block (normal mode)
        }  # Close If ($Text.Count -ne 0)

        # Post-text formatting
        If ($NoNewLine -eq $true) {
            Write-Host -NoNewline 
        } Else {
            Write-Host 
        }

        If ($LinesAfter -gt 0) {
            Write-Host -Object ("`n" * $LinesAfter) -NoNewline
        }
    }

    # Logging section
    If ($Text.Count -and $LogFile) {
        Write-DebugLog "Writing to log file: $LogFile"
        
        If (!(Test-Path -Path "$LogPath")) {
            $null = New-Item -ItemType 'Directory' -Path "$LogPath"
        }

        # Resolve log file path
        if ($LogFile -notmatch '[\\/]+') {
            if ($LogFile -notmatch '\.\w+$') {
                $LogFile += '.log'
            }
            $LogFilePath = Join-Path -Path $LogPath -ChildPath "$LogFile"
        } Else {
            $LogFilePath = $LogFile
        }

        # Prepare log text
        $TextToFile = $Text -join ''
        $Saved = $False
        $Retry = 0
        
        Do {
            $Retry++
            try {
                $LogInfo = ''
                If ($LogTime) {
                    $LogInfo += "[$([datetime]::Now.ToString($DateTimeFormat))]"
                }

                If ($LogLevel.Length -gt 0) {
                    $LogInfo += "[$LogLevel]"
                }

                If (-not $LogInfo) {
                    if ($NoNewLine) {
                        "$TextToFile" | Out-File -FilePath $LogFilePath -Encoding $Encoding -Append -NoNewline -ErrorAction Stop -WhatIf:$False
                    } else {
                        "$TextToFile" | Out-File -FilePath $LogFilePath -Encoding $Encoding -Append -ErrorAction Stop -WhatIf:$False
                    }
                } Else {
                    if ($NoNewLine) {
                        "$LogInfo $TextToFile" | Out-File -FilePath $LogFilePath -Encoding $Encoding -Append -NoNewline -ErrorAction Stop -WhatIf:$False
                    } else {
                        "$LogInfo $TextToFile" | Out-File -FilePath $LogFilePath -Encoding $Encoding -Append -ErrorAction Stop -WhatIf:$False
                    }
                }
                $Saved = $true
                Write-DebugLog "Successfully wrote to log file"
            } Catch {
                If ($Saved -eq $False -and $Retry -eq $LogRetry) {
                    Write-Warning "Write-ColorEX - Couldn't write to log file $($_.Exception.Message). Tried ($Retry/$LogRetry)"
                } Else {
                    Write-DebugLog "Log write failed, retrying... ($Retry/$LogRetry)"
                }
            }
        } Until ($Saved -eq $true -or $Retry -ge $LogRetry)
    }

    Write-DebugLog "Write-ColorEX completed"
}