function New-GradientColorArray {
    <#
    .SYNOPSIS
    Generates a gradient color array for character-by-character coloring

    .DESCRIPTION
    Creates an array of interpolated colors between waypoints for smooth gradients.
    Supports 2+ color waypoints and both TrueColor (RGB) and ANSI8 (256-color) modes.

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

    This is a private function used internally by Write-ColorEX for gradient processing.
    It performs linear interpolation between color waypoints to create smooth gradients.

    Performance: Uses List[object] for array building (18000x faster than += operator).

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

    # Performance: Use List instead of array += (18,000x faster for large arrays)
    $gradientColors = [System.Collections.Generic.List[object]]::new($Steps)

    # Convert all input colors to RGB first (performance: do once, reuse many times)
    $rgbColors = [System.Collections.Generic.List[array]]::new($Colors.Count)

    # Cache command availability check (avoid repeated Get-Command calls)
    $hasConvertHex = $null -ne (Get-Command Convert-HexToRGB -ErrorAction SilentlyContinue)
    $hasConvertANSI8 = $null -ne (Get-Command Convert-RGBToANSI8 -ErrorAction SilentlyContinue)
    $hasColorTable = $null -ne (Get-Command Get-ColorTableWithRGB -ErrorAction SilentlyContinue)

    foreach ($color in $Colors) {
        if ($color -is [array] -and $color.Count -eq 3) {
            # Already RGB - clamp to 0-255 range
            $null = $rgbColors.Add(@(
                [Math]::Max(0, [Math]::Min(255, [int]$color[0])),
                [Math]::Max(0, [Math]::Min(255, [int]$color[1])),
                [Math]::Max(0, [Math]::Min(255, [int]$color[2]))
            ))
        } elseif ($color -is [string] -and $color -match '^#|^0x') {
            # Hex color - convert to RGB
            if ($hasConvertHex) {
                $rgb = Convert-HexToRGB -Hex $color
                $null = $rgbColors.Add($rgb)
            } else {
                # Fallback to gray if conversion not available
                $null = $rgbColors.Add(@(128, 128, 128))
            }
        } else {
            # Named color - get RGB from color table
            if ($null -eq $script:CachedColorTable -and $hasColorTable) {
                $script:CachedColorTable = Get-ColorTableWithRGB
            }

            if ($null -ne $script:CachedColorTable) {
                # Direct hashtable access (2x faster than ContainsKey + lookup)
                $colorEntry = $script:CachedColorTable[$color]
                if ($colorEntry) {
                    $null = $rgbColors.Add($colorEntry[4])
                } else {
                    # Color not found - fallback to gray
                    $null = $rgbColors.Add(@(128, 128, 128))
                }
            } else {
                # No color table - fallback to gray
                $null = $rgbColors.Add(@(128, 128, 128))
            }
        }
    }

    # Edge case: single step (return first color)
    if ($Steps -eq 1) {
        $rgb = $rgbColors[0]
        if ($Mode -eq 'ANSI8') {
            if ($hasConvertANSI8) {
                $null = $gradientColors.Add((Convert-RGBToANSI8 -RGB $rgb))
            } else {
                $null = $gradientColors.Add(7)  # Gray fallback
            }
        } else {
            $null = $gradientColors.Add($rgb)
        }
        return ,$gradientColors.ToArray()
    }

    # Calculate gradient colors
    if ($rgbColors.Count -eq 2) {
        # Two-color gradient (optimized fast path)
        $startRGB = $rgbColors[0]
        $endRGB = $rgbColors[1]

        for ($i = 0; $i -lt $Steps; $i++) {
            # Linear interpolation
            $ratio = $i / ($Steps - 1)

            $r = [int]($startRGB[0] + ($endRGB[0] - $startRGB[0]) * $ratio)
            $g = [int]($startRGB[1] + ($endRGB[1] - $startRGB[1]) * $ratio)
            $b = [int]($startRGB[2] + ($endRGB[2] - $startRGB[2]) * $ratio)

            if ($Mode -eq 'ANSI8') {
                if ($hasConvertANSI8) {
                    $null = $gradientColors.Add((Convert-RGBToANSI8 -RGB @($r, $g, $b)))
                } else {
                    $null = $gradientColors.Add(7)  # Gray fallback
                }
            } else {
                $null = $gradientColors.Add(@($r, $g, $b))
            }
        }
    } else {
        # Multi-stop gradient (3+ colors)
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
                if ($hasConvertANSI8) {
                    $null = $gradientColors.Add((Convert-RGBToANSI8 -RGB @($r, $g, $b)))
                } else {
                    $null = $gradientColors.Add(7)  # Gray fallback
                }
            } else {
                $null = $gradientColors.Add(@($r, $g, $b))
            }
        }
    }

    # Return as array (comma operator prevents unwrapping)
    return ,$gradientColors.ToArray()
}
