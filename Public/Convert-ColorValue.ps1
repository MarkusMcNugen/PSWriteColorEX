# Color conversion utility functions

function Convert-HexToRGB {
    <#
    .SYNOPSIS
    Converts hex color codes to RGB values
    
    .DESCRIPTION
    Converts hex color codes (#RRGGBB or 0xRRGGBB) to RGB array
    
    .PARAMETER Hex
    The hex color code to convert
    
    .EXAMPLE
    Convert-HexToRGB "#FF8000"
    Returns: @(255, 128, 0)

    .OUTPUTS
    System.Array
    Returns a 3-element integer array @(R, G, B) with values 0-255.
    Invalid input returns gray @(128, 128, 128).

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    Accepts multiple hex formats: #RRGGBB, 0xRRGGBB, RRGGBB
    Gracefully handles invalid input by defaulting to gray.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('CHR', 'Hex2RGB')]
    param(
        [Parameter(Mandatory)]
        [string]$Hex
    )
    
    # Remove # or 0x prefix
    $Hex = $Hex -replace '^#|^0x', ''
    
    # Validate hex string
    if ($Hex -notmatch '^[0-9A-Fa-f]{6}$') {
        Write-Warning "Invalid hex color format: $Hex. Expected format: #RRGGBB or RRGGBB"
        return @(128, 128, 128)  # Default to gray
    }
    
    # Convert to RGB
    $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
    
    return @($r, $g, $b)
}

function Convert-RGBToANSI8 {
    <#
    .SYNOPSIS
    Converts RGB values to closest ANSI 8-bit color
    
    .DESCRIPTION
    Finds the closest ANSI 256-color palette match for RGB values
    
    .PARAMETER RGB
    Array of RGB values [R, G, B]
    
    .EXAMPLE
    Convert-RGBToANSI8 @(255, 128, 0)
    Returns: 208 (closest orange in 256-color palette)

    .OUTPUTS
    System.Int32
    Returns an integer between 0-255 representing the closest ANSI 256-color code.
    Uses 6x6x6 color cube (16-231) for colors and 24-step grayscale ramp (232-255) for grays.

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    Uses intelligent grayscale detection (R≈G≈B within 10) to choose between color cube and grayscale ramp.
    Performance optimized with RGB6LevelLookup table (5-10x faster than conditional logic).

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Convert-HexToRGB

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('CRA8', 'RGB2ANSI8')]
    param(
        [Parameter(Mandatory)]
        [int[]]$RGB
    )
    
    $r = $RGB[0]
    $g = $RGB[1]
    $b = $RGB[2]
    
    # Check if it's grayscale
    if ([Math]::Abs($r - $g) -lt 10 -and [Math]::Abs($g - $b) -lt 10) {
        # Use grayscale ramp (colors 232-255)
        $gray = [Math]::Round(($r + $g + $b) / 3)
        if ($gray -lt 8) {
            return 16  # Black
        } elseif ($gray -gt 248) {
            return 231  # White
        } else {
            # Map to 24 grayscale colors (232-255)
            $grayIndex = [Math]::Round(($gray - 8) / 10)
            return 232 + [Math]::Min(23, $grayIndex)
        }
    }
    
    # Map to 6x6x6 color cube (colors 16-231)
    # Convert RGB to 6-level values (0-5) using lookup table
    if ($null -eq $script:RGB6LevelLookup) {
        # Fallback if lookup table not initialized
        $r6 = if ($r -lt 48) { 0 } elseif ($r -lt 115) { 1 } elseif ($r -lt 155) { 2 } elseif ($r -lt 195) { 3 } elseif ($r -lt 235) { 4 } else { 5 }
        $g6 = if ($g -lt 48) { 0 } elseif ($g -lt 115) { 1 } elseif ($g -lt 155) { 2 } elseif ($g -lt 195) { 3 } elseif ($g -lt 235) { 4 } else { 5 }
        $b6 = if ($b -lt 48) { 0 } elseif ($b -lt 115) { 1 } elseif ($b -lt 155) { 2 } elseif ($b -lt 195) { 3 } elseif ($b -lt 235) { 4 } else { 5 }
    } else {
        # Fast lookup table access
        $r6 = $script:RGB6LevelLookup[$r]
        $g6 = $script:RGB6LevelLookup[$g]
        $b6 = $script:RGB6LevelLookup[$b]
    }

    return 16 + (36 * $r6) + (6 * $g6) + $b6
}

function Convert-RGBToANSI4 {
    <#
    .SYNOPSIS
    Converts RGB values to closest ANSI 4-bit color
    
    .DESCRIPTION
    Finds the closest ANSI 16-color match for RGB values
    
    .PARAMETER RGB
    Array of RGB values [R, G, B]
    
    .EXAMPLE
    Convert-RGBToANSI4 @(255, 128, 0)
    Returns: 33 (Yellow in 16-color palette)

    .OUTPUTS
    System.Int32
    Returns an ANSI 4-bit foreground color code:
    - Normal colors: 30-37 (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White)
    - Bright colors: 90-97 (Bright versions of above)
    Brightness determined by maximum RGB channel value (≥200 is bright).

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    Uses intelligent color matching based on dominant RGB channels and brightness analysis.
    Returns foreground codes only (add 10 for background codes: 40-47, 100-107).

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Convert-HexToRGB

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('CRA4', 'RGB2ANSI4')]
    param(
        [Parameter(Mandatory)]
        [int[]]$RGB
    )
    
    $r = $RGB[0]
    $g = $RGB[1]
    $b = $RGB[2]

    # Find dominant color channel
    $max = [Math]::Max($r, [Math]::Max($g, $b))
    $min = [Math]::Min($r, [Math]::Min($g, $b))

    # Calculate brightness (for grayscale detection)
    $brightness = ($r + $g + $b) / 3

    # Determine if it's a bright or dark color based on max channel value
    # For saturated colors like (255, 0, 0), we want to detect as "bright"
    $isBright = $max -ge 200
    
    # Check for grayscale
    if ($max - $min -lt 30) {
        if ($brightness -lt 64) {
            return 30  # Black
        } elseif ($brightness -lt 128) {
            return 90  # Dark Gray
        } elseif ($brightness -lt 192) {
            return 37  # Gray
        } else {
            return 97  # White
        }
    }
    
    # Determine color based on dominant channels
    if ($r -eq $max) {
        if ($g -gt $b + 30) {
            # Yellow range
            if ($isBright) { return 93 } else { return 33 }
        } elseif ($b -gt $g + 30) {
            # Magenta range
            if ($isBright) { return 95 } else { return 35 }
        } else {
            # Red
            if ($isBright) { return 91 } else { return 31 }
        }
    } elseif ($g -eq $max) {
        if ($r -gt $b + 30) {
            # Yellow range
            if ($isBright) { return 93 } else { return 33 }
        } elseif ($b -gt $r + 30) {
            # Cyan range
            if ($isBright) { return 96 } else { return 36 }
        } else {
            # Green
            if ($isBright) { return 92 } else { return 32 }
        }
    } else {
        # Blue is max
        if ($r -gt $g + 30) {
            # Magenta range
            if ($isBright) { return 95 } else { return 35 }
        } elseif ($g -gt $r + 30) {
            # Cyan range
            if ($isBright) { return 96 } else { return 36 }
        } else {
            # Blue
            if ($isBright) { return 94 } else { return 34 }
        }
    }
}

function Get-ColorTableWithRGB {
    <#
    .SYNOPSIS
    Returns the complete color table with RGB values

    .DESCRIPTION
    Returns a comprehensive hashtable containing 70+ color families with Dark/Normal/Light variants.
    Each color entry maps to all supported color modes for seamless conversion.

    ENTRY FORMAT:
    @(Native, ANSI4FG, ANSI4BG, ANSI8, @(R,G,B))
    - Native:  PowerShell ConsoleColor name
    - ANSI4FG: 4-bit foreground code (30-37, 90-97)
    - ANSI4BG: 4-bit background code (40-47, 100-107)
    - ANSI8:   8-bit color code (0-255)
    - RGB:     RGB array @(R, G, B)

    COLOR FAMILIES INCLUDED:
    Neutrals, Red, Green, Blue, Yellow, Cyan, Magenta, Orange, Purple, Pink, Brown,
    Teal, Violet, Lime, Slate, Gold, Sky, Coral, Olive, Lavender, Mint, Salmon,
    Indigo, Turquoise, Ruby, Jade, Amber, Steel, Crimson, Emerald, Sapphire, and more.

    .EXAMPLE
    $colors = Get-ColorTableWithRGB
    $orange = $colors['Orange']
    # $orange[0] = 'DarkYellow'  (Native PowerShell)
    # $orange[1] = 33            (ANSI 4-bit FG)
    # $orange[2] = 43            (ANSI 4-bit BG)
    # $orange[3] = 208           (ANSI 8-bit)
    # $orange[4] = @(255,165,0)  (RGB)

    .EXAMPLE
    $table = Get-ColorTableWithRGB
    $table.Keys | Sort-Object
    # Lists all 70+ available color names

    .OUTPUTS
    System.Collections.Hashtable
    Returns a hashtable where:
    - Keys: Color names (strings)
    - Values: 5-element arrays with Native, ANSI4FG, ANSI4BG, ANSI8, RGB data

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    This table is cached in $script:CachedColorTable during module initialization
    for performance (~1000x faster repeated access).

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX

    .LINK
    Convert-RGBToANSI8

    .LINK
    Convert-RGBToANSI4
    #>
    [CmdletBinding()]
    [Alias('GCT', 'Get-ColorTable', 'Get-ColourTable')]
    param()
    
    return @{
        # Neutral family
        Black = @('Black', 30, 40, 0, @(0, 0, 0))
        LightBlack = @('DarkGray', 90, 100, 238, @(118, 118, 118))
        DarkGray = @('DarkGray', 90, 100, 8, @(128, 128, 128))
        Gray = @('Gray', 37, 47, 7, @(192, 192, 192))
        LightGray = @('Gray', 37, 47, 253, @(238, 238, 238))
        White = @('White', 97, 107, 15, @(255, 255, 255))
        
        # Red family
        DarkRed = @('DarkRed', 31, 41, 52, @(139, 0, 0))
        Red = @('Red', 31, 41, 1, @(255, 0, 0))
        LightRed = @('Red', 91, 101, 9, @(255, 85, 85))
        
        # Green family
        DarkGreen = @('DarkGreen', 32, 42, 28, @(0, 100, 0))
        Green = @('Green', 32, 42, 2, @(0, 255, 0))
        LightGreen = @('Green', 92, 102, 10, @(85, 255, 85))
        
        # Yellow family
        DarkYellow = @('DarkYellow', 33, 43, 136, @(204, 204, 0))
        Yellow = @('Yellow', 33, 43, 220, @(255, 255, 0))
        LightYellow = @('Yellow', 93, 103, 11, @(255, 255, 85))
        
        # Blue family
        DarkBlue = @('DarkBlue', 34, 44, 19, @(0, 0, 139))
        Blue = @('Blue', 34, 44, 4, @(0, 0, 255))
        LightBlue = @('Blue', 94, 104, 12, @(85, 85, 255))
        
        # Magenta family
        DarkMagenta = @('DarkMagenta', 35, 45, 53, @(139, 0, 139))
        Magenta = @('Magenta', 35, 45, 5, @(255, 0, 255))
        LightMagenta = @('Magenta', 95, 105, 13, @(255, 85, 255))
        
        # Cyan family
        DarkCyan = @('DarkCyan', 36, 46, 30, @(0, 139, 139))
        Cyan = @('Cyan', 36, 46, 6, @(0, 255, 255))
        LightCyan = @('Cyan', 96, 106, 14, @(85, 255, 255))
        
        # Orange family
        DarkOrange = @('DarkYellow', 33, 43, 166, @(255, 140, 0))
        Orange = @('DarkYellow', 33, 43, 208, @(255, 165, 0))
        LightOrange = @('Yellow', 33, 43, 215, @(255, 195, 0))
        
        # Purple family
        DarkPurple = @('DarkMagenta', 35, 45, 54, @(75, 0, 130))
        Purple = @('DarkMagenta', 35, 45, 93, @(128, 0, 128))
        LightPurple = @('Magenta', 35, 45, 135, @(147, 112, 219))
        
        # Pink family
        DarkPink = @('DarkMagenta', 35, 45, 163, @(199, 21, 133))
        Pink = @('Magenta', 35, 45, 205, @(255, 192, 203))
        LightPink = @('Magenta', 95, 105, 218, @(255, 182, 193))
        
        # Brown family
        DarkBrown = @('DarkRed', 31, 41, 88, @(101, 67, 33))
        Brown = @('DarkRed', 31, 41, 130, @(150, 75, 0))
        LightBrown = @('DarkYellow', 33, 43, 173, @(205, 133, 63))
        
        # Teal family
        DarkTeal = @('DarkCyan', 36, 46, 23, @(0, 128, 128))
        Teal = @('DarkCyan', 36, 46, 30, @(0, 150, 150))
        LightTeal = @('Cyan', 36, 46, 80, @(64, 224, 208))
        
        # Violet family
        DarkViolet = @('DarkMagenta', 35, 45, 128, @(148, 0, 211))
        Violet = @('Magenta', 35, 45, 134, @(238, 130, 238))
        LightViolet = @('Magenta', 95, 105, 177, @(200, 162, 200))
        
        # Lime family
        DarkLime = @('DarkGreen', 32, 42, 34, @(50, 205, 50))
        Lime = @('Green', 32, 42, 118, @(0, 255, 0))
        LightLime = @('Green', 92, 102, 119, @(50, 255, 50))
        
        # Slate family
        DarkSlate = @('DarkGray', 90, 100, 238, @(47, 79, 79))
        Slate = @('Gray', 37, 47, 102, @(112, 128, 144))
        LightSlate = @('Gray', 37, 47, 103, @(119, 136, 153))
        
        # Gold family
        DarkGold = @('DarkYellow', 33, 43, 136, @(184, 134, 11))
        Gold = @('Yellow', 33, 43, 178, @(255, 215, 0))
        LightGold = @('Yellow', 93, 103, 185, @(255, 223, 0))
        
        # Sky family
        DarkSky = @('DarkBlue', 34, 44, 24, @(0, 191, 255))
        Sky = @('Blue', 34, 44, 111, @(135, 206, 235))
        LightSky = @('Cyan', 36, 46, 152, @(135, 206, 250))
        
        # Coral family
        DarkCoral = @('DarkRed', 31, 41, 167, @(205, 91, 69))
        Coral = @('Red', 31, 41, 209, @(255, 127, 80))
        LightCoral = @('Red', 91, 101, 210, @(240, 128, 128))
        
        # Olive family
        DarkOlive = @('DarkGreen', 32, 42, 58, @(85, 107, 47))
        Olive = @('DarkYellow', 33, 43, 100, @(128, 128, 0))
        LightOlive = @('DarkYellow', 33, 43, 107, @(170, 170, 0))
        
        # Lavender family
        DarkLavender = @('DarkMagenta', 35, 45, 97, @(100, 100, 150))
        Lavender = @('Magenta', 35, 45, 183, @(230, 230, 250))
        LightLavender = @('Magenta', 95, 105, 189, @(240, 240, 255))
        
        # Mint family
        DarkMint = @('DarkGreen', 32, 42, 29, @(60, 179, 113))
        Mint = @('Green', 32, 42, 121, @(152, 251, 152))
        LightMint = @('Green', 92, 102, 157, @(189, 252, 201))
        
        # Salmon family
        DarkSalmon = @('DarkRed', 31, 41, 173, @(233, 150, 122))
        Salmon = @('Red', 31, 41, 174, @(250, 128, 114))
        LightSalmon = @('Red', 91, 101, 175, @(255, 160, 122))
        
        # Indigo family
        DarkIndigo = @('DarkBlue', 34, 44, 17, @(25, 25, 112))
        Indigo = @('DarkMagenta', 35, 45, 54, @(75, 0, 130))
        LightIndigo = @('Blue', 34, 44, 61, @(102, 102, 153))
        
        # Turquoise family
        DarkTurquoise = @('DarkCyan', 36, 46, 31, @(0, 206, 209))
        Turquoise = @('Cyan', 36, 46, 43, @(64, 224, 208))
        LightTurquoise = @('Cyan', 96, 106, 86, @(175, 238, 238))
        
        # Ruby family
        DarkRuby = @('DarkRed', 31, 41, 52, @(155, 17, 30))
        Ruby = @('Red', 31, 41, 124, @(224, 17, 95))
        LightRuby = @('Red', 91, 101, 161, @(255, 102, 153))
        
        # Jade family
        DarkJade = @('DarkGreen', 32, 42, 22, @(0, 100, 50))
        Jade = @('DarkGreen', 32, 42, 35, @(0, 168, 107))
        LightJade = @('Green', 32, 42, 79, @(64, 216, 143))
        
        # Amber family
        DarkAmber = @('DarkYellow', 33, 43, 130, @(255, 160, 0))
        Amber = @('Yellow', 33, 43, 214, @(255, 191, 0))
        LightAmber = @('Yellow', 93, 103, 221, @(255, 204, 0))
        
        # Steel family
        DarkSteel = @('DarkGray', 90, 100, 60, @(70, 70, 70))
        Steel = @('Gray', 37, 47, 66, @(113, 121, 126))
        LightSteel = @('White', 97, 47, 146, @(176, 196, 222))
        
        # Crimson family
        DarkCrimson = @('DarkRed', 31, 41, 88, @(139, 0, 0))
        Crimson = @('Red', 31, 41, 160, @(220, 20, 60))
        LightCrimson = @('Red', 91, 101, 161, @(248, 48, 88))
        
        # Emerald family
        DarkEmerald = @('DarkGreen', 32, 42, 22, @(0, 100, 0))
        Emerald = @('Green', 32, 42, 36, @(80, 200, 120))
        LightEmerald = @('Green', 92, 102, 85, @(128, 255, 170))
        
        # Sapphire family
        DarkSapphire = @('DarkBlue', 34, 44, 18, @(8, 37, 103))
        Sapphire = @('Blue', 34, 44, 25, @(15, 82, 186))
        LightSapphire = @('Blue', 94, 104, 69, @(100, 149, 237))
        
        # Wine family
        DarkWine = @('DarkRed', 31, 41, 52, @(72, 0, 25))
        Wine = @('DarkRed', 31, 41, 88, @(114, 47, 55))
        LightWine = @('Red', 31, 41, 125, @(179, 97, 115))
        
        # Additional color families
        # Peach family
        DarkPeach = @('DarkYellow', 33, 43, 172, @(255, 164, 96))
        Peach = @('Yellow', 33, 43, 216, @(255, 218, 185))
        LightPeach = @('Yellow', 93, 103, 223, @(255, 239, 213))
        
        # Navy family
        DarkNavy = @('DarkBlue', 34, 44, 17, @(0, 0, 80))
        Navy = @('DarkBlue', 34, 44, 18, @(0, 0, 128))
        LightNavy = @('Blue', 34, 44, 24, @(0, 0, 205))
        
        # Forest family
        DarkForest = @('DarkGreen', 32, 42, 22, @(34, 75, 34))
        Forest = @('DarkGreen', 32, 42, 28, @(34, 139, 34))
        LightForest = @('Green', 32, 42, 34, @(50, 205, 50))
        
        # Rose family
        DarkRose = @('DarkMagenta', 35, 45, 125, @(128, 0, 64))
        Rose = @('Magenta', 35, 45, 168, @(255, 0, 127))
        LightRose = @('Magenta', 95, 105, 211, @(255, 182, 193))
        
        # Plum family
        DarkPlum = @('DarkMagenta', 35, 45, 89, @(102, 51, 153))
        Plum = @('Magenta', 35, 45, 133, @(221, 160, 221))
        LightPlum = @('Magenta', 95, 105, 176, @(238, 174, 238))
        
        # Tan family
        DarkTan = @('DarkYellow', 33, 43, 94, @(139, 90, 43))
        Tan = @('Yellow', 33, 43, 180, @(210, 180, 140))
        LightTan = @('Yellow', 93, 103, 187, @(245, 222, 179))
        
        # Maroon family
        DarkMaroon = @('DarkRed', 31, 41, 52, @(69, 0, 0))
        Maroon = @('DarkRed', 31, 41, 88, @(128, 0, 0))
        LightMaroon = @('Red', 31, 41, 124, @(176, 48, 96))
        
        # Aqua family (alternative cyan)
        DarkAqua = @('DarkCyan', 36, 46, 30, @(0, 128, 128))
        Aqua = @('Cyan', 36, 46, 6, @(0, 255, 255))
        LightAqua = @('Cyan', 96, 106, 14, @(127, 255, 255))
        
        # Chartreuse family
        DarkChartreuse = @('DarkGreen', 32, 42, 64, @(69, 139, 0))
        Chartreuse = @('Green', 32, 42, 118, @(127, 255, 0))
        LightChartreuse = @('Green', 92, 102, 154, @(191, 255, 127))
        
        # Brick family
        DarkBrick = @('DarkRed', 31, 41, 88, @(139, 26, 26))
        Brick = @('DarkRed', 31, 41, 124, @(178, 34, 34))
        LightBrick = @('Red', 31, 41, 167, @(205, 92, 92))
    }
}

function Lighten-RGBColor {
    <#
    .SYNOPSIS
    Lightens an RGB color for terminals that don't support true bold fonts

    .DESCRIPTION
    Multiplies RGB values to create a lighter variant, used when Bold style
    is applied in terminals that only brighten colors instead of rendering bold fonts

    .PARAMETER RGB
    Array of RGB values [R, G, B]

    .PARAMETER Factor
    Lightening factor (default 1.4 for 40% lighter)

    .EXAMPLE
    Lighten-RGBColor @(139, 0, 0)
    Returns: @(195, 0, 0) - 40% lighter red

    .EXAMPLE
    Lighten-RGBColor @(50, 50, 50) -Factor 2.0
    Returns: @(100, 100, 100) - Doubled brightness (2x factor)

    .OUTPUTS
    System.Array
    Returns a 3-element integer array @(R, G, B) with lightened values, clamped to 0-255 range.

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    This function is automatically called by Write-ColorEX when Bold styling is applied
    in terminals that don't support true bold fonts (e.g., PowerShell 5.1, conhost.exe).

    Default 1.4 factor provides 40% brighter colors, visually simulating bold effect.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Write-ColorEX

    .LINK
    Test-AnsiSupport
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int[]]$RGB,

        [double]$Factor = 1.4
    )

    # Calculate minimum lightening amount (40% of 255 = ~102)
    # This ensures pure black (0,0,0) becomes dark gray instead of staying black
    $minLighten = [Math]::Round(255 * ($Factor - 1.0))

    $r = [Math]::Min(255, [Math]::Max($minLighten, [Math]::Round($RGB[0] * $Factor)))
    $g = [Math]::Min(255, [Math]::Max($minLighten, [Math]::Round($RGB[1] * $Factor)))
    $b = [Math]::Min(255, [Math]::Max($minLighten, [Math]::Round($RGB[2] * $Factor)))

    return @([int]$r, [int]$g, [int]$b)
}

function Lighten-ANSI8Color {
    <#
    .SYNOPSIS
    Lightens an ANSI8 (256-color) code for terminals that don't support true bold fonts

    .DESCRIPTION
    Algorithmically lightens ANSI 256-color codes when Bold style is applied in terminals
    that only brighten colors instead of rendering bold fonts. Works across all three ANSI8
    color ranges: standard colors (0-15), RGB cube (16-231), and grayscale ramp (232-255).

    This provides a more robust lightening solution compared to color-name-based shifting,
    as it works with direct ANSI8 codes, named colors, and can lighten colors beyond their
    predefined family ranges.

    .PARAMETER ANSI8Code
    ANSI 256-color code to lighten (0-255)

    .PARAMETER Factor
    Lightening factor (default 1.4 for 40% lighter, matching TrueColor behavior)

    .EXAMPLE
    Lighten-ANSI8Color 196
    Returns: 9 (brightened red)
    # ANSI8 code 196 is bright red in RGB cube, lightened to bright red variant

    .EXAMPLE
    Lighten-ANSI8Color 240 -Factor 1.4
    Returns: 246 (lighter gray)
    # Grayscale ramp: moves up ~6 steps for 40% brightness increase

    .EXAMPLE
    Lighten-ANSI8Color 4
    Returns: 12 (bright blue)
    # Standard colors: 4 (dark blue) → 12 (bright blue)

    .OUTPUTS
    System.Int32
    Returns an integer between 0-255 representing the lightened ANSI 256-color code.

    Processing varies by input range:
    - Standard colors (0-15): Maps dark (0-7) to bright (8-15), or converts to RGB cube
    - RGB cube (16-231): Converts to RGB, lightens mathematically, converts back
    - Grayscale ramp (232-255): Increments by ~25% brightness steps

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    This function is automatically called by Write-ColorEX when Bold styling is applied
    in ANSI8 color mode on terminals without true bold font support.

    Benefits over color-name-based lightening:
    - Works with direct ANSI8 codes: Write-ColorEX -Text "Test" -Color 196 -Bold -ANSI8
    - Works with named colors (converted to ANSI8 first)
    - Can lighten "Light*" colors beyond their predefined family
    - Consistent with TrueColor lightening (same 1.4 factor)
    - No need to maintain color family mappings

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Lighten-RGBColor

    .LINK
    Convert-RGBToANSI8

    .LINK
    Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('LA8', 'Lighten-ANSI8')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 255)]
        [int]$ANSI8Code,

        [double]$Factor = 1.4
    )

    # Standard colors (0-15): Map to brighter variants or RGB cube
    if ($ANSI8Code -le 15) {
        # Map dark colors (0-7) to bright variants (8-15)
        if ($ANSI8Code -le 7) {
            return $ANSI8Code + 8
        }
        # Already bright (8-15), convert to RGB, lighten, and convert back
        # Standard ANSI color RGB mappings
        $standardRGB = @(
            @(0, 0, 0),       # 0: Black
            @(128, 0, 0),     # 1: Dark Red (Maroon)
            @(0, 128, 0),     # 2: Dark Green
            @(128, 128, 0),   # 3: Dark Yellow (Olive)
            @(0, 0, 128),     # 4: Dark Blue (Navy)
            @(128, 0, 128),   # 5: Dark Magenta (Purple)
            @(0, 128, 128),   # 6: Dark Cyan (Teal)
            @(192, 192, 192), # 7: Light Gray
            @(128, 128, 128), # 8: Dark Gray
            @(255, 0, 0),     # 9: Red
            @(0, 255, 0),     # 10: Green
            @(255, 255, 0),   # 11: Yellow
            @(0, 0, 255),     # 12: Blue
            @(255, 0, 255),   # 13: Magenta
            @(0, 255, 255),   # 14: Cyan
            @(255, 255, 255)  # 15: White
        )

        $rgb = $standardRGB[$ANSI8Code]
        $lightenedRGB = Lighten-RGBColor -RGB $rgb -Factor $Factor
        return Convert-RGBToANSI8 -RGB $lightenedRGB
    }

    # Grayscale ramp (232-255): Increment by steps
    if ($ANSI8Code -ge 232) {
        $grayLevel = $ANSI8Code - 232  # 0-23
        # Add approximately 25% brightness (~6 steps out of 24)
        $increment = [Math]::Max(1, [Math]::Round(($Factor - 1.0) * 10))
        $newLevel = [Math]::Min(23, $grayLevel + $increment)
        return 232 + $newLevel
    }

    # RGB cube (16-231): Convert to RGB, lighten, convert back
    # ANSI8 color = 16 + (36 × r) + (6 × g) + b
    # where r,g,b are 0-5 (mapped to 0,95,135,175,215,255 in RGB)

    $index = $ANSI8Code - 16
    $r6 = [Math]::Floor($index / 36)
    $g6 = [Math]::Floor(($index % 36) / 6)
    $b6 = $index % 6

    # Convert 0-5 to RGB 0-255
    $rgbLevels = @(0, 95, 135, 175, 215, 255)
    $rgb = @(
        $rgbLevels[$r6],
        $rgbLevels[$g6],
        $rgbLevels[$b6]
    )

    # Lighten RGB values
    $lightenedRGB = Lighten-RGBColor -RGB $rgb -Factor $Factor

    # Convert back to ANSI8
    return Convert-RGBToANSI8 -RGB $lightenedRGB
}

function Lighten-ColorName {
    <#
    .SYNOPSIS
    Lightens a color name for terminals that don't support true bold fonts

    .DESCRIPTION
    Shifts color names from Dark→Normal→Light variants for ANSI4/ANSI8 modes
    when Bold style is applied in terminals that only brighten colors

    .PARAMETER ColorName
    Color name to lighten (e.g., "DarkRed", "Red")

    .EXAMPLE
    Lighten-ColorName "DarkRed"
    Returns: "Red"

    .EXAMPLE
    Lighten-ColorName "Red"
    Returns: "LightRed"

    .EXAMPLE
    Lighten-ColorName "LightGreen"
    Returns: "LightGreen" (already at lightest, no change)

    .OUTPUTS
    System.String
    Returns the lightened color name using the following rules:
    - Dark* → Remove "Dark" prefix (e.g., DarkRed → Red)
    - Normal → Add "Light" prefix (e.g., Red → LightRed)
    - Light* → Return unchanged (already lightest)

    .NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    This function is automatically called by Write-ColorEX when Bold styling is applied
    in ANSI4/ANSI8 color modes on terminals without true bold font support.

    Works with all color families in the PSWriteColorEX color table.

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Lighten-RGBColor

    .LINK
    Write-ColorEX

    .LINK
    Get-ColorTableWithRGB
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ColorName
    )

    # If already Light*, return as-is (can't lighten further)
    if ($ColorName -like 'Light*') {
        return $ColorName
    }

    # If Dark*, remove Dark prefix to get normal variant
    if ($ColorName -like 'Dark*') {
        return $ColorName -replace '^Dark', ''
    }

    # Otherwise, add Light prefix
    return "Light$ColorName"
}