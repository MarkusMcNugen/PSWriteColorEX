Function Write-ColorEX {
    <#
    .SYNOPSIS
    Writes colored and styled text to the host, with optional padding, alignment and logging to a file.

    .DESCRIPTION
    Write-ColorEX writes text through Write-Host with more color, style and layout options:

    - Color modes: the console's 16 colors, ANSI 4-bit (16 colors), ANSI 8-bit (256 colors) and 24-bit TrueColor
    - Color formats: color names, hex codes (#RRGGBB, #RGB), rgb(r, g, b), hsl(h, s%, l%), RGB arrays @(R,G,B) and ANSI color numbers
    - Gradients across the characters of the text and of its background, between 2 or more colors
    - Markup tags that color and style part of a string, and patterns that color the text they match
    - Splitting a string into segments at separators or into equal parts, each with its own colors
    - Padding, centering and cutting to a display width (-AutoPad) that counts wide characters such as emoji and CJK as 2 cells, and wrapping to a width
    - Styles: Bold, Italic, Underline (single, double, curly, dotted or dashed, in a color of its own), Blink, Faint, CrossedOut, DoubleUnderline, Overline, Reverse
    - Links that terminals open when clicked
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
    then the console's 16 colors. These environment variables are read on each call, and the
    first of them that is set decides:

    - FORCE_COLOR=1, 2 or 3 sets the color mode: ANSI4, ANSI8 or TrueColor
    - FORCE_COLOR=0 or NO_COLOR turns colors and styles off
    - CLICOLOR_FORCE, set to anything but 0, keeps colors on: the support detected, or ANSI4
    - CLICOLOR=0 or TERM=dumb turns colors and styles off

    .PARAMETER Text
    The text to write. Several strings are written on one line, each with its own colors and styles.
    Strings piped in are written one line each.

    Example: -Text 'Hello', ' ', 'World'

    .PARAMETER Color
    The foreground color of each text segment, in any of these forms:

    - Color names: 'Red', 'Blue', 'DarkGreen', 'Cyan', and the other names of 44 color families, most with Dark and Light variants (Get-ColorTableWithRGB lists them)
    - Hex codes: '#FF0000', '0xFF0000', and the short forms '#F00' and '0xF00'
    - CSS forms: 'rgb(255, 0, 0)', and 'hsl(0, 100%, 50%)' with the hue in degrees
    - RGB arrays: @(255, 0, 0) with -TrueColor, or one RGB array per segment, @(@(255, 0, 0), @(0, 0, 255))
    - ANSI color numbers: 0-255 with -ANSI8, the ANSI4 codes with -ANSI4, and 0-15 (System.ConsoleColor) otherwise

    A hex code, an rgb() or hsl() color, or an RGB array is a TrueColor color. Without -TrueColor,
    -ANSI8 or -ANSI4, it is written in the best mode the terminal has: TrueColor, or the nearest
    256-color, 16-color or console color. With -ANSI8 or -ANSI4, a hex code, rgb() or hsl() color
    is written as the nearest color of that mode; an RGB array is one color only with -TrueColor.

    A color name is written in the mode the call uses: from its RGB value with -TrueColor or with
    a TrueColor color or a gradient in the call, as its 256-color number with -ANSI8, and
    otherwise as its 16-color code or console color.

    With fewer colors than text segments the colors repeat; extra colors are ignored. A $null or
    'None' entry leaves its segment in the terminal's default color, or to the gradient with
    -Gradient. A name the color table lacks gives a warning and leaves its segment in the
    terminal's default color. Without -Color the text takes the terminal's default color.

    Aliases: C, ForegroundColor, FGC

    Example: -Color 'Red', 'Blue' -or- -Color '#FF8000' -or- -Color @(255,128,0) -TrueColor

    .PARAMETER BackGroundColor
    The background color of each text segment, in the same forms as -Color. A $null or 'None'
    entry leaves its segment on the terminal's default background, as does leaving it out.

    Aliases: B, BGC

    Example: -BackGroundColor 'DarkRed' -or- -BackGroundColor '#2C2C2C'

    .PARAMETER Gradient
    Two or more colors to blend across the characters of the text. Each character takes a color
    interpolated between the colors given.

    A gradient needs ANSI 8-bit or TrueColor support and selects the best mode available.
    A segment with a color in -Color keeps that color instead of the gradient, and a $null entry
    leaves its segment to the gradient. -Color repeats its colors over the segments, so
    -Color $null, 'Yellow', $null colors the second of three segments yellow and the others
    with the gradient. -GradientSpace sets how the colors blend.

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

    Valid styles: Bold, Faint, Italic, Underline, Blink, CrossedOut, DoubleUnderline, Overline, Reverse

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
    Suppresses the warnings about colors that are unknown, out of range or of the wrong form, about
    markup tags and -Highlight styles that are not styles, and about fallbacks to a color mode the
    terminal supports.

    .PARAMETER Markup
    Reads tags in the text that color and style part of it: [style]text[/]. A tag holds style
    names, a text color, 'on' and a background color, and link=URL, separated by spaces. [/]
    closes the tag opened last, and a tag left open closes at the end of its string. [[ and ]]
    write [ and ]. A tag that is not a style is written as it is, with a warning.

    - Style names: bold, faint (dim), italic, underline, doubleunderline, curly, dotted, dashed, blink, crossedout (strike, strikethrough), overline, reverse (invert)
    - Colors: the names Get-ColorTableWithRGB lists, hex codes, rgb(r, g, b) and hsl(h, s%, l%)

    A tag's colors go over -Color, -BackGroundColor and the gradients for its text. Tags nest: an
    inner tag takes the colors and link it does not set from the tag around it, and the styles of
    both.

    Example: -Text '[bold red]Error:[/] file not found' -Markup
    Example: -Text '[white on #005F87] OK [/] see [link=https://example.com]the log[/]' -Markup

    .PARAMETER Split
    Cuts each text segment after each of these separators, so -Color and the other parameters
    that take one value per segment color the parts in turn, without the text given in pieces.
    The separator stays at the end of the part before it. Separators are matched as written, with
    case; where several match at one place, the longest is used. Only one of -Split, -SplitAround
    and -SplitEvenly is used in a call.

    Example: -Text 'one,two,three' -Split ',' -Color Red, Green, Blue
    Output: "one," in red, "two," in green, "three" in blue

    .PARAMETER SplitAround
    Cuts each text segment before and after each of these separators, so each separator is a
    segment of its own and takes colors of its own.

    Example: -Text 'key=value' -SplitAround '=' -Color Cyan, DarkGray, White
    Output: "key" in cyan, "=" in dark gray, "value" in white

    .PARAMETER SplitEvenly
    Cuts each text segment into as many parts as -Color has colors (-BackGroundColor's, without
    -Color), of equal length in display characters. When they cannot be equal, the first parts
    are one character longer.

    Example: -Text 'STATUS' -SplitEvenly -Color Red, Yellow, Green
    Output: "ST" in red, "AT" in yellow, "US" in green

    .PARAMETER Highlight
    Colors and styles the text that patterns match: a hashtable of .NET regular expressions, each
    with a style written as a markup tag's contents. Matching ignores case and runs over the whole
    line. Where the matches of two patterns overlap, the pattern listed first wins; an ordered
    hashtable, [ordered]@{ }, keeps the order given. A pattern that is not a valid regular
    expression stops the command with an error, and a style that is not a style skips its
    pattern with a warning.

    Example: -Text 'ERROR: disk full on /dev/sda1' -Highlight @{ 'error' = 'bold red'; '/dev/\w+' = 'cyan underline' }

    .PARAMETER Link
    Makes each segment a link to the address given, which terminals that support links (OSC 8)
    open when it is clicked: Windows Terminal, iTerm2, WezTerm, Kitty, GNOME Terminal and others.
    The addresses repeat over the segments as -Color's colors do, and a $null entry leaves its
    segment without a link. Other terminals show the text alone. Links are written only where
    colors are.

    Example: -Text 'See ', 'the docs' -Link $null, 'https://github.com/MarkusMcNugen/PSWriteColorEX'

    .PARAMETER Reverse
    Swaps the text and background colors.

    Alias: Invert

    .PARAMETER BackGroundGradient
    Two or more colors to blend across the background of the text, as -Gradient does for the
    text. A segment with a color in -BackGroundColor keeps it, and a $null entry leaves its
    segment to the gradient.

    Alias: BGGrad

    Example: -Text ' Deploying ' -Color White -BackGroundGradient '#1D976C', '#93F9B9'

    .PARAMETER GradientSpace
    How -Gradient and -BackGroundGradient blend their colors:

    - OKLab: in the OKLab color space, where equal steps look equally far apart and the brightness stays even. Red to green passes through a golden yellow rather than a dark olive, and blue to yellow through a light blue rather than gray.
    - RGB: red, green and blue each on their own.

    Default: OKLab

    .PARAMETER UnderlineColor
    The color of each segment's underline, in the forms of -Color; the colors repeat over the
    segments. A segment with an underline color and no other underline is underlined with one
    line. A terminal without underline colors draws the underline in the text color.

    Example: -Text 'misspeled' -UnderlineStyle Curly -UnderlineColor Red

    .PARAMETER UnderlineStyle
    The kind of underline for every segment: Single, Double, Curly, Dotted or Dashed. A terminal
    without the kind draws a single line, or none.

    .PARAMETER Truncate
    With -AutoPad, cuts text wider than -AutoPad to fit, ending it with an ellipsis (…) in the
    colors of the text it replaces.

    Example: -Text 'C:\a\very\long\path\to\a\file.txt' -AutoPad 20 -Truncate
    Output: "C:\a\very\long\path…"

    .PARAMETER PadCenter
    With -AutoPad, centers the text, padding on both sides. With an odd number of padding
    characters, the right side has one more.

    Example: -Text 'Menu' -AutoPad 10 -PadCenter -PadChar '='
    Output: "===Menu==="

    .PARAMETER Wrap
    Breaks text wider than the line into lines, at the last space that fits; a word wider than
    the line breaks between characters, and a line end in the text starts a new line. The width
    is -AutoPad, or without it the console window's width less the indentation and the time.
    Each line gets the indentation, and lines after the first get spaces in place of the time.
    With -AutoPad each line is padded. Without a known width, as with output redirected to a
    file, nothing wraps. With -Truncate, the text is cut to one line instead.

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

    .EXAMPLE
    Write-ColorEX -Text '[bold green]PASS[/] 12 tests, [bold red]FAIL[/] 1 test' -Markup

    Writes "PASS" in bold green and "FAIL" in bold red, the rest in the terminal's colors.

    .EXAMPLE
    Write-ColorEX -Text 'GET /api/users 200 12ms' -Split ' ' -Color Cyan, White, Green, DarkGray

    Writes each word of a log line in its own color, the space after it with it.

    .EXAMPLE
    Get-Content app.log | Write-ColorEX -Highlight ([ordered]@{ '\bERROR\b' = 'bold red'; '\bWARN\b' = 'yellow'; '\d+ms' = 'cyan' })

    Writes each line of a log file with ERROR, WARN and durations colored.

    .EXAMPLE
    Write-ColorEX -Text 'Release notes' -Link 'https://github.com/MarkusMcNugen/PSWriteColorEX/releases' -Underline

    Writes a link that terminals with link support open when it is clicked.

    .NOTES
    Name: Write-ColorEX
    Author: Mark Newton
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

    .LINK
    Format-ColorEX
    #>
    [CmdletBinding()]
    [Alias('Write-ColourEX', 'Write-Color', 'Write-Colour', 'WC', 'WCEX', 'wcolor', 'wcolour')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [alias ('T')][string[]] $Text,
        [alias ('C', 'ForegroundColor', 'FGC')][array] $Color = $null,
        [alias ('B', 'BGC')][array] $BackGroundColor = $null,
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
        [alias('PaddingChar', 'FillChar')][char] $PadChar = ' ',
        [switch] $Markup,
        [string[]] $Split,
        [string[]] $SplitAround,
        [switch] $SplitEvenly,
        [System.Collections.IDictionary] $Highlight,
        [string[]] $Link,
        [alias('Invert')][switch] $Reverse,
        [AllowNull()]
        [alias ('BGGrad')][object[]] $BackGroundGradient = $null,
        [ValidateSet('OKLab', 'RGB')][string] $GradientSpace = 'OKLab',
        [array] $UnderlineColor = $null,
        [ValidateSet('Single', 'Double', 'Curly', 'Dotted', 'Dashed')][string] $UnderlineStyle,
        [switch] $Truncate,
        [switch] $PadCenter,
        [switch] $Wrap
    )

    begin {
        # The folder of the script that called Write-ColorEX, for a bare -LogFile name
        $callerScriptRoot = $MyInvocation.PSScriptRoot


        # Each entry of -Color, -BackGroundColor and -UnderlineColor is a color: a string, an integer, or an array
        # of those and of arrays, such as an RGB array; or $null, which leaves its segment as it is.
        # A parameter check would refuse the $null entries, so the entries are checked here.
        foreach ($name in 'Color', 'BackGroundColor', 'UnderlineColor') {
            if (-not $PSBoundParameters.ContainsKey($name)) {
                continue
            }
            foreach ($value in @($PSBoundParameters[$name])) {
                $isColor = $null -eq $value -or $value -is [string] -or $value -is [int]
                if (-not $isColor -and $value -is [array]) {
                    $isColor = $true
                    foreach ($item in $value) {
                        if ($item -isnot [string] -and $item -isnot [int] -and $item -isnot [array]) {
                            $isColor = $false
                            break
                        }
                    }
                }
                if (-not $isColor) {
                    $shown = if ($value -is [array]) { $value.GetType().FullName } else { "$value" }
                    $message = "Cannot validate argument on parameter '$name'. The argument `"$shown`" is not a color: a string, an integer, or an array of strings, integers and arrays."
                    $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new($message), 'ParameterArgumentValidationError',
                        [System.Management.Automation.ErrorCategory]::InvalidData, $value))
                }
            }
        }

        # One way of splitting at a time
        $splitCount = 0
        if ($PSBoundParameters.ContainsKey('Split')) { $splitCount++ }
        if ($PSBoundParameters.ContainsKey('SplitAround')) { $splitCount++ }
        if ($SplitEvenly) { $splitCount++ }
        if ($splitCount -gt 1) {
            $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
                [System.ArgumentException]::new('Use only one of -Split, -SplitAround and -SplitEvenly.'), 'SplitConflict',
                [System.Management.Automation.ErrorCategory]::InvalidArgument, $null))
        }

        # -Highlight's patterns, compiled once for every line
        $highlightEntries = @()
        if ($Highlight -and $Highlight.Count -gt 0) {
            if ($null -eq $script:CachedColorTable) {
                $script:CachedColorTable = Get-ColorTableWithRGB
            }
            $highlightEntries = ConvertFrom-ColorHighlight -Highlight $Highlight
        }

        # With piped input, the parameter values as bound, put back before each piped string so
        # one string's processing does not carry into the next
        $boundAtStart = $null
        if ($MyInvocation.ExpectingInput) {
            $variables = $ExecutionContext.SessionState.PSVariable
            $boundAtStart = @{}
            foreach ($name in $MyInvocation.MyCommand.Parameters.Keys) {
                # -Style and -UnderlineStyle are left out: the function does not change them, and
                # their parameter checks would refuse the empty values they hold when not given
                if ($name -eq 'Text' -or $name -eq 'Style' -or $name -eq 'UnderlineStyle') { continue }
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

        if ($Debugging) { Write-DebugLog "Starting Write-ColorEX with Text count: $($Text.Count)" }

        # Format-ColorEX's list for the lines, which then go to it rather than to the host
        $captured = $script:CaptureLines

        if ($null -eq $script:CachedColorTable) {
            $script:CachedColorTable = Get-ColorTableWithRGB
        }
        $Colors = $script:CachedColorTable
        # The color names the table lacks, each warned about once per line
        $unknownColorNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        If ($Gradient -and $Gradient.Count -lt 2) {
            Write-ColorWarningMsg "Gradient requires at least 2 colors (received $($Gradient.Count)). Gradient disabled."
            if ($Debugging) { Write-DebugLog "Gradient validation failed: Only $($Gradient.Count) color(s) provided" }
            $Gradient = $null
        }
        If ($BackGroundGradient -and $BackGroundGradient.Count -lt 2) {
            Write-ColorWarningMsg "BackGroundGradient requires at least 2 colors (received $($BackGroundGradient.Count)). BackGroundGradient disabled."
            $BackGroundGradient = $null
        }

        # Only one color mode applies: TrueColor, then ANSI8, then ANSI4
        $colorModeCount = 0
        if ($ANSI4) { $colorModeCount++ }
        if ($ANSI8) { $colorModeCount++ }
        if ($ANSI24) { $colorModeCount++ }

        if ($colorModeCount -gt 1) {
            Write-Warning "Multiple color modes specified. Only one of -ANSI4, -ANSI8, or -TrueColor should be used."
            if ($ANSI24) {
                if ($Debugging) { Write-DebugLog "Using TrueColor mode (highest priority)" }
                $ANSI4 = $False
                $ANSI8 = $False
            } elseif ($ANSI8) {
                if ($Debugging) { Write-DebugLog "Using ANSI8 mode" }
                $ANSI4 = $False
                $ANSI24 = $False
            } else {
                if ($Debugging) { Write-DebugLog "Using ANSI4 mode" }
                $ANSI8 = $False
                $ANSI24 = $False
            }
        }

        if ($StyleProfile) {
            if ($Debugging) { Write-DebugLog "Applying style profile: $($StyleProfile.Name)" }
            $profileParams = $StyleProfile.ToWriteColorParams()
            foreach ($key in $profileParams.Keys) {
                if (-not $PSBoundParameters.ContainsKey($key)) {
                    $ExecutionContext.SessionState.PSVariable.Set($key, $profileParams[$key])
                }
            }
        }

        if ($Default -and [PSColorStyle]::Default) {
            if ($Debugging) { Write-DebugLog "Applying default style profile" }
            $defaultParams = [PSColorStyle]::Default.ToWriteColorParams()
            foreach ($key in $defaultParams.Keys) {
                if (-not $PSBoundParameters.ContainsKey($key) -and -not $StyleProfile) {
                    $ExecutionContext.SessionState.PSVariable.Set($key, $defaultParams[$key])
                }
            }
        }

        # The styles in use, kept apart from -Style, whose parameter check would refuse the empty
        # array the function puts in it. One style alone is the first segment's, as an array of
        # one; indexing the string itself would read its letters.
        $styles = $Style
        if ($styles -is [string]) {
            $styles = @($styles)
        }

        # Colors written #RGB, 0xRGB, rgb(r, g, b) or hsl(h, s%, l%) read as #RRGGBB, with a
        # warning for each name the color table lacks
        if ($null -ne $Color -and [ColorCode]::NeedsForm($Color, $Colors)) { $Color = ConvertTo-ColorFormList -Values $Color }
        if ($null -ne $BackGroundColor -and [ColorCode]::NeedsForm($BackGroundColor, $Colors)) { $BackGroundColor = ConvertTo-ColorFormList -Values $BackGroundColor }
        if ($null -ne $UnderlineColor -and [ColorCode]::NeedsForm($UnderlineColor, $Colors)) { $UnderlineColor = ConvertTo-ColorFormList -Values $UnderlineColor }
        if ($null -ne $Gradient -and [ColorCode]::NeedsForm($Gradient, $Colors)) { $Gradient = ConvertTo-ColorFormList -Values $Gradient }
        if ($null -ne $BackGroundGradient -and [ColorCode]::NeedsForm($BackGroundGradient, $Colors)) { $BackGroundGradient = ConvertTo-ColorFormList -Values $BackGroundGradient }

        # A hex code or an RGB array asks for TrueColor. Without a color mode given, it takes the
        # best mode the terminal has, without the warnings an explicit -TrueColor gives.
        $impliedTrueColor = $false
        if (-not ($ANSI4 -or $ANSI8 -or $ANSI24) -and ($null -ne $Color -or $null -ne $BackGroundColor -or $null -ne $UnderlineColor)) {
            foreach ($value in @($Color) + @($BackGroundColor) + @($UnderlineColor)) {
                if (($value -is [string] -and $value -match '^#|^0x') -or $value -is [array]) {
                    $impliedTrueColor = $true
                    break
                }
            }
            if ($impliedTrueColor) {
                if ($Debugging) { Write-DebugLog "Hex or RGB color without a color mode: using TrueColor" }
                $ANSI24 = $true
                $Color = [ColorCode]::ConsoleNumbers($Color)
                $BackGroundColor = [ColorCode]::ConsoleNumbers($BackGroundColor)
                $UnderlineColor = [ColorCode]::ConsoleNumbers($UnderlineColor)
            }
        }

        # Three integers for one segment under -TrueColor are one RGB color, not three colors
        if ($ANSI24 -and $Color -and $Color.Count -eq 3 -and
            $Color[0] -is [int] -and $Color[1] -is [int] -and $Color[2] -is [int] -and
            $Text.Count -eq 1) {
            if ($Debugging) { Write-DebugLog "Detected flattened RGB array, wrapping: @($($Color[0]),$($Color[1]),$($Color[2]))" }
            $Color = ,@($Color[0], $Color[1], $Color[2])
        }

        if ($ANSI24 -and $BackGroundColor -and $BackGroundColor.Count -eq 3 -and
            $BackGroundColor[0] -is [int] -and $BackGroundColor[1] -is [int] -and $BackGroundColor[2] -is [int] -and
            $Text.Count -eq 1) {
            if ($Debugging) { Write-DebugLog "Detected flattened RGB array for background, wrapping: @($($BackGroundColor[0]),$($BackGroundColor[1]),$($BackGroundColor[2]))" }
            $BackGroundColor = ,@($BackGroundColor[0], $BackGroundColor[1], $BackGroundColor[2])
        }

        if ($ANSI24 -and $UnderlineColor -and $UnderlineColor.Count -eq 3 -and
            $UnderlineColor[0] -is [int] -and $UnderlineColor[1] -is [int] -and $UnderlineColor[2] -is [int] -and
            $Text.Count -eq 1) {
            $UnderlineColor = ,@($UnderlineColor[0], $UnderlineColor[1], $UnderlineColor[2])
        }

        # The text as segments, each a list of runs: text with the colors, styles and link that
        # markup and -Highlight give it. -Split, -SplitAround and -SplitEvenly cut the segments.
        $segments = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $Text) {
            if ($Markup) {
                $runs = ConvertFrom-ColorMarkup -Text $item
                if ($runs.Count -eq 0) {
                    $runs.Add(@{ Text = ''; HasFg = $false; HasBg = $false; HasLink = $false; Styles = $null })
                }
            } else {
                $runs = [System.Collections.Generic.List[object]]::new()
                $runs.Add(@{ Text = [string]$item; HasFg = $false; HasBg = $false; HasLink = $false; Styles = $null })
            }
            $segments.Add($runs)
        }

        if ($Split -or $SplitAround) {
            $separators = if ($Split) { $Split } else { $SplitAround }
            $segments = Split-ColorSegment -Segments $segments -Separators $separators -Around:([bool]$SplitAround)
        } elseif ($SplitEvenly) {
            $parts = if ($Color.Count -gt 0) { $Color.Count } else { $BackGroundColor.Count }
            if ($parts -gt 1) {
                $segments = Split-ColorSegment -Segments $segments -Parts $parts
            }
        }

        if ($highlightEntries.Count -gt 0) {
            $segments = Add-ColorHighlight -Segments $segments -Entries $highlightEntries
        }

        # Whether markup or -Highlight gives runs colors, or styles or links, which need escape
        # codes. A hex code among their colors asks for TrueColor, as in -Color.
        $runColors = $false
        $runEscapes = $false
        if ($Markup -or $highlightEntries.Count -gt 0) {
            $runHex = $false
            foreach ($segment in $segments) {
                foreach ($run in $segment) {
                    if ($run.HasFg -or $run.HasBg) {
                        $runColors = $true
                        if (($run.HasFg -and $run.Fg -match '^#|^0x') -or ($run.HasBg -and $run.Bg -match '^#|^0x')) {
                            $runHex = $true
                        }
                    }
                    if ($run.HasLink -or ($null -ne $run.Styles -and $run.Styles.Count -gt 0)) {
                        $runEscapes = $true
                    }
                }
            }
            if ($runHex -and -not ($ANSI4 -or $ANSI8 -or $ANSI24)) {
                if ($Debugging) { Write-DebugLog "Hex or RGB color without a color mode: using TrueColor" }
                $impliedTrueColor = $true
                $ANSI24 = $true
                $Color = [ColorCode]::ConsoleNumbers($Color)
                $BackGroundColor = [ColorCode]::ConsoleNumbers($BackGroundColor)
                $UnderlineColor = [ColorCode]::ConsoleNumbers($UnderlineColor)
            }
        }

        # The color mode asked for, before any fallback, which the color checks read
        $OriginalTrueColor = [bool]$ANSI24
        $OriginalANSI8 = [bool]$ANSI8
        $OriginalANSI4 = [bool]$ANSI4

        # Padding to a display width, measured so wide characters count as 2 cells; with -Wrap,
        # each line is padded when it is written
        if ($AutoPad -gt 0) {
            if ($Debugging) { Write-DebugLog "AutoPad processing: Target width = $AutoPad, PadLeft = $PadLeft, PadChar = '$PadChar'" }

            $padCharWidth = Measure-DisplayWidth -Text $PadChar.ToString()

            if ($padCharWidth -eq 0) {
                Write-ColorWarningMsg "PadChar '$PadChar' is a zero-width character and cannot be used for padding. Using space instead."
                $PadChar = ' '
                $padCharWidth = 1
            }

            if ($padCharWidth -gt 1) {
                Write-ColorWarningMsg "PadChar '$PadChar' is a wide character ($padCharWidth cells). Padding alignment may be off."
            }

            if ($Truncate) {
                $segments = Limit-ColorSegmentWidth -Segments $segments -Width $AutoPad
            }

            if (-not $Wrap) {
                $currentWidth = Measure-DisplayWidth -Text ([ColorCode]::SegmentText($segments))
                if ($Debugging) { Write-DebugLog "Current text display width: $currentWidth cells" }

                if ($currentWidth -lt $AutoPad) {
                    $paddingCellsNeeded = $AutoPad - $currentWidth

                    if ($padCharWidth -gt 1) {
                        $padCount = [Math]::Floor($paddingCellsNeeded / $padCharWidth)
                        $remainder = $paddingCellsNeeded % $padCharWidth
                        if ($remainder -ne 0) {
                            if ($Debugging) { Write-DebugLog "Padding width ($paddingCellsNeeded cells) not evenly divisible by PadChar width ($padCharWidth cells). Off by $remainder cell(s)." }
                        }
                    } else {
                        $padCount = $paddingCellsNeeded
                    }

                    if ($padCount -gt 0) {
                        if ($Debugging) { Write-DebugLog "Adding $padCount '$PadChar' character(s) = $($padCount * $padCharWidth) cells" }

                        if ($PadCenter) {
                            $leftCount = [int][Math]::Floor($padCount / 2)
                            if ($leftCount -gt 0) {
                                $segments.Insert(0, [ColorCode]::Segment($PadChar.ToString() * $leftCount))
                            }
                            $segments.Add([ColorCode]::Segment($PadChar.ToString() * ($padCount - $leftCount)))
                            if ($Debugging) { Write-DebugLog "Applied padding on both sides (centered text)" }
                        } elseif ($PadLeft) {
                            $segments.Insert(0, [ColorCode]::Segment($PadChar.ToString() * $padCount))
                            if ($Debugging) { Write-DebugLog "Applied left padding (right-aligned text)" }
                        } else {
                            $segments.Add([ColorCode]::Segment($PadChar.ToString() * $padCount))
                            if ($Debugging) { Write-DebugLog "Applied right padding (left-aligned text)" }
                        }
                    }
                } else {
                    if ($Debugging) { Write-DebugLog "Text width ($currentWidth) >= Target width ($AutoPad). No padding applied." }
                }
            }
        }

        # The color variables, read on each call since they can change at any time. FORCE_COLOR 1 to
        # 3 keeps colors on in its mode; FORCE_COLOR=0 and NO_COLOR turn them off; CLICOLOR_FORCE,
        # set to anything but 0, keeps them on; CLICOLOR=0 and TERM=dumb turn them off. The first
        # of these set decides.
        $forceColor = [System.Environment]::GetEnvironmentVariable('FORCE_COLOR')
        $forcedColor = $forceColor -in @('1', '2', '3')
        $cliColorForced = $false
        $ColorDisabled = $false
        if (-not $forcedColor) {
            if ($forceColor -eq '0' -or -not [string]::IsNullOrEmpty([System.Environment]::GetEnvironmentVariable('NO_COLOR'))) {
                $ColorDisabled = $true
            } else {
                $cliColorForce = [System.Environment]::GetEnvironmentVariable('CLICOLOR_FORCE')
                if (-not [string]::IsNullOrEmpty($cliColorForce) -and $cliColorForce -ne '0') {
                    $cliColorForced = $true
                } elseif ([System.Environment]::GetEnvironmentVariable('CLICOLOR') -eq '0' -or [System.Environment]::GetEnvironmentVariable('TERM') -eq 'dumb') {
                    $ColorDisabled = $true
                }
            }
        }

        $UsingANSIFeatures = $ANSI4 -or $ANSI8 -or $ANSI24 -or $Bold -or $Italic -or $Underline -or
                             $Blink -or $Faint -or $CrossedOut -or $DoubleUnderline -or $Overline -or $styles -or $Gradient -or
                             $Reverse -or $UnderlineStyle -or $UnderlineColor -or $Link -or $BackGroundGradient -or $runEscapes

        $ComposeLine = $false
        If ($ColorDisabled) {
            if ($Debugging) { Write-DebugLog "Colors are off: NO_COLOR, FORCE_COLOR=0, CLICOLOR=0 or TERM=dumb" }
            $ANSISupport = $False
            $ANSIColorSupport = 'None'
            $styles = @()
            $Gradient = $null
            $BackGroundGradient = $null
            $ANSI4 = $False
            $ANSI8 = $False
            $ANSI24 = $False
        } ElseIf (-not $UsingANSIFeatures) {
            # Console colors only: no ANSI detection needed, only whether the line can go out as one call
            $ANSISupport = $False
            $ANSIColorSupport = 'None'
            if ($forcedColor -or $cliColorForced) {
                # FORCE_COLOR and CLICOLOR_FORCE keep the colors as escape codes, whatever the host
                $ComposeLine = $null -ne $captured -or -not $NoConsoleOutput
            } elseif ($null -ne $captured) {
                # A string for Format-ColorEX holds escape codes wherever the host shows them
                $ComposeLine = $script:CachedANSISupport -ne 'None' -and (Test-ColorHostAnsi)
            } else {
                $ComposeLine = (-not $NoConsoleOutput) -and (Test-ColorLineComposition)
            }
            if ($Debugging) { Write-DebugLog "Console colors only; one call per line: $ComposeLine" }
        } Else {
            if ($forcedColor) {
                if ($Debugging) { Write-DebugLog "FORCE_COLOR environment variable detected: $forceColor" }
                switch ($forceColor) {
                    '1' { $ANSIColorSupport = 'ANSI4' }
                    '2' { $ANSIColorSupport = 'ANSI8' }
                    '3' { $ANSIColorSupport = 'TrueColor' }
                }
                if ($Debugging) { Write-DebugLog "FORCE_COLOR override: $ANSIColorSupport" }
            } elseif ($cliColorForced) {
                # CLICOLOR_FORCE keeps the support detected, or the 16 colors where none was found
                if ($null -eq $script:CachedANSISupport) {
                    $script:CachedANSISupport = (Test-AnsiSupport -Silent).ColorSupport
                }
                $ANSIColorSupport = if ($script:CachedANSISupport -eq 'None') { 'ANSI4' } else { $script:CachedANSISupport }
                if ($Debugging) { Write-DebugLog "CLICOLOR_FORCE override: $ANSIColorSupport" }
            } else {
                if ($null -eq $script:CachedANSISupport) {
                    $script:CachedANSISupport = (Test-AnsiSupport -Silent).ColorSupport
                }
                $ANSIColorSupport = $script:CachedANSISupport
                if ($ANSIColorSupport -ne 'None' -and -not (Test-ColorHostAnsi)) {
                    # PowerShell would remove the escape codes before they reach the screen
                    if ($Debugging) { Write-DebugLog "The host renders no escape codes; using console colors" }
                    $ANSIColorSupport = 'None'
                }
                if ($Debugging) { Write-DebugLog "ANSI Color Support: $ANSIColorSupport (cached)" }
            }
            $ANSISupport = $ANSIColorSupport -ne 'None'

            If ($ANSIColorSupport -eq 'None') {
                $styles = @()
                $ANSI4 = $False
                $ANSI8 = $False
                $ANSI24 = $False
                if ($Debugging) { Write-DebugLog "ANSI support disabled - using native PowerShell colors" }
            } ElseIf ($ANSI24 -and $ANSIColorSupport -ne 'TrueColor') {
                if ($ANSIColorSupport -eq 'ANSI8') {
                    if (-not $impliedTrueColor) {
                        Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to ANSI8 (256 colors)."
                    }
                    if ($Debugging) { Write-DebugLog "Downgrading from TrueColor to ANSI8" }
                    $ANSI24 = $False
                    $ANSI8 = $True
                } else {
                    if (-not $impliedTrueColor) {
                        Write-ColorWarningMsg "TrueColor not supported by terminal. Falling back to ANSI4 (16 colors)."
                    }
                    if ($Debugging) { Write-DebugLog "Downgrading from TrueColor to ANSI4" }
                    $ANSI24 = $False
                    $ANSI4 = $True
                }
            } ElseIf ($ANSI8 -and $ANSIColorSupport -eq 'ANSI4') {
                Write-ColorWarningMsg "ANSI8 (256 colors) not supported by terminal. Falling back to ANSI4 (16 colors)."
                if ($Debugging) { Write-DebugLog "Downgrading from ANSI8 to ANSI4" }
                $ANSI8 = $False
                $ANSI4 = $True
            }

            If ($Gradient -and $Gradient.Count -ge 2) {
                if ($Debugging) { Write-DebugLog "Gradient requested with $($Gradient.Count) colors" }

                If ($ANSIColorSupport -eq 'None') {
                    Write-ColorWarningMsg "Gradient requires ANSI 256-color or TrueColor support. Terminal supports: None. Gradient disabled."
                    if ($Debugging) { Write-DebugLog "Gradient disabled: No ANSI support" }
                    $Gradient = $null
                } ElseIf ($ANSIColorSupport -eq 'ANSI4') {
                    Write-ColorWarningMsg "Gradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). Gradient disabled."
                    if ($Debugging) { Write-DebugLog "Gradient disabled: ANSI4 only" }
                    $Gradient = $null
                } Else {
                    If (-not $ANSI8 -and -not $ANSI24) {
                        If ($ANSIColorSupport -eq 'TrueColor') {
                            if ($Debugging) { Write-DebugLog "Gradient: Auto-enabling TrueColor mode" }
                            $ANSI24 = $True
                        } Else {
                            if ($Debugging) { Write-DebugLog "Gradient: Auto-enabling ANSI8 mode" }
                            $ANSI8 = $True
                        }
                    }
                    if ($Debugging) { Write-DebugLog "Gradient enabled in $ANSIColorSupport mode" }
                }
            }

            If ($BackGroundGradient -and $BackGroundGradient.Count -ge 2) {
                If ($ANSIColorSupport -eq 'None') {
                    Write-ColorWarningMsg "BackGroundGradient requires ANSI 256-color or TrueColor support. Terminal supports: None. BackGroundGradient disabled."
                    $BackGroundGradient = $null
                } ElseIf ($ANSIColorSupport -eq 'ANSI4') {
                    Write-ColorWarningMsg "BackGroundGradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). BackGroundGradient disabled."
                    $BackGroundGradient = $null
                } ElseIf (-not $ANSI8 -and -not $ANSI24) {
                    If ($ANSIColorSupport -eq 'TrueColor') {
                        $ANSI24 = $True
                    } Else {
                        $ANSI8 = $True
                    }
                }
            }
        }

        If (-not $NoConsoleOutput) {
            $WindowWidth = 0
            If ($BlankLine -or $HorizontalCenter -or ($Wrap -and $AutoPad -le 0)) {
                $WindowWidth = Get-ColorHostWidth
            }

            If ($BlankLine) {
                if ($Debugging) { Write-DebugLog "Processing blank line" }
                $HorizontalCenter = $False
                $StartTab = 0
                $StartSpaces = 0
                $ShowTime = $False
                $Wrap = $False
                $segments = [System.Collections.Generic.List[object]]::new()
                $segments.Add([ColorCode]::Segment(' ' * $WindowWidth))
            }

            $timeText = ''
            If ($ShowTime) {
                $timeText = "[$([datetime]::Now.ToString($DateTimeFormat))] "
            }

            # The lines to write, each a list of items: the segment whose colors a piece takes, and
            # its runs. Without -Wrap, one line of every segment.
            $segmentCount = $segments.Count
            $lines = [System.Collections.Generic.List[object]]::new()
            $wrapWidth = 0
            If ($Wrap) {
                $wrapWidth = if ($AutoPad -gt 0) { $AutoPad } else { $WindowWidth - 8 * $StartTab - $StartSpaces - (Measure-DisplayWidth -Text $timeText) }
            }
            If ($wrapWidth -gt 0) {
                $lines = Split-ColorLine -Segments $segments -Width $wrapWidth
                If ($AutoPad -gt 0) {
                    $side = if ($PadCenter) { 'Center' } elseif ($PadLeft) { 'Left' } else { 'Right' }
                    $padded = Add-ColorLinePadding -Lines $lines -SegmentCount $segmentCount -Width $AutoPad -PadChar $PadChar.ToString() -PadCharWidth $padCharWidth -Side $side
                    $lines = $padded.Lines
                    $segmentCount = $padded.SegmentCount
                }
            } Else {
                $items = [System.Collections.Generic.List[object]]::new()
                For ($i = 0; $i -lt $segments.Count; $i++) {
                    $items.Add(@{ Index = $i; Runs = $segments[$i] })
                }
                $lines.Add($items)
            }

            # Each run's characters, and where it starts in the gradients, which run across every
            # character written, padding included. A color code is never put inside a character.
            $totalChars = 0
            If (($Gradient -and $Gradient.Count -ge 2) -or ($BackGroundGradient -and $BackGroundGradient.Count -ge 2)) {
                foreach ($items in $lines) {
                    foreach ($item in $items) {
                        foreach ($run in $item.Runs) {
                            if ($null -eq $run.Characters) {
                                $run.Characters = @(Split-DisplayCharacter -Text $run.Text)
                            }
                            $run.GradientIndex = $totalChars
                            $totalChars += $run.Characters.Count
                        }
                    }
                }
            }

            $gradientMode = if ($ANSI24) { 'TrueColor' } else { 'ANSI8' }
            $gradientArray = $null
            If ($Gradient -and $Gradient.Count -ge 2) {
                if ($Debugging) { Write-DebugLog "Calculating gradient for text" }
                if ($Debugging) { Write-DebugLog "Total characters for gradient: $totalChars" }

                if ($Gradient.Count -gt $totalChars) {
                    Write-ColorWarningMsg "Gradient has $($Gradient.Count) colors but text only has $totalChars characters. Applying standard coloring instead."
                    if ($Debugging) { Write-DebugLog "Gradient disabled: More colors ($($Gradient.Count)) than characters ($totalChars)" }
                    $Gradient = $null
                } else {
                    if ($Debugging) { Write-DebugLog "Generating gradient in $gradientMode mode" }
                    $gradientArray = New-GradientColorArray -Colors $Gradient -Steps $totalChars -Mode $gradientMode -Space $GradientSpace
                    if (-not $gradientArray) {
                        if ($Debugging) { Write-DebugLog "Gradient array generation failed" }
                        $gradientArray = $null
                        $Gradient = $null
                    }
                }
            }

            $bgGradientArray = $null
            If ($BackGroundGradient -and $BackGroundGradient.Count -ge 2) {
                if ($BackGroundGradient.Count -gt $totalChars) {
                    Write-ColorWarningMsg "BackGroundGradient has $($BackGroundGradient.Count) colors but text only has $totalChars characters. Applying standard coloring instead."
                    $BackGroundGradient = $null
                } else {
                    $bgGradientArray = New-GradientColorArray -Colors $BackGroundGradient -Steps $totalChars -Mode $gradientMode -Space $GradientSpace
                    if (-not $bgGradientArray) {
                        $bgGradientArray = $null
                        $BackGroundGradient = $null
                    }
                }
            }

            # Colors that need no check, lightening or fallback conversion are taken as they are:
            # a name in the color table (its RGB in TrueColor), a hex code in TrueColor, and a
            # code 0-255 in ANSI8. The others go through ConvertTo-ForegroundModeColor and
            # ConvertTo-BackgroundModeColor, which warn and write debug messages.
            $directColors = -not $Debugging -and -not ($Bold -and -not $script:SupportsBoldFonts)

            # Each segment's text color, cycling through -Color, converted for the mode in use
            If ($Color.Count -gt 0 -and -not $ColorDisabled) {
                if ($Debugging) { Write-DebugLog "Processing $($Color.Count) colors" }
                $ProcessedColors = [System.Collections.Generic.List[object]]::new()
                For ($i = 0; $i -lt $segmentCount; $i++) {
                    $value = $Color[$i % $Color.Count]
                    if ($directColors) {
                        if ($value -is [string]) {
                            if ($Colors.ContainsKey($value)) {
                                if ($ANSI24) { $ProcessedColors.Add($Colors[$value][4]) } else { $ProcessedColors.Add($value) }
                                continue
                            }
                            if ($ANSI24) {
                                $rgb = [ColorCode]::HexToRgb($value)
                                if ($null -ne $rgb) {
                                    $ProcessedColors.Add($rgb)
                                    continue
                                }
                            }
                        } elseif ($value -is [int] -and $ANSI8 -and $OriginalANSI8 -and $value -ge 0 -and $value -le 255) {
                            $ProcessedColors.Add($value)
                            continue
                        }
                    }
                    $ProcessedColors.Add((ConvertTo-ForegroundModeColor -Value $value -Index $i -Original $value))
                }
                $Color = $ProcessedColors.ToArray()
            } Else {
                $Color = @()
            }

            # Each segment's background color, cycling through -BackGroundColor, converted for the mode in use
            If ($BackGroundColor.Count -gt 0 -and -not $ColorDisabled) {
                if ($Debugging) { Write-DebugLog "Processing $($BackGroundColor.Count) background colors" }
                $ProcessedBGColors = [System.Collections.Generic.List[object]]::new()
                For ($i = 0; $i -lt $segmentCount; $i++) {
                    $value = $BackGroundColor[$i % $BackGroundColor.Count]
                    if ($directColors) {
                        if ($value -is [string]) {
                            if ($Colors.ContainsKey($value)) {
                                if ($ANSI24) { $ProcessedBGColors.Add($Colors[$value][4]) } else { $ProcessedBGColors.Add($value) }
                                continue
                            }
                            if ($ANSI24) {
                                $rgb = [ColorCode]::HexToRgb($value)
                                if ($null -ne $rgb) {
                                    $ProcessedBGColors.Add($rgb)
                                    continue
                                }
                            }
                        } elseif ($value -is [int] -and $ANSI8 -and $OriginalANSI8 -and $value -ge 0 -and $value -le 255) {
                            $ProcessedBGColors.Add($value)
                            continue
                        }
                    }
                    $ProcessedBGColors.Add((ConvertTo-BackgroundModeColor -Value $value -Index $i -Original $value))
                }
                $BackGroundColor = $ProcessedBGColors.ToArray()
            } Else {
                $BackGroundColor = @()
            }

            # The colors markup and -Highlight give runs, converted for the mode in use
            If ($runColors -and -not $ColorDisabled) {
                foreach ($items in $lines) {
                    foreach ($item in $items) {
                        foreach ($run in $item.Runs) {
                            if ($run.HasFg) { $run.ModeFg = ConvertTo-ForegroundModeColor -Value $run.Fg -Index $item.Index -Original $run.Fg }
                            if ($run.HasBg) { $run.ModeBg = ConvertTo-BackgroundModeColor -Value $run.Bg -Index $item.Index -Original $run.Bg }
                        }
                    }
                }
            }

            # Each segment's underline color, cycling through -UnderlineColor. A segment with no
            # other underline takes a single one.
            $underlineCodes = [System.Collections.Generic.List[string]]::new()
            If ($ANSISupport -and $UnderlineColor.Count -gt 0) {
                $underlined = $Underline -or $DoubleUnderline -or $UnderlineStyle
                For ($i = 0; $i -lt $segmentCount; $i++) {
                    $code = Get-UnderlineColorSequence -Value $UnderlineColor[$i % $UnderlineColor.Count]
                    if ($code -and -not $underlined) {
                        $ownUnderline = $false
                        if ($styles) {
                            foreach ($name in @($styles[$i])) {
                                if ($name -in 'Underline', 'DoubleUnderline', 'Curly', 'Dotted', 'Dashed') { $ownUnderline = $true }
                            }
                        }
                        if (-not $ownUnderline) {
                            $code = $script:UnderlineStyleSgr['Single'] + $code
                        }
                    }
                    $underlineCodes.Add($code)
                }
            }

            # Each segment's link, cycling through -Link, where escape codes reach the terminal
            $linksOn = [bool]$ANSISupport
            $segmentLinks = [System.Collections.Generic.List[object]]::new()
            If ($linksOn -and $Link.Count -gt 0) {
                For ($i = 0; $i -lt $segmentCount; $i++) {
                    $segmentLinks.Add([ColorCode]::Link($Link[$i % $Link.Count]))
                }
            }

            # What writes each line: the colors, styles, underline colors, links and gradients
            $writer = [ColorLine]::new()
            $writer.LineStyles = ''
            $writer.ANSISupport = [bool]$ANSISupport
            $writer.ANSI24 = [bool]$ANSI24
            $writer.ANSI8 = [bool]$ANSI8
            $writer.ANSI4 = [bool]$ANSI4
            $writer.Colors = $Colors
            $writer.Styles = $styles
            $writer.Foregrounds = $Color
            $writer.Backgrounds = $BackGroundColor
            $writer.Underlines = $underlineCodes.ToArray()
            $writer.Links = $segmentLinks.ToArray()
            $writer.LinksOn = $linksOn
            $writer.Gradient = $gradientArray
            $writer.BackGroundGradient = $bgGradientArray
            # The styles of every segment, after each segment's own from -Style
            If ($ANSISupport) {
                $lineStyles = ''
                if ($Bold) { $lineStyles += [ColorCode]::StyleSgr['Bold'] }
                if ($Faint) { $lineStyles += [ColorCode]::StyleSgr['Faint'] }
                if ($Italic) { $lineStyles += [ColorCode]::StyleSgr['Italic'] }
                if ($Underline) { $lineStyles += [ColorCode]::StyleSgr['Underline'] }
                if ($Blink) { $lineStyles += [ColorCode]::StyleSgr['Blink'] }
                if ($CrossedOut) { $lineStyles += [ColorCode]::StyleSgr['CrossedOut'] }
                if ($DoubleUnderline) { $lineStyles += [ColorCode]::StyleSgr['DoubleUnderline'] }
                if ($Overline) { $lineStyles += [ColorCode]::StyleSgr['Overline'] }
                if ($Reverse) { $lineStyles += [ColorCode]::StyleSgr['Reverse'] }
                if ($UnderlineStyle) { $lineStyles += [ColorCode]::UnderlineStyleSgr[$UnderlineStyle] }
                $writer.LineStyles = $lineStyles
            }

            if ($Debugging) { Write-DebugLog "Starting text output" }

            # What comes before the text: centering, tabs and spaces, then the time. Lines after the
            # first take spaces in place of the time.
            $indent = ''
            If ($StartTab -gt 0) {
                $indent += "`t" * $StartTab
            }
            If ($StartSpaces -gt 0) {
                $indent += ' ' * $StartSpaces
            }

            For ($i = 0; $i -lt $LinesBefore; $i++) {
                if ($null -ne $captured) { $captured.Add(''); continue }
                Write-Host ''
            }

            For ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
                $items = $lines[$lineIndex]
                $lineNoNewLine = $NoNewLine -and $lineIndex -eq $lines.Count - 1
                $lineText = $null
                $prefix = ''
                If ($HorizontalCenter -and $WindowWidth -gt 0) {
                    $lineText = [ColorCode]::ItemText($items)
                    $MessageLength = Measure-DisplayWidth -Text $lineText
                    If ($WindowWidth -ge $MessageLength) {
                        $CenterPosition = [int][Math]::Max(0, $WindowWidth / 2 - [Math]::Floor($MessageLength / 2))
                        $prefix += ' ' * $CenterPosition
                    }
                }
                $prefix += $indent
                $lineTime = $timeText
                If ($lineIndex -gt 0 -and $timeText) {
                    $prefix += ' ' * (Measure-DisplayWidth -Text $timeText)
                    $lineTime = ''
                }

                If ($ColorDisabled) {
                    # One call, no colors or styles
                    if ($null -eq $lineText) {
                        $lineText = [ColorCode]::ItemText($items)
                    }
                    $line = $prefix + $lineTime + $lineText
                    If ($null -ne $captured) {
                        $captured.Add($line)
                    } ElseIf ($line.Length -gt 0 -or -not $lineNoNewLine) {
                        Write-Host -Object $line -NoNewline:$lineNoNewLine
                    }
                } ElseIf ($ANSISupport -or $ComposeLine) {
                    # One call, the colors and styles as escape codes
                    if ($Debugging -and $gradientArray) {
                        Write-DebugLog "Using gradient mode for output"
                        foreach ($item in $items) {
                            if ($item.Index -lt $Color.Count -and $null -ne $Color[$item.Index]) {
                                Write-DebugLog "Segment $($item.Index) has explicit color override (skipping gradient)"
                            }
                        }
                    }
                    $line = $prefix
                    If ($lineTime) {
                        $line += "$script:Esc[90m$lineTime$script:SgrReset"
                    }
                    $line += $writer.Ansi($items)
                    If ($null -ne $captured) {
                        $captured.Add($line)
                    } ElseIf ($line.Length -gt 0 -or -not $lineNoNewLine) {
                        Write-Host -Object $line -NoNewline:$lineNoNewLine
                    }
                } Else {
                    # One call per color, each with -ForegroundColor and -BackgroundColor
                    $merged = $writer.Pieces($prefix, $lineTime, $items)
                    If ($null -ne $captured) {
                        # Console colors cannot be held in a string: the text alone
                        $captured.Add((-join @(foreach ($piece in $merged) { $piece.Text })))
                    } ElseIf ($merged.Count -eq 0) {
                        If (-not $lineNoNewLine) {
                            Write-Host ''
                        }
                    } Else {
                        $lastPiece = $merged.Count - 1
                        For ($p = 0; $p -le $lastPiece; $p++) {
                            $piece = $merged[$p]
                            $hostParameters = @{
                                Object = $piece.Text
                                NoNewline = ($p -lt $lastPiece) -or $lineNoNewLine
                            }
                            if ($piece.Fg) { $hostParameters['ForegroundColor'] = $piece.Fg }
                            if ($piece.Bg) { $hostParameters['BackgroundColor'] = $piece.Bg }
                            Write-Host @hostParameters
                        }
                    }
                }
            }

            For ($i = 0; $i -lt $LinesAfter; $i++) {
                if ($null -ne $captured) { $captured.Add(''); continue }
                Write-Host ''
            }
        }

        If ($segments.Count -and $LogFile) {
            if ($Debugging) { Write-DebugLog "Writing to log file: $LogFile" }

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
            $TextToFile = [ColorCode]::SegmentText($segments)
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
                    if ($Debugging) { Write-DebugLog "Successfully wrote to log file" }
                } Catch {
                    If ($Retry -ge $attempts) {
                        Write-Warning "Write-ColorEX - Couldn't write to log file $($_.Exception.Message). Tried ($Retry/$attempts)"
                    } Else {
                        if ($Debugging) { Write-DebugLog "Log write failed, retrying... ($Retry/$attempts)" }
                        Start-Sleep -Milliseconds 50
                    }
                }
            } Until ($Saved -or $Retry -ge $attempts)
        }

        if ($Debugging) { Write-DebugLog "Write-ColorEX completed" }
    }
}
