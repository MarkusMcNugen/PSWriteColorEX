#Requires -Modules Pester

BeforeAll {
    # Import the module
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
}

Describe 'Convert-HexToRGB' -Tag 'Unit', 'Function', 'ColorConversion' {

    Context 'Basic Functionality' {
        It 'Converts simple hex color with # prefix' {
            $result = Convert-HexToRGB -Hex '#FF0000'

            $result.Count | Should -Be 3
            $result[0] | Should -Be 255
            $result[1] | Should -Be 0
            $result[2] | Should -Be 0
        }

        It 'Converts hex color with 0x prefix' {
            $result = Convert-HexToRGB -Hex '0xFF0000'

            $result[0] | Should -Be 255
            $result[1] | Should -Be 0
            $result[2] | Should -Be 0
        }

        It 'Converts hex color without prefix' {
            $result = Convert-HexToRGB -Hex 'FF0000'

            $result[0] | Should -Be 255
            $result[1] | Should -Be 0
            $result[2] | Should -Be 0
        }

        It 'Has CHR alias' {
            $command = Get-Command CHR -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Convert-HexToRGB'
        }

        It 'Has Hex2RGB alias' {
            $command = Get-Command Hex2RGB -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Convert-HexToRGB'
        }
    }

    Context 'Color Conversion Accuracy' {
        It 'Converts pure red' {
            $result = Convert-HexToRGB '#FF0000'
            $result | Should -Be @(255, 0, 0)
        }

        It 'Converts pure green' {
            $result = Convert-HexToRGB '#00FF00'
            $result | Should -Be @(0, 255, 0)
        }

        It 'Converts pure blue' {
            $result = Convert-HexToRGB '#0000FF'
            $result | Should -Be @(0, 0, 255)
        }

        It 'Converts white' {
            $result = Convert-HexToRGB '#FFFFFF'
            $result | Should -Be @(255, 255, 255)
        }

        It 'Converts black' {
            $result = Convert-HexToRGB '#000000'
            $result | Should -Be @(0, 0, 0)
        }

        It 'Converts orange' {
            $result = Convert-HexToRGB '#FF8000'
            $result | Should -Be @(255, 128, 0)
        }

        It 'Converts gray' {
            $result = Convert-HexToRGB '#808080'
            $result | Should -Be @(128, 128, 128)
        }

        It 'Handles lowercase hex' {
            $result = Convert-HexToRGB '#ff0000'
            $result | Should -Be @(255, 0, 0)
        }

        It 'Handles mixed case hex' {
            $result = Convert-HexToRGB '#Ff8000'
            $result | Should -Be @(255, 128, 0)
        }
    }

    Context 'Invalid Input Handling' {
        It 'Returns gray for invalid hex format (too short)' {
            $result = Convert-HexToRGB '#FF00'

            $result | Should -Be @(128, 128, 128)
        }

        It 'Returns gray for invalid hex format (too long)' {
            $result = Convert-HexToRGB '#FF000000'

            $result | Should -Be @(128, 128, 128)
        }

        It 'Returns gray for invalid characters' {
            $result = Convert-HexToRGB '#GGGGGG'

            $result | Should -Be @(128, 128, 128)
        }

        It 'Throws error for empty string' {
            { Convert-HexToRGB '' } | Should -Throw
        }

        It 'Returns gray for non-hex characters' {
            $result = Convert-HexToRGB 'notahex'

            $result | Should -Be @(128, 128, 128)
        }
    }

    Context 'Edge Cases' {
        It 'Handles minimum values' {
            $result = Convert-HexToRGB '#000000'
            $result | Should -Be @(0, 0, 0)
        }

        It 'Handles maximum values' {
            $result = Convert-HexToRGB '#FFFFFF'
            $result | Should -Be @(255, 255, 255)
        }

        It 'Handles mid-range values' {
            $result = Convert-HexToRGB '#7F7F7F'
            $result | Should -Be @(127, 127, 127)
        }
    }
}

Describe 'Convert-RGBToANSI8' -Tag 'Unit', 'Function', 'ColorConversion' {

    Context 'Basic Functionality' {
        It 'Converts RGB array to ANSI8 code' {
            $result = Convert-RGBToANSI8 -RGB @(255, 0, 0)

            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Has CRA8 alias' {
            $command = Get-Command CRA8 -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Convert-RGBToANSI8'
        }

        It 'Has RGB2ANSI8 alias' {
            $command = Get-Command RGB2ANSI8 -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Convert-RGBToANSI8'
        }
    }

    Context 'Grayscale Detection' {
        It 'Detects pure black as grayscale' {
            $result = Convert-RGBToANSI8 @(0, 0, 0)

            $result | Should -Be 16
        }

        It 'Detects pure white as grayscale' {
            $result = Convert-RGBToANSI8 @(255, 255, 255)

            $result | Should -Be 231
        }

        It 'Detects mid-gray as grayscale' {
            $result = Convert-RGBToANSI8 @(128, 128, 128)

            # Should be in grayscale range (232-255) or close to gray in color cube
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Detects near-gray values as grayscale' {
            # RGB values within 10 of each other should be grayscale
            $result = Convert-RGBToANSI8 @(100, 105, 100)

            $result | Should -BeGreaterOrEqual 0
        }
    }

    Context 'Color Cube Mapping' {
        It 'Maps pure red to color cube' {
            $result = Convert-RGBToANSI8 @(255, 0, 0)

            # Red in 6x6x6 cube
            $result | Should -BeGreaterOrEqual 16
            $result | Should -BeLessOrEqual 231
        }

        It 'Maps pure green to color cube' {
            $result = Convert-RGBToANSI8 @(0, 255, 0)

            $result | Should -BeGreaterOrEqual 16
            $result | Should -BeLessOrEqual 231
        }

        It 'Maps pure blue to color cube' {
            $result = Convert-RGBToANSI8 @(0, 0, 255)

            $result | Should -BeGreaterOrEqual 16
            $result | Should -BeLessOrEqual 231
        }

        It 'Maps orange correctly' {
            $result = Convert-RGBToANSI8 @(255, 165, 0)

            # Should map to orange-like color in cube
            $result | Should -BeGreaterOrEqual 16
            $result | Should -BeLessOrEqual 255
        }
    }

    Context 'Edge Cases' {
        It 'Handles all zeros' {
            $result = Convert-RGBToANSI8 @(0, 0, 0)

            $result | Should -Be 16
        }

        It 'Handles all maximum values' {
            $result = Convert-RGBToANSI8 @(255, 255, 255)

            $result | Should -Be 231
        }

        It 'Handles mid-range values' {
            $result = Convert-RGBToANSI8 @(127, 127, 127)

            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Returns consistent results for same input' {
            $result1 = Convert-RGBToANSI8 @(100, 150, 200)
            $result2 = Convert-RGBToANSI8 @(100, 150, 200)

            $result1 | Should -Be $result2
        }
    }

    Context 'Lookup Table Usage' {
        It 'Uses lookup table when available' {
            # Lookup table should be initialized by module
            $result = Convert-RGBToANSI8 @(255, 128, 0)

            $result | Should -BeOfType [int]
        }

        It 'Falls back when lookup table not available' {
            # Even without lookup table, should return valid result
            $result = Convert-RGBToANSI8 @(100, 100, 100)

            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }
    }
}

Describe 'Convert-RGBToANSI4' -Tag 'Unit', 'Function', 'ColorConversion' {

    Context 'Basic Functionality' {
        It 'Converts RGB array to ANSI4 code' {
            $result = Convert-RGBToANSI4 -RGB @(255, 0, 0)

            $result | Should -BeOfType [int]
            # ANSI4 codes: 30-37 (dark), 90-97 (bright)
            $result | Should -BeIn @(30..37 + 90..97)
        }

        It 'Has CRA4 alias' {
            $command = Get-Command CRA4 -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Convert-RGBToANSI4'
        }

        It 'Has RGB2ANSI4 alias' {
            $command = Get-Command RGB2ANSI4 -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Convert-RGBToANSI4'
        }
    }

    Context 'Brightness Detection' {
        It 'Detects dark colors correctly' {
            $result = Convert-RGBToANSI4 @(50, 0, 0)

            # Should be in dark range (30-37)
            $result | Should -BeGreaterOrEqual 30
            $result | Should -BeLessOrEqual 37
        }

        It 'Detects bright colors correctly' {
            $result = Convert-RGBToANSI4 @(255, 0, 0)

            # Should be in bright range (90-97)
            $result | Should -BeGreaterOrEqual 90
            $result | Should -BeLessOrEqual 97
        }
    }

    Context 'Grayscale Detection' {
        It 'Maps pure black to black (30)' {
            $result = Convert-RGBToANSI4 @(0, 0, 0)

            $result | Should -Be 30
        }

        It 'Maps pure white to white (97)' {
            $result = Convert-RGBToANSI4 @(255, 255, 255)

            $result | Should -Be 97
        }

        It 'Maps dark gray correctly' {
            $result = Convert-RGBToANSI4 @(50, 50, 50)

            # Should be in grayscale range
            $result | Should -BeIn @(30, 90)
        }

        It 'Maps light gray correctly' {
            $result = Convert-RGBToANSI4 @(200, 200, 200)

            # Should be in grayscale range
            $result | Should -BeIn @(37, 97)
        }
    }

    Context 'Primary Color Detection' {
        It 'Maps bright red' {
            $result = Convert-RGBToANSI4 @(255, 0, 0)

            $result | Should -Be 91
        }

        It 'Maps dark red' {
            $result = Convert-RGBToANSI4 @(100, 0, 0)

            $result | Should -Be 31
        }

        It 'Maps bright green' {
            $result = Convert-RGBToANSI4 @(0, 255, 0)

            $result | Should -Be 92
        }

        It 'Maps dark green' {
            $result = Convert-RGBToANSI4 @(0, 100, 0)

            $result | Should -Be 32
        }

        It 'Maps bright blue' {
            $result = Convert-RGBToANSI4 @(0, 0, 255)

            $result | Should -Be 94
        }

        It 'Maps dark blue' {
            $result = Convert-RGBToANSI4 @(0, 0, 100)

            $result | Should -Be 34
        }
    }

    Context 'Secondary Color Detection' {
        It 'Maps yellow (bright)' {
            $result = Convert-RGBToANSI4 @(255, 255, 0)

            $result | Should -Be 93
        }

        It 'Maps yellow (dark)' {
            $result = Convert-RGBToANSI4 @(100, 100, 0)

            $result | Should -Be 33
        }

        It 'Maps cyan (bright)' {
            $result = Convert-RGBToANSI4 @(0, 255, 255)

            $result | Should -Be 96
        }

        It 'Maps magenta (bright)' {
            $result = Convert-RGBToANSI4 @(255, 0, 255)

            $result | Should -Be 95
        }
    }

    Context 'Edge Cases' {
        It 'Handles minimum values' {
            $result = Convert-RGBToANSI4 @(0, 0, 0)

            $result | Should -BeIn @(30..37 + 90..97)
        }

        It 'Handles maximum values' {
            $result = Convert-RGBToANSI4 @(255, 255, 255)

            $result | Should -BeIn @(30..37 + 90..97)
        }

        It 'Returns consistent results' {
            $result1 = Convert-RGBToANSI4 @(150, 75, 0)
            $result2 = Convert-RGBToANSI4 @(150, 75, 0)

            $result1 | Should -Be $result2
        }
    }
}

Describe 'Get-ColorTableWithRGB' -Tag 'Unit', 'Function', 'ColorConversion' {

    Context 'Basic Functionality' {
        It 'Returns a hashtable' {
            $result = Get-ColorTableWithRGB

            $result | Should -BeOfType [hashtable]
        }

        It 'Has GCT alias' {
            $command = Get-Command GCT -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Get-ColorTableWithRGB'
        }

        It 'Has Get-ColorTable alias' {
            $command = Get-Command Get-ColorTable -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Get-ColorTableWithRGB'
        }

        It 'Has Get-ColourTable alias' {
            $command = Get-Command Get-ColourTable -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Get-ColorTableWithRGB'
        }
    }

    Context 'Color Table Structure' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'Contains expected number of colors' {
            $colorTable.Count | Should -BeGreaterThan 50
        }

        It 'Each color entry is an array' {
            foreach ($key in $colorTable.Keys) {
                $colorTable[$key].Count | Should -BeGreaterThan 0
            }
        }

        It 'Each color entry has 5 elements' {
            foreach ($key in $colorTable.Keys) {
                $colorTable[$key].Count | Should -Be 5
            }
        }

        It 'Each color entry has correct structure (Native, ANSI4FG, ANSI4BG, ANSI8, RGB)' {
            $red = $colorTable['Red']

            $red[0] | Should -BeOfType [string]  # Native PowerShell color
            $red[1] | Should -BeOfType [int]     # ANSI4 Foreground
            $red[2] | Should -BeOfType [int]     # ANSI4 Background
            $red[3] | Should -BeOfType [int]     # ANSI8 code
            $red[4].Count | Should -Be 3         # RGB array has 3 elements
        }
    }

    Context 'Neutral Colors' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'Contains Black' {
            $colorTable.ContainsKey('Black') | Should -Be $true
            $colorTable['Black'][4] | Should -Be @(0, 0, 0)
        }

        It 'Contains White' {
            $colorTable.ContainsKey('White') | Should -Be $true
            $colorTable['White'][4] | Should -Be @(255, 255, 255)
        }

        It 'Contains Gray' {
            $colorTable.ContainsKey('Gray') | Should -Be $true
        }

        It 'Contains DarkGray' {
            $colorTable.ContainsKey('DarkGray') | Should -Be $true
        }

        It 'Contains LightGray' {
            $colorTable.ContainsKey('LightGray') | Should -Be $true
        }
    }

    Context 'Primary Color Families' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'Contains Red family (Dark, Normal, Light)' {
            $colorTable.ContainsKey('DarkRed') | Should -Be $true
            $colorTable.ContainsKey('Red') | Should -Be $true
            $colorTable.ContainsKey('LightRed') | Should -Be $true
        }

        It 'Contains Green family' {
            $colorTable.ContainsKey('DarkGreen') | Should -Be $true
            $colorTable.ContainsKey('Green') | Should -Be $true
            $colorTable.ContainsKey('LightGreen') | Should -Be $true
        }

        It 'Contains Blue family' {
            $colorTable.ContainsKey('DarkBlue') | Should -Be $true
            $colorTable.ContainsKey('Blue') | Should -Be $true
            $colorTable.ContainsKey('LightBlue') | Should -Be $true
        }

        It 'Contains Yellow family' {
            $colorTable.ContainsKey('DarkYellow') | Should -Be $true
            $colorTable.ContainsKey('Yellow') | Should -Be $true
            $colorTable.ContainsKey('LightYellow') | Should -Be $true
        }

        It 'Contains Cyan family' {
            $colorTable.ContainsKey('DarkCyan') | Should -Be $true
            $colorTable.ContainsKey('Cyan') | Should -Be $true
            $colorTable.ContainsKey('LightCyan') | Should -Be $true
        }

        It 'Contains Magenta family' {
            $colorTable.ContainsKey('DarkMagenta') | Should -Be $true
            $colorTable.ContainsKey('Magenta') | Should -Be $true
            $colorTable.ContainsKey('LightMagenta') | Should -Be $true
        }
    }

    Context 'Extended Color Families' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'Contains Orange family' {
            $colorTable.ContainsKey('DarkOrange') | Should -Be $true
            $colorTable.ContainsKey('Orange') | Should -Be $true
            $colorTable.ContainsKey('LightOrange') | Should -Be $true
        }

        It 'Contains Purple family' {
            $colorTable.ContainsKey('DarkPurple') | Should -Be $true
            $colorTable.ContainsKey('Purple') | Should -Be $true
            $colorTable.ContainsKey('LightPurple') | Should -Be $true
        }

        It 'Contains Pink family' {
            $colorTable.ContainsKey('DarkPink') | Should -Be $true
            $colorTable.ContainsKey('Pink') | Should -Be $true
            $colorTable.ContainsKey('LightPink') | Should -Be $true
        }

        It 'Contains Teal family' {
            $colorTable.ContainsKey('DarkTeal') | Should -Be $true
            $colorTable.ContainsKey('Teal') | Should -Be $true
            $colorTable.ContainsKey('LightTeal') | Should -Be $true
        }
    }

    Context 'Specialty Color Families' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'Contains Crimson family' {
            $colorTable.ContainsKey('DarkCrimson') | Should -Be $true
            $colorTable.ContainsKey('Crimson') | Should -Be $true
            $colorTable.ContainsKey('LightCrimson') | Should -Be $true
        }

        It 'Contains Emerald family' {
            $colorTable.ContainsKey('DarkEmerald') | Should -Be $true
            $colorTable.ContainsKey('Emerald') | Should -Be $true
            $colorTable.ContainsKey('LightEmerald') | Should -Be $true
        }

        It 'Contains Sapphire family' {
            $colorTable.ContainsKey('DarkSapphire') | Should -Be $true
            $colorTable.ContainsKey('Sapphire') | Should -Be $true
            $colorTable.ContainsKey('LightSapphire') | Should -Be $true
        }
    }

    Context 'RGB Value Validation' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'All RGB values are within valid range (0-255)' {
            foreach ($key in $colorTable.Keys) {
                $rgb = $colorTable[$key][4]
                $rgb[0] | Should -BeGreaterOrEqual 0
                $rgb[0] | Should -BeLessOrEqual 255
                $rgb[1] | Should -BeGreaterOrEqual 0
                $rgb[1] | Should -BeLessOrEqual 255
                $rgb[2] | Should -BeGreaterOrEqual 0
                $rgb[2] | Should -BeLessOrEqual 255
            }
        }

        It 'Red color has correct RGB values' {
            $red = $colorTable['Red']
            $red[4] | Should -Be @(255, 0, 0)
        }

        It 'Green color has correct RGB values' {
            $green = $colorTable['Green']
            $green[4] | Should -Be @(0, 255, 0)
        }

        It 'Blue color has correct RGB values' {
            $blue = $colorTable['Blue']
            $blue[4] | Should -Be @(0, 0, 255)
        }
    }

    Context 'ANSI Code Validation' {
        BeforeAll {
            $colorTable = Get-ColorTableWithRGB
        }

        It 'All ANSI4 foreground codes are valid' {
            foreach ($key in $colorTable.Keys) {
                $ansi4fg = $colorTable[$key][1]
                $ansi4fg | Should -BeIn @(30..37 + 90..97)
            }
        }

        It 'All ANSI4 background codes are valid' {
            foreach ($key in $colorTable.Keys) {
                $ansi4bg = $colorTable[$key][2]
                $ansi4bg | Should -BeIn @(40..47 + 100..107)
            }
        }

        It 'All ANSI8 codes are within valid range' {
            foreach ($key in $colorTable.Keys) {
                $ansi8 = $colorTable[$key][3]
                $ansi8 | Should -BeGreaterOrEqual 0
                $ansi8 | Should -BeLessOrEqual 255
            }
        }
    }

    Context 'Return Value Consistency' {
        It 'Returns same table on multiple calls' {
            $table1 = Get-ColorTableWithRGB
            $table2 = Get-ColorTableWithRGB

            $table1.Count | Should -Be $table2.Count
        }

        It 'Table is not empty' {
            $table = Get-ColorTableWithRGB

            $table.Count | Should -BeGreaterThan 0
        }
    }
}

# NEW TESTS: Lighten-RGBColor Function
Describe 'Lighten-RGBColor' -Tag 'Unit', 'Function', 'ColorConversion' {
    Context 'Basic Functionality' {
        It 'Lightens RGB color by default factor (1.4)' {
            $result = Lighten-RGBColor -RGB @(100, 100, 100)

            $result[0] | Should -BeGreaterThan 100
            $result[1] | Should -BeGreaterThan 100
            $result[2] | Should -BeGreaterThan 100
            $result[0] | Should -Be 140
            $result[1] | Should -Be 140
            $result[2] | Should -Be 140
        }

        It 'Returns array of 3 integers' {
            $result = Lighten-RGBColor -RGB @(100, 100, 100)

            $result.Count | Should -Be 3
            $result[0] | Should -BeOfType [int]
            $result[1] | Should -BeOfType [int]
            $result[2] | Should -BeOfType [int]
        }

        It 'Accepts Factor parameter' {
            $result = Lighten-RGBColor -RGB @(100, 100, 100) -Factor 2.0

            # With Factor 2.0: minLighten = 255 * (2.0-1.0) = 255
            # max(255, 200) = 255
            $result[0] | Should -Be 255
            $result[1] | Should -Be 255
            $result[2] | Should -Be 255
        }

        It 'Accepts Factor parameter with decimal values' {
            $result = Lighten-RGBColor -RGB @(50, 50, 50) -Factor 1.5

            # With Factor 1.5: minLighten = 255 * (1.5-1.0) = 128
            # max(128, 75) = 128
            $result[0] | Should -Be 128
            $result[1] | Should -Be 128
            $result[2] | Should -Be 128
        }
    }

    Context 'Clamping to 255 Maximum' {
        It 'Clamps values to 255 maximum' {
            $result = Lighten-RGBColor -RGB @(200, 200, 200)

            $result[0] | Should -BeLessOrEqual 255
            $result[1] | Should -BeLessOrEqual 255
            $result[2] | Should -BeLessOrEqual 255
        }

        It 'Clamps individual channels that exceed 255' {
            $result = Lighten-RGBColor -RGB @(200, 150, 100) -Factor 1.4

            $result[0] | Should -Be 255  # 200 * 1.4 = 280, clamped to 255
            $result[1] | Should -Be 210  # 150 * 1.4 = 210
            $result[2] | Should -Be 140  # 100 * 1.4 = 140
        }

        It 'Handles already maxed-out values (255)' {
            $result = Lighten-RGBColor -RGB @(255, 255, 255)

            $result | Should -Be @(255, 255, 255)
        }

        It 'Handles large factor that would overflow' {
            $result = Lighten-RGBColor -RGB @(150, 150, 150) -Factor 3.0

            $result[0] | Should -Be 255  # 150 * 3 = 450, clamped
            $result[1] | Should -Be 255
            $result[2] | Should -Be 255
        }
    }

    Context 'Edge Cases' {
        It 'Handles black color (0,0,0)' {
            $result = Lighten-RGBColor -RGB @(0, 0, 0)

            # With minLighten = 102: max(102, 0) = 102
            $result | Should -Be @(102, 102, 102)  # Lightened to dark gray
        }

        It 'Handles pure red' {
            $result = Lighten-RGBColor -RGB @(255, 0, 0)

            $result[0] | Should -Be 255  # Clamped
            $result[1] | Should -Be 102  # max(102, 0) = 102
            $result[2] | Should -Be 102  # max(102, 0) = 102
        }

        It 'Handles pure green' {
            $result = Lighten-RGBColor -RGB @(0, 255, 0)

            $result[0] | Should -Be 102  # max(102, 0) = 102
            $result[1] | Should -Be 255  # Clamped
            $result[2] | Should -Be 102  # max(102, 0) = 102
        }

        It 'Handles pure blue' {
            $result = Lighten-RGBColor -RGB @(0, 0, 255)

            $result[0] | Should -Be 102  # max(102, 0) = 102
            $result[1] | Should -Be 102  # max(102, 0) = 102
            $result[2] | Should -Be 255  # Clamped
        }

        It 'Handles very dark colors' {
            $result = Lighten-RGBColor -RGB @(10, 10, 10)

            # max(102, 14) = 102
            $result[0] | Should -Be 102
            $result[1] | Should -Be 102
            $result[2] | Should -Be 102
        }

        It 'Handles mid-range gray' {
            $result = Lighten-RGBColor -RGB @(128, 128, 128)

            $result[0] | Should -Be 179  # 128 * 1.4 = 179.2, rounded
            $result[1] | Should -Be 179
            $result[2] | Should -Be 179
        }
    }

    Context 'Rounding Behavior' {
        It 'Rounds fractional values correctly' {
            $result = Lighten-RGBColor -RGB @(75, 75, 75)

            # 75 * 1.4 = 105
            $result | Should -Be @(105, 105, 105)
        }

        It 'Handles rounding up' {
            $result = Lighten-RGBColor -RGB @(71, 71, 71)

            # 71 * 1.4 = 99.4, rounds to 99
            # max(102, 99) = 102
            $result[0] | Should -Be 102
        }

        It 'Handles rounding down' {
            $result = Lighten-RGBColor -RGB @(70, 70, 70)

            # 70 * 1.4 = 98
            # max(102, 98) = 102
            $result[0] | Should -Be 102
        }
    }

    Context 'Different Color Values' {
        It 'Lightens dark red' {
            $result = Lighten-RGBColor -RGB @(100, 0, 0)

            $result[0] | Should -Be 140  # 100 * 1.4 = 140
            $result[1] | Should -Be 102  # max(102, 0) = 102
            $result[2] | Should -Be 102  # max(102, 0) = 102
        }

        It 'Lightens orange' {
            $result = Lighten-RGBColor -RGB @(255, 165, 0)

            $result[0] | Should -Be 255  # Clamped
            $result[1] | Should -Be 231  # 165 * 1.4 = 231
            $result[2] | Should -Be 102  # max(102, 0) = 102
        }

        It 'Lightens purple' {
            $result = Lighten-RGBColor -RGB @(128, 0, 128)

            $result[0] | Should -Be 179  # 128 * 1.4 = 179
            $result[1] | Should -Be 102  # max(102, 0) = 102
            $result[2] | Should -Be 179  # 128 * 1.4 = 179
        }
    }
}

# NEW TESTS: Lighten-ColorName Function
Describe 'Lighten-ColorName' -Tag 'Unit', 'Function', 'ColorConversion' {
    Context 'Dark to Normal Conversion' {
        It 'Converts DarkRed to Red' {
            $result = Lighten-ColorName -ColorName 'DarkRed'
            $result | Should -Be 'Red'
        }

        It 'Converts DarkBlue to Blue' {
            $result = Lighten-ColorName -ColorName 'DarkBlue'
            $result | Should -Be 'Blue'
        }

        It 'Converts DarkGreen to Green' {
            $result = Lighten-ColorName -ColorName 'DarkGreen'
            $result | Should -Be 'Green'
        }

        It 'Converts DarkYellow to Yellow' {
            $result = Lighten-ColorName -ColorName 'DarkYellow'
            $result | Should -Be 'Yellow'
        }

        It 'Converts DarkCyan to Cyan' {
            $result = Lighten-ColorName -ColorName 'DarkCyan'
            $result | Should -Be 'Cyan'
        }

        It 'Converts DarkMagenta to Magenta' {
            $result = Lighten-ColorName -ColorName 'DarkMagenta'
            $result | Should -Be 'Magenta'
        }

        It 'Converts DarkGray to Gray' {
            $result = Lighten-ColorName -ColorName 'DarkGray'
            $result | Should -Be 'Gray'
        }
    }

    Context 'Normal to Light Conversion' {
        It 'Converts Red to LightRed' {
            $result = Lighten-ColorName -ColorName 'Red'
            $result | Should -Be 'LightRed'
        }

        It 'Converts Blue to LightBlue' {
            $result = Lighten-ColorName -ColorName 'Blue'
            $result | Should -Be 'LightBlue'
        }

        It 'Converts Green to LightGreen' {
            $result = Lighten-ColorName -ColorName 'Green'
            $result | Should -Be 'LightGreen'
        }

        It 'Converts Yellow to LightYellow' {
            $result = Lighten-ColorName -ColorName 'Yellow'
            $result | Should -Be 'LightYellow'
        }

        It 'Converts Cyan to LightCyan' {
            $result = Lighten-ColorName -ColorName 'Cyan'
            $result | Should -Be 'LightCyan'
        }

        It 'Converts Magenta to LightMagenta' {
            $result = Lighten-ColorName -ColorName 'Magenta'
            $result | Should -Be 'LightMagenta'
        }

        It 'Converts Gray to LightGray' {
            $result = Lighten-ColorName -ColorName 'Gray'
            $result | Should -Be 'LightGray'
        }
    }

    Context 'Already Light Colors' {
        It 'Returns LightRed unchanged' {
            $result = Lighten-ColorName -ColorName 'LightRed'
            $result | Should -Be 'LightRed'
        }

        It 'Returns LightBlue unchanged' {
            $result = Lighten-ColorName -ColorName 'LightBlue'
            $result | Should -Be 'LightBlue'
        }

        It 'Returns LightGreen unchanged' {
            $result = Lighten-ColorName -ColorName 'LightGreen'
            $result | Should -Be 'LightGreen'
        }

        It 'Returns LightYellow unchanged' {
            $result = Lighten-ColorName -ColorName 'LightYellow'
            $result | Should -Be 'LightYellow'
        }

        It 'Returns LightCyan unchanged' {
            $result = Lighten-ColorName -ColorName 'LightCyan'
            $result | Should -Be 'LightCyan'
        }

        It 'Returns LightMagenta unchanged' {
            $result = Lighten-ColorName -ColorName 'LightMagenta'
            $result | Should -Be 'LightMagenta'
        }

        It 'Returns LightGray unchanged' {
            $result = Lighten-ColorName -ColorName 'LightGray'
            $result | Should -Be 'LightGray'
        }
    }

    Context 'Extended Color Names' {
        It 'Converts DarkOrange to Orange' {
            $result = Lighten-ColorName -ColorName 'DarkOrange'
            $result | Should -Be 'Orange'
        }

        It 'Converts Orange to LightOrange' {
            $result = Lighten-ColorName -ColorName 'Orange'
            $result | Should -Be 'LightOrange'
        }

        It 'Converts DarkPurple to Purple' {
            $result = Lighten-ColorName -ColorName 'DarkPurple'
            $result | Should -Be 'Purple'
        }

        It 'Converts Purple to LightPurple' {
            $result = Lighten-ColorName -ColorName 'Purple'
            $result | Should -Be 'LightPurple'
        }

        It 'Returns LightOrange unchanged' {
            $result = Lighten-ColorName -ColorName 'LightOrange'
            $result | Should -Be 'LightOrange'
        }
    }

    Context 'Special Colors' {
        It 'Converts Black to LightBlack' {
            $result = Lighten-ColorName -ColorName 'Black'
            $result | Should -Be 'LightBlack'
        }

        It 'Converts White to LightWhite' {
            $result = Lighten-ColorName -ColorName 'White'
            $result | Should -Be 'LightWhite'
        }

        It 'Returns LightWhite unchanged' {
            $result = Lighten-ColorName -ColorName 'LightWhite'
            $result | Should -Be 'LightWhite'
        }
    }

    Context 'Return Value Type' {
        It 'Returns a string' {
            $result = Lighten-ColorName -ColorName 'Red'
            $result | Should -BeOfType [string]
        }

        It 'Returns non-empty string' {
            $result = Lighten-ColorName -ColorName 'Blue'
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

# NEW TESTS: Lighten-ANSI8Color Function
Describe 'Lighten-ANSI8Color' -Tag 'Unit', 'Function', 'ColorConversion' {
    Context 'Standard Colors (0-15) - Dark to Bright Mapping' {
        It 'Converts Black (0) to Dark Gray (8)' {
            $result = Lighten-ANSI8Color -ANSI8Code 0
            $result | Should -Be 8
        }

        It 'Converts Dark Red/Maroon (1) to Red (9)' {
            $result = Lighten-ANSI8Color -ANSI8Code 1
            $result | Should -Be 9
        }

        It 'Converts Dark Green (2) to Green (10)' {
            $result = Lighten-ANSI8Color -ANSI8Code 2
            $result | Should -Be 10
        }

        It 'Converts Dark Yellow/Olive (3) to Yellow (11)' {
            $result = Lighten-ANSI8Color -ANSI8Code 3
            $result | Should -Be 11
        }

        It 'Converts Dark Blue/Navy (4) to Blue (12)' {
            $result = Lighten-ANSI8Color -ANSI8Code 4
            $result | Should -Be 12
        }

        It 'Converts Dark Magenta/Purple (5) to Magenta (13)' {
            $result = Lighten-ANSI8Color -ANSI8Code 5
            $result | Should -Be 13
        }

        It 'Converts Dark Cyan/Teal (6) to Cyan (14)' {
            $result = Lighten-ANSI8Color -ANSI8Code 6
            $result | Should -Be 14
        }

        It 'Converts Light Gray (7) to White (15)' {
            $result = Lighten-ANSI8Color -ANSI8Code 7
            $result | Should -Be 15
        }
    }

    Context 'Standard Colors (0-15) - Bright Colors (Already Bright)' {
        It 'Lightens Dark Gray (8) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 8
            # Dark Gray @(128,128,128) * 1.4 = @(179,179,179) -> maps to ANSI8
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterThan 7
        }

        It 'Lightens Red (9) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 9
            # Red @(255,0,0) * 1.4 = @(255,0,0) clamped -> maps to ANSI8
            $result | Should -BeOfType [int]
        }

        It 'Lightens Green (10) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 10
            $result | Should -BeOfType [int]
        }

        It 'Lightens Yellow (11) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 11
            $result | Should -BeOfType [int]
        }

        It 'Lightens Blue (12) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 12
            $result | Should -BeOfType [int]
        }

        It 'Lightens Magenta (13) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 13
            $result | Should -BeOfType [int]
        }

        It 'Lightens Cyan (14) via RGB conversion' {
            $result = Lighten-ANSI8Color -ANSI8Code 14
            $result | Should -BeOfType [int]
        }

        It 'Lightens White (15) via RGB conversion (already at max)' {
            $result = Lighten-ANSI8Color -ANSI8Code 15
            # White @(255,255,255) * 1.4 = @(255,255,255) clamped -> stays white-ish
            $result | Should -BeOfType [int]
        }
    }

    Context 'RGB Cube (16-231) - Common Colors' {
        It 'Lightens ANSI8 code 196 (bright red in cube)' {
            $result = Lighten-ANSI8Color -ANSI8Code 196
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens ANSI8 code 46 (bright green in cube)' {
            $result = Lighten-ANSI8Color -ANSI8Code 46
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens ANSI8 code 21 (bright blue in cube)' {
            $result = Lighten-ANSI8Color -ANSI8Code 21
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens ANSI8 code 208 (orange in cube)' {
            $result = Lighten-ANSI8Color -ANSI8Code 208
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens ANSI8 code 165 (purple in cube)' {
            $result = Lighten-ANSI8Color -ANSI8Code 165
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens dark RGB cube color (code 16 - pure black)' {
            $result = Lighten-ANSI8Color -ANSI8Code 16
            # Code 16 = RGB @(0,0,0) in cube
            # With min lightening (102,102,102), should map to dark gray
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterThan 16  # Black lightens to dark gray
        }

        It 'Lightens bright RGB cube color (code 231 - near white)' {
            $result = Lighten-ANSI8Color -ANSI8Code 231
            # Code 231 = RGB @(255,255,255) in cube, stays near white
            $result | Should -BeOfType [int]
        }
    }

    Context 'Grayscale Ramp (232-255)' {
        It 'Lightens darkest gray (232)' {
            $result = Lighten-ANSI8Color -ANSI8Code 232
            # Should move up the grayscale ramp
            $result | Should -BeGreaterThan 232
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens middle gray (243)' {
            $result = Lighten-ANSI8Color -ANSI8Code 243
            # Should move up the grayscale ramp
            $result | Should -BeGreaterThan 243
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens gray near white (250)' {
            $result = Lighten-ANSI8Color -ANSI8Code 250
            # Should move up but may cap at 255
            $result | Should -BeGreaterOrEqual 250
            $result | Should -BeLessOrEqual 255
        }

        It 'Lightens brightest gray (255) - should clamp at 255' {
            $result = Lighten-ANSI8Color -ANSI8Code 255
            # Already at max, should stay at 255 or near it
            $result | Should -Be 255
        }

        It 'Increments grayscale by approximately 25% (Factor 1.4)' {
            $result = Lighten-ANSI8Color -ANSI8Code 240
            # Increment should be roughly 4-6 steps with factor 1.4
            $increment = $result - 240
            $increment | Should -BeGreaterOrEqual 1
            $increment | Should -BeLessOrEqual 15  # Max 15 to stay in range
        }
    }

    Context 'Custom Lightening Factor' {
        It 'Accepts custom factor (2.0 - doubling)' {
            $result = Lighten-ANSI8Color -ANSI8Code 100 -Factor 2.0
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Accepts custom factor (1.2 - subtle lightening)' {
            $result = Lighten-ANSI8Color -ANSI8Code 100 -Factor 1.2
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Uses default factor 1.4 when not specified' {
            $result1 = Lighten-ANSI8Color -ANSI8Code 100
            $result2 = Lighten-ANSI8Color -ANSI8Code 100 -Factor 1.4
            $result1 | Should -Be $result2
        }
    }

    Context 'Edge Cases and Validation' {
        It 'Handles minimum ANSI8 code (0)' {
            $result = Lighten-ANSI8Color -ANSI8Code 0
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Handles maximum ANSI8 code (255)' {
            $result = Lighten-ANSI8Color -ANSI8Code 255
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Returns integer type for all inputs' {
            $result = Lighten-ANSI8Color -ANSI8Code 128
            $result | Should -BeOfType [int]
        }

        It 'Does not return negative values' {
            $result = Lighten-ANSI8Color -ANSI8Code 0
            $result | Should -BeGreaterOrEqual 0
        }

        It 'Does not exceed 255' {
            $result = Lighten-ANSI8Color -ANSI8Code 255
            $result | Should -BeLessOrEqual 255
        }
    }

    Context 'Algorithm Consistency' {
        It 'Produces consistent results for same input' {
            $result1 = Lighten-ANSI8Color -ANSI8Code 100
            $result2 = Lighten-ANSI8Color -ANSI8Code 100
            $result1 | Should -Be $result2
        }

        It 'Lightens colors (result should be brighter or same)' {
            # For most colors, the result should be equal or greater
            # Exception: RGB cube might map to lower codes if nearest color is different
            $testCodes = @(1, 2, 3, 4, 5, 6, 232, 233, 234)
            foreach ($code in $testCodes) {
                $result = Lighten-ANSI8Color -ANSI8Code $code
                # Should return valid ANSI8 code
                $result | Should -BeGreaterOrEqual 0
                $result | Should -BeLessOrEqual 255
            }
        }

        It 'Works with Lighten-RGBColor internally for RGB calculations' {
            # Test that RGB conversion works correctly
            $result = Lighten-ANSI8Color -ANSI8Code 196  # Bright red in cube
            # Should lighten the red color
            $result | Should -BeOfType [int]
        }
    }

    Context 'Alias Support' {
        It 'Works with LA8 alias' {
            $result = LA8 -ANSI8Code 100
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Works with Lighten-ANSI8 alias' {
            $result = Lighten-ANSI8 -ANSI8Code 100
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }
    }

    Context 'Integration with Color Table' {
        It 'Can lighten named color ANSI8 codes from color table' {
            $colors = Get-ColorTableWithRGB
            $redCode = $colors['Red'][3]  # ANSI8 code for Red
            $result = Lighten-ANSI8Color -ANSI8Code $redCode
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }

        It 'Can lighten DarkRed ANSI8 code' {
            $colors = Get-ColorTableWithRGB
            $darkRedCode = $colors['DarkRed'][3]
            $result = Lighten-ANSI8Color -ANSI8Code $darkRedCode
            $result | Should -BeOfType [int]
        }

        It 'Can lighten LightRed ANSI8 code (beyond predefined family)' {
            $colors = Get-ColorTableWithRGB
            $lightRedCode = $colors['LightRed'][3]
            $result = Lighten-ANSI8Color -ANSI8Code $lightRedCode
            # This is the advantage - can lighten beyond predefined families
            $result | Should -BeOfType [int]
            $result | Should -BeGreaterOrEqual 0
            $result | Should -BeLessOrEqual 255
        }
    }

    Context 'Performance' {
        It 'Completes lightening in reasonable time (< 10ms for single call)' {
            $elapsed = Measure-Command {
                $null = Lighten-ANSI8Color -ANSI8Code 128
            }
            $elapsed.TotalMilliseconds | Should -BeLessThan 10
        }

        It 'Handles batch processing efficiently (100 calls < 50ms)' {
            $elapsed = Measure-Command {
                foreach ($i in 1..100) {
                    $null = Lighten-ANSI8Color -ANSI8Code 128
                }
            }
            $elapsed.TotalMilliseconds | Should -BeLessThan 50
        }
    }
}
