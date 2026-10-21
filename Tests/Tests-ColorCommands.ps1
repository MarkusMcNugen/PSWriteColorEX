#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

# Format-ColorEX, Show-ColorTable, Register-ColorName, Unregister-ColorName, Export-ColorProfile,
# Import-ColorProfile and its themes, Remove-ColorProfile, tab completion, and PSColorStyle's
# background gradient, underline and layout properties.

BeforeAll {
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
    $script:esc = [char]27

    function Set-TestColorSupport {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'A test helper; -WhatIf has no meaning in a test.')]
        param($Support, [bool]$BoldFonts = $true)
        & (Get-Module PSWriteColorEX) { param($s, $b) $script:CachedANSISupport = $s; $script:SupportsBoldFonts = $b } $Support $BoldFonts
    }

    function Get-TestColorSupport {
        & (Get-Module PSWriteColorEX) { @($script:CachedANSISupport, $script:SupportsBoldFonts) }
    }

    function Save-ColorEnvironment {
        $saved = @{}
        foreach ($name in 'NO_COLOR', 'FORCE_COLOR', 'TERM', 'CLICOLOR', 'CLICOLOR_FORCE') {
            $saved[$name] = [System.Environment]::GetEnvironmentVariable($name)
        }
        foreach ($name in 'NO_COLOR', 'FORCE_COLOR', 'CLICOLOR', 'CLICOLOR_FORCE') {
            [System.Environment]::SetEnvironmentVariable($name, $null)
        }
        if ($saved['TERM'] -eq 'dumb') {
            [System.Environment]::SetEnvironmentVariable('TERM', $null)
        }
        return $saved
    }

    function Restore-ColorEnvironment {
        param([hashtable]$Saved)
        foreach ($name in $Saved.Keys) {
            [System.Environment]::SetEnvironmentVariable($name, $Saved[$name])
        }
    }

    # The color names and profiles a test added, removed so the next test starts from the
    # module's own
    function Reset-ColorState {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'A test helper; -WhatIf has no meaning in a test.')]
        param()
        & (Get-Module PSWriteColorEX) {
            $script:CustomColors.Clear()
            $script:CachedColorTable = $null
            [PSColorStyle]::Profiles.Clear()
            [PSColorStyle]::InitializeDefaultProfiles()
        }
    }
}

Describe 'Formatting, color name and profile commands' -Tag 'Unit', 'Commands' {

    BeforeAll {
        $script:hostCalls = [System.Collections.Generic.List[object]]::new()
        Mock -ModuleName PSWriteColorEX Write-Host {
            $script:hostCalls.Add([pscustomobject]@{
                Object = [string]$Object
                NoNewline = [bool]$NoNewline
                ForegroundColor = if ($PesterBoundParameters.ContainsKey('ForegroundColor')) { [string]$ForegroundColor } else { '' }
                BackgroundColor = if ($PesterBoundParameters.ContainsKey('BackgroundColor')) { [string]$BackgroundColor } else { '' }
            })
        }
        Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $true }
        Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $true }
        $script:savedSupport = Get-TestColorSupport
    }

    AfterAll {
        Set-TestColorSupport -Support $script:savedSupport[0] -BoldFonts $script:savedSupport[1]
        Reset-ColorState
    }

    BeforeEach {
        $script:hostCalls.Clear()
        $script:savedEnvironment = Save-ColorEnvironment
        Set-TestColorSupport -Support 'TrueColor'
    }

    AfterEach {
        Restore-ColorEnvironment -Saved $script:savedEnvironment
        Reset-ColorState
    }

    Context 'Format-ColorEX' {
        It 'Returns the line as a string, writing nothing to the host' {
            $line = Format-ColorEX 'OK' -Color Green -Bold

            $line | Should -BeOfType [string]
            $line | Should -Be "$esc[1m$esc[92mOK$esc[0m"
            $script:hostCalls | Should -HaveCount 0
        }

        It 'Fits inside a larger string' {
            "Status: $(Format-ColorEX 'OK' -Color Green)" | Should -Be "Status: $esc[92mOK$esc[0m"
        }

        It 'Returns one string for each line -Wrap makes' {
            $lines = @(Format-ColorEX 'the quick brown fox' -AutoPad 10 -Wrap)

            $lines | Should -Be @('the quick ', 'brown fox ')
        }

        It 'Returns one string for each string piped in' {
            $lines = @('a', 'b' | Format-ColorEX -Color Red)

            $lines | Should -Be @("$esc[91ma$esc[0m", "$esc[91mb$esc[0m")
        }

        It 'Returns the text alone with colors off' {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', '1')

            Format-ColorEX 'x' -Color Red -Bold | Should -Be 'x'
        }

        It 'Returns the text alone where only console colors would be written' {
            Set-TestColorSupport -Support 'None'

            Format-ColorEX 'a', 'b' -Color Red, Green | Should -Be 'ab'
        }

        It 'Returns empty strings for a profile''s blank lines' {
            $style = New-ColorStyle -Name 'Spaced' -ForegroundColor Red -LinesBefore 1 -LinesAfter 1

            $lines = @(Format-ColorEX 'x' -StyleProfile $style)

            $lines | Should -Be @('', "$esc[91mx$esc[0m", '')
        }

        It 'Passes Write-ColorEX''s warnings on' {
            Format-ColorEX 'x' -Color Purpel -WarningVariable warnings -WarningAction SilentlyContinue | Out-Null

            @($warnings | ForEach-Object { "$_" }) | Should -Be @("Unknown color 'Purpel'.")
        }

        It 'Has the aliases Format-ColourEX and FCEX' {
            (Get-Command Format-ColourEX).ResolvedCommandName | Should -Be 'Format-ColorEX'
            (Get-Command FCEX).ResolvedCommandName | Should -Be 'Format-ColorEX'
        }
    }

    Context 'Register-ColorName and Unregister-ColorName' {
        It 'Adds a name every command takes, in every color mode' {
            Register-ColorName -Name Brand -Color '#FF6B35'

            Write-ColorEX -Text 'x' -Color Brand -TrueColor
            Write-ColorEX -Text 'x' -Color Brand -ANSI8
            Write-ColorEX -Text '[Brand]x[/]' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;107;53mx$esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[38;5;$(Convert-RGBToANSI8 -RGB @(255, 107, 53))mx$esc[0m"
            $script:hostCalls[2].Object | Should -Match 'x'
            (Get-ColorTableWithRGB)['Brand'][4] | Should -Be @(255, 107, 53)
        }

        It 'Reads <Form> as the color' -TestCases @(
            @{ Form = '#F63' }
            @{ Form = 'rgb(255, 102, 51)' }
            @{ Form = 'hsl(15, 100%, 60%)' }
        ) {
            Register-ColorName -Name Mine -Color $Form

            (Get-ColorTableWithRGB)['Mine'][4] | Should -Be @(255, 102, 51)
        }

        It 'Takes an RGB array, and copies a name already in the table' {
            Register-ColorName -Name One -Color @(1, 2, 3)
            Register-ColorName -Name Two -Color Orange

            (Get-ColorTableWithRGB)['One'][4] | Should -Be @(1, 2, 3)
            (Get-ColorTableWithRGB)['Two'][4] | Should -Be (Get-ColorTableWithRGB)['Orange'][4]
        }

        It 'Refuses a name in use without -Force' {
            { Register-ColorName -Name Red -Color '#000000' -ErrorAction Stop } | Should -Throw "The color name 'Red' is in use. Use -Force to replace it."
        }

        It 'Replaces a built-in name with -Force, and Unregister-ColorName brings it back' {
            Register-ColorName -Name Red -Color '#123456' -Force
            (Get-ColorTableWithRGB)['Red'][4] | Should -Be @(0x12, 0x34, 0x56)

            Unregister-ColorName -Name Red
            (Get-ColorTableWithRGB)['Red'][4] | Should -Be @(255, 0, 0)
        }

        It 'Refuses <Name> as a name' -TestCases @(
            @{ Name = 'bold' }
            @{ Name = 'on' }
            @{ Name = 'None' }
            @{ Name = '9lives' }
            @{ Name = 'two words' }
            @{ Name = '#abc' }
        ) {
            { Register-ColorName -Name $Name -Color '#000000' -ErrorAction Stop } | Should -Throw "'$Name' cannot be a color name.*"
        }

        It 'Refuses a value that is not a color' {
            { Register-ColorName -Name Mine -Color 'nope' -ErrorAction Stop } | Should -Throw "'nope' is not a color.*"
            { Register-ColorName -Name Mine -Color @(1, 2, 300) -ErrorAction Stop } | Should -Throw "'@(1, 2, 300)' is not a color.*"
        }

        It 'Says when a name to remove was not registered' {
            { Unregister-ColorName -Name Nothing -ErrorAction Stop } | Should -Throw "No color name 'Nothing' was registered."
        }
    }

    Context 'Show-ColorTable' {
        BeforeAll {
            # The lines the host calls wrote, the calls of a line written with -NoNewline joined
            function Get-WrittenLines {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'It returns several lines, which the plural names.')]
                param()
                $lines = [System.Collections.Generic.List[string]]::new()
                $current = ''
                foreach ($call in $script:hostCalls) {
                    $current += $call.Object
                    if (-not $call.NoNewline) {
                        $lines.Add($current)
                        $current = ''
                    }
                }
                if ($current) {
                    $lines.Add($current)
                }
                , $lines.ToArray()
            }

            function Remove-Escapes {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'It returns the text without its escape codes and changes nothing.')]
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'It removes every escape code, which the plural names.')]
                param([string]$Text)
                $Text -replace "$([char]27)\[[0-9;:]*m", ''
            }
        }

        It 'Writes a heading and a line for each name, by family' {
            Show-ColorTable -Name *Lime

            $lines = @($script:hostCalls | Where-Object { -not $_.NoNewline } | Select-Object -ExpandProperty Object)
            $lines[0] | Should -Match 'Name +TrueColor +256 +16 +Console +Hex +ANSI8 +Console color'
            $names = @($script:hostCalls | Where-Object { $_.Object -match '^\w+ +$' } | ForEach-Object { $_.Object.Trim() })
            $names | Should -Be @('DarkLime', 'Lime', 'LightLime')
        }

        It 'Writes each sample in its own color mode' {
            Show-ColorTable -Name Red

            $objects = @($script:hostCalls.Object)
            $objects | Should -Contain "$esc[38;2;255;0;0m$([string][char]0x2588 * 6)$esc[0m"
            $objects | Should -Contain "$esc[38;5;1m$([string][char]0x2588 * 6)$esc[0m"
            $objects | Should -Contain "$esc[31m$([string][char]0x2588 * 6)$esc[0m"
        }

        It 'Writes the samples as backgrounds with -Background' {
            Show-ColorTable -Name Red -Background

            @($script:hostCalls.Object) | Should -Contain "$esc[48;2;255;0;0m      $esc[0m"
        }

        It 'Writes nothing when no name matches' {
            Show-ColorTable -Name NoSuchColor*

            $script:hostCalls | Should -HaveCount 0
        }

        It 'Writes each text style with a sample, its parameter and its markup tags' {
            Show-ColorTable -Styles

            $lines = Get-WrittenLines
            $lines | Should -HaveCount 14
            $lines[0] | Should -Be "$esc[1mStyle            Sample       Parameter               Markup$esc[0m"
            $lines[1] | Should -Be "Bold             $esc[1mSample text$esc[0m  -Bold                   [bold]"
            $lines[2] | Should -Be "Faint            $esc[2mSample text$esc[0m  -Faint                  [faint] [dim]"
            $lines[6] | Should -Be "Curly            $esc[4:3mSample text$esc[0m  -UnderlineStyle Curly   [curly]"
            $lines[10] | Should -Be "Reverse          $esc[7mSample text$esc[0m  -Reverse                [reverse] [invert]"
            $lines[11] | Should -Be "CrossedOut       $esc[9mSample text$esc[0m  -CrossedOut             [crossedout] [strike]"
            $lines[12] | Should -Be "$(' ' * 54)[strikethrough]"
            $lines[13] | Should -Be "Overline         $esc[53mSample text$esc[0m  -Overline               [overline]"
        }

        It 'Writes the 256-color chart by parts' {
            Show-ColorTable -Palette

            $expected = [System.Collections.Generic.List[string]]::new()
            $expected.Add((@(0..7 | ForEach-Object { '{0,3} ' -f $_ }) -join ''))
            $expected.Add((@(8..15 | ForEach-Object { '{0,3} ' -f $_ }) -join ''))
            $expected.Add('')
            foreach ($band in 0, 1) {
                for ($r = 0; $r -lt 6; $r++) {
                    $blocks = foreach ($block in 0..2) {
                        $start = 16 + ($band * 3 + $block) * 36 + $r * 6
                        (@($start..($start + 5) | ForEach-Object { '{0,3} ' -f $_ }) -join '')
                    }
                    $expected.Add($blocks -join '  ')
                }
                $expected.Add('')
            }
            $expected.Add((@(232..243 | ForEach-Object { '{0,3} ' -f $_ }) -join ''))
            $expected.Add((@(244..255 | ForEach-Object { '{0,3} ' -f $_ }) -join ''))

            $lines = Get-WrittenLines
            @($lines | ForEach-Object { Remove-Escapes $_ }) | Should -Be $expected.ToArray()
        }

        It 'Writes each number of the chart in black or white on its own color' {
            Show-ColorTable -Palette

            $text = (Get-WrittenLines) -join "`n"
            foreach ($cell in @(
                @(0, 231), @(6, 231), @(7, 16), @(8, 231), @(9, 16), @(15, 16)
                @(16, 231), @(21, 231), @(46, 16), @(88, 231), @(196, 16), @(226, 16), @(231, 16)
                @(232, 231), @(242, 231), @(243, 16), @(255, 16)
            )) {
                $text.Contains("$esc[38;5;$($cell[1])m$esc[48;5;$($cell[0])m$('{0,3} ' -f $cell[0])$esc[0m") | Should -BeTrue -Because "$($cell[0]) takes text $($cell[1])"
            }
        }

        It 'Takes black text over white from a relative luminance of about 0.179' {
            $reads = & (Get-Module PSWriteColorEX) {
                @(foreach ($gray in 0, 117, 118, 255) { [ColorMath]::BlackTextReads($gray, $gray, $gray) })
            }

            $reads | Should -Be @($false, $false, $true, $true)
        }

        It 'Writes each profile with a sample in its colors and styles, then its settings' {
            Register-ColorName -Name Brand -Color '#FF6B35'
            New-ColorStyle -Name 'Build' -ForegroundColor Brand -BackgroundColor @(0, 0, 64) -Bold -UnderlineStyle Curly -AutoPad 20 -PadChar '.' -AddToProfiles | Out-Null
            [PSColorStyle]::new('Plain', $null, $null).AddToProfiles()

            Show-ColorTable -Profiles

            $lines = Get-WrittenLines
            @($lines | ForEach-Object { (Remove-Escapes $_).Split(' ')[0] }) | Should -Be @('Profile', 'Build', 'Critical', 'Debug', 'Default', 'Error', 'Info', 'Plain', 'Success', 'Warning')
            $lines[0] | Should -Be "$esc[1mProfile   Sample       Settings$esc[0m"
            Remove-Escapes $lines[1] | Should -Be "Build     Sample text  Brand on @(0, 0, 64), Bold, UnderlineStyle Curly, AutoPad 20, PadChar '.'"
            $lines[2] | Should -Be "Critical  $esc[1m$esc[5m$esc[97m$esc[41mSample text$esc[0m  White on DarkRed, Bold, Blink"
            $lines[4] | Should -Be "Default   $esc[37mSample text$esc[0m  Gray (the default style)"
            Remove-Escapes $lines[7] | Should -Be 'Plain     Sample text  no settings'
        }

        It 'Leaves a profile''s layout out of its sample' {
            New-ColorStyle -Name 'Wide' -ForegroundColor Red -AutoPad 30 -LinesBefore 2 -HorizontalCenter -AddToProfiles | Out-Null

            Show-ColorTable -Profiles -Name Wide

            $lines = Get-WrittenLines
            $lines | Should -HaveCount 2
            $lines[1] | Should -Be "Wide     $esc[91mSample text$esc[0m  Red, LinesBefore 2, AutoPad 30, HorizontalCenter"
        }

        It 'Writes the profiles -Name picks, and nothing when none matches' {
            Show-ColorTable -Profiles -Name Er*, W*

            $lines = Get-WrittenLines
            @($lines | ForEach-Object { (Remove-Escapes $_).Split(' ')[0] }) | Should -Be @('Profile', 'Error', 'Warning')

            $script:hostCalls.Clear()
            Show-ColorTable -Profiles -Name Nothing*
            $script:hostCalls | Should -HaveCount 0
        }

        It 'Writes the error of a color Write-ColorEX does not take in place of the sample, and goes on' {
            New-ColorStyle -Name 'Odd' -ForegroundColor 5.5 -AddToProfiles | Out-Null

            # Continue, as under a caller's Stop the error stops the view, as one from any cmdlet does
            $records = @(Show-ColorTable -Profiles -Name Odd, Warning -ErrorAction Continue 2>&1)

            $records | Should -HaveCount 1
            $records[0] | Should -BeOfType [System.Management.Automation.ErrorRecord]
            $records[0].Exception.Message | Should -BeLike "Cannot validate argument on parameter 'Color'. The argument `"5.5`" is not a color*"
            $lines = Get-WrittenLines
            @($lines | ForEach-Object { Remove-Escapes $_ }) | Should -Be @('Profile  Sample       Settings', 'Odd        5.5', 'Warning  Sample text  Yellow')
        }
    }

    Context 'Export-ColorProfile, Import-ColorProfile and Remove-ColorProfile' {
        It 'Writes the profiles and color names as JSON' {
            $path = Join-Path $TestDrive 'profiles.json'
            Register-ColorName -Name Brand -Color '#FF6B35'
            New-ColorStyle -Name 'Build' -ForegroundColor Brand -BackgroundColor @(0, 0, 64) -Bold -UnderlineStyle Curly -AutoPad 20 -PadChar '.' -AddToProfiles | Out-Null

            Export-ColorProfile -Path $path -Name 'Build'

            $expected = "{`n  `"Colors`": {`n    `"Brand`": `"#FF6B35`"`n  },`n  `"Profiles`": [`n    {`n      `"Name`": `"Build`",`n      `"ForegroundColor`": `"Brand`",`n      `"BackgroundColor`": [0, 0, 64],`n      `"Bold`": true,`n      `"UnderlineStyle`": `"Curly`",`n      `"AutoPad`": 20,`n      `"PadChar`": `".`"`n    }`n  ]`n}`n"
            [System.IO.File]::ReadAllText($path) | Should -BeExactly $expected
        }

        It 'Reads back what it wrote, color names first' {
            $path = Join-Path $TestDrive 'roundtrip.json'
            Register-ColorName -Name Brand -Color '#FF6B35'
            New-ColorStyle -Name 'Build' -ForegroundColor Brand -Gradient Red, '#00FF00' -Italic -Wrap -UnderlineColor @(1, 2, 3) -AddToProfiles | Out-Null
            Export-ColorProfile -Path $path
            Reset-ColorState

            $imported = @(Import-ColorProfile -Path $path -PassThru)

            ($imported | Where-Object Name -eq 'Build') | Should -Not -BeNullOrEmpty
            $style = [PSColorStyle]::Profiles['Build']
            $style.ForegroundColor | Should -Be 'Brand'
            $style.Gradient | Should -Be @('Red', '#00FF00')
            $style.Italic | Should -BeTrue
            $style.Wrap | Should -BeTrue
            $style.UnderlineColor | Should -Be @(1, 2, 3)
            $style.UnderlineColor[0] | Should -BeOfType [int]
            (Get-ColorTableWithRGB)['Brand'][4] | Should -Be @(255, 107, 53)
        }

        It 'Makes the style the file names the default' {
            $path = Join-Path $TestDrive 'default.json'
            $null = New-ColorStyle -Name 'Mine' -ForegroundColor Cyan -AddToProfiles -SetAsDefault
            Export-ColorProfile -Path $path -Name 'Mine'
            Reset-ColorState

            Import-ColorProfile -Path $path

            [PSColorStyle]::Default.Name | Should -Be 'Mine'
        }

        It 'Stops with an error for a file that is not JSON' {
            $path = Join-Path $TestDrive 'bad.json'
            Set-Content -LiteralPath $path -Value 'not json'

            { Import-ColorProfile -Path $path } | Should -Throw "Cannot read the profiles in '$path'.*"
        }

        It 'Removes a profile, and with -WhatIf leaves it' {
            New-ColorStyle -Name 'Gone' -AddToProfiles | Out-Null

            Remove-ColorProfile -Name 'Gone' -WhatIf
            [PSColorStyle]::Profiles.ContainsKey('Gone') | Should -BeTrue

            Remove-ColorProfile -Name 'Gone'
            [PSColorStyle]::Profiles.ContainsKey('Gone') | Should -BeFalse
        }

        It 'Says when a profile to remove does not exist' {
            { Remove-ColorProfile -Name 'Nothing' -ErrorAction Stop } | Should -Throw "No profile named 'Nothing'."
        }
    }

    Context 'Import-ColorProfile -Theme' {
        BeforeAll {
            $script:themeFolder = Join-Path $ModuleRoot 'Themes'

            # The properties ConvertFrom-SgrStyle reads from escape codes, as one line
            function Get-SgrSummary {
                param([string]$Sequence)
                $read = & (Get-Module PSWriteColorEX) { param($s) ConvertFrom-SgrStyle -Sequence $s } $Sequence
                $p = $read.Properties
                $parts = @()
                if ($null -ne $p.ForegroundColor) { $parts += "fg=$($p.ForegroundColor)" }
                if ($null -ne $p.BackgroundColor) { $parts += "bg=$($p.BackgroundColor)" }
                if ($null -ne $p.UnderlineColor) { $parts += "ul=$($p.UnderlineColor)" }
                foreach ($style in 'Bold', 'Faint', 'Italic', 'Underline', 'DoubleUnderline', 'Blink', 'Reverse', 'CrossedOut', 'Overline') {
                    if ($p[$style]) { $parts += $style }
                }
                if ($p.UnderlineStyle) { $parts += $p.UnderlineStyle }
                if ($read.Ignored.Count -gt 0) { $parts += "ignored=$($read.Ignored -join ',')" }
                $parts -join ' '
            }
        }

        It 'Reads <Theme> as Export-ColorProfile wrote it' -TestCases @(
            @{ Theme = 'CatppuccinFrappe' }
            @{ Theme = 'CatppuccinLatte' }
            @{ Theme = 'CatppuccinMacchiato' }
            @{ Theme = 'CatppuccinMocha' }
            @{ Theme = 'Dracula' }
            @{ Theme = 'GruvboxDark' }
            @{ Theme = 'GruvboxLight' }
            @{ Theme = 'Nord' }
            @{ Theme = 'OneDark' }
            @{ Theme = 'SolarizedDark' }
            @{ Theme = 'SolarizedLight' }
            @{ Theme = 'TokyoNight' }
        ) {
            $path = Join-Path $TestDrive "$Theme.json"

            $imported = @(Import-ColorProfile -Theme $Theme -PassThru)
            Export-ColorProfile -Path $path

            @($imported.Name) | Should -Be @('Critical', 'Debug', 'Default', 'Error', 'Info', 'Success', 'Warning')
            [PSColorStyle]::Default.Name | Should -Be 'Default'
            [System.IO.File]::ReadAllText($path) | Should -BeExactly ([System.IO.File]::ReadAllText((Join-Path $script:themeFolder "$Theme.json")))
        }

        It 'Finds a theme whatever the case of its name' {
            Import-ColorProfile -Theme nord

            (Get-ColorTableWithRGB)['Nord8'][4] | Should -Be @(0x88, 0xC0, 0xD0)
        }

        It 'Refuses a theme the module does not have' {
            { Import-ColorProfile -Theme Nope } | Should -Throw "*parameter 'Theme'*"
        }

        It 'Adds the CSS names the color table lacks, and leaves names in use alone' {
            $names = @((Get-Content (Join-Path $script:themeFolder 'CSS.json') -Raw | ConvertFrom-Json).Colors.PSObject.Properties.Name)
            Register-ColorName -Name Tomato -Color '#010203'

            $imported = @(Import-ColorProfile -Theme CSS -PassThru)

            $table = Get-ColorTableWithRGB
            $names | Should -HaveCount 100
            @($names | Where-Object { -not $table.ContainsKey($_) }) | Should -BeNullOrEmpty
            $imported | Should -HaveCount 0
            $table['Tomato'][4] | Should -Be @(1, 2, 3)
            $table['RebeccaPurple'][4] | Should -Be @(102, 51, 153)
            $table['SlateGrey'][4] | Should -Be @(112, 128, 144)
            $table['Green'][4] | Should -Be @(0, 255, 0)
            $table['Grey'][4] | Should -Be $table['Gray'][4]
            $table['DarkGrey'][4] | Should -Be $table['DarkGray'][4]
            $table['LightGrey'][4] | Should -Be $table['LightGray'][4]
        }

        It 'Gives each CSS name the color .NET gives it, and the grey spellings of our names our grays' {
            Add-Type -AssemblyName System.Drawing
            $colors = (Get-Content (Join-Path $script:themeFolder 'CSS.json') -Raw | ConvertFrom-Json).Colors
            $unknown = [System.Collections.Generic.List[string]]::new()
            $differ = [System.Collections.Generic.List[string]]::new()
            foreach ($property in $colors.PSObject.Properties) {
                if ($property.Name -in 'Grey', 'DarkGrey', 'LightGrey') {
                    continue
                }
                $net = [System.Drawing.Color]::FromName(($property.Name -replace 'Grey', 'Gray'))
                if (-not $net.IsKnownColor) {
                    $unknown.Add($property.Name)
                    continue
                }
                $hex = '#{0:X2}{1:X2}{2:X2}' -f $net.R, $net.G, $net.B
                if ($hex -ne $property.Value) {
                    $differ.Add("$($property.Name) $($property.Value) $hex")
                }
            }

            # .NET Framework, under Windows PowerShell 5.1, has no RebeccaPurple and gives DarkSeaGreen
            # as #8FBC8B, where CSS and PowerShell 7's .NET give #8FBC8F
            $expectedDiffer = ''
            $expectedUnknown = ''
            if ($PSVersionTable.PSEdition -eq 'Desktop') {
                $expectedDiffer = 'DarkSeaGreen #8FBC8F #8FBC8B'
                $expectedUnknown = 'RebeccaPurple'
            }
            $differ -join ', ' | Should -Be $expectedDiffer
            $unknown -join ', ' | Should -Be $expectedUnknown
        }

        It 'Restyles the profiles from $PSStyle, writing the codes PowerShell writes' {
            Mock -ModuleName PSWriteColorEX Get-PowerShellColorSetting {
                $e = [char]27
                @{
                    PSStyle = [pscustomobject]@{ Formatting = [pscustomobject]@{
                            Error = "$e[31;1m"; Warning = "$e[33;1m"; Verbose = "$e[33;1m"; Debug = "$e[33;1m"
                            ErrorAccent = "$e[36;1m"; FormatAccent = "$e[32;1m"
                        } }
                    PrivateData = $null
                }
            }

            $imported = @(Import-ColorProfile -Theme PowerShell -PassThru)
            Write-ColorError 'x'
            Write-ColorWarning 'x'

            @($imported.Name) | Should -Be @('Error', 'Warning', 'Info', 'Debug', 'Critical', 'Default')
            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[31mx$esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[1m$esc[33mx$esc[0m"
            [PSColorStyle]::Default.ForegroundColor | Should -Be 'DarkGreen'
            [PSColorStyle]::Default.Bold | Should -BeTrue
            $critical = [PSColorStyle]::Profiles['Critical']
            $critical.ForegroundColor | Should -Be 'DarkCyan'
            $critical.BackgroundColor | Should -BeNullOrEmpty
            $critical.Blink | Should -BeFalse
            [PSColorStyle]::Profiles['Debug'].Italic | Should -BeFalse
            [PSColorStyle]::Profiles['Success'].ForegroundColor | Should -Be 'Green'
        }

        It 'Restyles Error, Warning, Info and Debug from the host''s colors where there is no $PSStyle' {
            Mock -ModuleName PSWriteColorEX Get-PowerShellColorSetting {
                @{
                    PSStyle = $null
                    PrivateData = [pscustomobject]@{
                        ErrorForegroundColor = [ConsoleColor]::Red; ErrorBackgroundColor = [ConsoleColor]::Black
                        WarningForegroundColor = [ConsoleColor]::Yellow; WarningBackgroundColor = [ConsoleColor]::Black
                        DebugForegroundColor = [ConsoleColor]::Yellow; DebugBackgroundColor = [ConsoleColor]::Black
                        VerboseForegroundColor = [ConsoleColor]::Cyan; VerboseBackgroundColor = [ConsoleColor]::Black
                    }
                }
            }

            $imported = @(Import-ColorProfile -Theme PowerShell -PassThru)
            Write-ColorError 'x'

            @($imported.Name) | Should -Be @('Error', 'Warning', 'Info', 'Debug')
            $script:hostCalls[0].Object | Should -Be "$esc[91m$esc[40mx$esc[0m"
            [PSColorStyle]::Profiles['Error'].Bold | Should -BeFalse
            [PSColorStyle]::Profiles['Info'].ForegroundColor | Should -Be 'Cyan'
            [PSColorStyle]::Profiles['Critical'].BackgroundColor | Should -Be 'DarkRed'
            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Gray'
        }

        It 'Keeps a profile the host has no setting for, with a warning' {
            Mock -ModuleName PSWriteColorEX Get-PowerShellColorSetting {
                @{ PSStyle = $null; PrivateData = [pscustomobject]@{ ErrorForegroundColor = [ConsoleColor]::Magenta } }
            }

            Import-ColorProfile -Theme PowerShell -WarningVariable warnings -WarningAction SilentlyContinue

            [PSColorStyle]::Profiles['Error'].ForegroundColor | Should -Be 'Magenta'
            [PSColorStyle]::Profiles['Error'].BackgroundColor | Should -BeNullOrEmpty
            [PSColorStyle]::Profiles['Warning'].ForegroundColor | Should -Be 'Yellow'
            @($warnings | ForEach-Object { "$_" }) | Should -Be @(
                'The host has no Warning colors, so the Warning profile keeps its colors.'
                'The host has no Verbose colors, so the Info profile keeps its colors.'
                'The host has no Debug colors, so the Debug profile keeps its colors.'
            )
        }

        It 'Warns about codes in a setting that no profile holds' {
            Mock -ModuleName PSWriteColorEX Get-PowerShellColorSetting {
                $e = [char]27
                @{
                    PSStyle = [pscustomobject]@{ Formatting = [pscustomobject]@{
                            Error = "$e[31;8m"; Warning = ''; Verbose = ''; Debug = ''; ErrorAccent = ''; FormatAccent = ''
                        } }
                    PrivateData = $null
                }
            }

            Import-ColorProfile -Theme PowerShell -WarningVariable warnings -WarningAction SilentlyContinue

            @($warnings | ForEach-Object { "$_" }) | Should -Be @("PowerShell's Error setting has codes no profile holds, left out of the Error profile: 8")
            [PSColorStyle]::Profiles['Error'].ForegroundColor | Should -Be 'DarkRed'
            [PSColorStyle]::Profiles['Warning'].ForegroundColor | Should -BeNullOrEmpty
        }

        It 'Reads <Label> as "<Expected>"' -TestCases @(
            @{ Label = 'ESC[31;1m'; Sequence = "$([char]27)[31;1m"; Expected = 'fg=DarkRed Bold' }
            @{ Label = 'ESC[91m'; Sequence = "$([char]27)[91m"; Expected = 'fg=Red' }
            @{ Label = 'ESC[38;5;208m'; Sequence = "$([char]27)[38;5;208m"; Expected = 'fg=#FF8700' }
            @{ Label = 'ESC[38;5;3m'; Sequence = "$([char]27)[38;5;3m"; Expected = 'fg=DarkYellow' }
            @{ Label = 'ESC[38:5:11m'; Sequence = "$([char]27)[38:5:11m"; Expected = 'fg=Yellow' }
            @{ Label = 'ESC[38;2;10;20;30m'; Sequence = "$([char]27)[38;2;10;20;30m"; Expected = 'fg=#0A141E' }
            @{ Label = 'ESC[38:2::10:20:30m'; Sequence = "$([char]27)[38:2::10:20:30m"; Expected = 'fg=#0A141E' }
            @{ Label = 'ESC[44m'; Sequence = "$([char]27)[44m"; Expected = 'bg=DarkBlue' }
            @{ Label = 'ESC[104m'; Sequence = "$([char]27)[104m"; Expected = 'bg=Blue' }
            @{ Label = 'ESC[48;5;240m'; Sequence = "$([char]27)[48;5;240m"; Expected = 'bg=#585858' }
            @{ Label = 'ESC[2;3;5;7;9;53m'; Sequence = "$([char]27)[2;3;5;7;9;53m"; Expected = 'Faint Italic Blink Reverse CrossedOut Overline' }
            @{ Label = 'ESC[4:3m'; Sequence = "$([char]27)[4:3m"; Expected = 'Curly' }
            @{ Label = 'ESC[21m'; Sequence = "$([char]27)[21m"; Expected = 'DoubleUnderline' }
            @{ Label = 'ESC[4;58;5;1m'; Sequence = "$([char]27)[4;58;5;1m"; Expected = 'ul=DarkRed Underline' }
            @{ Label = 'ESC[58;2;1;2;3m'; Sequence = "$([char]27)[58;2;1;2;3m"; Expected = '' }
            @{ Label = 'ESC[1m ESC[22m'; Sequence = "$([char]27)[1m$([char]27)[22m"; Expected = '' }
            @{ Label = 'ESC[31m ESC[0m ESC[32m'; Sequence = "$([char]27)[31m$([char]27)[0m$([char]27)[32m"; Expected = 'fg=DarkGreen' }
            @{ Label = 'ESC[31;39m'; Sequence = "$([char]27)[31;39m"; Expected = '' }
            @{ Label = 'ESC[8m'; Sequence = "$([char]27)[8m"; Expected = 'ignored=8' }
            @{ Label = 'ESC[38;5;300m'; Sequence = "$([char]27)[38;5;300m"; Expected = 'ignored=38;5;300' }
            @{ Label = 'ESC[31m and text'; Sequence = "$([char]27)[31m>> "; Expected = "fg=DarkRed ignored='>> '" }
            @{ Label = 'an empty setting'; Sequence = ''; Expected = '' }
        ) {
            Get-SgrSummary -Sequence $Sequence | Should -BeExactly $Expected
        }

        It 'Reads a host color with R, G and B as hex, and a transparent one as none' {
            $module = Get-Module PSWriteColorEX

            & $module { ConvertFrom-HostColor -Value ([pscustomobject]@{ A = 255; R = 1; G = 2; B = 254 }) } | Should -Be '#0102FE'
            & $module { ConvertFrom-HostColor -Value ([pscustomobject]@{ A = 0; R = 255; G = 255; B = 255 }) } | Should -BeNullOrEmpty
            & $module { ConvertFrom-HostColor -Value ([ConsoleColor]::DarkCyan) } | Should -Be 'DarkCyan'
        }
    }

    Context 'The about_PSWriteColorEX help topic' {
        It 'Is found by Get-Help and lists every theme and named gradient' {
            $topic = Get-Help about_PSWriteColorEX | Out-String
            $themes = @((Get-Command Import-ColorProfile).Parameters['Theme'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } | ForEach-Object { $_.ValidValues })
            $gradients = @(& (Get-Module PSWriteColorEX) { $script:GradientNames.Keys })

            $topic | Should -Match 'TOPIC\s+about_PSWriteColorEX'
            $themes | Should -HaveCount 14
            $gradients | Should -HaveCount 21
            @($themes + $gradients | Where-Object { $topic -notmatch "\b$_\b" }) | Should -HaveCount 0
        }

        It 'Keeps its text within 80 columns, all but the example commands' {
            $lines = [System.IO.File]::ReadAllLines((Join-Path $ModuleRoot 'en-US/about_PSWriteColorEX.help.txt'))

            @($lines | Where-Object { $_.Length -gt 80 -and $_ -notmatch '^\s+PS> ' }) | Should -HaveCount 0
        }
    }

    Context 'Tab completion' {
        It 'Completes color names for -Color, registered names among them' {
            Register-ColorName -Name Brandy -Color '#AA5500'

            $completions = (TabExpansion2 -inputScript 'Write-ColorEX -Color Bra' -cursorColumn 24).CompletionMatches

            @($completions.CompletionText) | Should -Be @('Brandy')
        }

        It 'Completes the next color of a list, in family order' {
            $completions = (TabExpansion2 -inputScript 'Write-ColorEX -Color Red, DarkG' -cursorColumn 31).CompletionMatches

            @($completions.CompletionText) | Should -Be @('DarkGold', 'DarkGray', 'DarkGreen')
        }

        It 'Completes profile names for Remove-ColorProfile' {
            $completions = (TabExpansion2 -inputScript 'Remove-ColorProfile Er' -cursorColumn 22).CompletionMatches

            @($completions.CompletionText) | Should -Be @('Error')
        }

        It 'Completes theme names for Import-ColorProfile -Theme' {
            $completions = (TabExpansion2 -inputScript 'Import-ColorProfile -Theme Cat' -cursorColumn 30).CompletionMatches

            @($completions.CompletionText) | Should -Be @('CatppuccinFrappe', 'CatppuccinLatte', 'CatppuccinMacchiato', 'CatppuccinMocha')
        }
    }

    Context 'PSColorStyle background gradient, underline and layout properties' {
        It 'Hands each property to Write-ColorEX' {
            $style = New-ColorStyle -Name 'All' -BackgroundGradient Red, Blue -GradientSpace RGB -Reverse -UnderlineColor Red -UnderlineStyle Dotted -AutoPad 9 -PadCenter -Truncate -Wrap

            $params = $style.ToWriteColorParams()

            $params['BackGroundGradient'] | Should -Be @('Red', 'Blue')
            $params.ContainsKey('BackGroundColor') | Should -BeFalse
            $params['GradientSpace'] | Should -Be 'RGB'
            $params['Reverse'] | Should -BeTrue
            $params['UnderlineColor'] | Should -Be 'Red'
            $params['UnderlineStyle'] | Should -Be 'Dotted'
            $params['PadCenter'] | Should -BeTrue
            $params['Truncate'] | Should -BeTrue
            $params['Wrap'] | Should -BeTrue
        }

        It 'Copies each property with Clone' {
            $style = New-ColorStyle -Name 'All' -BackgroundGradient Red, Blue -GradientSpace RGB -Reverse -UnderlineColor @(1, 2, 3) -UnderlineStyle Dotted -PadCenter -Truncate -Wrap

            $copy = $style.Clone()
            $copy.UnderlineColor[0] = 9

            $copy.BackgroundGradient | Should -Be @('Red', 'Blue')
            $copy.GradientSpace | Should -Be 'RGB'
            $copy.Reverse | Should -BeTrue
            $copy.UnderlineStyle | Should -Be 'Dotted'
            $copy.PadCenter | Should -BeTrue
            $copy.Truncate | Should -BeTrue
            $copy.Wrap | Should -BeTrue
            $style.UnderlineColor[0] | Should -Be 1
        }

        It 'Writes with a profile''s new properties' {
            $style = New-ColorStyle -Name 'Centered' -ForegroundColor Red -AutoPad 7 -PadCenter -Reverse

            Write-ColorEX -Text 'abc' -StyleProfile $style

            $script:hostCalls[0].Object | Should -Be "$esc[7m$esc[91m  $esc[0m$esc[7m$esc[91mabc$esc[0m$esc[7m$esc[91m  $esc[0m"
        }
    }
}
