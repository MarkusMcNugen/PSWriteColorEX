#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeDiscovery {
    # Each case: a name, the code points of the text, its width, and its width with -AmbiguousAsWide
    $widthCases = @(
        @{ Name = 'printable ASCII'; CodePoints = @(0x48, 0x65, 0x6C, 0x6C, 0x6F); Width = 5; WideWidth = 5 }
        @{ Name = 'CJK characters'; CodePoints = @(0x4E16, 0x754C); Width = 4; WideWidth = 4 }
        @{ Name = 'ASCII and CJK'; CodePoints = @(0x48, 0x69, 0x20, 0x4E16, 0x754C); Width = 7; WideWidth = 7 }
        @{ Name = 'fullwidth letter'; CodePoints = @(0xFF21); Width = 2; WideWidth = 2 }
        @{ Name = 'check mark U+2713'; CodePoints = @(0x2713); Width = 1; WideWidth = 1 }
        @{ Name = 'check mark button U+2705'; CodePoints = @(0x2705); Width = 2; WideWidth = 2 }
        @{ Name = 'emoji outside the BMP'; CodePoints = @(0x1F600); Width = 2; WideWidth = 2 }
        @{ Name = 'two emoji'; CodePoints = @(0x1F600, 0x1F44D); Width = 4; WideWidth = 4 }
        @{ Name = 'black circle (ambiguous)'; CodePoints = @(0x25CF); Width = 1; WideWidth = 2 }
        @{ Name = 'rightwards arrow (ambiguous)'; CodePoints = @(0x2192); Width = 1; WideWidth = 2 }
        @{ Name = 'box drawing (ambiguous)'; CodePoints = @(0x2554, 0x2550, 0x2550, 0x2550, 0x2557); Width = 5; WideWidth = 10 }
        @{ Name = 'precomposed e acute'; CodePoints = @(0xE9); Width = 1; WideWidth = 1 }
        @{ Name = 'e and a combining acute accent'; CodePoints = @(0x65, 0x301); Width = 1; WideWidth = 1 }
        @{ Name = 'zero width space'; CodePoints = @(0x200B); Width = 0; WideWidth = 0 }
        @{ Name = 'tab between letters'; CodePoints = @(0x61, 0x9, 0x62); Width = 2; WideWidth = 2 }
        @{ Name = 'Hangul jamo syllable'; CodePoints = @(0x1100, 0x1161); Width = 2; WideWidth = 2 }
        @{ Name = 'warning sign alone'; CodePoints = @(0x26A0); Width = 1; WideWidth = 1 }
        @{ Name = 'warning sign with U+FE0F'; CodePoints = @(0x26A0, 0xFE0F); Width = 2; WideWidth = 2 }
        @{ Name = 'heart with U+FE0F'; CodePoints = @(0x2764, 0xFE0F); Width = 2; WideWidth = 2 }
        @{ Name = 'watch alone'; CodePoints = @(0x231A); Width = 2; WideWidth = 2 }
        @{ Name = 'watch with U+FE0E'; CodePoints = @(0x231A, 0xFE0E); Width = 1; WideWidth = 2 }
        @{ Name = 'thumbs up with skin tone'; CodePoints = @(0x1F44D, 0x1F3FD); Width = 2; WideWidth = 2 }
        @{ Name = 'family joined by U+200D'; CodePoints = @(0x1F468, 0x200D, 0x1F469, 0x200D, 0x1F467); Width = 2; WideWidth = 2 }
        @{ Name = 'technologist with skin tone'; CodePoints = @(0x1F469, 0x1F3FD, 0x200D, 0x1F4BB); Width = 2; WideWidth = 2 }
        @{ Name = 'eye in speech bubble'; CodePoints = @(0x1F441, 0xFE0F, 0x200D, 0x1F5E8, 0xFE0F); Width = 2; WideWidth = 2 }
        @{ Name = 'heart on fire'; CodePoints = @(0x2764, 0xFE0F, 0x200D, 0x1F525); Width = 2; WideWidth = 2 }
        @{ Name = 'flag'; CodePoints = @(0x1F1FA, 0x1F1F8); Width = 2; WideWidth = 2 }
        @{ Name = 'text after an emoji sequence'; CodePoints = @(0x1F44D, 0x1F3FD, 0x20, 0x6F, 0x6B); Width = 5; WideWidth = 5 }
    )
}

BeforeAll {
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force

    # Builds a string from code points, so this file holds only ASCII
    function ConvertTo-TestString {
        param([int[]]$CodePoints)
        -join ($CodePoints | ForEach-Object { [char]::ConvertFromUtf32($_) })
    }
}

Describe 'Measure-DisplayWidth' -Tag 'Unit', 'Function', 'DisplayWidth' {

    Context 'Widths' {
        It 'Measures <Name> as <Width> cells' -TestCases $widthCases {
            $text = ConvertTo-TestString $CodePoints
            Measure-DisplayWidth -Text $text | Should -Be $Width
        }

        It 'Measures <Name> as <WideWidth> cells with -AmbiguousAsWide' -TestCases $widthCases {
            $text = ConvertTo-TestString $CodePoints
            Measure-DisplayWidth -Text $text -AmbiguousAsWide | Should -Be $WideWidth
        }
    }

    Context 'Input' {
        It 'Measures an empty string as 0' {
            Measure-DisplayWidth -Text '' | Should -Be 0
        }

        It 'Measures each string piped in' {
            $results = @('ab', (ConvertTo-TestString 0x4E16, 0x754C)) | Measure-DisplayWidth
            $results | Should -Be @(2, 4)
        }

        It 'Takes the text by position' {
            Measure-DisplayWidth 'abc' | Should -Be 3
        }

        It 'Answers an integer' {
            Measure-DisplayWidth 'abc' | Should -BeOfType [int]
        }

        It 'Measures a lone surrogate as 1' {
            Measure-DisplayWidth ([string][char]0xD83D) | Should -Be 1
        }
    }

    Context 'Aliases' {
        It 'MDW runs Measure-DisplayWidth' {
            (Get-Command MDW).ResolvedCommandName | Should -Be 'Measure-DisplayWidth'
        }

        It 'Get-DisplayWidth runs Measure-DisplayWidth' {
            (Get-Command Get-DisplayWidth).ResolvedCommandName | Should -Be 'Measure-DisplayWidth'
        }
    }
}
