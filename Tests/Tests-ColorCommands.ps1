#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

# Format-ColorEX, Show-ColorTable, Register-ColorName, Unregister-ColorName, Export-ColorProfile,
# Import-ColorProfile, Remove-ColorProfile, tab completion, and PSColorStyle's background
# gradient, underline and layout properties.

BeforeAll {
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
    $esc = [char]27

    function Set-TestColorSupport {
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
        It 'Answers the line as a string, writing nothing to the host' {
            $line = Format-ColorEX 'OK' -Color Green -Bold

            $line | Should -BeOfType [string]
            $line | Should -Be "$esc[1m$esc[92mOK$esc[0m"
            $script:hostCalls | Should -HaveCount 0
        }

        It 'Fits inside a larger string' {
            "Status: $(Format-ColorEX 'OK' -Color Green)" | Should -Be "Status: $esc[92mOK$esc[0m"
        }

        It 'Answers one string for each line -Wrap makes' {
            $lines = @(Format-ColorEX 'the quick brown fox' -AutoPad 10 -Wrap)

            $lines | Should -Be @('the quick ', 'brown fox ')
        }

        It 'Answers one string for each string piped in' {
            $lines = @('a', 'b' | Format-ColorEX -Color Red)

            $lines | Should -Be @("$esc[91ma$esc[0m", "$esc[91mb$esc[0m")
        }

        It 'Answers the text alone with colors off' {
            [System.Environment]::SetEnvironmentVariable('NO_COLOR', '1')

            Format-ColorEX 'x' -Color Red -Bold | Should -Be 'x'
        }

        It 'Answers the text alone where only console colors would be written' {
            Set-TestColorSupport -Support 'None'

            Format-ColorEX 'a', 'b' -Color Red, Green | Should -Be 'ab'
        }

        It 'Answers empty strings for a profile''s blank lines' {
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
            $style = New-ColorStyle -Name 'Mine' -ForegroundColor Cyan -AddToProfiles -SetAsDefault
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
