function New-GradientColorArray {
    <#
    .SYNOPSIS
    Generates a gradient color array for character-by-character coloring

    .DESCRIPTION
    Interpolates colors evenly between 2 or more waypoint colors, one color per step,
    as RGB arrays (TrueColor) or ANSI 256-color codes (ANSI8).

    .PARAMETER Colors
    Array of gradient waypoints (minimum 2 colors).
    Accepts color names, hex codes, or RGB arrays.

    .PARAMETER Places
    Each waypoint's place from 0 to 1, or $null for one with none, as Split-GradientPlace returns
    them; $null for none placed.

    .PARAMETER Steps
    Number of colors to generate (typically total character count)

    .PARAMETER Mode
    Color mode: 'TrueColor' returns RGB arrays, 'ANSI8' returns ANSI 256-color codes

    .PARAMETER Space
    The space colors are blended in, as Write-ColorEX's -GradientSpace names them.

    .PARAMETER Hue
    The way round the hue wheel, as Write-ColorEX's -GradientHue names it.

    .PARAMETER Easing
    The easing curve, as Write-ColorEX's -GradientEasing names it.

    .PARAMETER Repeat
    What the gradient does past its first and last waypoints, as Write-ColorEX's -GradientRepeat
    names it.

    .PARAMETER Direction
    The way across the steps, as Write-ColorEX's -GradientDirection names it.

    .PARAMETER Bands
    The bands of solid color, as Write-ColorEX's -GradientSteps gives them; 0 for a smooth blend.

    .EXAMPLE
    New-GradientColorArray -Colors @("Red","Blue") -Steps 10 -Mode TrueColor
    Returns 10 RGB arrays interpolated from Red to Blue

    .EXAMPLE
    New-GradientColorArray -Colors @("#FF0000","#00FF00","#0000FF") -Steps 20 -Mode ANSI8
    Returns 20 ANSI8 codes for a red-green-blue gradient

    .OUTPUTS
    System.Array
    Returns an array of color values matching the Steps count:
    - TrueColor mode: Array of RGB arrays @(R,G,B)
    - ANSI8 mode: Array of ANSI 256-color codes (integers 0-255)

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    Write-ColorEX calls this private function for -Gradient and -BackGroundGradient, and
    Get-GradientColor for -Count. With at least as many steps as waypoints, each waypoint moves to
    the step nearest its place, a half rounded up, so every waypoint is drawn; with fewer, the
    steps are spread over the whole gradient. Each other step's color is blended between the two
    waypoints around it in the space, and in ANSI8 is the 256-color code Convert-RGBToANSI8 returns
    for it. A color name not in the color table and an invalid hex code are gray. The result of
    each set of waypoints, places, options, steps and mode is kept for the session, so a gradient
    written again costs a lookup.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'It returns a new array of colors and changes nothing.')]
    param(
        [Parameter(Mandatory)]
        [object[]]$Colors,

        [AllowNull()]
        [object[]]$Places = $null,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Steps,

        [Parameter(Mandatory)]
        [ValidateSet('TrueColor', 'ANSI8')]
        [string]$Mode,

        [ValidateSet('OKLab', 'RGB', 'LinearRGB', 'OKLCH', 'HSL', 'HSV', 'Lab', 'LCh')]
        [string]$Space = 'OKLab',

        [ValidateSet('Shorter', 'Longer', 'Increasing', 'Decreasing')]
        [string]$Hue = 'Shorter',

        [ValidateSet('Linear', 'InSine', 'OutSine', 'InOutSine', 'InQuad', 'OutQuad', 'InOutQuad', 'InCubic', 'OutCubic', 'InOutCubic', 'InQuart', 'OutQuart', 'InOutQuart', 'InQuint', 'OutQuint', 'InOutQuint', 'InExpo', 'OutExpo', 'InOutExpo', 'InCirc', 'OutCirc', 'InOutCirc', 'InBack', 'OutBack', 'InOutBack', 'InElastic', 'OutElastic', 'InOutElastic', 'InBounce', 'OutBounce', 'InOutBounce')]
        [string]$Easing = 'Linear',

        [ValidateSet('None', 'Repeat', 'Mirror')]
        [string]$Repeat = 'None',

        [ValidateSet('Forward', 'Reverse', 'CenterOut', 'EdgesIn')]
        [string]$Direction = 'Forward',

        [ValidateRange(0, [int]::MaxValue)]
        [int]$Bands = 0
    )

    # Validate colors count
    if ($Colors.Count -lt 2) {
        throw "Gradient requires at least 2 colors (received $($Colors.Count))"
    }

    $rgbColors = ConvertTo-GradientStopRgb -Colors $Colors

    # The key holds the options by name, so GradientOptions runs only for a gradient not yet built
    $stopTexts = foreach ($stop in $rgbColors) { $stop -join ',' }
    $placeKey = ''
    if ($null -ne $Places) {
        $placeTexts = foreach ($place in $Places) {
            if ($null -eq $place) { '' } else { ([double]$place).ToString('R', [System.Globalization.CultureInfo]::InvariantCulture) }
        }
        $placeKey = @($placeTexts) -join ';'
    }
    $cacheKey = '{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}' -f $Mode, $Space, $Hue, $Easing, $Repeat, $Direction, $Bands, $Steps, (@($stopTexts) -join ';'), $placeKey
    $cached = $script:GradientCache[$cacheKey]
    if ($null -ne $cached) {
        return ,$cached
    }

    $options = [ColorMath]::GradientOptions($Space, $Hue, $Easing, $Repeat, $Direction, $Bands)
    $result = [ColorMath]::GradientRgb($rgbColors, $Places, $Steps, $options)
    if ($Mode -eq 'ANSI8') {
        for ($step = 0; $step -lt $result.Count; $step++) {
            $rgb = $result[$step]
            $result[$step] = [ColorMath]::NearestAnsi8($rgb[0], $rgb[1], $rgb[2])
        }
    }
    if ($script:GradientCache.Count -ge 256) {
        $script:GradientCache.Clear()
    }
    $script:GradientCache[$cacheKey] = $result

    # The comma keeps the array whole rather than unrolled into the pipeline
    return ,$result
}

function ConvertTo-GradientStopRgb {
    <#
    .SYNOPSIS
    Each of a gradient's colors as an RGB array: an RGB array clamped to 0-255, a hex code, or a
    color name. A name the color table lacks and an invalid hex code are gray.
    #>
    param([object[]]$Colors)
    if ($null -eq $script:CachedColorTable) {
        $script:CachedColorTable = Get-ColorTableWithRGB
    }
    $rgbColors = [System.Collections.Generic.List[array]]::new($Colors.Count)
    foreach ($color in $Colors) {
        if ($color -is [array] -and $color.Count -eq 3) {
            $null = $rgbColors.Add(@(
                [Math]::Max(0, [Math]::Min(255, [int]$color[0])),
                [Math]::Max(0, [Math]::Min(255, [int]$color[1])),
                [Math]::Max(0, [Math]::Min(255, [int]$color[2]))
            ))
        } elseif ($color -is [string] -and $color -match '^#|^0x') {
            $null = $rgbColors.Add((Convert-HexToRGB -Hex $color))
        } else {
            $colorEntry = $script:CachedColorTable[$color]
            if ($colorEntry) {
                $null = $rgbColors.Add($colorEntry[4])
            } else {
                $null = $rgbColors.Add(@(128, 128, 128))
            }
        }
    }
    # The comma keeps the array whole rather than unrolled into the pipeline
    return ,$rgbColors.ToArray()
}

# The gradients built so far, by mode, options, steps, waypoints and places
$script:GradientCache = @{}
