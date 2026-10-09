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

    .PARAMETER Steps
    Number of colors to generate (typically total character count)

    .PARAMETER Mode
    Color mode: 'TrueColor' returns RGB arrays, 'ANSI8' returns ANSI 256-color codes

    .PARAMETER Space
    The space colors are blended in: 'OKLab', where equal steps look equally far apart and the
    brightness stays even, or 'RGB', each channel on its own. The first and last step of each
    stretch between two waypoints are the waypoints themselves.

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

    Write-ColorEX calls this private function for -Gradient and -BackGroundGradient. Each step's
    color is a linear interpolation between the two waypoints around it, in OKLab or in RGB. A
    color name not in the color table and an invalid hex code are gray. The result of each set of
    waypoints, steps, mode and space is kept for the session, so a gradient written again costs a
    lookup.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Colors,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Steps,

        [Parameter(Mandatory)]
        [ValidateSet('TrueColor', 'ANSI8')]
        [string]$Mode,

        [ValidateSet('OKLab', 'RGB')]
        [string]$Space = 'OKLab'
    )

    # Validate colors count
    if ($Colors.Count -lt 2) {
        throw "Gradient requires at least 2 colors (received $($Colors.Count))"
    }

    # Every waypoint as RGB
    $rgbColors = [System.Collections.Generic.List[array]]::new($Colors.Count)

    if ($null -eq $script:CachedColorTable) {
        $script:CachedColorTable = Get-ColorTableWithRGB
    }

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

    $cacheKey = '{0}|{1}|{2}|{3}' -f $Mode, $Space, $Steps, (($rgbColors | ForEach-Object { $_ -join ',' }) -join ';')
    $cached = $script:GradientCache[$cacheKey]
    if ($null -ne $cached) {
        return ,$cached
    }

    $result = [ColorMath]::Blend($rgbColors.ToArray(), $Steps, $Mode -eq 'ANSI8', $Space -eq 'OKLab')
    if ($script:GradientCache.Count -ge 256) {
        $script:GradientCache.Clear()
    }
    $script:GradientCache[$cacheKey] = $result

    # The comma keeps the array whole rather than unrolled into the pipeline
    return ,$result
}

# The gradients built so far, by mode, space, steps and waypoints
$script:GradientCache = @{}
