#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

# Write-ColorEX's color forms and unknown names, the color variables, markup, splitting,
# highlighting, links, underline styles and colors, Reverse, background gradients, the gradient
# color space, truncating, centering and wrapping. Each test checks the exact text and escape
# codes Write-ColorEX hands to Write-Host.

BeforeAll {
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
    $script:esc = [char]27
    $script:ellipsis = [string][char]0x2026

    # Sets the color support Write-ColorEX found at import, and whether bold is a bold font
    function Set-TestColorSupport {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'A test helper; -WhatIf has no meaning in a test.')]
        param($Support, [bool]$BoldFonts = $true)
        & (Get-Module PSWriteColorEX) { param($s, $b) $script:CachedANSISupport = $s; $script:SupportsBoldFonts = $b } $Support $BoldFonts
    }

    function Get-TestColorSupport {
        & (Get-Module PSWriteColorEX) { @($script:CachedANSISupport, $script:SupportsBoldFonts) }
    }

    # The color variables change the output, so the tests clear them
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
}

Describe 'Write-ColorEX markup, splitting, highlighting, links and layout' -Tag 'Unit', 'Output' {

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
        # Escape codes reach the screen, and a line of console colors goes out as one call
        Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $true }
        Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $true }
        $script:savedSupport = Get-TestColorSupport
    }

    AfterAll {
        Set-TestColorSupport -Support $script:savedSupport[0] -BoldFonts $script:savedSupport[1]
    }

    BeforeEach {
        $script:hostCalls.Clear()
        $script:savedEnvironment = Save-ColorEnvironment
        Set-TestColorSupport -Support 'TrueColor'
    }

    AfterEach {
        Restore-ColorEnvironment -Saved $script:savedEnvironment
    }

    Context 'The color variables' {
        It 'Writes plain text with CLICOLOR=0' {
            [System.Environment]::SetEnvironmentVariable('CLICOLOR', '0')

            Write-ColorEX -Text 'x' -Color Red -Bold

            $script:hostCalls[0].Object | Should -Be 'x'
        }

        It 'Writes 16 colors with CLICOLOR_FORCE where no support was found' {
            Set-TestColorSupport -Support 'None'
            [System.Environment]::SetEnvironmentVariable('CLICOLOR_FORCE', '1')

            Write-ColorEX -Text 'x' -Color '#FF0000' -Bold

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[91mx$esc[0m"
        }

        It 'Puts CLICOLOR_FORCE before CLICOLOR=0 and TERM=dumb' {
            [System.Environment]::SetEnvironmentVariable('CLICOLOR_FORCE', '1')
            [System.Environment]::SetEnvironmentVariable('CLICOLOR', '0')
            [System.Environment]::SetEnvironmentVariable('TERM', 'dumb')

            Write-ColorEX -Text 'x' -Bold

            $script:hostCalls[0].Object | Should -Be "$esc[1mx$esc[0m"
        }

        It 'Puts NO_COLOR before CLICOLOR_FORCE' {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', '1')
            [System.Environment]::SetEnvironmentVariable('CLICOLOR_FORCE', '1')

            Write-ColorEX -Text 'x' -Bold

            $script:hostCalls[0].Object | Should -Be 'x'
        }

        It 'Writes a line of color names as escape codes with <Variable>=<Value>, in a host that takes console colors' -TestCases @(
            @{ Variable = 'FORCE_COLOR'; Value = '1' }
            @{ Variable = 'FORCE_COLOR'; Value = '3' }
            @{ Variable = 'CLICOLOR_FORCE'; Value = '1' }
        ) {
            Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $false }
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }
            Set-TestColorSupport -Support 'None'
            [System.Environment]::SetEnvironmentVariable($Variable, $Value)

            Write-ColorEX -Text 'a', 'b' -Color Red, DarkBlue -BackGroundColor Black, Gray

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be "$esc[91m$esc[40ma$esc[0m$esc[34m$esc[47mb$esc[0m"
        }

        It 'Returns color names as escape codes with FORCE_COLOR, in a host that takes console colors' {
            Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $false }
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }
            Set-TestColorSupport -Support 'None'
            [System.Environment]::SetEnvironmentVariable('FORCE_COLOR', '2')

            Format-ColorEX -Text 'x' -Color Red | Should -Be "$esc[91mx$esc[0m"
        }

        It 'Writes color names as console colors in a host that takes them, with no variable forcing colors' {
            Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $false }
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }
            Set-TestColorSupport -Support 'None'

            Write-ColorEX -Text 'x' -Color Red

            $script:hostCalls[0].Object | Should -Be 'x'
            $script:hostCalls[0].ForegroundColor | Should -Be 'Red'
        }
    }

    Context '-ColorSupport' {
        It 'Returns the same string with <Variable>=<Value> set, in a host that shows no escape codes' -TestCases @(
            @{ Variable = 'NO_COLOR'; Value = '1' }
            @{ Variable = 'FORCE_COLOR'; Value = '0' }
            @{ Variable = 'FORCE_COLOR'; Value = '3' }
            @{ Variable = 'CLICOLOR'; Value = '0' }
            @{ Variable = 'TERM'; Value = 'dumb' }
        ) {
            Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $false }
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }
            Set-TestColorSupport -Support 'None'
            [System.Environment]::SetEnvironmentVariable($Variable, $Value)

            Format-ColorEX -Text 'x' -Color '#FF8000' -ColorSupport ANSI8 | Should -Be "$esc[38;5;208mx$esc[0m"
        }

        It 'Writes a hex color for <Support> as <Expected>' -TestCases @(
            @{ Support = 'ANSI4'; Expected = '93' }
            @{ Support = 'ANSI8'; Expected = '38;5;208' }
            @{ Support = 'TrueColor'; Expected = '38;2;255;128;0' }
            @{ Support = 'truecolor'; Expected = '38;2;255;128;0' }
        ) {
            Set-TestColorSupport -Support 'None'

            Format-ColorEX -Text 'x' -Color '#FF8000' -ColorSupport $Support | Should -Be "$esc[$($Expected)mx$esc[0m"
        }

        It 'Returns the text alone with None, even with FORCE_COLOR set' {
            [System.Environment]::SetEnvironmentVariable('FORCE_COLOR', '3')

            Format-ColorEX -Text 'a', 'b' -Color Red, '#FF8000' -Gradient Red, Blue -Italic -ColorSupport None -Silent | Should -Be 'ab'
        }

        It 'Writes console colors with None, even where escape codes reach the screen' {
            Write-ColorEX -Text 'x' -Color Red -ColorSupport None

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be 'x'
            $script:hostCalls[0].ForegroundColor | Should -Be 'Red'
        }

        It 'Writes a line of console colors as escape codes with ANSI4, in a host that takes console colors' {
            Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $false }
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }
            Set-TestColorSupport -Support 'None'

            Write-ColorEX -Text 'a', 'b' -Color Red, DarkBlue -ColorSupport ANSI4

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be "$esc[91ma$esc[0m$esc[34mb$esc[0m"
        }

        It 'Writes each piped string for the support given' {
            'a', 'b' | Write-ColorEX -Color Red -ColorSupport ANSI4

            $script:hostCalls.Object | Should -Be @("$esc[91ma$esc[0m", "$esc[91mb$esc[0m")
        }

        It 'Drops a gradient with ANSI4, with the warning a 16-color terminal gives' {
            $text = Format-ColorEX -Text 'ab' -Gradient Red, Blue -ColorSupport ANSI4 -WarningVariable warnings -WarningAction SilentlyContinue

            $text | Should -Be 'ab'
            $warnings.Message | Should -Be 'Gradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). Gradient disabled.'
        }

        It 'Lightens bold colors with None, where the terminal draws bold fonts' {
            Set-TestColorSupport -Support 'TrueColor' -BoldFonts $true

            Write-ColorEX -Text 'x' -Color DarkRed -Bold -ColorSupport None

            $script:hostCalls[0].ForegroundColor | Should -Be 'Red'
        }

        It 'Writes bold with <Support> as the terminal draws it: bold fonts <BoldFonts>' -TestCases @(
            @{ Support = 'ANSI8'; BoldFonts = $true; Expected = '31' }
            @{ Support = 'ANSI8'; BoldFonts = $false; Expected = '91' }
            @{ Support = 'TrueColor'; BoldFonts = $true; Expected = '38;2;128;64;0' }
            @{ Support = 'TrueColor'; BoldFonts = $false; Expected = '38;2;179;102;102' }
        ) {
            Set-TestColorSupport -Support 'None' -BoldFonts $BoldFonts
            $color = if ($Support -eq 'ANSI8') { 'DarkRed' } else { '#804000' }

            Format-ColorEX -Text 'x' -Color $color -Bold -ColorSupport $Support | Should -Be "$esc[1m$esc[$($Expected)mx$esc[0m"
        }

        It 'Refuses a support outside the four' {
            { Format-ColorEX -Text 'x' -ColorSupport ANSI16 } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Format-ColorEX'
            { Write-ColorEX -Text 'x' -ColorSupport '' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Write-ColorEX'
        }
    }

    Context 'Color forms' {
        It 'Reads <Form> as <Expected>' -TestCases @(
            @{ Form = '#F80'; Expected = '255;136;0' }
            @{ Form = '0xf80'; Expected = '255;136;0' }
            @{ Form = 'rgb(255, 128, 0)'; Expected = '255;128;0' }
            @{ Form = 'RGB(255 128 0)'; Expected = '255;128;0' }
            @{ Form = 'hsl(30, 100%, 50%)'; Expected = '255;128;0' }
            @{ Form = 'hsl(-120 50 25)'; Expected = '32;32;96' }
            @{ Form = 'hsl(390deg, 100%, 50%)'; Expected = '255;128;0' }
        ) {
            Write-ColorEX -Text 'x' -Color $Form

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;${Expected}mx$esc[0m"
        }

        It 'Reads the forms in -BackGroundColor, -UnderlineColor and -Gradient too' {
            Write-ColorEX -Text 'ab' -BackGroundColor 'rgb(0, 0, 255)' -UnderlineColor '#F00' -Gradient 'hsl(0, 100%, 50%)', '#00F' -GradientSpace RGB

            $script:hostCalls[0].Object | Should -Be "$esc[4m$esc[58;2;255;0;0m$esc[48;2;0;0;255m$esc[38;2;255;0;0ma$esc[38;2;0;0;255mb$esc[0m"
        }

        It 'Clamps rgb() channels out of range, with a warning' {
            Write-ColorEX -Text 'x' -Color 'rgb(300, -5, 128)' -WarningVariable warnings -WarningAction SilentlyContinue

            $warnings | Should -HaveCount 1
            "$($warnings[0])" | Should -Be 'RGB values out of range (0-255). Original: @(300,-5,128). Clamped to: @(255,0,128)'
            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;0;128mx$esc[0m"
        }

        It 'Writes <Form> as the nearest color of <Mode>' -TestCases @(
            @{ Form = '#FF8800'; Mode = 'ANSI8'; Expected = '38;5;208' }
            @{ Form = 'rgb(255, 136, 0)'; Mode = 'ANSI8'; Expected = '38;5;208' }
            @{ Form = 'hsl(32, 100%, 50%)'; Mode = 'ANSI8'; Expected = '38;5;208' }
            @{ Form = '#FF8800'; Mode = 'ANSI4'; Expected = '93' }
            @{ Form = '0xF80'; Mode = 'ANSI4'; Expected = '93' }
        ) {
            $mode = @{ $Mode = $true }
            Write-ColorEX -Text 'x' -Color $Form @mode -WarningVariable warnings

            $warnings | Should -HaveCount 0
            $script:hostCalls[0].Object | Should -Be "$esc[${Expected}mx$esc[0m"
        }

        It 'Writes a hex background in the mode asked for' {
            Write-ColorEX -Text 'a', 'b' -BackGroundColor '#FF8800', '#003366' -ANSI4

            $script:hostCalls[0].Object | Should -Be "$esc[103ma$esc[0m$esc[46mb$esc[0m"
        }

        It 'Writes the hex colors of markup tags and -Highlight in the mode asked for' {
            Write-ColorEX -Text '[#FF8800 on #003366]a[/] b' -Markup -Highlight @{ 'b' = '#FF8800' } -ANSI8

            $script:hostCalls[0].Object | Should -Be "$esc[38;5;208m$esc[48;5;17ma$esc[0m $esc[38;5;208mb$esc[0m"
        }

        It 'Lightens a bold hex color before writing it in the mode asked for' {
            Set-TestColorSupport -Support 'TrueColor' -BoldFonts $false
            Write-ColorEX -Text 'x' -Color '#804000' -Bold -ANSI8

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[38;5;131mx$esc[0m"
        }
    }

    Context 'Color names the table lacks' {
        It 'Warns once per line about each unknown name and leaves its segments in the terminal color' {
            Write-ColorEX -Text 'a', 'b', 'c' -Color Purpel, Red, Purpel -WarningVariable warnings -WarningAction SilentlyContinue

            $warnings | Should -HaveCount 1
            "$($warnings[0])" | Should -Be "Unknown color 'Purpel'."
            $script:hostCalls[0].Object | Should -Be "a$esc[91mb$esc[0mc"
        }

        It 'Leaves an unknown name in the terminal color with console colors too' {
            Set-TestColorSupport -Support 'None'
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }

            Write-ColorEX -Text 'x' -Color Purpel -WarningAction SilentlyContinue

            $script:hostCalls[0].ForegroundColor | Should -Be ''
        }

        It 'Takes None and an empty string as no color, without a warning' {
            Write-ColorEX -Text 'a', 'b' -Color 'None', '' -WarningVariable warnings

            $warnings | Should -HaveCount 0
            $script:hostCalls[0].Object | Should -Be 'ab'
        }

        It 'Warns about an unknown -BackGroundColor, -UnderlineColor and -Gradient name' {
            Write-ColorEX -Text 'ab' -BackGroundColor Bleu -WarningVariable warnings -WarningAction SilentlyContinue
            Write-ColorEX -Text 'ab' -UnderlineColor Grene -WarningVariable +warnings -WarningAction SilentlyContinue
            Write-ColorEX -Text 'ab' -Gradient Rde, Blue -WarningVariable +warnings -WarningAction SilentlyContinue

            @($warnings | ForEach-Object { "$_" }) | Should -Be @("Unknown color 'Bleu'.", "Unknown color 'Grene'.", "Unknown color 'Rde'.")
        }

        It 'Says nothing with -Silent' {
            Write-ColorEX -Text 'x' -Color Purpel -Silent -WarningVariable warnings

            $warnings | Should -HaveCount 0
        }
    }

    Context '-Markup' {
        It 'Colors and styles the text of a tag' {
            Write-ColorEX -Text '[bold red]Error:[/] not found' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[91mError:$esc[0m not found"
        }

        It 'Takes a background after on' {
            Write-ColorEX -Text '[white on blue]x[/]' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[97m$esc[104mx$esc[0m"
        }

        It 'Nests tags, the inner taking what it does not set from the outer' {
            Write-ColorEX -Text '[red]a[bold]b[/]c[/]d' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[91ma$esc[0m$esc[1m$esc[91mb$esc[0m$esc[91mc$esc[0md"
        }

        It 'Closes a tag left open at the end of its string' {
            Write-ColorEX -Text '[red]a', 'b' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[91ma$esc[0mb"
        }

        It 'Writes [[ and ]] as [ and ]' {
            Write-ColorEX -Text '[[x]] [[[red]y[/]]]' -Markup

            $script:hostCalls[0].Object | Should -Be "[x] [$esc[91my$esc[0m]"
        }

        It 'Writes a tag that is not a style as text, with a warning' {
            Write-ColorEX -Text '[nosuch]x' -Markup -WarningVariable warnings -WarningAction SilentlyContinue

            "$($warnings[0])" | Should -Be 'Markup tag [nosuch] is not a style; it is written as text.'
            $script:hostCalls[0].Object | Should -Be '[nosuch]x'
        }

        It 'Writes a closing tag with no tag open as text, with a warning' {
            Write-ColorEX -Text 'a[/]b' -Markup -WarningVariable warnings -WarningAction SilentlyContinue

            "$($warnings[0])" | Should -Be 'Markup tag [/] closes no tag; it is written as text.'
            $script:hostCalls[0].Object | Should -Be 'a[/]b'
        }

        It 'Writes a tag with an unknown color as text, and its closing tag, which then closes nothing' {
            Write-ColorEX -Text '[Purpel]x[/]' -Markup -WarningVariable warnings -WarningAction SilentlyContinue

            @($warnings | ForEach-Object { "$_" }) | Should -Be @(
                'Markup tag [Purpel] is not a style; it is written as text.'
                'Markup tag [/] closes no tag; it is written as text.'
            )
            $script:hostCalls[0].Object | Should -Be '[Purpel]x[/]'
        }

        It 'Leaves the text alone without -Markup' {
            Write-ColorEX -Text '[red]x[/]'

            $script:hostCalls[0].Object | Should -Be '[red]x[/]'
        }

        It 'Writes a hex color in TrueColor' {
            Write-ColorEX -Text '[#FF8000]x[/]' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;128;0mx$esc[0m"
        }

        It 'Puts a tag''s color over -Color and the segment''s styles under it' {
            Write-ColorEX -Text '[red]a[/]b' -Color Green -Style Italic -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[3m$esc[91ma$esc[0m$esc[3m$esc[92mb$esc[0m"
        }

        It 'Puts a tag''s color over the gradient' {
            Write-ColorEX -Text 'a[red]b[/]c' -Gradient '#000000', '#0000FF' -GradientSpace RGB -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;0;0;0ma$esc[0m$esc[38;2;255;0;0mb$esc[0m$esc[38;2;0;0;255mc$esc[0m"
        }

        It 'Writes the text without tags to the log file' {
            $log = Join-Path $TestDrive 'markup.log'

            Write-ColorEX -Text '[bold]a[/]b[[c]]' -Markup -LogFile $log

            [System.IO.File]::ReadAllText($log) | Should -Be "ab[c]$([System.Environment]::NewLine)"
        }
    }

    Context '-Split, -SplitAround and -SplitEvenly' {
        It 'Cuts after each separator, which stays with the part before it' {
            Write-ColorEX -Text 'one,two,three' -Split ',' -Color Red, Green, Blue

            $script:hostCalls[0].Object | Should -Be "$esc[91mone,$esc[0m$esc[92mtwo,$esc[0m$esc[94mthree$esc[0m"
        }

        It 'Takes the longest separator that matches at a place' {
            Write-ColorEX -Text 'a--b-c' -Split '-', '--' -Color Red, Green, Blue

            $script:hostCalls[0].Object | Should -Be "$esc[91ma--$esc[0m$esc[92mb-$esc[0m$esc[94mc$esc[0m"
        }

        It 'Matches separators with case' {
            Write-ColorEX -Text 'aXbxc' -Split 'x' -Color Red, Green

            $script:hostCalls[0].Object | Should -Be "$esc[91maXbx$esc[0m$esc[92mc$esc[0m"
        }

        It 'Makes each separator a part of its own with -SplitAround' {
            Write-ColorEX -Text 'key=value' -SplitAround '=' -Color Cyan, DarkGray, White

            $script:hostCalls[0].Object | Should -Be "$esc[96mkey$esc[0m$esc[90m=$esc[0m$esc[97mvalue$esc[0m"
        }

        It 'Cuts into as many parts as -Color has colors, the first ones longer, with -SplitEvenly' {
            Write-ColorEX -Text 'abcdefg' -SplitEvenly -Color Red, Green, Blue

            $script:hostCalls[0].Object | Should -Be "$esc[91mabc$esc[0m$esc[92mde$esc[0m$esc[94mfg$esc[0m"
        }

        It 'Counts display characters with -SplitEvenly' {
            $emoji = [char]::ConvertFromUtf32(0x1F600)

            Write-ColorEX -Text "a$($emoji)bc" -SplitEvenly -Color Red, Green

            $script:hostCalls[0].Object | Should -Be "$esc[91ma$emoji$esc[0m$esc[92mbc$esc[0m"
        }

        It 'Counts -BackGroundColor without -Color for -SplitEvenly' {
            Write-ColorEX -Text 'abcd' -SplitEvenly -BackGroundColor Red, Blue

            $script:hostCalls[0].Object | Should -Be "$esc[101mab$esc[0m$esc[104mcd$esc[0m"
        }

        It 'Splits each -Text string on its own' {
            Write-ColorEX -Text 'a,b', 'c,d' -Split ',' -Color Red, Green

            $script:hostCalls[0].Object | Should -Be "$esc[91ma,$esc[0m$esc[92mb$esc[0m$esc[91mc,$esc[0m$esc[92md$esc[0m"
        }

        It 'Splits the text markup leaves, keeping each part''s tags' {
            Write-ColorEX -Text '[bold]a,b[/],c' -Split ',' -Color Red, Green, Blue -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[91ma,$esc[0m$esc[1m$esc[92mb$esc[0m$esc[92m,$esc[0m$esc[94mc$esc[0m"
        }

        It 'Refuses more than one way of splitting' {
            { Write-ColorEX -Text 'a' -Split ',' -SplitEvenly } | Should -Throw 'Use only one of -Split, -SplitAround and -SplitEvenly.'
            { Write-ColorEX -Text 'a' -Split ',' -SplitAround ',' } | Should -Throw 'Use only one of -Split, -SplitAround and -SplitEvenly.'
        }
    }

    Context '-Highlight' {
        It 'Colors and styles the text a pattern matches, without regard to case' {
            Write-ColorEX -Text 'ERROR: disk full' -Highlight @{ 'error' = 'bold red' }

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[91mERROR$esc[0m: disk full"
        }

        It 'Gives overlapping text to the pattern listed first' {
            Write-ColorEX -Text 'abcd' -Highlight ([ordered]@{ 'abc' = 'red'; 'bcd' = 'blue' })

            $script:hostCalls[0].Object | Should -Be "$esc[91mabc$esc[0m$esc[94md$esc[0m"
        }

        It 'Matches across segments, each part keeping its segment''s colors under the style' {
            Write-ColorEX -Text 'ab', 'cd' -Color Green, Yellow -Highlight @{ 'bc' = 'underline' }

            $script:hostCalls[0].Object | Should -Be "$esc[92ma$esc[0m$esc[4m$esc[92mb$esc[0m$esc[4m$esc[93mc$esc[0m$esc[93md$esc[0m"
        }

        It 'Stops with an error for a pattern that is not a regular expression' {
            { Write-ColorEX -Text 'x' -Highlight @{ '(' = 'red' } } | Should -Throw "Cannot validate argument on parameter 'Highlight'.*"
        }

        It 'Skips a pattern whose style is not a style, with a warning' {
            Write-ColorEX -Text 'abc' -Highlight @{ 'b' = 'nosuch' } -WarningVariable warnings -WarningAction SilentlyContinue

            "$($warnings[0])" | Should -Be "Highlight style 'nosuch' for 'b' is not a style; the pattern is skipped."
            $script:hostCalls[0].Object | Should -Be 'abc'
        }
    }

    Context '-Link' {
        It 'Opens a link before a segment and closes it after' {
            Write-ColorEX -Text 'See ', 'the docs' -Link $null, 'https://example.com'

            $script:hostCalls[0].Object | Should -Be "See $esc]8;;https://example.com$esc\the docs$esc]8;;$esc\"
        }

        It 'Keeps one link over consecutive segments with the same address' {
            Write-ColorEX -Text 'a', 'b' -Color Red, Green -Link 'https://example.com'

            $script:hostCalls[0].Object | Should -Be "$esc]8;;https://example.com$esc\$esc[91ma$esc[0m$esc[92mb$esc[0m$esc]8;;$esc\"
        }

        It 'Removes control characters from the address' {
            Write-ColorEX -Text 'x' -Link "https://exa$([char]7)mple.com/$esc"

            $script:hostCalls[0].Object | Should -Be "$esc]8;;https://example.com/$esc\x$esc]8;;$esc\"
        }

        It 'Takes a link from a markup tag' {
            Write-ColorEX -Text 'a [link=https://example.com]b[/]' -Markup

            $script:hostCalls[0].Object | Should -Be "a $esc]8;;https://example.com$esc\b$esc]8;;$esc\"
        }

        It 'Writes no link where colors are off' {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', '1')

            Write-ColorEX -Text 'x' -Link 'https://example.com'

            $script:hostCalls[0].Object | Should -Be 'x'
        }

        It 'Writes no link with console colors' {
            Set-TestColorSupport -Support 'None'
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }

            Write-ColorEX -Text 'x' -Link 'https://example.com'

            $script:hostCalls[0].Object | Should -Be 'x'
        }
    }

    Context 'Underlines and -Reverse' {
        It 'Writes -Reverse as code 7' {
            Write-ColorEX -Text 'x' -Reverse -Color Red

            $script:hostCalls[0].Object | Should -Be "$esc[7m$esc[91mx$esc[0m"
        }

        It 'Writes -UnderlineStyle <Style> as <Code>' -TestCases @(
            @{ Style = 'Single'; Code = '4' }
            @{ Style = 'Double'; Code = '21' }
            @{ Style = 'Curly'; Code = '4:3' }
            @{ Style = 'Dotted'; Code = '4:4' }
            @{ Style = 'Dashed'; Code = '4:5' }
        ) {
            Write-ColorEX -Text 'x' -UnderlineStyle $Style

            $script:hostCalls[0].Object | Should -Be "$esc[${Code}mx$esc[0m"
        }

        It 'Underlines a segment with an underline color and no other underline' {
            Write-ColorEX -Text 'a', 'b' -UnderlineColor '#FF0000', $null

            $script:hostCalls[0].Object | Should -Be "$esc[4m$esc[58;2;255;0;0ma$esc[0mb"
        }

        It 'Adds no underline of its own to one already set' {
            Write-ColorEX -Text 'x' -UnderlineStyle Curly -UnderlineColor '#FF0000'

            $script:hostCalls[0].Object | Should -Be "$esc[4:3m$esc[58;2;255;0;0mx$esc[0m"
        }

        It 'Writes an underline color as a 256-color number in ANSI8' {
            Write-ColorEX -Text 'x' -Underline -UnderlineColor Orange -ANSI8

            $script:hostCalls[0].Object | Should -Be "$esc[4m$esc[58;5;214mx$esc[0m"
        }

        It 'Writes a console color name''s underline color as its number 0-15' {
            Write-ColorEX -Text 'x' -Underline -UnderlineColor Red

            $script:hostCalls[0].Object | Should -Be "$esc[4m$esc[58;5;9mx$esc[0m"
        }

        It 'Lets a markup tag''s underline style win over the underline color''s single line' {
            Write-ColorEX -Text '[curly]x[/]' -UnderlineColor '#00FF00' -Markup

            $script:hostCalls[0].Object | Should -Be "$esc[4m$esc[58;2;0;255;0m$esc[4:3mx$esc[0m"
        }
    }

    Context 'Gradients' {
        It 'Blends in OKLab by default and in RGB with -GradientSpace RGB' {
            Write-ColorEX -Text 'abc' -Gradient Red, Blue
            Write-ColorEX -Text 'abc' -Gradient Red, Blue -GradientSpace RGB

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;0;0ma$esc[38;2;140;83;162mb$esc[38;2;0;0;255mc$esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[38;2;255;0;0ma$esc[38;2;128;0;128mb$esc[38;2;0;0;255mc$esc[0m"
        }

        It 'Blends -BackGroundGradient across the background' {
            Write-ColorEX -Text 'ab' -Color White -BackGroundGradient Red, Blue

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;255;255m$esc[48;2;255;0;0ma$esc[48;2;0;0;255mb$esc[0m"
        }

        It 'Leaves a segment with its own -BackGroundColor out of the background gradient' {
            Write-ColorEX -Text 'ab', 'c' -BackGroundColor $null, Green -BackGroundGradient Red, Blue -GradientSpace RGB

            $script:hostCalls[0].Object | Should -Be "$esc[48;2;255;0;0ma$esc[48;2;128;0;128mb$esc[0m$esc[48;2;0;255;0mc$esc[0m"
        }

        It 'Writes a -BackGroundColor under a text gradient' {
            Write-ColorEX -Text 'ab' -Gradient Red, Blue -BackGroundColor Black

            $script:hostCalls[0].Object | Should -Be "$esc[48;2;0;0;0m$esc[38;2;255;0;0ma$esc[38;2;0;0;255mb$esc[0m"
        }

        It 'Turns -BackGroundGradient off with fewer than 2 colors, with a warning' {
            Write-ColorEX -Text 'ab' -BackGroundGradient Red -WarningVariable warnings -WarningAction SilentlyContinue

            "$($warnings[0])" | Should -Be 'BackGroundGradient requires at least 2 colors (received 1). BackGroundGradient disabled.'
            $script:hostCalls[0].Object | Should -Be 'ab'
        }

        It 'Turns -BackGroundGradient off on a 16-color terminal, with a warning' {
            Set-TestColorSupport -Support 'ANSI4'

            Write-ColorEX -Text 'ab' -BackGroundGradient Red, Blue -WarningVariable warnings -WarningAction SilentlyContinue

            "$($warnings[0])" | Should -Be 'BackGroundGradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). BackGroundGradient disabled.'
        }
    }

    Context '256 colors and gradient stops' {
        It 'Writes a color name in 256 colors with the code its hex code takes' {
            Write-ColorEX -Text 'x' -Color Lime -ANSI8
            Write-ColorEX -Text 'x' -Color '#00FF00' -ANSI8

            $script:hostCalls[0].Object | Should -Be "$esc[38;5;46mx$esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[38;5;46mx$esc[0m"
        }

        It 'Draws every stop of a gradient on a character of its own' {
            Write-ColorEX -Text 'Sixstopsmakearainbow' -Gradient Red, Yellow, Green, Cyan, Blue, Magenta

            $codes = @([regex]::Matches($script:hostCalls[0].Object, '38;2;(\d+;\d+;\d+)m') | ForEach-Object { $_.Groups[1].Value })
            $codes.Count | Should -Be 20
            @($codes[0], $codes[4], $codes[8], $codes[11], $codes[15], $codes[19]) | Should -Be @('255;0;0', '255;255;0', '0;255;0', '0;255;255', '0;0;255', '255;0;255')
        }

        It 'Spreads a text gradient over the characters that show, leaving out spaces' {
            Write-ColorEX -Text 'Six stops make a rainbow' -Gradient Red, Yellow, Green, Cyan, Blue, Magenta

            ($script:hostCalls[0].Object -replace "$esc\[[\d;]*m", '') | Should -Be 'Six stops make a rainbow'
            [regex]::Matches($script:hostCalls[0].Object, '38;2;').Count | Should -Be 20
            $script:hostCalls[0].Object | Should -Match ([regex]::Escape("$esc[38;2;0;255;255me"))
        }

        It 'Gives white space a text gradient color where an underline, a markup underline or -Reverse shows it' {
            Write-ColorEX -Text 'a b' -Gradient Red, Blue -Underline
            Write-ColorEX -Text 'a b' -Gradient Red, Blue -Reverse
            Write-ColorEX -Text '[underline]a b[/] c d' -Gradient Red, Blue -Markup

            [regex]::Matches($script:hostCalls[0].Object, '38;2;').Count | Should -Be 3
            [regex]::Matches($script:hostCalls[1].Object, '38;2;').Count | Should -Be 3
            [regex]::Matches($script:hostCalls[2].Object, '38;2;').Count | Should -Be 5
        }

        It 'Spreads a background gradient over every character, spaces included' {
            Write-ColorEX -Text 'a b' -Color White -BackGroundGradient Red, Blue

            [regex]::Matches($script:hostCalls[0].Object, '48;2;').Count | Should -Be 3
        }

        It 'Writes the rainbow in 256 colors with its hues in order' {
            Write-ColorEX -Text 'Six stops make a rainbow' -Gradient Red, Yellow, Green, Cyan, Blue, Magenta -ANSI8

            $codes = @([regex]::Matches($script:hostCalls[0].Object, '38;5;(\d+)m') | ForEach-Object { $_.Groups[1].Value }) -join ' '
            $codes | Should -Be '196 202 214 220 226 190 154 118 46 48 50 51 45 39 27 21 57 93 165 201'
        }
    }

    Context 'Named gradients' {
        It 'Writes a named gradient as its colors' {
            Write-ColorEX -Text 'abcdefgh' -Gradient Sunset
            Write-ColorEX -Text 'abcdefgh' -Gradient '#4A1C6F', '#C2185B', '#FF6F3C', '#FFC857'

            $script:hostCalls[0].Object | Should -Be $script:hostCalls[1].Object
        }

        It 'Reads a gradient name without regard to case, for the background too' {
            Write-ColorEX -Text 'abcd' -Color White -BackGroundGradient fire
            Write-ColorEX -Text 'abcd' -Color White -BackGroundGradient '#8B0000', '#FF4500', '#FF8C00', '#FFD700'

            $script:hostCalls[0].Object | Should -Be $script:hostCalls[1].Object
        }

        It 'Draws the named gradient of a style' {
            $style = New-ColorStyle -Name 'NamedGradientStyle' -Gradient Ocean
            Write-ColorEX -Text 'abcdefgh' -StyleProfile $style
            Write-ColorEX -Text 'abcdefgh' -Gradient '#003366', '#0077B6', '#00B4D8', '#90E0EF'

            $script:hostCalls[0].Object | Should -Be $script:hostCalls[1].Object
        }

        It 'Reads two values as colors, even one that names a gradient' {
            Write-ColorEX -Text 'ab' -Gradient Forest, Blue

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;34;139;34ma$esc[38;2;0;0;255mb$esc[0m"
        }

        It 'Holds 21 named gradients of two valid colors or more' {
            $names = & (Get-Module PSWriteColorEX) { $script:GradientNames }

            $names.Count | Should -Be 21
            foreach ($name in $names.Keys) {
                $names[$name].Count | Should -BeGreaterOrEqual 2 -Because $name
                foreach ($stop in $names[$name]) { $stop | Should -Match '^#[0-9A-F]{6}$' -Because $name }
            }
        }

        It 'Completes gradient names first, each with its colors, and each name once' {
            $result = TabExpansion2 -inputScript 'Write-ColorEX -Text x -Gradient Fore' -cursorColumn 36

            @($result.CompletionMatches | ForEach-Object CompletionText) | Should -Be @('Forest')
            $result.CompletionMatches[0].ToolTip | Should -Be 'Forest  #0B3D20 #1E6B3A #4C9A2A #A3C94F'
        }
    }

    Context 'Gradient options' {
        BeforeAll {
            # The 24-bit colors of a line, in order
            function Get-TestGradientCode([string]$Line) {
                @([regex]::Matches($Line, '38;2;(\d+;\d+;\d+)m') | ForEach-Object { $_.Groups[1].Value })
            }
        }

        It 'Goes round the hue wheel the way -GradientHue names' {
            Write-ColorEX -Text 'abc' -Gradient Red, Blue -GradientSpace HSL
            Write-ColorEX -Text 'abc' -Gradient Red, Blue -GradientSpace HSL -GradientHue Longer

            # Red is at 0 degrees and blue at 240: the short way passes magenta at 300, the long way green at 120
            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;0;0ma$esc[38;2;255;0;255mb$esc[38;2;0;0;255mc$esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[38;2;255;0;0ma$esc[38;2;0;255;0mb$esc[38;2;0;0;255mc$esc[0m"
        }

        It 'Moves the colors along the text with -GradientEasing' {
            Write-ColorEX -Text 'abcde' -Gradient Black, White -GradientSpace RGB -GradientEasing InQuad

            # InQuad puts the middle character a quarter of the way along: 255 / 4 rounds to 64
            (Get-TestGradientCode $script:hostCalls[0].Object)[2] | Should -Be '64;64;64'
        }

        It 'Cuts the gradient into bands with -GradientSteps, with both ends exact' {
            Write-ColorEX -Text 'abcdefghijkl' -Gradient Black, White -GradientSpace RGB -GradientSteps 4

            (Get-TestGradientCode $script:hostCalls[0].Object) -join ' ' | Should -Be ((@('0;0;0') * 3 + @('85;85;85') * 3 + @('170;170;170') * 3 + @('255;255;255') * 3) -join ' ')
        }

        It 'Draws placed stops again past their span with -GradientRepeat' {
            Write-ColorEX -Text 'abcdefghi' -Gradient 'Red@0', 'Blue@25' -GradientSpace RGB -GradientRepeat Repeat
            Write-ColorEX -Text 'abcdefghi' -Gradient 'Red@0', 'Blue@25' -GradientSpace RGB

            $repeated = Get-TestGradientCode $script:hostCalls[0].Object
            @($repeated[0], $repeated[2], $repeated[3], $repeated[4]) | Should -Be @('255;0;0', '0;0;255', '128;0;128', '255;0;0')
            (Get-TestGradientCode $script:hostCalls[1].Object)[3..8] | Should -Be (@('0;0;255') * 6)
        }

        It 'Runs from the middle out with -GradientDirection CenterOut, and from the end with Reverse' {
            Write-ColorEX -Text 'abcdefghi' -Gradient Red, Lime, Blue -GradientDirection CenterOut
            Write-ColorEX -Text 'abcde' -Gradient Red, Blue -GradientSpace RGB -GradientDirection Reverse

            $center = Get-TestGradientCode $script:hostCalls[0].Object
            @($center[0], $center[4], $center[8]) | Should -Be @('0;0;255', '255;0;0', '0;0;255')
            (Get-TestGradientCode $script:hostCalls[1].Object) -join ' ' | Should -Be '0;0;255 64;0;191 128;0;128 191;0;64 255;0;0'
        }

        It 'Puts a stop placed with @ on the character nearest its place' {
            Write-ColorEX -Text 'abcdefghij' -Gradient 'Red', '#FFD700@40', 'Blue'

            # 40% of 10 characters is character 3.6, which takes the color on character 4
            (Get-TestGradientCode $script:hostCalls[0].Object)[4] | Should -Be '255;215;0'
        }

        It 'Takes every gradient option from a style' {
            $style = New-ColorStyle -Name 'GradientOptionsStyle' -Gradient Red, Blue -GradientSpace HSL -GradientHue Longer

            Write-ColorEX -Text 'abc' -StyleProfile $style

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;0;0ma$esc[38;2;0;255;0mb$esc[38;2;0;0;255mc$esc[0m"
        }

        It 'Refuses a style value outside its set with an error and writes the text with the setting left out' {
            $style = New-ColorStyle -Name 'BadGradientOptionStyle' -Gradient Red, Blue -GradientSpace HSL
            $style.GradientHue = 'Sideways'

            Write-ColorEX -Text 'abc' -StyleProfile $style -ErrorVariable problems -ErrorAction SilentlyContinue

            "$($problems[0])" | Should -BeLike "Cannot validate argument on parameter 'GradientHue'. The argument `"Sideways`" does not belong to the set *"
            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;0;0ma$esc[38;2;255;0;255mb$esc[38;2;0;0;255mc$esc[0m"
        }
    }

    Context 'Get-GradientColor' {
        It 'Returns one RGB array for each of -Count colors' {
            $colors = @(Get-GradientColor -Gradient Black, White -Count 3 -GradientSpace RGB)

            $colors.Count | Should -Be 3
            $colors[1].GetType() | Should -Be ([int[]])
            $colors[1] | Should -Be @(128, 128, 128)
        }

        It 'Returns the one color at -Place, the nearer end for a place outside 0 to 1' {
            (Get-GradientColor -Gradient Black, White -Place 0.5 -GradientSpace RGB) | Should -Be @(128, 128, 128)
            (Get-GradientColor -Gradient Black, White -Place 7 -GradientSpace RGB) | Should -Be @(255, 255, 255)
            (Get-GradientColor -Gradient Black, White -Place -1 -GradientSpace RGB) | Should -Be @(0, 0, 0)
        }

        It 'Returns the color at each of several places, in order, each as -Place gives it alone' {
            $places = 0.75, 0.25, 7, 0.5
            $together = @(Get-GradientColor -Gradient 'Red', 'Gold@40', 'Blue' -Place $places -GradientSpace OKLCH)
            $alone = @(foreach ($place in $places) { , (Get-GradientColor -Gradient 'Red', 'Gold@40', 'Blue' -Place $place -GradientSpace OKLCH) })

            $together.Count | Should -Be 4
            $together[2].GetType() | Should -Be ([int[]])
            ($together | ForEach-Object { $_ -join ',' }) -join ' ' | Should -Be (($alone | ForEach-Object { $_ -join ',' }) -join ' ')
        }

        It 'Returns 101 colors for the whole percents from one call' {
            $colors = @(Get-GradientColor -Gradient Progress -Place (0..100 | ForEach-Object { $_ / 100 }))

            $colors.Count | Should -Be 101
            $colors[0] | Should -Be @(255, 0, 0)
            $colors[100] | Should -Be @(0, 255, 0)
        }

        It 'Reads a named gradient and placed stops as -Gradient does' {
            $progress = @(Get-GradientColor -Gradient Progress -Count 5)

            ($progress | ForEach-Object { $_ -join ',' }) -join ' ' | Should -Be '255,0,0 255,102,153 255,165,0 255,255,0 0,255,0'
        }

        It 'Refuses fewer than 2 colors' {
            { Get-GradientColor -Gradient Red -Count 3 } | Should -Throw -ErrorId 'GradientTooFewColors,*'
        }
    }

    Context '-Truncate and -PadCenter' {
        It 'Cuts text wider than -AutoPad, ending it with an ellipsis' {
            Write-ColorEX -Text 'abcdefgh' -AutoPad 5 -Truncate

            $script:hostCalls[0].Object | Should -Be "abcd$ellipsis"
        }

        It 'Puts the ellipsis in the colors of the text it replaces' {
            Write-ColorEX -Text 'abc', 'def' -Color Red, Blue -AutoPad 5 -Truncate

            $script:hostCalls[0].Object | Should -Be "$esc[91mabc$esc[0m$esc[94md$ellipsis$esc[0m"
        }

        It 'Pads after cutting where a wide character does not fit' {
            $world = "$([char]0x4E16)$([char]0x754C)"

            Write-ColorEX -Text "$world$world" -AutoPad 4 -Truncate

            $script:hostCalls[0].Object | Should -Be "$([char]0x4E16)$ellipsis "
        }

        It 'Leaves text that fits as it is' {
            Write-ColorEX -Text 'abc' -AutoPad 5 -Truncate

            $script:hostCalls[0].Object | Should -Be 'abc  '
        }

        It 'Writes the cut text to the log file' {
            $log = Join-Path $TestDrive 'cut.log'

            Write-ColorEX -Text 'abcdefgh' -AutoPad 5 -Truncate -LogFile $log -NoConsoleOutput

            [System.IO.File]::ReadAllText($log) | Should -Be "abcd$ellipsis$([System.Environment]::NewLine)"
        }

        It 'Centers the text with -PadCenter, the right side one longer when odd' {
            Write-ColorEX -Text 'Menu' -AutoPad 10 -PadCenter -PadChar '='
            Write-ColorEX -Text 'abc' -AutoPad 6 -PadCenter

            $script:hostCalls[0].Object | Should -Be '===Menu==='
            $script:hostCalls[1].Object | Should -Be ' abc  '
        }

        It 'Colors the padding on each side as segments of their own' {
            Write-ColorEX -Text 'ab' -AutoPad 6 -PadCenter -BackGroundColor Blue, Red, Green

            $script:hostCalls[0].Object | Should -Be "$esc[104m  $esc[0m$esc[101mab$esc[0m$esc[102m  $esc[0m"
        }
    }

    Context '-Wrap' {
        BeforeEach {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', '1')
        }

        It 'Breaks at the last space that fits, padding each line to -AutoPad' {
            Write-ColorEX -Text 'the quick brown fox' -AutoPad 10 -Wrap

            @($script:hostCalls.Object) | Should -Be @('the quick ', 'brown fox ')
        }

        It 'Breaks a word wider than the line between characters' {
            Write-ColorEX -Text 'abcdefghij' -AutoPad 4 -Wrap

            @($script:hostCalls.Object) | Should -Be @('abcd', 'efgh', 'ij  ')
        }

        It 'Starts a new line at a line end in the text' {
            Write-ColorEX -Text "a`r`nb" -AutoPad 3 -Wrap

            @($script:hostCalls.Object) | Should -Be @('a  ', 'b  ')
        }

        It 'Wraps to the window less the indentation without -AutoPad' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 12 }

            Write-ColorEX -Text 'aaaa bbbb cccc' -StartSpaces 2 -Wrap

            @($script:hostCalls.Object) | Should -Be @('  aaaa bbbb', '  cccc')
        }

        It 'Gives lines after the first spaces in place of the time' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 20 }

            Write-ColorEX -Text 'aaaa bbbb cccc' -ShowTime -DateTimeFormat 'HH:mm' -Wrap

            $script:hostCalls[0].Object | Should -Match '^\[\d\d:\d\d\] aaaa bbbb$'
            $script:hostCalls[1].Object | Should -Be '        cccc'
        }

        It 'Writes one line without a known width' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 0 }

            Write-ColorEX -Text 'aaaa bbbb cccc' -Wrap

            @($script:hostCalls.Object) | Should -Be @('aaaa bbbb cccc')
        }

        It 'Leaves the last line open with -NoNewLine' {
            Write-ColorEX -Text 'aaaa bbbb' -AutoPad 4 -Wrap -NoNewLine

            @($script:hostCalls.NoNewline) | Should -Be @($false, $true)
        }

        It 'Runs the gradient on from line to line' {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', $null)

            Write-ColorEX -Text 'ab cd' -AutoPad 2 -Wrap -Gradient '#000000', '#0000FF', '#000000', '#0000FF' -GradientSpace RGB

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;0;0;0ma$esc[38;2;0;0;255mb$esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[38;2;0;0;0mc$esc[38;2;0;0;255md$esc[0m"
        }

        It 'Keeps a segment''s colors on each line it spans' {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', $null)

            Write-ColorEX -Text 'aa bb' -AutoPad 3 -Wrap -Color Red

            $script:hostCalls[0].Object | Should -Be "$esc[91maa$esc[0m$esc[91m $esc[0m"
            $script:hostCalls[1].Object | Should -Be "$esc[91mbb$esc[0m$esc[91m $esc[0m"
        }

        It 'Writes the text as one line to the log file' {
            $log = Join-Path $TestDrive 'wrap.log'

            Write-ColorEX -Text 'aaaa bbbb' -AutoPad 4 -Wrap -LogFile $log

            [System.IO.File]::ReadAllText($log) | Should -Be "aaaa bbbb$([System.Environment]::NewLine)"
        }
    }
}
