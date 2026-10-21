function Format-ColorEX {
    <#
    .SYNOPSIS
    Returns text with its colors and styles as escape codes, as Write-ColorEX would write it.

    .DESCRIPTION
    Format-ColorEX takes Write-ColorEX's text, color, style and width parameters and returns each
    line as a string instead of writing it to the host, for a string built from several pieces,
    a table column, a file or another command.

    The strings hold escape codes wherever the host shows them, by the same detection and color
    variables Write-ColorEX uses. Where it would write console colors instead, or with colors
    turned off, the strings are the text alone. -ColorSupport gives the color support to format
    for in place of the detection and the color variables, so the strings are the same wherever
    they are made.

    -Wrap returns one string per line, and a style profile's -LinesBefore and -LinesAfter return
    empty strings.

    .PARAMETER Text
    The text. Several strings make one line, each with its own colors and styles. Strings piped
    in are formatted one line each.

    .PARAMETER Color
    The text color of each segment, as Write-ColorEX's -Color takes it.

    .PARAMETER BackGroundColor
    The background color of each segment, as Write-ColorEX's -BackGroundColor takes it.

    .PARAMETER Gradient
    Two or more colors to blend across the text, as Write-ColorEX's -Gradient takes them.

    .PARAMETER BackGroundGradient
    Two or more colors to blend across the background, as Write-ColorEX's -BackGroundGradient
    takes them.

    .PARAMETER GradientSpace
    How the gradients blend their colors: OKLab (the default), RGB, LinearRGB, OKLCH, HSL, HSV,
    Lab or LCh, as Write-ColorEX's -GradientSpace takes them.

    .PARAMETER GradientHue
    The way round the hue wheel in OKLCH, HSL, HSV and LCh: Shorter (the default), Longer,
    Increasing or Decreasing.

    .PARAMETER GradientEasing
    A curve that moves the colors along the text, as Write-ColorEX's -GradientEasing takes it.

    .PARAMETER GradientRepeat
    What a gradient does past placed first and last colors: None (the default), Repeat or Mirror.

    .PARAMETER GradientDirection
    The way a gradient runs across the text: Forward (the default), Reverse, CenterOut or EdgesIn.

    .PARAMETER GradientSteps
    Cuts a gradient into this many bands of solid color; 0, the default, blends smoothly.

    .PARAMETER ANSI4
    Uses ANSI 4-bit colors.

    .PARAMETER ANSI8
    Uses ANSI 8-bit colors.

    .PARAMETER ANSI24
    Uses 24-bit TrueColor.

    .PARAMETER ColorSupport
    The color support to format for, in place of the detection and the color variables: None,
    ANSI4, ANSI8 or TrueColor, as Write-ColorEX's -ColorSupport takes it. ANSI4, ANSI8 and
    TrueColor give escape codes for that support, and None gives the text alone.

    .PARAMETER Style
    The styles of each segment, as Write-ColorEX's -Style takes them.

    .PARAMETER StyleProfile
    A PSColorStyle with colors, styles and layout settings. Parameters given take precedence.

    .PARAMETER Default
    Applies the default style set with Set-ColorDefault.

    .PARAMETER Bold
    Bold text.

    .PARAMETER Faint
    Faint (dimmed) text.

    .PARAMETER Italic
    Italic text.

    .PARAMETER Underline
    Underlined text.

    .PARAMETER Blink
    Blinking text, where the terminal supports it.

    .PARAMETER CrossedOut
    Text struck through.

    .PARAMETER DoubleUnderline
    Text underlined twice, where the terminal supports it.

    .PARAMETER Overline
    A line above the text, where the terminal supports it.

    .PARAMETER Reverse
    Swaps the text and background colors.

    .PARAMETER UnderlineColor
    The color of each segment's underline.

    .PARAMETER UnderlineStyle
    The kind of underline: Single, Double, Curly, Dotted or Dashed.

    .PARAMETER Markup
    Reads [style]text[/] tags in the text, as Write-ColorEX's -Markup does.

    .PARAMETER Split
    Cuts each segment after each of these separators.

    .PARAMETER SplitAround
    Cuts each segment before and after each of these separators.

    .PARAMETER SplitEvenly
    Cuts each segment into as many equal parts as -Color has colors.

    .PARAMETER Highlight
    Colors and styles the text that patterns match: a hashtable of regular expressions and styles.

    .PARAMETER Link
    Makes each segment a link to the address given, in terminals that open links.

    .PARAMETER StartTab
    The number of tab characters before the text.

    .PARAMETER StartSpaces
    The number of spaces before the text, after any tabs.

    .PARAMETER AutoPad
    Pads the text to this display width.

    .PARAMETER PadLeft
    With -AutoPad, pads on the left.

    .PARAMETER PadCenter
    With -AutoPad, pads on both sides.

    .PARAMETER PadChar
    The character -AutoPad pads with.

    .PARAMETER Truncate
    With -AutoPad, cuts text wider than -AutoPad, ending it with an ellipsis.

    .PARAMETER Wrap
    Breaks text wider than the line into lines.

    .PARAMETER Debugging
    Writes [DEBUG] messages about color processing to the verbose stream.

    .PARAMETER Silent
    Suppresses Write-ColorEX's warnings about colors and color modes.

    .INPUTS
    System.String[]
    Strings piped to Format-ColorEX bind to -Text, and each is formatted as its own line.

    .OUTPUTS
    System.String
    One string for each line.

    .EXAMPLE
    "Status: $(Format-ColorEX 'OK' -Color Green -Bold)"

    A string with "OK" in bold green inside it.

    .EXAMPLE
    Get-Service | Format-Table Name, @{ Name = 'Status'; Expression = { Format-ColorEX "$($_.Status)" -Color $(if ($_.Status -eq 'Running') { 'Green' } else { 'Red' }) } }

    A table with each service's status in green or red.

    .EXAMPLE
    Format-ColorEX 'A long paragraph of text to wrap at twenty cells.' -AutoPad 20 -Wrap

    Three strings, each 20 cells wide.

    .EXAMPLE
    Format-ColorEX 'Done' -Color Green -ColorSupport ANSI8

    "Done" in green as a 256-color escape code. The string is the same whether it is made in a
    terminal, with output redirected or with NO_COLOR set.

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    PowerShell 7.2 and later remove escape codes from strings written to a host or a redirected
    output that does not show them, as $PSStyle.OutputRendering sets.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [Alias('Format-ColourEX', 'FCEX')]
    [OutputType([string])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [alias ('T')][string[]] $Text,
        [Parameter(Position = 1)]
        [alias ('C', 'ForegroundColor', 'FGC')][array] $Color = $null,
        [Parameter(Position = 2)]
        [alias ('B', 'BGC')][array] $BackGroundColor = $null,
        [AllowNull()]
        [alias ('Grad')][object[]] $Gradient = $null,
        [AllowNull()]
        [alias ('BGGrad')][object[]] $BackGroundGradient = $null,
        [ValidateSet('OKLab', 'RGB', 'LinearRGB', 'OKLCH', 'HSL', 'HSV', 'Lab', 'LCh')][string] $GradientSpace = 'OKLab',
        [ValidateSet('Shorter', 'Longer', 'Increasing', 'Decreasing')][string] $GradientHue = 'Shorter',
        [ValidateSet('Linear', 'InSine', 'OutSine', 'InOutSine', 'InQuad', 'OutQuad', 'InOutQuad', 'InCubic', 'OutCubic', 'InOutCubic', 'InQuart', 'OutQuart', 'InOutQuart', 'InQuint', 'OutQuint', 'InOutQuint', 'InExpo', 'OutExpo', 'InOutExpo', 'InCirc', 'OutCirc', 'InOutCirc', 'InBack', 'OutBack', 'InOutBack', 'InElastic', 'OutElastic', 'InOutElastic', 'InBounce', 'OutBounce', 'InOutBounce')][string] $GradientEasing = 'Linear',
        [ValidateSet('None', 'Repeat', 'Mirror')][string] $GradientRepeat = 'None',
        [ValidateSet('Forward', 'Reverse', 'CenterOut', 'EdgesIn')][string] $GradientDirection = 'Forward',
        [ValidateRange(0, [int]::MaxValue)][int] $GradientSteps = 0,
        [alias ('A4')][switch] $ANSI4,
        [alias ('A8')][switch] $ANSI8,
        [alias ('A24', 'TrueColor', 'TC')][switch] $ANSI24,
        [ValidateSet('None', 'ANSI4', 'ANSI8', 'TrueColor')][string] $ColorSupport,
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
        [alias('Invert')][switch] $Reverse,
        [array] $UnderlineColor = $null,
        [ValidateSet('Single', 'Double', 'Curly', 'Dotted', 'Dashed')][string] $UnderlineStyle,
        [switch] $Markup,
        [string[]] $Split,
        [string[]] $SplitAround,
        [switch] $SplitEvenly,
        [System.Collections.IDictionary] $Highlight,
        [string[]] $Link,
        [alias ('Indent')][int] $StartTab = 0,
        [int] $StartSpaces = 0,
        [alias('PadWidth', 'Pad')][int] $AutoPad = 0,
        [alias('RightAlign')][switch] $PadLeft,
        [switch] $PadCenter,
        [alias('PaddingChar', 'FillChar')][char] $PadChar = ' ',
        [switch] $Truncate,
        [switch] $Wrap,
        [switch] $Debugging,
        [switch] $Silent
    )

    begin {
        # The parameters given, for Write-ColorEX; the common parameters act on this command
        $parameters = @{}
        foreach ($name in $PSBoundParameters.Keys) {
            if ($name -ne 'Text' -and -not [System.Management.Automation.Cmdlet]::CommonParameters.Contains($name)) {
                $parameters[$name] = $PSBoundParameters[$name]
            }
        }
    }

    process {
        $lines = [System.Collections.Generic.List[string]]::new()
        $script:CaptureLines = $lines
        try {
            Write-ColorEX @parameters -Text $Text
        } finally {
            $script:CaptureLines = $null
        }
        foreach ($line in $lines) {
            $line
        }
    }
}
