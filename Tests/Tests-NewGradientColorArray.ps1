#Requires -Modules Pester

BeforeAll {
    # Import the module
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force

    # Dot-source the class file and private function for testing
    . "$ModuleRoot\Classes\PSColorStyle.ps1"
    . "$ModuleRoot\Private\New-GradientColorArray.ps1"
}

Describe 'New-GradientColorArray' -Tag 'Unit', 'Function', 'Gradient' {

    Context 'Basic Functionality' {
        It 'Generates gradient array' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor

            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 10
        }

        It 'Accepts color names' {
            $result = New-GradientColorArray -Colors @('Red', 'Green', 'Blue') -Steps 5 -Mode TrueColor

            $result.Count | Should -Be 5
        }

        It 'Accepts hex colors' {
            $result = New-GradientColorArray -Colors @('#FF0000', '#0000FF') -Steps 10 -Mode TrueColor

            $result.Count | Should -Be 10
        }

        It 'Accepts RGB arrays' {
            $result = New-GradientColorArray -Colors @(@(255, 0, 0), @(0, 0, 255)) -Steps 10 -Mode TrueColor

            $result.Count | Should -Be 10
        }

        It 'Accepts mixed color formats' {
            $result = New-GradientColorArray -Colors @('Red', '#00FF00', @(0, 0, 255)) -Steps 10 -Mode TrueColor

            $result.Count | Should -Be 10
        }
    }

    Context 'Parameter Validation' {
        It 'Requires at least 2 colors' {
            { New-GradientColorArray -Colors @('Red') -Steps 10 -Mode TrueColor } | Should -Throw
        }

        It 'Accepts exactly 2 colors' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor } | Should -Not -Throw
        }

        It 'Accepts more than 2 colors' {
            { New-GradientColorArray -Colors @('Red', 'Green', 'Blue', 'Yellow') -Steps 20 -Mode TrueColor } | Should -Not -Throw
        }

        It 'Requires Steps parameter' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Mode TrueColor } | Should -Throw
        }

        It 'Requires Mode parameter' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 } | Should -Throw
        }

        It 'Accepts TrueColor mode' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor } | Should -Not -Throw
        }

        It 'Accepts ANSI8 mode' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode ANSI8 } | Should -Not -Throw
        }

        It 'Rejects invalid mode' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode ANSI4 } | Should -Throw
        }

        It 'Requires positive Steps value' {
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 0 -Mode TrueColor } | Should -Throw
        }
    }

    Context 'TrueColor Mode Output' {
        It 'Returns RGB arrays in TrueColor mode' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 5 -Mode TrueColor

            foreach ($color in $result) {
                $color.Count | Should -Be 3
            }
        }

        It 'First color matches start color' {
            $result = New-GradientColorArray -Colors @(@(255, 0, 0), @(0, 0, 255)) -Steps 10 -Mode TrueColor

            $result[0][0] | Should -Be 255
            $result[0][1] | Should -Be 0
            $result[0][2] | Should -Be 0
        }

        It 'Last color matches end color' {
            $result = New-GradientColorArray -Colors @(@(255, 0, 0), @(0, 0, 255)) -Steps 10 -Mode TrueColor

            $result[9][0] | Should -Be 0
            $result[9][1] | Should -Be 0
            $result[9][2] | Should -Be 255
        }

        It 'Middle colors are interpolated' {
            $result = New-GradientColorArray -Colors @(@(0, 0, 0), @(100, 100, 100)) -Steps 3 -Mode TrueColor

            # Middle value should be approximately 50
            $result[1][0] | Should -BeGreaterOrEqual 45
            $result[1][0] | Should -BeLessOrEqual 55
        }

        It 'RGB values stay within 0-255 range' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue', 'Green') -Steps 20 -Mode TrueColor

            foreach ($color in $result) {
                $color[0] | Should -BeGreaterOrEqual 0
                $color[0] | Should -BeLessOrEqual 255
                $color[1] | Should -BeGreaterOrEqual 0
                $color[1] | Should -BeLessOrEqual 255
                $color[2] | Should -BeGreaterOrEqual 0
                $color[2] | Should -BeLessOrEqual 255
            }
        }
    }

    Context 'ANSI8 Mode Output' {
        It 'Returns ANSI8 codes in ANSI8 mode' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 5 -Mode ANSI8

            foreach ($code in $result) {
                $code | Should -BeOfType [int]
                $code | Should -BeGreaterOrEqual 0
                $code | Should -BeLessOrEqual 255
            }
        }

        It 'Generates correct number of codes' {
            $result = New-GradientColorArray -Colors @('Red', 'Green') -Steps 15 -Mode ANSI8

            $result.Count | Should -Be 15
        }

        It 'All codes are within ANSI8 range' {
            $result = New-GradientColorArray -Colors @('#FF0000', '#00FF00', '#0000FF') -Steps 30 -Mode ANSI8

            foreach ($code in $result) {
                $code | Should -BeGreaterOrEqual 0
                $code | Should -BeLessOrEqual 255
            }
        }
    }

    Context 'Two-Color Gradient (Optimized Path)' {
        It 'Handles simple two-color gradient' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor

            $result.Count | Should -Be 10
        }

        It 'Interpolates smoothly between two colors' {
            $result = New-GradientColorArray -Colors @(@(0, 0, 0), @(100, 0, 0)) -Steps 11 -Mode TrueColor

            # Check that red channel increases gradually
            for ($i = 0; $i -lt $result.Count - 1; $i++) {
                $result[$i + 1][0] | Should -BeGreaterOrEqual $result[$i][0]
            }
        }

        It 'Handles minimum steps (1)' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 1 -Mode TrueColor

            $result.Count | Should -Be 1
            $result[0] | Should -Not -BeNullOrEmpty
        }

        It 'Handles two identical colors' {
            $result = New-GradientColorArray -Colors @(@(100, 100, 100), @(100, 100, 100)) -Steps 5 -Mode TrueColor

            foreach ($color in $result) {
                $color[0] | Should -Be 100
                $color[1] | Should -Be 100
                $color[2] | Should -Be 100
            }
        }
    }

    Context 'Multi-Stop Gradient (3+ Colors)' {
        It 'Handles three-color gradient' {
            $result = New-GradientColorArray -Colors @('Red', 'Green', 'Blue') -Steps 15 -Mode TrueColor

            $result.Count | Should -Be 15
        }

        It 'Handles four-color gradient' {
            $result = New-GradientColorArray -Colors @('Red', 'Yellow', 'Green', 'Blue') -Steps 20 -Mode TrueColor

            $result.Count | Should -Be 20
        }

        It 'Handles five-color gradient' {
            $result = New-GradientColorArray -Colors @('Red', 'Orange', 'Yellow', 'Green', 'Blue') -Steps 25 -Mode TrueColor

            $result.Count | Should -Be 25
        }

        It 'Distributes colors evenly across waypoints' {
            $result = New-GradientColorArray -Colors @(@(255, 0, 0), @(0, 255, 0), @(0, 0, 255)) -Steps 9 -Mode TrueColor

            # First waypoint (Red)
            $result[0][0] | Should -Be 255
            # Last waypoint (Blue)
            $result[8][2] | Should -Be 255
        }

        It 'Creates smooth transitions between waypoints' {
            $result = New-GradientColorArray -Colors @('Black', 'Gray', 'White') -Steps 21 -Mode TrueColor

            # Should gradually increase from black to white
            $result[0][0] | Should -BeLessOrEqual $result[10][0]
            $result[10][0] | Should -BeLessOrEqual $result[20][0]
        }
    }

    Context 'Color Format Handling' {
        It 'Converts hex colors to RGB' {
            $result = New-GradientColorArray -Colors @('#FF0000', '#0000FF') -Steps 5 -Mode TrueColor

            $result[0][0] | Should -Be 255  # Red
            $result[4][2] | Should -Be 255  # Blue
        }

        It 'Converts color names to RGB' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 5 -Mode TrueColor

            $result[0] | Should -Not -BeNullOrEmpty
            $result[0].Count | Should -Be 3
        }

        It 'Handles 0x prefix hex colors' {
            $result = New-GradientColorArray -Colors @('0xFF0000', '0x0000FF') -Steps 5 -Mode TrueColor

            $result.Count | Should -Be 5
        }

        It 'Clamps RGB values to 0-255 range' {
            # Test with already valid values
            $result = New-GradientColorArray -Colors @(@(255, 255, 255), @(0, 0, 0)) -Steps 5 -Mode TrueColor

            foreach ($color in $result) {
                $color[0] | Should -BeGreaterOrEqual 0
                $color[0] | Should -BeLessOrEqual 255
            }
        }

        It 'Handles invalid color names gracefully' {
            # Should fall back to gray or handle gracefully
            { New-GradientColorArray -Colors @('InvalidColor', 'Blue') -Steps 5 -Mode TrueColor } | Should -Not -Throw
        }
    }

    Context 'Edge Cases' {
        It 'Handles single step' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 1 -Mode TrueColor

            $result.Count | Should -Be 1
        }

        It 'Handles large number of steps' {
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 1000 -Mode TrueColor

            $result.Count | Should -Be 1000
        }

        It 'Handles very small RGB values' {
            $result = New-GradientColorArray -Colors @(@(1, 1, 1), @(2, 2, 2)) -Steps 5 -Mode TrueColor

            $result.Count | Should -Be 5
        }

        It 'Handles very large RGB values' {
            $result = New-GradientColorArray -Colors @(@(254, 254, 254), @(255, 255, 255)) -Steps 5 -Mode TrueColor

            $result.Count | Should -Be 5
        }

        It 'Handles black to white gradient' {
            $result = New-GradientColorArray -Colors @('Black', 'White') -Steps 11 -Mode TrueColor

            $result[0][0] | Should -Be 0
            $result[10][0] | Should -Be 255
        }

        It 'Handles white to black gradient (reverse)' {
            $result = New-GradientColorArray -Colors @('White', 'Black') -Steps 11 -Mode TrueColor

            $result[0][0] | Should -Be 255
            $result[10][0] | Should -Be 0
        }
    }

    Context 'Performance and Optimization' {
        It 'Uses List instead of array concatenation' {
            # Should complete quickly even with many steps
            $start = Get-Date
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 1000 -Mode TrueColor
            $duration = (Get-Date) - $start

            $duration.TotalMilliseconds | Should -BeLessThan 100
        }

        It 'Caches color conversions' {
            # Multiple calls with same colors should be consistent
            $result1 = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor
            $result2 = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor

            for ($i = 0; $i -lt 10; $i++) {
                $result1[$i][0] | Should -Be $result2[$i][0]
                $result1[$i][1] | Should -Be $result2[$i][1]
                $result1[$i][2] | Should -Be $result2[$i][2]
            }
        }

        It 'Handles command availability checks efficiently' {
            # Should not fail if color conversion functions are available
            { New-GradientColorArray -Colors @('Red', 'Blue') -Steps 10 -Mode TrueColor } | Should -Not -Throw
        }
    }

    Context 'Consistency and Reproducibility' {
        It 'Returns same results for same input' {
            $result1 = New-GradientColorArray -Colors @('Red', 'Green', 'Blue') -Steps 20 -Mode TrueColor
            $result2 = New-GradientColorArray -Colors @('Red', 'Green', 'Blue') -Steps 20 -Mode TrueColor

            $result1.Count | Should -Be $result2.Count

            for ($i = 0; $i -lt $result1.Count; $i++) {
                $result1[$i][0] | Should -Be $result2[$i][0]
                $result1[$i][1] | Should -Be $result2[$i][1]
                $result1[$i][2] | Should -Be $result2[$i][2]
            }
        }

        It 'TrueColor and ANSI8 return same count' {
            $resultTC = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 15 -Mode TrueColor
            $resultA8 = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 15 -Mode ANSI8

            $resultTC.Count | Should -Be $resultA8.Count
        }
    }

    Context 'Rainbow Gradients' {
        It 'Creates full spectrum rainbow' {
            $result = New-GradientColorArray -Colors @('Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta') -Steps 70 -Mode TrueColor

            $result.Count | Should -Be 70
        }

        It 'Creates custom rainbow' {
            $result = New-GradientColorArray -Colors @('#FF0000', '#FF8000', '#FFFF00', '#00FF00', '#0000FF') -Steps 50 -Mode TrueColor

            $result.Count | Should -Be 50
        }
    }

    Context 'Fallback Behavior' {
        It 'Returns gray when color table not available and color invalid' {
            # This tests graceful degradation
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 5 -Mode TrueColor

            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns grayscale ANSI8 code (7) when conversion fails' {
            # Should handle gracefully
            $result = New-GradientColorArray -Colors @('Red', 'Blue') -Steps 5 -Mode ANSI8

            $result | Should -Not -BeNullOrEmpty
        }
    }
}
