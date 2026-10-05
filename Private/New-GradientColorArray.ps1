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
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    Write-ColorEX calls this private function for -Gradient. Each step's color is a linear
    interpolation between the two waypoints around it. A color name not in the color table and
    an invalid hex code are gray.

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
        [string]$Mode
    )

    # Validate colors count
    if ($Colors.Count -lt 2) {
        throw "Gradient requires at least 2 colors (received $($Colors.Count))"
    }

    $gradientColors = [System.Collections.Generic.List[object]]::new($Steps)

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

    # One step is the first color
    if ($Steps -eq 1) {
        $rgb = $rgbColors[0]
        if ($Mode -eq 'ANSI8') {
            $null = $gradientColors.Add((Convert-RGBToANSI8 -RGB $rgb))
        } else {
            $null = $gradientColors.Add($rgb)
        }
        return ,$gradientColors.ToArray()
    }

    if ($rgbColors.Count -eq 2) {
        $startRGB = $rgbColors[0]
        $endRGB = $rgbColors[1]

        for ($i = 0; $i -lt $Steps; $i++) {
            # Linear interpolation
            $ratio = $i / ($Steps - 1)

            $r = [int]($startRGB[0] + ($endRGB[0] - $startRGB[0]) * $ratio)
            $g = [int]($startRGB[1] + ($endRGB[1] - $startRGB[1]) * $ratio)
            $b = [int]($startRGB[2] + ($endRGB[2] - $startRGB[2]) * $ratio)

            if ($Mode -eq 'ANSI8') {
                $null = $gradientColors.Add((Convert-RGBToANSI8 -RGB @($r, $g, $b)))
            } else {
                $null = $gradientColors.Add(@($r, $g, $b))
            }
        }
    } else {
        # Three or more waypoints: each step falls between the two waypoints around it
        $segmentCount = $rgbColors.Count - 1

        for ($step = 0; $step -lt $Steps; $step++) {
            # Determine which color segment this step falls into
            $position = $step / ($Steps - 1) * $segmentCount
            $segmentIndex = [Math]::Min([int][Math]::Floor($position), $segmentCount - 1)
            $segmentProgress = $position - $segmentIndex

            $startRGB = $rgbColors[$segmentIndex]
            $endRGB = $rgbColors[$segmentIndex + 1]

            # Linear interpolation within segment
            $r = [int]($startRGB[0] + ($endRGB[0] - $startRGB[0]) * $segmentProgress)
            $g = [int]($startRGB[1] + ($endRGB[1] - $startRGB[1]) * $segmentProgress)
            $b = [int]($startRGB[2] + ($endRGB[2] - $startRGB[2]) * $segmentProgress)

            if ($Mode -eq 'ANSI8') {
                $null = $gradientColors.Add((Convert-RGBToANSI8 -RGB @($r, $g, $b)))
            } else {
                $null = $gradientColors.Add(@($r, $g, $b))
            }
        }
    }

    # The comma keeps the array whole rather than unrolled into the pipeline
    return ,$gradientColors.ToArray()
}
