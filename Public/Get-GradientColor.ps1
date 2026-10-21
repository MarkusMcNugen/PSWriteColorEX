function Get-GradientColor {
    <#
    .SYNOPSIS
    Returns the colors of a gradient: one for each of a number of characters, or the color at each
    of several places along it.

    .DESCRIPTION
    Get-GradientColor blends a gradient as Write-ColorEX's -Gradient does and returns its colors as
    RGB arrays, three values from 0 to 255 in each, the form -Color and -Gradient take.

    -Count returns the colors of that many characters, as Write-ColorEX draws the gradient across a
    line of that length. -Place returns the color at each place given along the gradient, from 0 at
    its start to 1 at its end, in the order given, for a single color that moves along it; colors
    placed with '@' keep their exact places, since there are no characters to move them to.

    .PARAMETER Gradient
    Two or more colors, or the name of a named gradient, as Write-ColorEX's -Gradient takes them. A
    color may give its place along the gradient after an '@', as a percent: 'Gold@40'.

    .PARAMETER Count
    The number of colors to return, as for a line of that many characters.

    .PARAMETER Place
    The places along the gradient of the colors to return, from 0 at its start to 1 at its end: one
    color for each place, in the order given. A place below 0 is 0 and above 1 is 1.

    .PARAMETER GradientSpace
    How the colors blend: OKLab (the default), RGB, LinearRGB, OKLCH, HSL, HSV, Lab or LCh, as
    Write-ColorEX's -GradientSpace takes them.

    .PARAMETER GradientHue
    The way round the hue wheel in OKLCH, HSL, HSV and LCh: Shorter (the default), Longer,
    Increasing or Decreasing.

    .PARAMETER GradientEasing
    A curve that moves the colors along the gradient, as Write-ColorEX's -GradientEasing takes it.

    .PARAMETER GradientRepeat
    What the gradient does past placed first and last colors: None (the default), Repeat or Mirror.

    .PARAMETER GradientDirection
    The way the gradient runs: Forward (the default), Reverse, CenterOut or EdgesIn.

    .PARAMETER GradientSteps
    Cuts the gradient into this many bands of solid color; 0, the default, blends smoothly.

    .INPUTS
    None

    .OUTPUTS
    System.Int32[]
    One RGB array for each color.

    .EXAMPLE
    Get-GradientColor -Gradient Red, Blue -Count 5

    The five colors Write-ColorEX -Gradient Red, Blue draws across five characters.

    .EXAMPLE
    Get-GradientColor -Gradient Progress -Place 0.75

    The color three quarters of the way along the Progress gradient.

    .EXAMPLE
    Get-GradientColor -Gradient Progress -Place (0..100 | ForEach-Object { $_ / 100 })

    The Progress gradient's color at each whole percent, 101 colors from one call.

    .EXAMPLE
    $colors = Get-GradientColor -Gradient Sunset -Count 3 -GradientSpace OKLCH
    Write-ColorEX -Text 'one ', 'two ', 'three' -Color $colors

    Writes each word in one of three colors from the Sunset gradient, blended in OKLCH.

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    A color name the color table lacks gives a warning and blends as gray.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding(DefaultParameterSetName = 'Count')]
    [Alias('Get-GradientColour')]
    [OutputType([int[]])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'unknownColorNames', Justification = 'The helpers in Private/WriteColorCore.ps1 that this function calls read it through PowerShell''s dynamic scope.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'The comma writes each Int32[] to the pipeline whole; the analyzer reads the comma''s own array type.')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [object[]] $Gradient,

        [Parameter(Mandatory, ParameterSetName = 'Count')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Count,

        [Parameter(Mandatory, ParameterSetName = 'Place')]
        [double[]] $Place,

        [ValidateSet('OKLab', 'RGB', 'LinearRGB', 'OKLCH', 'HSL', 'HSV', 'Lab', 'LCh')][string] $GradientSpace = 'OKLab',
        [ValidateSet('Shorter', 'Longer', 'Increasing', 'Decreasing')][string] $GradientHue = 'Shorter',
        [ValidateSet('Linear', 'InSine', 'OutSine', 'InOutSine', 'InQuad', 'OutQuad', 'InOutQuad', 'InCubic', 'OutCubic', 'InOutCubic', 'InQuart', 'OutQuart', 'InOutQuart', 'InQuint', 'OutQuint', 'InOutQuint', 'InExpo', 'OutExpo', 'InOutExpo', 'InCirc', 'OutCirc', 'InOutCirc', 'InBack', 'OutBack', 'InOutBack', 'InElastic', 'OutElastic', 'InOutElastic', 'InBounce', 'OutBounce', 'InOutBounce')][string] $GradientEasing = 'Linear',
        [ValidateSet('None', 'Repeat', 'Mirror')][string] $GradientRepeat = 'None',
        [ValidateSet('Forward', 'Reverse', 'CenterOut', 'EdgesIn')][string] $GradientDirection = 'Forward',
        [ValidateRange(0, [int]::MaxValue)][int] $GradientSteps = 0
    )

    if ($null -eq $script:CachedColorTable) {
        $script:CachedColorTable = Get-ColorTableWithRGB
    }
    # The color names the table lacks, each warned about once
    $unknownColorNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $colors = Resolve-GradientName -Values $Gradient
    if ($colors.Count -lt 2) {
        $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
            [System.ArgumentException]::new("Gradient requires at least 2 colors (received $($colors.Count))."), 'GradientTooFewColors',
            [System.Management.Automation.ErrorCategory]::InvalidArgument, $null))
    }
    $split = Split-GradientPlace -Values $colors
    $colors = ConvertTo-ColorFormList -Values $split.Colors

    if ($PSCmdlet.ParameterSetName -eq 'Count') {
        $rgbs = New-GradientColorArray -Colors $colors -Places $split.Places -Steps $Count -Mode TrueColor -Space $GradientSpace -Hue $GradientHue -Easing $GradientEasing -Repeat $GradientRepeat -Direction $GradientDirection -Bands $GradientSteps
        # Copies, so a change to one leaves the gradients the module keeps alone
        foreach ($rgb in $rgbs) {
            , ([int[]]$rgb.Clone())
        }
        return
    }
    $options = [ColorMath]::GradientOptions($GradientSpace, $GradientHue, $GradientEasing, $GradientRepeat, $GradientDirection, $GradientSteps)
    $stops = ConvertTo-GradientStopRgb -Colors $colors
    foreach ($at in $Place) {
        , [ColorMath]::GradientRgbAt($stops, $split.Places, $at, $options)
    }
}
