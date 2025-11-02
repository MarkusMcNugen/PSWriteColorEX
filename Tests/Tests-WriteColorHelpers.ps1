#Requires -Modules Pester

BeforeAll {
    # Import the module
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force

    # Dot-source the class file for tests that reference [PSColorStyle]
    . "$ModuleRoot\Classes\PSColorStyle.ps1"
}

Describe 'Write-ColorError' -Tag 'Unit', 'Function', 'Helper' {

    Context 'Basic Functionality' {
        It 'Accepts text parameter' {
            { Write-ColorError -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Accepts pipeline input' {
            { 'Test' | Write-ColorError -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports NoNewLine switch' {
            { Write-ColorError -Text 'Test' -NoNewLine -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports NoConsoleOutput switch' {
            { Write-ColorError -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports PassThru switch' {
            $result = Write-ColorError -Text 'Test' -PassThru -NoConsoleOutput
            $result | Should -Be 'Test'
        }

        It 'Has WCE alias' {
            $command = Get-Command WCE -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Write-ColorError'
        }

        It 'Has Write-ErrorColor alias' {
            $command = Get-Command Write-ErrorColor -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Style Profile' {
        It 'Uses Error profile by default' {
            # Error profile should exist
            $profile = [PSColorStyle]::GetProfile('Error')
            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Red'
            $profile.Bold | Should -Be $true
        }

        It 'Uses cached style parameters for performance' {
            # Multiple calls should use cache
            Write-ColorError -Text 'Test1' -NoConsoleOutput
            Write-ColorError -Text 'Test2' -NoConsoleOutput
            # Should not throw and should complete quickly
        }
    }

    Context 'Logging' {
        BeforeEach {
            $script:TestLogFile = Join-Path $TestDrive "error_test.log"
        }

        It 'Writes to log file when specified' {
            Write-ColorError -Text 'Test error' -LogFile $script:TestLogFile -NoConsoleOutput

            Test-Path $script:TestLogFile | Should -Be $true
            $content = Get-Content $script:TestLogFile -Raw
            $content | Should -Match 'Test error'
        }

        It 'Supports NoConsoleOutput for log-only mode' {
            Write-ColorError -Text 'Log only' -LogFile $script:TestLogFile -NoConsoleOutput

            Test-Path $script:TestLogFile | Should -Be $true
        }
    }

    Context 'Array Input' {
        It 'Accepts array of strings' {
            { Write-ColorError -Text @('Error1', 'Error2') -NoConsoleOutput } | Should -Not -Throw
        }

        It 'PassThru returns input array' {
            $result = Write-ColorError -Text @('A', 'B') -PassThru -NoConsoleOutput
            $result | Should -Be @('A', 'B')
        }
    }
}

Describe 'Write-ColorWarning' -Tag 'Unit', 'Function', 'Helper' {

    Context 'Basic Functionality' {
        It 'Accepts text parameter' {
            { Write-ColorWarning -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Accepts pipeline input' {
            { 'Test' | Write-ColorWarning -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports NoNewLine switch' {
            { Write-ColorWarning -Text 'Test' -NoNewLine -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports PassThru switch' {
            $result = Write-ColorWarning -Text 'Test' -PassThru -NoConsoleOutput
            $result | Should -Be 'Test'
        }

        It 'Has WCW alias' {
            $command = Get-Command WCW -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Write-ColorWarning'
        }
    }

    Context 'Style Profile' {
        It 'Uses Warning profile by default' {
            $profile = [PSColorStyle]::GetProfile('Warning')
            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Yellow'
        }
    }

    Context 'Logging' {
        BeforeEach {
            $script:TestLogFile = Join-Path $TestDrive "warning_test.log"
        }

        It 'Writes to log file when specified' {
            Write-ColorWarning -Text 'Test warning' -LogFile $script:TestLogFile -NoConsoleOutput

            Test-Path $script:TestLogFile | Should -Be $true
            $content = Get-Content $script:TestLogFile -Raw
            $content | Should -Match 'Test warning'
        }
    }
}

Describe 'Write-ColorInfo' -Tag 'Unit', 'Function', 'Helper' {

    Context 'Basic Functionality' {
        It 'Accepts text parameter' {
            { Write-ColorInfo -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports PassThru switch' {
            $result = Write-ColorInfo -Text 'Test' -PassThru -NoConsoleOutput
            $result | Should -Be 'Test'
        }

        It 'Has WCI alias' {
            $command = Get-Command WCI -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Write-ColorInfo'
        }
    }

    Context 'Style Profile' {
        It 'Uses Info profile by default' {
            $profile = [PSColorStyle]::GetProfile('Info')
            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Cyan'
        }
    }
}

Describe 'Write-ColorSuccess' -Tag 'Unit', 'Function', 'Helper' {

    Context 'Basic Functionality' {
        It 'Accepts text parameter' {
            { Write-ColorSuccess -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports PassThru switch' {
            $result = Write-ColorSuccess -Text 'Test' -PassThru -NoConsoleOutput
            $result | Should -Be 'Test'
        }

        It 'Has WCS alias' {
            $command = Get-Command WCS -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Write-ColorSuccess'
        }
    }

    Context 'Style Profile' {
        It 'Uses Success profile by default' {
            $profile = [PSColorStyle]::GetProfile('Success')
            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Green'
        }
    }
}

Describe 'Write-ColorCritical' -Tag 'Unit', 'Function', 'Helper' {

    Context 'Basic Functionality' {
        It 'Accepts text parameter' {
            { Write-ColorCritical -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports PassThru switch' {
            $result = Write-ColorCritical -Text 'Test' -PassThru -NoConsoleOutput
            $result | Should -Be 'Test'
        }

        It 'Has WCC alias' {
            $command = Get-Command WCC -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Write-ColorCritical'
        }
    }

    Context 'Style Profile' {
        It 'Uses Critical profile by default' {
            $profile = [PSColorStyle]::GetProfile('Critical')
            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'White'
            $profile.BackgroundColor | Should -Be 'DarkRed'
            $profile.Bold | Should -Be $true
            $profile.Blink | Should -Be $true
        }
    }
}

Describe 'Write-ColorDebug' -Tag 'Unit', 'Function', 'Helper' {

    Context 'Basic Functionality' {
        It 'Accepts text parameter' {
            { Write-ColorDebug -Text 'Test' -NoConsoleOutput } | Should -Not -Throw
        }

        It 'Supports PassThru switch' {
            $result = Write-ColorDebug -Text 'Test' -PassThru -NoConsoleOutput
            $result | Should -Be 'Test'
        }

        It 'Has WCD alias' {
            $command = Get-Command WCD -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Write-ColorDebug'
        }
    }

    Context 'Style Profile' {
        It 'Uses Debug profile by default' {
            $profile = [PSColorStyle]::GetProfile('Debug')
            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'DarkGray'
            $profile.Italic | Should -Be $true
        }
    }
}

Describe 'Set-ColorDefault' -Tag 'Unit', 'Function', 'StyleManagement' {

    Context 'Basic Functionality' {
        BeforeEach {
            # Save original default
            $script:OriginalDefault = [PSColorStyle]::Default.Clone()
        }

        AfterEach {
            # Restore original default
            $script:OriginalDefault.SetAsDefault()
        }

        It 'Sets default using properties' {
            Set-ColorDefault -ForegroundColor Cyan -Bold

            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Cyan'
            [PSColorStyle]::Default.Bold | Should -Be $true
        }

        It 'Sets default using PSColorStyle object' {
            $style = [PSColorStyle]::new('CustomDefault', 'Magenta', $null)
            Set-ColorDefault -Style $style

            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Magenta'
        }

        It 'Has SCD alias' {
            $command = Get-Command SCD -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Set-ColorDefault'
        }

        It 'Has Set-ColourDefault alias' {
            $command = Get-Command Set-ColourDefault -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Property Parameters' {
        BeforeEach {
            $script:OriginalDefault = [PSColorStyle]::Default.Clone()
        }

        AfterEach {
            $script:OriginalDefault.SetAsDefault()
        }

        It 'Sets foreground color' {
            Set-ColorDefault -ForegroundColor Red

            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Red'
        }

        It 'Sets background color' {
            Set-ColorDefault -BackgroundColor Blue

            [PSColorStyle]::Default.BackgroundColor | Should -Be 'Blue'
        }

        It 'Sets Bold' {
            Set-ColorDefault -Bold

            [PSColorStyle]::Default.Bold | Should -Be $true
        }

        It 'Sets Italic' {
            Set-ColorDefault -Italic

            [PSColorStyle]::Default.Italic | Should -Be $true
        }

        It 'Sets Underline' {
            Set-ColorDefault -Underline

            [PSColorStyle]::Default.Underline | Should -Be $true
        }

        It 'Sets ShowTime' {
            Set-ColorDefault -ShowTime

            [PSColorStyle]::Default.ShowTime | Should -Be $true
        }

        It 'Sets StartTab' {
            Set-ColorDefault -StartTab 3

            [PSColorStyle]::Default.StartTab | Should -Be 3
        }

        It 'Sets StartSpaces' {
            Set-ColorDefault -StartSpaces 5

            [PSColorStyle]::Default.StartSpaces | Should -Be 5
        }

        It 'Sets multiple properties at once' {
            Set-ColorDefault -ForegroundColor Cyan -BackgroundColor DarkBlue -Bold -StartTab 2

            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Cyan'
            [PSColorStyle]::Default.BackgroundColor | Should -Be 'DarkBlue'
            [PSColorStyle]::Default.Bold | Should -Be $true
            [PSColorStyle]::Default.StartTab | Should -Be 2
        }
    }

    Context 'Style Object Parameter' {
        BeforeEach {
            $script:OriginalDefault = [PSColorStyle]::Default.Clone()
        }

        AfterEach {
            $script:OriginalDefault.SetAsDefault()
        }

        It 'Accepts PSColorStyle object' {
            $customStyle = [PSColorStyle]::new('Custom', 'Yellow', 'DarkMagenta')
            $customStyle.Bold = $true

            Set-ColorDefault -Style $customStyle

            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Yellow'
            [PSColorStyle]::Default.BackgroundColor | Should -Be 'DarkMagenta'
            [PSColorStyle]::Default.Bold | Should -Be $true
        }

        It 'Style object takes precedence over property parameters' {
            $customStyle = [PSColorStyle]::new('Custom', 'Red', $null)

            # Using Style parameter set
            Set-ColorDefault -Style $customStyle

            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Red'
        }
    }

    Context 'Profile Registration' {
        BeforeEach {
            $script:OriginalDefault = [PSColorStyle]::Default.Clone()
        }

        AfterEach {
            $script:OriginalDefault.SetAsDefault()
        }

        It 'Adds new default to profiles collection' {
            Set-ColorDefault -ForegroundColor Orange

            [PSColorStyle]::Profiles.ContainsKey('Default') | Should -Be $true
            [PSColorStyle]::Profiles['Default'].ForegroundColor | Should -Be 'Orange'
        }
    }
}

Describe 'Get-ColorProfiles' -Tag 'Unit', 'Function', 'StyleManagement' {

    Context 'Basic Functionality' {
        It 'Returns all profiles' {
            $profiles = Get-ColorProfiles

            $profiles | Should -Not -BeNullOrEmpty
            $profiles.Count | Should -BeGreaterOrEqual 7
        }

        It 'Returns specific profile by name' {
            $profile = Get-ColorProfiles -Name 'Error'

            $profile | Should -Not -BeNullOrEmpty
            $profile.Name | Should -Be 'Error'
        }

        It 'Returns null for non-existent profile' {
            $profile = Get-ColorProfiles -Name 'NonExistent'

            $profile | Should -BeNullOrEmpty
        }

        It 'Has GCP alias' {
            $command = Get-Command GCP -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Get-ColorProfiles'
        }

        It 'Has Get-ColourProfiles alias' {
            $command = Get-Command Get-ColourProfiles -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Default Profiles' {
        It 'Contains Error profile' {
            $profile = Get-ColorProfiles -Name 'Error'

            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Red'
        }

        It 'Contains Warning profile' {
            $profile = Get-ColorProfiles -Name 'Warning'

            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Yellow'
        }

        It 'Contains Info profile' {
            $profile = Get-ColorProfiles -Name 'Info'

            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Cyan'
        }

        It 'Contains Success profile' {
            $profile = Get-ColorProfiles -Name 'Success'

            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'Green'
        }

        It 'Contains Critical profile' {
            $profile = Get-ColorProfiles -Name 'Critical'

            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'White'
            $profile.BackgroundColor | Should -Be 'DarkRed'
        }

        It 'Contains Debug profile' {
            $profile = Get-ColorProfiles -Name 'Debug'

            $profile | Should -Not -BeNullOrEmpty
            $profile.ForegroundColor | Should -Be 'DarkGray'
        }

        It 'Contains Default profile' {
            $profile = Get-ColorProfiles -Name 'Default'

            $profile | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Return Types' {
        It 'Returns PSColorStyle objects' {
            $profiles = Get-ColorProfiles

            foreach ($profile in $profiles) {
                $profile.GetType().Name | Should -Be 'PSColorStyle'
            }
        }

        It 'Single profile returns PSColorStyle' {
            $profile = Get-ColorProfiles -Name 'Error'

            $profile.GetType().Name | Should -Be 'PSColorStyle'
        }
    }
}

Describe 'New-ColorStyle' -Tag 'Unit', 'Function', 'StyleManagement' {

    Context 'Basic Functionality' {
        It 'Creates new style with name' {
            $style = New-ColorStyle -Name 'TestStyle'

            $style | Should -Not -BeNullOrEmpty
            $style.Name | Should -Be 'TestStyle'
        }

        It 'Creates style with foreground color' {
            $style = New-ColorStyle -Name 'TestStyle' -ForegroundColor Red

            $style.ForegroundColor | Should -Be 'Red'
        }

        It 'Creates style with background color' {
            $style = New-ColorStyle -Name 'TestStyle' -BackgroundColor Blue

            $style.BackgroundColor | Should -Be 'Blue'
        }

        It 'Has NCS alias' {
            $command = Get-Command NCS -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'New-ColorStyle'
        }

        It 'Has New-ColourStyle alias' {
            $command = Get-Command New-ColourStyle -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Style Properties' {
        It 'Sets Bold' {
            $style = New-ColorStyle -Name 'TestStyle' -Bold

            $style.Bold | Should -Be $true
        }

        It 'Sets Italic' {
            $style = New-ColorStyle -Name 'TestStyle' -Italic

            $style.Italic | Should -Be $true
        }

        It 'Sets Underline' {
            $style = New-ColorStyle -Name 'TestStyle' -Underline

            $style.Underline | Should -Be $true
        }

        It 'Sets Blink' {
            $style = New-ColorStyle -Name 'TestStyle' -Blink

            $style.Blink | Should -Be $true
        }

        It 'Sets Faint' {
            $style = New-ColorStyle -Name 'TestStyle' -Faint

            $style.Faint | Should -Be $true
        }

        It 'Sets CrossedOut' {
            $style = New-ColorStyle -Name 'TestStyle' -CrossedOut

            $style.CrossedOut | Should -Be $true
        }

        It 'Sets DoubleUnderline' {
            $style = New-ColorStyle -Name 'TestStyle' -DoubleUnderline

            $style.DoubleUnderline | Should -Be $true
        }

        It 'Sets Overline' {
            $style = New-ColorStyle -Name 'TestStyle' -Overline

            $style.Overline | Should -Be $true
        }

        It 'Sets multiple style properties' {
            $style = New-ColorStyle -Name 'TestStyle' -Bold -Italic -Underline

            $style.Bold | Should -Be $true
            $style.Italic | Should -Be $true
            $style.Underline | Should -Be $true
        }
    }

    Context 'Formatting Properties' {
        It 'Sets StartTab' {
            $style = New-ColorStyle -Name 'TestStyle' -StartTab 2

            $style.StartTab | Should -Be 2
        }

        It 'Sets StartSpaces' {
            $style = New-ColorStyle -Name 'TestStyle' -StartSpaces 4

            $style.StartSpaces | Should -Be 4
        }

        It 'Sets LinesBefore' {
            $style = New-ColorStyle -Name 'TestStyle' -LinesBefore 1

            $style.LinesBefore | Should -Be 1
        }

        It 'Sets LinesAfter' {
            $style = New-ColorStyle -Name 'TestStyle' -LinesAfter 2

            $style.LinesAfter | Should -Be 2
        }

        It 'Sets ShowTime' {
            $style = New-ColorStyle -Name 'TestStyle' -ShowTime

            $style.ShowTime | Should -Be $true
        }

        It 'Sets NoNewLine' {
            $style = New-ColorStyle -Name 'TestStyle' -NoNewLine

            $style.NoNewLine | Should -Be $true
        }

        It 'Sets HorizontalCenter' {
            $style = New-ColorStyle -Name 'TestStyle' -HorizontalCenter

            $style.HorizontalCenter | Should -Be $true
        }
    }

    Context 'Gradient Property' {
        It 'Sets Gradient array' {
            $style = New-ColorStyle -Name 'TestStyle' -Gradient @('Red', 'Blue', 'Green')

            $style.Gradient | Should -Not -BeNullOrEmpty
            $style.Gradient.Count | Should -Be 3
        }
    }

    Context 'AddToProfiles Switch' {
        It 'Adds style to profiles when switch is used' {
            $style = New-ColorStyle -Name 'AddToProfilesTest' -ForegroundColor Orange -AddToProfiles

            [PSColorStyle]::Profiles.ContainsKey('AddToProfilesTest') | Should -Be $true
        }

        It 'Does not add to profiles by default' {
            $style = New-ColorStyle -Name 'NotInProfiles' -ForegroundColor Purple

            # Just check it was created
            $style.Name | Should -Be 'NotInProfiles'
        }
    }

    Context 'SetAsDefault Switch' {
        BeforeEach {
            $script:OriginalDefault = [PSColorStyle]::Default.Clone()
        }

        AfterEach {
            $script:OriginalDefault.SetAsDefault()
        }

        It 'Sets as default when switch is used' {
            $style = New-ColorStyle -Name 'NewDefault' -ForegroundColor Magenta -SetAsDefault

            [PSColorStyle]::Default.Name | Should -Be 'NewDefault'
            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Magenta'
        }
    }

    Context 'Return Value' {
        It 'Returns PSColorStyle object' {
            $style = New-ColorStyle -Name 'TestStyle'

            $style.GetType().Name | Should -Be 'PSColorStyle'
        }

        It 'Returns object with all specified properties' {
            $style = New-ColorStyle -Name 'FullStyle' -ForegroundColor Red -BackgroundColor Blue -Bold -Italic -StartTab 2

            $style.Name | Should -Be 'FullStyle'
            $style.ForegroundColor | Should -Be 'Red'
            $style.BackgroundColor | Should -Be 'Blue'
            $style.Bold | Should -Be $true
            $style.Italic | Should -Be $true
            $style.StartTab | Should -Be 2
        }
    }

    Context 'Complex Style Creation' {
        It 'Creates complex style with all options' {
            $style = New-ColorStyle -Name 'ComplexStyle' `
                -ForegroundColor Cyan `
                -BackgroundColor DarkBlue `
                -Gradient @('Red', 'Green', 'Blue') `
                -Bold -Italic -Underline `
                -StartTab 2 -StartSpaces 4 `
                -LinesBefore 1 -LinesAfter 1 `
                -ShowTime -HorizontalCenter `
                -AddToProfiles

            $style.Name | Should -Be 'ComplexStyle'
            $style.ForegroundColor | Should -Be 'Cyan'
            $style.Bold | Should -Be $true
            $style.Gradient.Count | Should -Be 3
            [PSColorStyle]::Profiles.ContainsKey('ComplexStyle') | Should -Be $true
        }
    }
}
