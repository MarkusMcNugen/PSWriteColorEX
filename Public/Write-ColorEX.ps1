Function Write-ColorEX {
    <#
    .SYNOPSIS
    Writes colored and styled text to the host, with optional padding, alignment and logging to a file.

    .DESCRIPTION
    Write-ColorEX writes text through Write-Host with more color, style and layout options:

    - Color modes: the console's 16 colors, ANSI 4-bit (16 colors), ANSI 8-bit (256 colors) and 24-bit TrueColor
    - Color formats: color names, hex codes (#RRGGBB), RGB arrays @(R,G,B) and ANSI color numbers
    - Gradients across the characters of the text, between 2 or more colors
    - Padding to a display width (-AutoPad) that counts wide characters such as emoji and CJK as 2 cells
    - Styles: Bold, Italic, Underline, Blink, Faint, CrossedOut, DoubleUnderline, Overline
    - Reusable style profiles (PSColorStyle objects)
    - Indentation, centering, blank lines before and after, and timestamps
    - Logging to a file, with a timestamp and a level

    Each line goes to the host in as few Write-Host calls as the colors allow, with the line end on
    the last call. PowerShell records each Write-Host call as one line in a transcript, so:
    - Where escape codes reach the screen, a line goes out as one call: on PowerShell 7.2 and later
      always, and on Windows PowerShell 5.1 when the line uses styles or an ANSI mode. PowerShell 7.2
      and later remove escape codes from transcripts; Windows PowerShell 5.1 keeps them.
    - Otherwise each color is its own Write-Host call with -ForegroundColor and -BackgroundColor, and a
      line of several colors takes several lines in a transcript.

    The terminal's color support is detected with Test-AnsiSupport when the module is imported.
    A color mode the terminal does not support falls back: TrueColor, then ANSI8, then ANSI4,
    then the console's 16 colors. NO_COLOR, FORCE_COLOR=0 or TERM=dumb turn colors and styles off,
    and FORCE_COLOR=1, 2 or 3 sets the color mode.

    .PARAMETER Text
    The text to write. Several strings are written on one line, each with its own colors and styles.
    Strings piped in are written one line each.

    Example: -Text 'Hello', ' ', 'World'

    .PARAMETER Color
    The foreground color of each text segment, in any of these forms:

    - Color names: 'Red', 'Blue', 'DarkGreen', 'Cyan', and the other names of 44 color families, most with Dark and Light variants (Get-ColorTableWithRGB lists them)
    - Hex codes: '#FF0000', '0xFF0000'
    - RGB arrays: @(255, 0, 0) with -TrueColor, or one RGB array per segment, @(@(255, 0, 0), @(0, 0, 255))
    - ANSI color numbers: 0-255 with -ANSI8, the ANSI4 codes with -ANSI4, and 0-15 (System.ConsoleColor) otherwise

    A hex code or an RGB array is a TrueColor color. Without -TrueColor, -ANSI8 or -ANSI4, it is
    written in the best mode the terminal has: TrueColor, or the nearest 256-color, 16-color or
    console color.

    With fewer colors than text segments the colors repeat; extra colors are ignored.
    Without -Color the text takes the terminal's default color.

    Aliases: C, ForegroundColor, FGC

    Example: -Color 'Red', 'Blue' -or- -Color '#FF8000' -or- -Color @(255,128,0)

    .PARAMETER BackGroundColor
    The background color of each text segment, in the same forms as -Color.
    Without it the text takes the terminal's default background.

    Aliases: B, BGC

    Example: -BackGroundColor 'DarkRed' -or- -BackGroundColor '#2C2C2C'

    .PARAMETER Gradient
    Two or more colors to blend across the characters of the text. Each character takes a color
    interpolated between the colors given.

    A gradient needs ANSI 8-bit or TrueColor support and selects the best mode available.
    A segment with its own entry in -Color keeps that color instead of the gradient; $null in
    -Color leaves a segment to the gradient.

    Alias: Grad

    Example: -Gradient @('Red', 'Blue')
    Example: -Gradient @('Red', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta')

    .PARAMETER ANSI4
    Uses ANSI 4-bit colors (16 colors: 8 normal and 8 bright).
    Without terminal support it falls back to the console's colors.

    Alias: A4

    .PARAMETER ANSI8
    Uses ANSI 8-bit colors (256 colors: 16 standard, a 216-color cube and 24 grays).
    Without terminal support it falls back to ANSI4 or the console's colors.

    Alias: A8

    .PARAMETER ANSI24
    Uses 24-bit TrueColor (RGB). Three integers for one segment, @(255, 0, 0), are one RGB color
    only with it. Without terminal support it falls back to ANSI8 or ANSI4, with a warning.

    Aliases: A24, TrueColor, TC

    .PARAMETER Style
    Styles for the text segments in order: an array with one style per segment, or with an array
    of styles for a segment that takes several. One style alone styles the first segment, as an
    array of one does. -Bold and the other style switches style every segment.

    Valid styles: Bold, Faint, Italic, Underline, Blink, CrossedOut, DoubleUnderline, Overline

    Alias: S

    Example: -Style 'Bold'
    Example: -Style @('Bold', 'Italic', 'Underline')
    Example: -Style @(@('Bold', 'Underline'), 'Italic')

    .PARAMETER StyleProfile
    A PSColorStyle object holding colors, styles and layout settings.
    Parameters given on the command line take precedence over the profile.

    Built-in profiles: Default, Error, Warning, Info, Success, Critical, Debug
    New-ColorStyle creates more.

    Example: -StyleProfile ([PSColorStyle]::Profiles['Error'])

    .PARAMETER Default
    Applies the default style set with Set-ColorDefault.
    Parameters given on the command line take precedence over it.

    .PARAMETER Bold
    Writes the text in bold. Where the terminal shows bold as brighter colors rather than a bold
    font, the colors are made lighter instead.

    .PARAMETER Faint
    Writes the text faint (dimmed). With ANSI4 colors only bright colors dim.

    .PARAMETER Italic
    Writes the text in italics. The Windows console host (conhost.exe) does not show italics.

    .PARAMETER Underline
    Underlines the text.

    .PARAMETER Blink
    Makes the text blink, where the terminal supports it. Many terminals do not.

    .PARAMETER CrossedOut
    Strikes the text through.

    Alias: Strikethrough

    .PARAMETER DoubleUnderline
    Underlines the text twice, where the terminal supports it. Most terminals show a single underline.

    .PARAMETER Overline
    Draws a line above the text, where the terminal supports it.

    .PARAMETER StartTab
    The number of tab characters before the text.

    Default: 0
    Alias: Indent

    .PARAMETER LinesBefore
    The number of blank lines before the text.

    Default: 0

    .PARAMETER LinesAfter
    The number of blank lines after the text.

    Default: 0

    .PARAMETER StartSpaces
    The number of spaces before the text, after any tabs from -StartTab.

    Default: 0

    .PARAMETER AutoPad
    Pads the text to this display width, measured with Measure-DisplayWidth, so wide characters
    such as emoji and CJK count as 2 cells and combining marks as 0.

    Text already this wide or wider is not padded or cut. 0 turns padding off.

    Default: 0
    Aliases: PadWidth, Pad

    Example: -AutoPad 20
    Example: 'Server ✅' -AutoPad 21  # ✅ takes 2 cells, so 12 spaces are added

    .PARAMETER PadLeft
    With -AutoPad, pads on the left (right-aligns the text) instead of the right.

    Alias: RightAlign

    Example: -AutoPad 20 -PadLeft

    .PARAMETER PadChar
    The character -AutoPad pads with. A wide character (2 cells) gives a warning, since the padding
    may then fall a cell short. A zero-width character is replaced with a space.

    Default: ' ' (space)
    Aliases: PaddingChar, FillChar

    Example: -PadChar '.'

    .PARAMETER LogFile
    Writes the text to this log file as well.
    A file name alone goes in the folder from -LogPath. A path with a folder is used as given,
    relative to the current location, and -LogPath is not used.
    A name without an extension gets .log. A missing folder is created.

    Default: '' (no logging)
    Alias: L

    Example: -LogFile 'application.log'
    Example: -LogFile 'C:\Logs\app.log'

    .PARAMETER LogPath
    The folder for a -LogFile given as a file name alone.

    Default: the folder of the script calling Write-ColorEX, or the current location when it is called from the prompt
    Alias: LP

    Example: -LogPath 'C:\Logs'

    .PARAMETER LogLevel
    A level written in brackets before the text in the log file, such as ERROR or INFO.

    Default: '' (no level)
    Aliases: LL, LogLvl

    Example: -LogLevel 'ERROR'

    .PARAMETER LogTime
    Writes a timestamp in brackets before the text in the log file, in the -DateTimeFormat format.

    Alias: LT

    .PARAMETER DateTimeFormat
    The .NET date and time format for -LogTime and -ShowTime.

    Default: 'yyyy-MM-dd HH:mm:ss'
    Aliases: DateFormat, TimeFormat, Timestamp, TS

    Example: -DateTimeFormat 'yyyy-MM-dd HH:mm:ss.fff'

    .PARAMETER LogRetry
    How many times to try writing the log file, 50 ms apart, when the file is locked.

    Default: 2

    .PARAMETER Encoding
    The text encoding of the log file. Each name gives the same bytes on Windows PowerShell 5.1
    and PowerShell 7:

    - utf8, utf8NoBOM, default: UTF-8 without a byte order mark
    - utf8BOM: UTF-8 with a byte order mark
    - unicode, string, unknown: UTF-16 little-endian with a byte order mark
    - bigendianunicode: UTF-16 big-endian with a byte order mark
    - utf32, bigendianutf32: UTF-32 with a byte order mark
    - ascii, utf7
    - ansi, oem: the system's code pages on Windows, UTF-8 elsewhere

    A byte order mark is written only to a new or empty file.

    Default: utf8

    .PARAMETER ShowTime
    Writes the time in brackets, in dark gray, before the text on the console.

    .PARAMETER NoNewLine
    Leaves the line open, so the next output continues it.

    Example: Write-ColorEX 'Name: ' -NoNewLine; Write-ColorEX 'John' -Color Green

    .PARAMETER HorizontalCenter
    Centers the text in the console window, measuring the text with Measure-DisplayWidth.
    Nothing is centered when the window width is unknown, as with output redirected to a file.

    Alias: Center

    .PARAMETER BlankLine
    Writes a line of spaces as wide as the console window, which -BackGroundColor colors.
    With output redirected, where the window width is unknown, it writes an empty line.

    Aliases: BL, Empty, Blank

    Example: -BlankLine -BackGroundColor 'DarkBlue'

    .PARAMETER NoConsoleOutput
    Writes nothing to the host, only to the log file.

    Aliases: HideConsole, NoConsole, LogOnly, LO

    Example: -NoConsoleOutput -LogFile 'app.log'

    .PARAMETER Debugging
    Writes [DEBUG] messages about color processing and detection to the verbose stream.

    .PARAMETER Silent
    Suppresses the warnings about colors that are out of range or of the wrong form, and about
    fallbacks to a color mode the terminal supports.

    .INPUTS
    System.String[]
    Strings piped to Write-ColorEX bind to -Text, and each is written as its own line.

    .OUTPUTS
    None
    Write-ColorEX writes to the host and the log file, not to the pipeline.

    .EXAMPLE
    Write-ColorEX -Text 'Hello World' -Color Green

    Writes "Hello World" in green.

    .EXAMPLE
    Write-ColorEX -Text 'Error: ', 'File not found' -Color Red, Yellow -Bold

    Writes "Error: " in red and "File not found" in yellow, both bold.

    .EXAMPLE
    Write-ColorEX -Text 'Server Status' -Color '#00FF80' -TrueColor -Bold

    Writes "Server Status" in TrueColor green (#00FF80), bold.

    .EXAMPLE
    Write-ColorEX -Text 'RGB Color' -Color @(255, 128, 0) -TrueColor

    Writes "RGB Color" in orange from an RGB array.

    .EXAMPLE
    Write-ColorEX -Text 'RAINBOW' -Gradient @('Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta')

    Writes "RAINBOW" with a 7-color gradient across its characters.

    .EXAMPLE
    Write-ColorEX -Text 'Test' -AutoPad 20 -Color Cyan -NoNewLine
    Write-Host '|'

    Writes "Test" padded to 20 cells in cyan, then "|" on the same line.
    Output: "Test                |"

    .EXAMPLE
    Write-ColorEX -Text 'Server ✅' -AutoPad 21 -Color White

    Pads "Server ✅" to 21 cells. ✅ takes 2 cells, so the text is 9 cells and 12 spaces are added.

    .EXAMPLE
    Write-ColorEX -Text 'CPU: 45%' -AutoPad 20 -PadLeft -Color Yellow

    Right-aligns "CPU: 45%" in 20 cells.
    Output: "            CPU: 45%"

    .EXAMPLE
    Write-ColorEX -Text 'Total' -AutoPad 20 -PadChar '.' -Color White

    Pads "Total" to 20 cells with dots.
    Output: "Total..............."

    .EXAMPLE
    Write-ColorEX '║ ' -Color Cyan -NoNewLine
    Write-ColorEX 'Web Server' -AutoPad 21 -Color White -NoNewLine
    Write-ColorEX ' [OK] ║' -Color Green

    Writes one row of a status table with box-drawing characters, aligned with -AutoPad.
    Output: "║ Web Server           [OK] ║"

    .EXAMPLE
    Write-ColorError 'Operation failed'

    Writes with the built-in Error profile (red, bold).

    .EXAMPLE
    Set-ColorDefault -ForegroundColor Cyan -Bold
    Write-ColorEX -Text 'This uses default style' -Default

    Writes with the default style set by Set-ColorDefault.

    .EXAMPLE
    $style = New-ColorStyle -Name 'Header' -ForegroundColor Cyan -Bold -Underline -HorizontalCenter
    Write-ColorEX -Text 'SECTION HEADER' -StyleProfile $style

    Writes centered, bold, underlined cyan text from a custom profile.

    .EXAMPLE
    Write-ColorEX -Text 'Log Entry' -LogFile 'app.log' -LogTime -LogLevel 'INFO'

    Writes "Log Entry" to the host and to app.log in the calling script's folder.
    Log entry: "[2025-01-02 14:30:45][INFO] Log Entry"

    .EXAMPLE
    Write-ColorEX -Text 'Silent logging' -LogFile 'app.log' -NoConsoleOutput

    Writes to the log file only.

    .EXAMPLE
    Write-ColorEX -Text 'Title' -Color White -BackGroundColor DarkBlue -Bold -HorizontalCenter -LinesBefore 1 -LinesAfter 1

    Writes centered white text on dark blue, bold, with a blank line before and after.

    .EXAMPLE
    Write-ColorEX -BlankLine -BackGroundColor DarkGray

    Writes a dark gray bar across the console.

    .EXAMPLE
    foreach ($file in $files) {
        Write-ColorEX $file.Name -AutoPad 40 -NoNewLine
        Write-ColorEX $file.Length -AutoPad 12 -PadLeft -Color Cyan -NoNewLine
        Write-ColorEX ' bytes' -Color Gray
    }

    Writes a file listing with names left-aligned and sizes right-aligned.

    .EXAMPLE
    'first', 'second' | Write-ColorEX -Color Green

    Writes "first" and "second" on two lines, in green.

    .NOTES
    Name: Write-ColorEX
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    Windows PowerShell 5.1 reads a script without a byte order mark in the system's code page, so a
    script holding emoji or other non-ASCII text needs to be saved as UTF-8 with a byte order mark there.

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
        [Parameter(ValueFromPipeline = $true)]
        [alias ('T')][string[]] $Text,
        [ValidateScript({
            # Strings, integers, and arrays of those or of RGB arrays
            if ($_ -is [string] -or $_ -is [int]) { return $true }
            if ($_ -is [array]) {
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
            # Strings, integers, and arrays of those or of RGB arrays
            if ($_ -is [string] -or $_ -is [int]) { return $true }
            if ($_ -is [array]) {
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
        [alias ('LP')][string] $LogPath = '',
        [alias ('LL', 'LogLvl')][string] $LogLevel = '',
        [alias ('LT')][switch] $LogTime,
        [Alias('DateFormat', 'TimeFormat', 'Timestamp', 'TS')][string] $DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [int] $LogRetry = 2,
        [ValidateSet('unknown', 'string', 'unicode', 'bigendianunicode', 'utf8', 'utf8BOM', 'utf8NoBOM', 'utf7', 'utf32', 'bigendianutf32', 'ascii', 'ansi', 'default', 'oem')][string]$Encoding = 'utf8',
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

    begin {
        function Write-DebugLog {
            param([string]$Message)
            if ($Debugging) {
                Write-Verbose "[DEBUG] $Message" -Verbose
            }
        }

        # A warning that -Silent suppresses
        function Write-ColorWarningMsg {
            param([string]$Message)
            if (-not $Silent) {
                Write-Warning $Message
            }
        }

        # The console color an ANSI4 foreground or background code stands for
        function ConvertANSI4ToNativeColor {
            param([int]$Code)

            if (($Code -ge 40 -and $Code -le 47) -or ($Code -ge 100 -and $Code -le 107)) {
                $Code -= 10
            }
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

        # The ANSI4 foreground code nearest an ANSI8 color code
        function ConvertANSI8ToANSI4 {
            param([int]$Code)

            if ($Code -lt 8) { return 30 + $Code }
            if ($Code -lt 16) { return 82 + $Code }
            if ($Code -lt 232) {
                # The 6x6x6 color cube
                $levels = 0, 95, 135, 175, 215, 255
                $index = $Code - 16
                $rgb = @($levels[[int][Math]::Floor($index / 36)], $levels[[int][Math]::Floor($index / 6) % 6], $levels[$index % 6])
            } else {
                # The 24 grays
                $value = 8 + ($Code - 232) * 10
                $rgb = @($value, $value, $value)
            }
            return Convert-RGBToANSI4 -RGB $rgb
        }

        # Console color numbers 0-15 as their names, so they keep their meaning in another color mode
        function ConvertConsoleColorNumber {
            param([object[]]$Values)

            $converted = [System.Collections.Generic.List[object]]::new()
            foreach ($value in $Values) {
                if ($value -is [int] -and $value -ge 0 -and $value -le 15) {
                    $converted.Add(([System.ConsoleColor]$value).ToString())
                } else {
                    $converted.Add($value)
                }
            }
            return ,$converted.ToArray()
        }

        # The console color for a processed color value. An unknown name or value is Gray for
        # text and Black for a background.
        function Get-NativeColorName {
            param([object]$Value, [bool]$Background)

            $fallback = if ($Background) { 'Black' } else { 'Gray' }
            if ($Value -is [string]) {
                $entry = $Colors[$Value]
                if ($entry) { return $entry[0] }
                return $fallback
            }
            if ($Value -is [int] -and $Value -ge 0 -and $Value -le 15) {
                return ([System.ConsoleColor]$Value).ToString()
            }
            return $fallback
        }

        # The escape sequence that sets a processed color in the active color mode, or '' for none.
        # Without an ANSI mode the color is the console color as an ANSI4 code.
        function Get-ColorSequence {
            param([object]$Value, [bool]$Background)

            if ($null -eq $Value) { return '' }
            $layer = if ($Background) { 48 } else { 38 }
            if ($ANSI24 -and $Value -is [array] -and $Value.Count -eq 3) {
                return "$esc[$layer;2;$($Value[0]);$($Value[1]);$($Value[2])m"
            }
            if ($ANSI8) {
                if ($Value -is [string]) {
                    $entry = $Colors[$Value]
                    if ($entry) { return "$esc[$layer;5;$($entry[3])m" }
                } elseif ($Value -is [int]) {
                    return "$esc[$layer;5;${Value}m"
                }
                return ''
            }
            if ($ANSI4) {
                if ($Value -is [string]) {
                    $entry = $Colors[$Value]
                    if ($entry) {
                        $code = if ($Background) { $entry[2] } else { $entry[1] }
                        return "$esc[${code}m"
                    }
                } elseif ($Value -is [int]) {
                    return "$esc[${Value}m"
                }
                return ''
            }
            # A console color name maps to itself in the color table
            $code = $script:ConsoleColorSgr[$Value]
            if ($null -eq $code -or $Value -isnot [string]) {
                $code = $script:ConsoleColorSgr[(Get-NativeColorName -Value $Value -Background $Background)]
            }
            if ($Background) { $code += 10 }
            return "$esc[${code}m"
        }

        # The styles that apply to one segment: its own from -Style, then those of the whole line
        function Get-StyleSequence {
            param([int]$Index)

            $parts = [System.Text.StringBuilder]::new()
            if ($Style -and $Style[$Index]) {
                if ($Style[$Index] -is [array]) {
                    foreach ($TextStyle in $Style[$Index]) {
                        [void]$parts.Append($ANSI[$TextStyle])
                    }
                } elseif ($Style[$Index] -is [string]) {
                    [void]$parts.Append($ANSI[$Style[$Index]])
                }
            }
            if ($Bold) { [void]$parts.Append($ANSI['Bold']) }
            if ($Faint) { [void]$parts.Append($ANSI['Faint']) }
            if ($Italic) { [void]$parts.Append($ANSI['Italic']) }
            if ($Underline) { [void]$parts.Append($ANSI['Underline']) }
            if ($Blink) { [void]$parts.Append($ANSI['Blink']) }
            if ($CrossedOut) { [void]$parts.Append($ANSI['CrossedOut']) }
            if ($DoubleUnderline) { [void]$parts.Append($ANSI['DoubleUnderline']) }
            if ($Overline) { [void]$parts.Append($ANSI['Overline']) }
            return $parts.ToString()
        }

        # The folder of the script that called Write-ColorEX, for a bare -LogFile name
        $callerScriptRoot = $MyInvocation.PSScriptRoot

        # The checks on -Color, -BackGroundColor and -Style run when the parameters are bound, and
        # stay on the variables, where they would reject the $null entries the function puts in
        # them. They are taken off the variables.
        $variables = $ExecutionContext.SessionState.PSVariable
        foreach ($name in 'Color', 'BackGroundColor', 'Style') {
            $variable = $variables.Get($name)
            foreach ($attribute in @($variable.Attributes)) {
                if ($attribute -is [System.Management.Automation.ValidateArgumentsAttribute]) {
                    [void]$variable.Attributes.Remove($attribute)
                }
            }
        }

        # With piped input, the parameter values as bound, put back before each piped string so
        # one string's processing does not carry into the next
        $boundAtStart = $null
        if ($MyInvocation.ExpectingInput) {
            $boundAtStart = @{}
            foreach ($name in $MyInvocation.MyCommand.Parameters.Keys) {
                if ($name -eq 'Text') { continue }
                $variable = $variables.Get($name)
                if ($variable) {
                    $boundAtStart[$name] = $variable.Value
                }
            }
        }
    }

    process {
        if ($null -ne $boundAtStart) {
            foreach ($name in $boundAtStart.Keys) {
                $variables.Set($name, $boundAtStart[$name])
            }
        }

        Write-DebugLog "Starting Write-ColorEX with Text count: $($Text.Count)"

        If ($Gradient -and $Gradient.Count -lt 2) {
            Write-ColorWarningMsg "Gradient requires at least 2 colors (received $($Gradient.Count)). Gradient disabled."
            Write-DebugLog "Gradient validation failed: Only $($Gradient.Count) color(s) provided"
            $Gradient = $null
        }

        # Only one color mode applies: TrueColor, then ANSI8, then ANSI4
        $colorModeCount = 0
        if ($ANSI4) { $colorModeCount++ }
        if ($ANSI8) { $colorModeCount++ }
        if ($ANSI24) { $colorModeCount++ }

        if ($colorModeCount -gt 1) {
            Write-Warning "Multiple color modes specified. Only one of -ANSI4, -ANSI8, or -TrueColor should be used."
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

        if ($StyleProfile) {
            Write-DebugLog "Applying style profile: $($StyleProfile.Name)"
            $profileParams = $StyleProfile.ToWriteColorParams()
            foreach ($key in $profileParams.Keys) {
                if (-not $PSBoundParameters.ContainsKey($key)) {
                    Set-Variable -Name $key -Value $profileParams[$key]
                }
            }
        }

        if ($Default -and [PSColorStyle]::Default) {
            Write-DebugLog "Applying default style profile"
            $defaultParams = [PSColorStyle]::Default.ToWriteColorParams()
            foreach ($key in $defaultParams.Keys) {
                if (-not $PSBoundParameters.ContainsKey($key) -and -not $StyleProfile) {
                    Set-Variable -Name $key -Value $defaultParams[$key]
                }
            }
        }

        # One style alone is the first segment's, as an array of one; indexing the string itself
        # would read its letters
        if ($Style -is [string]) {
            $Style = @($Style)
        }

        # A hex code or an RGB array asks for TrueColor. Without a color mode given, it takes the
        # best mode the terminal has, without the warnings an explicit -TrueColor gives.
        $impliedTrueColor = $false
        if (-not ($ANSI4 -or $ANSI8 -or $ANSI24)) {
            foreach ($value in @($Color) + @($BackGroundColor)) {
                if (($value -is [string] -and $value -match '^#|^0x') -or $value -is [array]) {
                    $impliedTrueColor = $true
                    break
                }
            }
            if ($impliedTrueColor) {
                Write-DebugLog "Hex or RGB color without a color mode: using TrueColor"
                $ANSI24 = $true
                $Color = ConvertConsoleColorNumber -Values $Color
                $BackGroundColor = ConvertConsoleColorNumber -Values $BackGroundColor
            }
        }

        # The color mode asked for, before any fallback, which the color checks read
        $OriginalTrueColor = [bool]$ANSI24
        $OriginalANSI8 = [bool]$ANSI8
        $OriginalANSI4 = [bool]$ANSI4

        # Three integers for one segment under -TrueColor are one RGB color, not three colors
        if ($OriginalTrueColor -and $Color -and $Color.Count -eq 3 -and
            $Color[0] -is [int] -and $Color[1] -is [int] -and $Color[2] -is [int] -and
            $Text.Count -eq 1) {
            Write-DebugLog "Detected flattened RGB array, wrapping: @($($Color[0]),$($Color[1]),$($Color[2]))"
            $Color = ,@($Color[0], $Color[1], $Color[2])
        }

        if ($OriginalTrueColor -and $BackGroundColor -and $BackGroundColor.Count -eq 3 -and
            $BackGroundColor[0] -is [int] -and $BackGroundColor[1] -is [int] -and $BackGroundColor[2] -is [int] -and
            $Text.Count -eq 1) {
            Write-DebugLog "Detected flattened RGB array for background, wrapping: @($($BackGroundColor[0]),$($BackGroundColor[1]),$($BackGroundColor[2]))"
            $BackGroundColor = ,@($BackGroundColor[0], $BackGroundColor[1], $BackGroundColor[2])
        }

        # Padding to a display width, measured so wide characters count as 2 cells
        if ($AutoPad -gt 0) {
            Write-DebugLog "AutoPad processing: Target width = $AutoPad, PadLeft = $PadLeft, PadChar = '$PadChar'"

            $padCharWidth = Measure-DisplayWidth -Text $PadChar.ToString()

            if ($padCharWidth -eq 0) {
                Write-ColorWarningMsg "PadChar '$PadChar' is a zero-width character and cannot be used for padding. Using space instead."
                $PadChar = ' '
                $padCharWidth = 1
            }

            if ($padCharWidth -gt 1) {
                Write-ColorWarningMsg "PadChar '$PadChar' is a wide character ($padCharWidth cells). Padding alignment may be off."
            }

            $currentWidth = Measure-DisplayWidth -Text ($Text -join '')
            Write-DebugLog "Current text display width: $currentWidth cells"

            if ($currentWidth -lt $AutoPad) {
                $paddingCellsNeeded = $AutoPad - $currentWidth

                if ($padCharWidth -gt 1) {
                    $padCount = [Math]::Floor($paddingCellsNeeded / $padCharWidth)
                    $remainder = $paddingCellsNeeded % $padCharWidth
                    if ($remainder -ne 0) {
                        Write-DebugLog "Padding width ($paddingCellsNeeded cells) not evenly divisible by PadChar width ($padCharWidth cells). Off by $remainder cell(s)."
                    }
                } else {
                    $padCount = $paddingCellsNeeded
                }

                if ($padCount -gt 0) {
                    $paddingString = $PadChar.ToString() * $padCount
                    Write-DebugLog "Adding $padCount '$PadChar' character(s) = $($padCount * $padCharWidth) cells"

                    if ($PadLeft) {
                        $Text = @($paddingString) + $Text
                        Write-DebugLog "Applied left padding (right-aligned text)"
                    } else {
                        $Text = $Text + @($paddingString)
                        Write-DebugLog "Applied right padding (left-aligned text)"
                    }
                }
            } else {
                Write-DebugLog "Text width ($currentWidth) >= Target width ($AutoPad). No padding applied."
            }
        }

        # NO_COLOR, FORCE_COLOR=0 and TERM=dumb turn colors and styles off; FORCE_COLOR 1 to 3 keeps them on
        $forcedColor = $env:FORCE_COLOR -in @('1', '2', '3')
        $ColorDisabled = (-not $forcedColor) -and (
            ($env:FORCE_COLOR -eq '0') -or
            (-not [string]::IsNullOrEmpty($env:NO_COLOR)) -or
            ($env:TERM -eq 'dumb'))

        $UsingANSIFeatures = $ANSI4 -or $ANSI8 -or $ANSI24 -or $Bold -or $Italic -or $Underline -or
                             $Blink -or $Faint -or $CrossedOut -or $DoubleUnderline -or $Overline -or $Style -or $Gradient

        $ComposeLine = $false
        If ($ColorDisabled) {
            Write-DebugLog "Colors are off: NO_COLOR, FORCE_COLOR=0 or TERM=dumb"
            $ANSISupport = $False
            $ANSIColorSupport = 'None'
            $Style = @()
            $Gradient = $null
            $ANSI4 = $False
            $ANSI8 = $False
            $ANSI24 = $False
        } ElseIf (-not $UsingANSIFeatures) {
            # Console colors only: no ANSI detection needed, only whether the line can go out as one call
            $ANSISupport = $False
            $ANSIColorSupport = 'None'
            $ComposeLine = (-not $NoConsoleOutput) -and (Test-ColorLineComposition)
            Write-DebugLog "Console colors only; one call per line: $ComposeLine"
        } Else {
            # FORCE_COLOR can change at any time, so it is read here rather than cached
            if ($forcedColor) {
                Write-DebugLog "FORCE_COLOR environment variable detected: $($env:FORCE_COLOR)"
                switch ($env:FORCE_COLOR) {
                    '1' { $ANSIColorSupport = 'ANSI4' }
                    '2' { $ANSIColorSupport = 'ANSI8' }
                    '3' { $ANSIColorSupport = 'TrueColor' }
                }
                Write-DebugLog "FORCE_COLOR override: $ANSIColorSupport"
            } else {
                if ($null -eq $script:CachedANSISupport) {
                    $script:CachedANSISupport = (Test-AnsiSupport -Silent).ColorSupport
                }
                $ANSIColorSupport = $script:CachedANSISupport
                if ($ANSIColorSupport -ne 'None' -and -not (Test-ColorHostAnsi)) {
                    # PowerShell would remove the escape codes before they reach the screen
                    Write-DebugLog "The host renders no escape codes; using console colors"
                    $ANSIColorSupport = 'None'
                }
                Write-DebugLog "ANSI Color Support: $ANSIColorSupport (cached)"
            }
            $ANSISupport = $ANSIColorSupport -ne 'None'

            If ($ANSIColorSupport -eq 'None') {
                $Style = @()
                $ANSI4 = $False
                $ANSI8 = $False
                $ANSI24 = $False
                Write-DebugLog "ANSI support disabled - using native PowerShell colors"
            } ElseIf ($ANSI24 -and $ANSIColorSupport -ne 'TrueColor') {
                if ($ANSIColorSupport -eq 'ANSI8') {
                    if (-not $impliedTrueColor) {
                        Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to ANSI8 (256 colors)."
                    }
                    Write-DebugLog "Downgrading from TrueColor to ANSI8"
                    $ANSI24 = $False
                    $ANSI8 = $True
                } else {
                    if (-not $impliedTrueColor) {
                        Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to ANSI4 (16 colors)."
                    }
                    Write-DebugLog "Downgrading from TrueColor to ANSI4"
                    $ANSI24 = $False
                    $ANSI4 = $True
                }
            } ElseIf ($ANSI8 -and $ANSIColorSupport -eq 'ANSI4') {
                Write-ColorWarningMsg "ANSI8 (256 colors) not supported by terminal. Falling back to ANSI4 (16 colors)."
                Write-DebugLog "Downgrading from ANSI8 to ANSI4"
                $ANSI8 = $False
                $ANSI4 = $True
            }

            If ($Gradient -and $Gradient.Count -ge 2) {
                Write-DebugLog "Gradient requested with $($Gradient.Count) colors"

                If ($ANSIColorSupport -eq 'None') {
                    Write-ColorWarningMsg "Gradient requires ANSI 256-color or TrueColor support. Terminal supports: None. Gradient disabled."
                    Write-DebugLog "Gradient disabled: No ANSI support"
                    $Gradient = $null
                } ElseIf ($ANSIColorSupport -eq 'ANSI4') {
                    Write-ColorWarningMsg "Gradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). Gradient disabled."
                    Write-DebugLog "Gradient disabled: ANSI4 only"
                    $Gradient = $null
                } Else {
                    If (-not $ANSI8 -and -not $ANSI24) {
                        If ($ANSIColorSupport -eq 'TrueColor') {
                            Write-DebugLog "Gradient: Auto-enabling TrueColor mode"
                            $ANSI24 = $True
                        } Else {
                            Write-DebugLog "Gradient: Auto-enabling ANSI8 mode"
                            $ANSI8 = $True
                        }
                    }
                    Write-DebugLog "Gradient enabled in $ANSIColorSupport mode"
                }
            }
        }

        If (-not $NoConsoleOutput) {
            $esc = [char]27

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

            if ($null -eq $script:CachedColorTable) {
                $script:CachedColorTable = Get-ColorTableWithRGB
            }
            $Colors = $script:CachedColorTable

            $WindowWidth = 0
            If ($BlankLine -or $HorizontalCenter) {
                $WindowWidth = Get-ColorHostWidth
            }

            If ($BlankLine) {
                Write-DebugLog "Processing blank line"
                $HorizontalCenter = $False
                $StartTab = 0
                $StartSpaces = 0
                $ShowTime = $False
                $Text = [string[]]@(' ' * $WindowWidth)
            }

            $gradientArray = $null
            If ($Gradient -and $Gradient.Count -ge 2) {
                Write-DebugLog "Calculating gradient for text"

                # Each segment split into the characters a terminal draws, so no color code lands
                # inside an emoji or between a letter and its accent
                $gradientCharacters = [System.Collections.Generic.List[object]]::new()
                $totalChars = 0
                foreach ($segment in $Text) {
                    $characters = @(Split-DisplayCharacter -Text $segment)
                    $gradientCharacters.Add($characters)
                    $totalChars += $characters.Count
                }
                Write-DebugLog "Total characters for gradient: $totalChars"

                if ($Gradient.Count -gt $totalChars) {
                    Write-ColorWarningMsg "Gradient has $($Gradient.Count) colors but text only has $totalChars characters. Applying standard coloring instead."
                    Write-DebugLog "Gradient disabled: More colors ($($Gradient.Count)) than characters ($totalChars)"
                    $Gradient = $null
                } else {
                    $gradientMode = if ($ANSI24) { 'TrueColor' } else { 'ANSI8' }
                    Write-DebugLog "Generating gradient in $gradientMode mode"
                    $gradientArray = New-GradientColorArray -Colors $Gradient -Steps $totalChars -Mode $gradientMode
                    if (-not $gradientArray) {
                        Write-DebugLog "Gradient array generation failed"
                        $Gradient = $null
                    }
                }
            }

            # Each segment's foreground color, cycling through -Color, converted for the active mode
            If ($Color.Count -gt 0 -and -not $ColorDisabled) {
                Write-DebugLog "Processing $($Color.Count) colors"
                $ProcessedColors = [System.Collections.Generic.List[object]]::new()

                For ($i = 0; $i -lt $Text.Length; $i++) {
                    $colorIndex = $i % $Color.Count
                    $currentColor = $Color[$colorIndex]

                    if ($null -eq $currentColor) {
                        # $null leaves the segment to a gradient, or to the terminal's color
                        $null = $ProcessedColors.Add($null)
                        continue
                    }

                    Write-DebugLog "Processing color at index $($i): $currentColor (type: $($currentColor.GetType().Name))"

                    # Checked against the mode asked for, before any fallback
                    if ($OriginalTrueColor) {
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $r = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[0]))
                            $g = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[1]))
                            $b = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[2]))

                            if ($r -ne $currentColor[0] -or $g -ne $currentColor[1] -or $b -ne $currentColor[2]) {
                                Write-ColorWarningMsg "RGB values out of range (0-255). Original: @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])). Clamped to: @($r,$g,$b)"
                                $currentColor = @($r, $g, $b)
                            }
                        } elseif ($currentColor -is [int] -and -not $impliedTrueColor) {
                            Write-ColorWarningMsg "TrueColor mode expects RGB array @(R,G,B) or hex color, but received integer code $currentColor. Use -ANSI8 or -ANSI4 for integer codes."
                            Write-DebugLog "Type mismatch: integer $currentColor provided for TrueColor"
                        }
                    } elseif ($OriginalANSI8) {
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            Write-ColorWarningMsg "ANSI8 mode expects integer code (0-255) or color name, but received RGB array. Use -TrueColor for RGB arrays."
                            Write-DebugLog "Type mismatch: RGB array provided for ANSI8"
                        } elseif ($currentColor -is [int]) {
                            if ($currentColor -lt 0 -or $currentColor -gt 255) {
                                Write-ColorWarningMsg "ANSI8 color code $currentColor is out of range (0-255). Using Gray (7)."
                                $currentColor = 7
                            }
                        }
                    }

                    # Where the terminal shows bold as brighter colors, the color is made lighter instead
                    if ($Bold -and -not $script:SupportsBoldFonts) {
                        Write-DebugLog "Bold enabled but terminal doesn't support bold fonts - auto-lightening color"

                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $currentColor = Get-LighterRGBColor -RGB $currentColor
                            Write-DebugLog "RGB color lightened to: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])"
                        } elseif ($currentColor -is [int]) {
                            # ANSI4 codes are left to the terminal, which brightens them for bold
                            if ($ANSI8 -and $currentColor -ge 0 -and $currentColor -le 255) {
                                $originalCode = $currentColor
                                $currentColor = Get-LighterANSI8Color -ANSI8Code $currentColor
                                Write-DebugLog "ANSI8 code $originalCode algorithmically lightened to $currentColor"
                            }
                        } elseif ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x') {
                            $lightenedName = Get-LighterColorName -ColorName $currentColor
                            if ($lightenedName -ne $currentColor) {
                                $currentColor = $lightenedName
                                Write-DebugLog "Color name lightened from $($Color[$colorIndex]) to $currentColor"
                            } else {
                                # No lighter name: ANSI8 and TrueColor lighten the color's value instead
                                if ($ANSI8 -and $Colors.ContainsKey($currentColor)) {
                                    $ansi8Code = $Colors[$currentColor][3]
                                    $lightenedCode = Get-LighterANSI8Color -ANSI8Code $ansi8Code
                                    $currentColor = $lightenedCode
                                    Write-DebugLog "Color name $($Color[$colorIndex]) algorithmically lightened in ANSI8 from code $ansi8Code to $lightenedCode"
                                } elseif ($ANSI24 -and $Colors.ContainsKey($currentColor)) {
                                    $rgb = $Colors[$currentColor][4]
                                    $lightenedRGB = Get-LighterRGBColor -RGB $rgb
                                    $currentColor = $lightenedRGB
                                    Write-DebugLog "Color name $($Color[$colorIndex]) algorithmically lightened in ANSI24 from RGB to R=$($lightenedRGB[0]) G=$($lightenedRGB[1]) B=$($lightenedRGB[2])"
                                }
                            }
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $currentColor = Get-LighterRGBColor -RGB $rgb
                            Write-DebugLog "Hex color $($Color[$colorIndex]) converted to RGB and lightened"
                        }
                    }

                    # Converted for the mode in use after any fallback
                    if ($ANSI24) {
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $null = $ProcessedColors.Add($currentColor)
                            Write-DebugLog "RGB array color: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])"
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $null = $ProcessedColors.Add($rgb)
                            Write-DebugLog "Hex color $currentColor converted to RGB: R=$($rgb[0]) G=$($rgb[1]) B=$($rgb[2])"
                        } elseif ($currentColor -is [string]) {
                            $colorEntry = $Colors[$currentColor]
                            if ($colorEntry) {
                                $null = $ProcessedColors.Add($colorEntry[4])
                                Write-DebugLog "Named color $currentColor mapped to RGB"
                            } else {
                                $null = $ProcessedColors.Add($currentColor)
                            }
                        } else {
                            $null = $ProcessedColors.Add($currentColor)
                        }
                    } elseif ($ANSI8 -and $OriginalTrueColor) {
                        # TrueColor fell back to ANSI8
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $ansi8Code = Convert-RGBToANSI8 -RGB $currentColor
                            $null = $ProcessedColors.Add($ansi8Code)
                            Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI8: $ansi8Code"
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $ansi8Code = Convert-RGBToANSI8 -RGB (Convert-HexToRGB -Hex $currentColor)
                            $null = $ProcessedColors.Add($ansi8Code)
                            Write-DebugLog "Hex $currentColor converted to ANSI8: $ansi8Code"
                        } else {
                            $null = $ProcessedColors.Add($currentColor)
                        }
                    } elseif ($ANSI4 -and $OriginalTrueColor) {
                        # TrueColor fell back to ANSI4
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $ansi4Code = Convert-RGBToANSI4 -RGB $currentColor
                            $null = $ProcessedColors.Add($ansi4Code)
                            Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI4: $ansi4Code"
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $ansi4Code = Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor)
                            $null = $ProcessedColors.Add($ansi4Code)
                            Write-DebugLog "Hex $currentColor converted to ANSI4: $ansi4Code"
                        } else {
                            $null = $ProcessedColors.Add($currentColor)
                        }
                    } elseif (-not $ANSISupport -and $OriginalTrueColor) {
                        # TrueColor fell back to console colors, through the nearest ANSI4 code
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $nativeColor = ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB $currentColor)
                            $null = $ProcessedColors.Add($nativeColor)
                            Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to Native: $nativeColor"
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $nativeColor = ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor))
                            $null = $ProcessedColors.Add($nativeColor)
                            Write-DebugLog "Hex $currentColor converted to Native: $nativeColor"
                        } else {
                            $null = $ProcessedColors.Add($currentColor)
                        }
                    } elseif ($currentColor -is [int] -and $ANSI4 -and $OriginalANSI8) {
                        # ANSI8 fell back to ANSI4
                        $ansi4Code = ConvertANSI8ToANSI4 -Code $currentColor
                        $null = $ProcessedColors.Add($ansi4Code)
                        Write-DebugLog "ANSI8 code $currentColor converted to ANSI4: $ansi4Code"
                    } elseif ($currentColor -is [int] -and -not $ANSISupport -and ($OriginalANSI8 -or $OriginalANSI4)) {
                        # ANSI8 or ANSI4 fell back to console colors
                        $ansi4Code = if ($OriginalANSI8) { ConvertANSI8ToANSI4 -Code $currentColor } else { $currentColor }
                        $nativeColor = ConvertANSI4ToNativeColor -Code $ansi4Code
                        $null = $ProcessedColors.Add($nativeColor)
                        Write-DebugLog "Color code $currentColor converted to Native: $nativeColor"
                    } else {
                        $null = $ProcessedColors.Add($currentColor)
                    }
                }

                $Color = $ProcessedColors.ToArray()
            } Else {
                $Color = @()
            }

            # Each segment's background color, cycling through -BackGroundColor, converted for the active mode
            If ($BackGroundColor.Count -gt 0 -and -not $ColorDisabled) {
                Write-DebugLog "Processing $($BackGroundColor.Count) background colors"
                $ProcessedBGColors = [System.Collections.Generic.List[object]]::new()

                For ($i = 0; $i -lt $Text.Length; $i++) {
                    $colorIndex = $i % $BackGroundColor.Count
                    $currentColor = $BackGroundColor[$colorIndex]

                    if ($null -eq $currentColor -or $currentColor -eq "None") {
                        $null = $ProcessedBGColors.Add($null)
                        continue
                    }

                    # Checked against the mode asked for, before any fallback
                    if ($OriginalTrueColor) {
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $r = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[0]))
                            $g = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[1]))
                            $b = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[2]))

                            if ($r -ne $currentColor[0] -or $g -ne $currentColor[1] -or $b -ne $currentColor[2]) {
                                Write-ColorWarningMsg "Background RGB values out of range (0-255). Original: @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])). Clamped to: @($r,$g,$b)"
                                $currentColor = @($r, $g, $b)
                            }
                        } elseif ($currentColor -is [int] -and -not $impliedTrueColor) {
                            Write-ColorWarningMsg "TrueColor mode expects RGB array @(R,G,B) or hex color for background, but received integer code $currentColor. Use -ANSI8 or -ANSI4 for integer codes."
                            Write-DebugLog "Type mismatch: integer $currentColor provided for TrueColor background"
                        }
                    } elseif ($OriginalANSI8) {
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            Write-ColorWarningMsg "ANSI8 mode expects integer code (0-255) or color name for background, but received RGB array. Use -TrueColor for RGB arrays."
                            Write-DebugLog "Type mismatch: RGB array provided for ANSI8 background"
                        } elseif ($currentColor -is [int]) {
                            if ($currentColor -lt 0 -or $currentColor -gt 255) {
                                Write-ColorWarningMsg "Background ANSI8 color code $currentColor is out of range (0-255). Using Gray (7)."
                                $currentColor = 7
                            }
                        }
                    }

                    # Where the terminal shows bold as brighter colors, the color is made lighter instead
                    if ($Bold -and -not $script:SupportsBoldFonts) {
                        Write-DebugLog "Bold enabled but terminal doesn't support bold fonts - auto-lightening background color"

                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $currentColor = Get-LighterRGBColor -RGB $currentColor
                            Write-DebugLog "Background RGB color lightened to: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])"
                        } elseif ($currentColor -is [int]) {
                            # ANSI4 codes are left to the terminal, which brightens them for bold
                            if ($ANSI8 -and $currentColor -ge 0 -and $currentColor -le 255) {
                                $originalCode = $currentColor
                                $currentColor = Get-LighterANSI8Color -ANSI8Code $currentColor
                                Write-DebugLog "Background ANSI8 code $originalCode algorithmically lightened to $currentColor"
                            }
                        } elseif ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x') {
                            $lightenedName = Get-LighterColorName -ColorName $currentColor
                            if ($lightenedName -ne $currentColor) {
                                $currentColor = $lightenedName
                                Write-DebugLog "Background color name lightened from $($BackGroundColor[$colorIndex]) to $currentColor"
                            } else {
                                # No lighter name: ANSI8 and TrueColor lighten the color's value instead
                                if ($ANSI8 -and $Colors.ContainsKey($currentColor)) {
                                    $ansi8Code = $Colors[$currentColor][3]
                                    $lightenedCode = Get-LighterANSI8Color -ANSI8Code $ansi8Code
                                    $currentColor = $lightenedCode
                                    Write-DebugLog "Background color name $($BackGroundColor[$colorIndex]) algorithmically lightened in ANSI8 from code $ansi8Code to $lightenedCode"
                                } elseif ($ANSI24 -and $Colors.ContainsKey($currentColor)) {
                                    $rgb = $Colors[$currentColor][4]
                                    $lightenedRGB = Get-LighterRGBColor -RGB $rgb
                                    $currentColor = $lightenedRGB
                                    Write-DebugLog "Background color name $($BackGroundColor[$colorIndex]) algorithmically lightened in ANSI24 from RGB to R=$($lightenedRGB[0]) G=$($lightenedRGB[1]) B=$($lightenedRGB[2])"
                                }
                            }
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $rgb = Convert-HexToRGB -Hex $currentColor
                            $currentColor = Get-LighterRGBColor -RGB $rgb
                            Write-DebugLog "Background hex color $($BackGroundColor[$colorIndex]) converted to RGB and lightened"
                        }
                    }

                    # Converted for the mode in use after any fallback
                    if ($ANSI24) {
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $null = $ProcessedBGColors.Add($currentColor)
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $null = $ProcessedBGColors.Add((Convert-HexToRGB -Hex $currentColor))
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
                        # TrueColor fell back to ANSI8
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $ansi8Code = Convert-RGBToANSI8 -RGB $currentColor
                            $null = $ProcessedBGColors.Add($ansi8Code)
                            Write-DebugLog "Background RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI8: $ansi8Code"
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $ansi8Code = Convert-RGBToANSI8 -RGB (Convert-HexToRGB -Hex $currentColor)
                            $null = $ProcessedBGColors.Add($ansi8Code)
                            Write-DebugLog "Background hex $currentColor converted to ANSI8: $ansi8Code"
                        } else {
                            $null = $ProcessedBGColors.Add($currentColor)
                        }
                    } elseif ($ANSI4 -and $OriginalTrueColor) {
                        # TrueColor fell back to ANSI4; a background code is the foreground code plus 10
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $ansi4Code = (Convert-RGBToANSI4 -RGB $currentColor) + 10
                            $null = $ProcessedBGColors.Add($ansi4Code)
                            Write-DebugLog "Background RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI4: $ansi4Code"
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $ansi4Code = (Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor)) + 10
                            $null = $ProcessedBGColors.Add($ansi4Code)
                            Write-DebugLog "Background hex $currentColor converted to ANSI4: $ansi4Code"
                        } else {
                            $null = $ProcessedBGColors.Add($currentColor)
                        }
                    } elseif (-not $ANSISupport -and $OriginalTrueColor) {
                        # TrueColor fell back to console colors, through the nearest ANSI4 code
                        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
                            $null = $ProcessedBGColors.Add((ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB $currentColor)))
                        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
                            $null = $ProcessedBGColors.Add((ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor))))
                        } else {
                            $null = $ProcessedBGColors.Add($currentColor)
                        }
                    } elseif ($currentColor -is [int] -and $ANSI4 -and $OriginalANSI8) {
                        # ANSI8 fell back to ANSI4; a background code is the foreground code plus 10
                        $ansi4Code = (ConvertANSI8ToANSI4 -Code $currentColor) + 10
                        $null = $ProcessedBGColors.Add($ansi4Code)
                        Write-DebugLog "Background ANSI8 code $currentColor converted to ANSI4: $ansi4Code"
                    } elseif ($currentColor -is [int] -and -not $ANSISupport -and ($OriginalANSI8 -or $OriginalANSI4)) {
                        # ANSI8 or ANSI4 fell back to console colors
                        $ansi4Code = if ($OriginalANSI8) { ConvertANSI8ToANSI4 -Code $currentColor } else { $currentColor }
                        $null = $ProcessedBGColors.Add((ConvertANSI4ToNativeColor -Code $ansi4Code))
                    } else {
                        $null = $ProcessedBGColors.Add($currentColor)
                    }
                }

                $BackGroundColor = $ProcessedBGColors.ToArray()
            } Else {
                $BackGroundColor = @()
            }

            Write-DebugLog "Starting text output"

            # What comes before the text: centering, tabs and spaces, then the time
            $prefix = ''
            If ($HorizontalCenter -and $WindowWidth -gt 0) {
                $MessageLength = Measure-DisplayWidth -Text ($Text -join '')
                If ($WindowWidth -ge $MessageLength) {
                    $CenterPosition = [int][Math]::Max(0, $WindowWidth / 2 - [Math]::Floor($MessageLength / 2))
                    $prefix += ' ' * $CenterPosition
                }
            }
            If ($StartTab -gt 0) {
                $prefix += "`t" * $StartTab
            }
            If ($StartSpaces -gt 0) {
                $prefix += ' ' * $StartSpaces
            }
            $timeText = ''
            If ($ShowTime) {
                $timeText = "[$([datetime]::Now.ToString($DateTimeFormat))] "
            }

            For ($i = 0; $i -lt $LinesBefore; $i++) {
                Write-Host ''
            }

            If ($ColorDisabled) {
                # One call, no colors or styles
                $line = $prefix + $timeText + ($Text -join '')
                If ($line.Length -gt 0 -or -not $NoNewLine) {
                    Write-Host -Object $line -NoNewline:$NoNewLine
                }
            } ElseIf ($ANSISupport -or $ComposeLine) {
                # One call, the colors and styles as escape codes
                $builder = [System.Text.StringBuilder]::new()
                [void]$builder.Append($prefix)
                If ($timeText) {
                    [void]$builder.Append("$esc[90m$timeText$($ANSI['Reset'])")
                }

                If ($gradientArray) {
                    Write-DebugLog "Using gradient mode for output"
                    $charIndex = 0

                    For ($segmentIdx = 0; $segmentIdx -lt $Text.Length; $segmentIdx++) {
                        $segment = $Text[$segmentIdx]

                        $explicitColor = $null
                        if ($segmentIdx -lt $Color.Count) {
                            $explicitColor = $Color[$segmentIdx]
                        }

                        if ($null -ne $explicitColor) {
                            # A segment with its own color keeps it instead of the gradient
                            Write-DebugLog "Segment $segmentIdx has explicit color override (skipping gradient)"
                            [void]$builder.Append((Get-StyleSequence -Index $segmentIdx))
                            [void]$builder.Append((Get-ColorSequence -Value $explicitColor -Background $false))
                            [void]$builder.Append($segment)
                            [void]$builder.Append($ANSI['Reset'])
                            $charIndex += $gradientCharacters[$segmentIdx].Count
                        } else {
                            [void]$builder.Append((Get-StyleSequence -Index $segmentIdx))
                            foreach ($char in $gradientCharacters[$segmentIdx]) {
                                $gradientColor = $gradientArray[$charIndex]
                                If ($ANSI24 -and $gradientColor -is [array] -and $gradientColor.Count -eq 3) {
                                    [void]$builder.Append("$esc[38;2;$($gradientColor[0]);$($gradientColor[1]);$($gradientColor[2])m")
                                } ElseIf ($ANSI8 -and $gradientColor -is [int]) {
                                    [void]$builder.Append("$esc[38;5;${gradientColor}m")
                                }
                                [void]$builder.Append($char)
                                $charIndex++
                            }
                            [void]$builder.Append($ANSI['Reset'])
                        }
                    }
                } Else {
                    For ($i = 0; $i -lt $Text.Length; $i++) {
                        $codes = ''
                        If ($ANSISupport) {
                            $codes = Get-StyleSequence -Index $i
                        }
                        If ($i -lt $Color.Count) {
                            $codes += Get-ColorSequence -Value $Color[$i] -Background $false
                        }
                        If ($i -lt $BackGroundColor.Count) {
                            $codes += Get-ColorSequence -Value $BackGroundColor[$i] -Background $true
                        }
                        [void]$builder.Append($codes)
                        [void]$builder.Append($Text[$i])
                        If ($codes.Length -gt 0) {
                            [void]$builder.Append($ANSI['Reset'])
                        }
                    }
                }

                $line = $builder.ToString()
                If ($line.Length -gt 0 -or -not $NoNewLine) {
                    Write-Host -Object $line -NoNewline:$NoNewLine
                }
            } Else {
                # One call per color, each with -ForegroundColor and -BackgroundColor
                $pieces = [System.Collections.Generic.List[object]]::new()
                If ($prefix) {
                    $pieces.Add(@{ Text = $prefix; Fg = $null; Bg = $null })
                }
                If ($timeText) {
                    $pieces.Add(@{ Text = $timeText; Fg = 'DarkGray'; Bg = $null })
                }
                For ($i = 0; $i -lt $Text.Length; $i++) {
                    $fg = $null
                    $bg = $null
                    If ($i -lt $Color.Count -and $null -ne $Color[$i]) {
                        $fg = Get-NativeColorName -Value $Color[$i] -Background $false
                    }
                    If ($i -lt $BackGroundColor.Count -and $null -ne $BackGroundColor[$i]) {
                        $bg = Get-NativeColorName -Value $BackGroundColor[$i] -Background $true
                    }
                    $pieces.Add(@{ Text = [string]$Text[$i]; Fg = $fg; Bg = $bg })
                }

                # White space with no background shows no foreground color, so it joins a
                # neighbor with no background; pieces of one color pair go out together
                $merged = [System.Collections.Generic.List[object]]::new()
                foreach ($piece in $pieces) {
                    if ($piece.Text.Length -eq 0) { continue }
                    $previousPiece = if ($merged.Count -gt 0) { $merged[$merged.Count - 1] } else { $null }
                    $blank = [string]::IsNullOrWhiteSpace($piece.Text) -and $null -eq $piece.Bg
                    if ($null -ne $previousPiece -and $null -eq $previousPiece.Bg -and $blank) {
                        $previousPiece.Text += $piece.Text
                        continue
                    }
                    if ($null -ne $previousPiece -and $previousPiece.Fg -eq $piece.Fg -and $previousPiece.Bg -eq $piece.Bg) {
                        $previousPiece.Text += $piece.Text
                        continue
                    }
                    if ($null -ne $previousPiece -and $null -eq $piece.Bg -and $null -eq $previousPiece.Bg -and [string]::IsNullOrWhiteSpace($previousPiece.Text)) {
                        $piece.Text = $previousPiece.Text + $piece.Text
                        $merged[$merged.Count - 1] = $piece
                        continue
                    }
                    $merged.Add($piece)
                }

                If ($merged.Count -eq 0) {
                    If (-not $NoNewLine) {
                        Write-Host ''
                    }
                } Else {
                    $lastPiece = $merged.Count - 1
                    For ($p = 0; $p -le $lastPiece; $p++) {
                        $piece = $merged[$p]
                        $hostParameters = @{
                            Object = $piece.Text
                            NoNewline = ($p -lt $lastPiece) -or $NoNewLine
                        }
                        if ($piece.Fg) { $hostParameters['ForegroundColor'] = $piece.Fg }
                        if ($piece.Bg) { $hostParameters['BackgroundColor'] = $piece.Bg }
                        Write-Host @hostParameters
                    }
                }
            }

            For ($i = 0; $i -lt $LinesAfter; $i++) {
                Write-Host ''
            }
        }

        If ($Text.Count -and $LogFile) {
            Write-DebugLog "Writing to log file: $LogFile"

            $logName = $LogFile
            If ($logName -notmatch '[\\/]') {
                if ($logName -notmatch '\.\w+$') {
                    $logName += '.log'
                }
                $folder = $LogPath
                If ([string]::IsNullOrEmpty($folder)) {
                    $folder = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
                }
                $logName = Join-Path -Path $folder -ChildPath $logName
            }
            $LogFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($logName)

            $LogInfo = ''
            If ($LogTime) {
                $LogInfo += "[$([datetime]::Now.ToString($DateTimeFormat))]"
            }
            If ($LogLevel.Length -gt 0) {
                $LogInfo += "[$LogLevel]"
            }
            $TextToFile = $Text -join ''
            $entry = If ($LogInfo) { "$LogInfo $TextToFile" } Else { $TextToFile }
            If (-not $NoNewLine) {
                $entry += [System.Environment]::NewLine
            }
            $logEncoding = Get-ColorLogEncoding -Name $Encoding

            $Saved = $False
            $Retry = 0
            $attempts = [Math]::Max(1, $LogRetry)
            Do {
                $Retry++
                try {
                    $logFolder = [System.IO.Path]::GetDirectoryName($LogFilePath)
                    If ($logFolder -and -not [System.IO.Directory]::Exists($logFolder)) {
                        $null = [System.IO.Directory]::CreateDirectory($logFolder)
                    }
                    [System.IO.File]::AppendAllText($LogFilePath, $entry, $logEncoding)
                    $Saved = $true
                    Write-DebugLog "Successfully wrote to log file"
                } Catch {
                    If ($Retry -ge $attempts) {
                        Write-Warning "Write-ColorEX - Couldn't write to log file $($_.Exception.Message). Tried ($Retry/$attempts)"
                    } Else {
                        Write-DebugLog "Log write failed, retrying... ($Retry/$attempts)"
                        Start-Sleep -Milliseconds 50
                    }
                }
            } Until ($Saved -or $Retry -ge $attempts)
        }

        Write-DebugLog "Write-ColorEX completed"
    }
}
