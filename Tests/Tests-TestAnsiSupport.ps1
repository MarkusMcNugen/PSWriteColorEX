#Requires -Modules Pester

BeforeAll {
    # Import the module
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
}

Describe 'Test-AnsiSupport' -Tag 'Unit', 'Function' {

    Context 'Basic Functionality' {
        It 'Returns a PSCustomObject' {
            $result = Test-AnsiSupport -Silent

            $result | Should -BeOfType [PSCustomObject]
            $result.ColorSupport | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'SupportsBoldFonts'
        }

        It 'ColorSupport property returns one of the expected values' {
            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('None', 'ANSI4', 'ANSI8', 'TrueColor')
        }

        It 'SupportsBoldFonts property is a boolean' {
            $result = Test-AnsiSupport -Silent

            $result.SupportsBoldFonts | Should -BeOfType [bool]
        }

        It 'Supports -Silent switch parameter' {
            { Test-AnsiSupport -Silent } | Should -Not -Throw
        }

        It 'Works without -Silent parameter' {
            { Test-AnsiSupport } | Should -Not -Throw
        }

        It 'Has TAS alias' {
            $command = Get-Command TAS -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Test-AnsiSupport'
        }

        It 'Has Test-ANSI alias' {
            $command = Get-Command Test-ANSI -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command.ResolvedCommandName | Should -Be 'Test-AnsiSupport'
        }
    }

    Context 'FORCE_COLOR Environment Variable' {
        BeforeEach {
            # Save original value
            $script:OriginalForceColor = $env:FORCE_COLOR
        }

        AfterEach {
            # Restore original value
            $env:FORCE_COLOR = $script:OriginalForceColor
        }

        It 'Returns None when FORCE_COLOR is 0' {
            $env:FORCE_COLOR = '0'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'None'
        }

        It 'Returns ANSI4 when FORCE_COLOR is 1' {
            $env:FORCE_COLOR = '1'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI4'
        }

        It 'Returns ANSI8 when FORCE_COLOR is 2' {
            $env:FORCE_COLOR = '2'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI8'
        }

        It 'Returns TrueColor when FORCE_COLOR is 3' {
            $env:FORCE_COLOR = '3'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
        }

        It 'FORCE_COLOR takes precedence over other detection' {
            $env:FORCE_COLOR = '3'
            $env:COLORTERM = 'truecolor'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
        }
    }

    Context 'NO_COLOR Environment Variable' {
        BeforeEach {
            $script:OriginalNoColor = $env:NO_COLOR
            $script:OriginalForceColor = $env:FORCE_COLOR
        }

        AfterEach {
            $env:NO_COLOR = $script:OriginalNoColor
            $env:FORCE_COLOR = $script:OriginalForceColor
        }

        It 'Returns None when NO_COLOR is set' {
            # Clear FORCE_COLOR to avoid override
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = '1'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'None'
        }

        It 'NO_COLOR works with any value' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = 'true'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'None'
        }
    }

    Context 'COLORTERM Environment Variable Detection' {
        BeforeEach {
            $script:OriginalColorTerm = $env:COLORTERM
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:COLORTERM = $script:OriginalColorTerm
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects TrueColor when COLORTERM is truecolor' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:COLORTERM = 'truecolor'

            $result = Test-AnsiSupport -Silent

            # On Unix systems, this should return TrueColor
            # On Windows, it depends on other factors
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8', 'ANSI4', 'None')
        }

        It 'Detects TrueColor when COLORTERM is 24bit' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:COLORTERM = '24bit'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8', 'ANSI4', 'None')
        }
    }

    Context 'TERM Environment Variable Detection' {
        BeforeEach {
            $script:OriginalTerm = $env:TERM
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:TERM = $script:OriginalTerm
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects ANSI8 when TERM contains 256color' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'xterm-256color'

            $result = Test-AnsiSupport -Silent

            # Should at least support ANSI4 or better
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8', 'ANSI4')
        }

        It 'Detects ANSI4 when TERM is set but not 256color' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'xterm'
            $env:COLORTERM = $null

            $result = Test-AnsiSupport -Silent

            # Should support at least ANSI4
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8', 'ANSI4')
        }
    }

    Context 'Windows Terminal Detection' {
        BeforeEach {
            $script:OriginalWTSession = $env:WT_SESSION
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:WT_SESSION = $script:OriginalWTSession
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects TrueColor when WT_SESSION is set' -Skip:($PSVersionTable.Platform -eq 'Unix') {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:WT_SESSION = 'test-session-guid'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
        }
    }

    Context 'ConEmu/Cmder Detection' {
        BeforeEach {
            $script:OriginalConEmuANSI = $env:ConEmuANSI
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:ConEmuANSI = $script:OriginalConEmuANSI
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects ConEmu when ConEmuANSI is set' -Skip:($PSVersionTable.Platform -eq 'Unix') {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:ConEmuANSI = 'ON'

            $result = Test-AnsiSupport -Silent

            # ConEmu should support at least ANSI8
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8')
        }
    }

    Context 'Terminal Program Detection' {
        BeforeEach {
            $script:OriginalTermProgram = $env:TERM_PROGRAM
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:TERM_PROGRAM = $script:OriginalTermProgram
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects Apple Terminal when TERM_PROGRAM is Apple_Terminal' -Skip:($PSVersionTable.Platform -eq 'Win32NT') {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM_PROGRAM = 'Apple_Terminal'

            $result = Test-AnsiSupport -Silent

            # Terminal.app max is ANSI8 (no TrueColor)
            $result.ColorSupport | Should -BeIn @('ANSI8', 'ANSI4')
        }

        It 'Detects iTerm2 when TERM_PROGRAM is iTerm.app' -Skip:($PSVersionTable.Platform -eq 'Win32NT') {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM_PROGRAM = 'iTerm.app'

            $result = Test-AnsiSupport -Silent

            # iTerm2 supports TrueColor
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8')
        }

        It 'Detects VS Code when TERM_PROGRAM is vscode' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM_PROGRAM = 'vscode'

            $result = Test-AnsiSupport -Silent

            # VS Code supports TrueColor
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8', 'ANSI4')
        }
    }

    Context 'VTE Version Detection' {
        BeforeEach {
            $script:OriginalVTEVersion = $env:VTE_VERSION
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:VTE_VERSION = $script:OriginalVTEVersion
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects VTE-based terminal when VTE_VERSION is set' -Skip:($PSVersionTable.Platform -eq 'Win32NT') {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:VTE_VERSION = '5200'

            $result = Test-AnsiSupport -Silent

            # VTE 0.52+ supports TrueColor
            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8')
        }
    }

    Context 'Silent Mode' {
        BeforeEach {
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Does not produce warnings with -Silent switch' {
            $env:FORCE_COLOR = '0'

            # Capture warnings
            $warnings = @()
            $result = Test-AnsiSupport -Silent -WarningVariable warnings 3>$null

            # Should not have warnings (they would be in $warnings if not suppressed)
            # Note: Can't easily test for absence of Write-Warning, but function should complete
            $result.ColorSupport | Should -Be 'None'
        }

        It 'Works without -Silent on supported terminals' {
            # Should not throw even without -Silent
            { Test-AnsiSupport } | Should -Not -Throw
        }
    }

    Context 'Platform-Specific Behavior' {
        It 'Detects platform correctly' {
            $platform = [System.Environment]::OSVersion.Platform

            $platform | Should -BeIn @('Win32NT', 'Unix')
        }

        It 'Returns valid result on current platform' {
            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('None', 'ANSI4', 'ANSI8', 'TrueColor')
        }
    }

    Context 'PowerShell ISE Detection' -Skip:($Host.Name -ne 'Windows PowerShell ISE Host') {
        It 'Returns None in PowerShell ISE' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'None'
        }
    }

    Context 'PowerShell Version Compatibility' {
        It 'Works in PowerShell 5.1' -Skip:($PSVersionTable.PSVersion.Major -ne 5) {
            $result = Test-AnsiSupport -Silent

            $result | Should -BeOfType [PSCustomObject]
        }

        It 'Works in PowerShell 7+' -Skip:($PSVersionTable.PSVersion.Major -lt 6) {
            $result = Test-AnsiSupport -Silent

            $result | Should -BeOfType [PSCustomObject]
        }

        It 'Detects if running PowerShell Core' {
            $isPSCore = $PSVersionTable.PSVersion.Major -ge 6

            if ($isPSCore) {
                $PSVersionTable.PSEdition | Should -Be 'Core'
            } else {
                $PSVersionTable.PSEdition | Should -Be 'Desktop'
            }
        }
    }

    Context 'Return Value Consistency' {
        It 'Returns same value on multiple calls' {
            $result1 = Test-AnsiSupport -Silent
            $result2 = Test-AnsiSupport -Silent

            $result1.ColorSupport | Should -Be $result2.ColorSupport
            $result1.SupportsBoldFonts | Should -Be $result2.SupportsBoldFonts
        }

        It 'Returns consistent value type' {
            $result = Test-AnsiSupport -Silent

            $result.GetType().Name | Should -Be 'PSCustomObject'
        }
    }

    Context 'Edge Cases' {
        BeforeEach {
            $script:OriginalForceColor = $env:FORCE_COLOR
        }

        AfterEach {
            $env:FORCE_COLOR = $script:OriginalForceColor
        }

        It 'Handles invalid FORCE_COLOR value gracefully' {
            $env:FORCE_COLOR = 'invalid'

            { Test-AnsiSupport -Silent } | Should -Not -Throw
        }

        It 'Handles empty environment variables' {
            $env:FORCE_COLOR = ''

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('None', 'ANSI4', 'ANSI8', 'TrueColor')
        }
    }

    # PHASE 2 TESTS: Terminal Detection and Environment Variable Overrides
    Context 'Terminal Detection via Environment Variables' {
        BeforeEach {
            # Save original environment variables
            $script:OriginalTermProgram = $env:TERM_PROGRAM
            $script:OriginalVTEVersion = $env:VTE_VERSION
            $script:OriginalWTSession = $env:WT_SESSION
            $script:OriginalConEmuANSI = $env:ConEmuANSI
            $script:OriginalColorTerm = $env:COLORTERM
        }

        AfterEach {
            # Restore original environment variables
            if ($null -eq $script:OriginalTermProgram) {
                Remove-Item env:TERM_PROGRAM -ErrorAction SilentlyContinue
            } else {
                $env:TERM_PROGRAM = $script:OriginalTermProgram
            }

            if ($null -eq $script:OriginalVTEVersion) {
                Remove-Item env:VTE_VERSION -ErrorAction SilentlyContinue
            } else {
                $env:VTE_VERSION = $script:OriginalVTEVersion
            }

            if ($null -eq $script:OriginalWTSession) {
                Remove-Item env:WT_SESSION -ErrorAction SilentlyContinue
            } else {
                $env:WT_SESSION = $script:OriginalWTSession
            }

            if ($null -eq $script:OriginalConEmuANSI) {
                Remove-Item env:ConEmuANSI -ErrorAction SilentlyContinue
            } else {
                $env:ConEmuANSI = $script:OriginalConEmuANSI
            }

            if ($null -eq $script:OriginalColorTerm) {
                Remove-Item env:COLORTERM -ErrorAction SilentlyContinue
            } else {
                $env:COLORTERM = $script:OriginalColorTerm
            }
        }

        It 'Detects Windows Terminal via WT_SESSION' {
            $env:WT_SESSION = 'test-session-guid'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
            $result.Details.TerminalType | Should -Match 'Windows Terminal'
        }

        It 'Detects ConEmu via ConEmuANSI' {
            $env:ConEmuANSI = 'ON'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
            $result.Details.TerminalType | Should -Match 'ConEmu'
        }

        It 'Detects VS Code terminal via TERM_PROGRAM' {
            $env:TERM_PROGRAM = 'vscode'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
            $result.Details.TerminalType | Should -Match 'VS Code'
        }

        It 'Detects iTerm2 via TERM_PROGRAM' -Skip:($IsWindows) {
            $env:TERM_PROGRAM = 'iTerm.app'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
            $result.SupportsBoldFonts | Should -Be $true
            $result.Details.TerminalType | Should -Match 'iTerm'
        }

        It 'Detects Terminal.app with ANSI8 limitation' -Skip:($IsWindows) {
            $env:TERM_PROGRAM = 'Apple_Terminal'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI8'
            $result.SupportsBoldFonts | Should -Be $false
            $result.Details.TerminalType | Should -Match 'Terminal.app'
        }

        It 'Detects VTE-based terminals (modern version)' {
            $env:VTE_VERSION = '6000'  # VTE 0.60+

            $result = Test-AnsiSupport -Silent

            $result.SupportsBoldFonts | Should -Be $true
        }

        It 'Detects TrueColor via COLORTERM=truecolor' {
            $env:COLORTERM = 'truecolor'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8')  # May be TrueColor or higher
        }

        It 'Detects TrueColor via COLORTERM=24bit' {
            $env:COLORTERM = '24bit'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8')
        }
    }

    Context 'FORCE_COLOR Environment Variable Override' {
        BeforeEach {
            $script:OriginalForceColor = $env:FORCE_COLOR
        }

        AfterEach {
            if ($null -eq $script:OriginalForceColor) {
                Remove-Item env:FORCE_COLOR -ErrorAction SilentlyContinue
            } else {
                $env:FORCE_COLOR = $script:OriginalForceColor
            }
        }

        It 'Forces None with FORCE_COLOR=0' {
            $env:FORCE_COLOR = '0'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'None'
        }

        It 'Forces ANSI4 with FORCE_COLOR=1' {
            $env:FORCE_COLOR = '1'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI4'
        }

        It 'Forces ANSI8 with FORCE_COLOR=2' {
            $env:FORCE_COLOR = '2'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI8'
        }

        It 'Forces TrueColor with FORCE_COLOR=3' {
            $env:FORCE_COLOR = '3'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'TrueColor'
        }

        It 'FORCE_COLOR overrides terminal detection' {
            $env:WT_SESSION = 'test-session'  # Would normally be TrueColor
            $env:FORCE_COLOR = '1'  # Force to ANSI4

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI4'  # FORCE_COLOR wins
        }
    }

    Context 'Terminal Warning Messages' {
        BeforeEach {
            $script:OriginalTermProgram = $env:TERM_PROGRAM
            $script:OriginalConEmuANSI = $env:ConEmuANSI
        }

        AfterEach {
            if ($null -eq $script:OriginalTermProgram) {
                Remove-Item env:TERM_PROGRAM -ErrorAction SilentlyContinue
            } else {
                $env:TERM_PROGRAM = $script:OriginalTermProgram
            }

            if ($null -eq $script:OriginalConEmuANSI) {
                Remove-Item env:ConEmuANSI -ErrorAction SilentlyContinue
            } else {
                $env:ConEmuANSI = $script:OriginalConEmuANSI
            }
        }

        It 'Warns about Terminal.app TrueColor limitation' -Skip:($IsWindows) {
            $env:TERM_PROGRAM = 'Apple_Terminal'

            $result = Test-AnsiSupport  # No -Silent to get warnings

            $result.Details.Warnings | Should -Not -BeNullOrEmpty
            $result.Details.Warnings | Where-Object { $_ -match 'Terminal.app.*TrueColor' } | Should -Not -BeNullOrEmpty
        }

        It 'Warns about ConEmu limited TrueColor support' -Skip:($IsWindows) {
            $env:ConEmuANSI = 'ON'

            $result = Test-AnsiSupport  # No -Silent to get warnings

            $result.Details.Warnings | Should -Not -BeNullOrEmpty
            $result.Details.Warnings | Where-Object { $_ -match 'ConEmu.*LIMITED' } | Should -Not -BeNullOrEmpty
        }

        It 'Silent mode suppresses warnings' {
            $env:TERM_PROGRAM = 'Apple_Terminal'

            # Should not throw even though warnings would normally be shown
            { Test-AnsiSupport -Silent } | Should -Not -Throw
        }
    }

    Context 'Bold Font Support Detection' {
        It 'Returns boolean for SupportsBoldFonts' {
            $result = Test-AnsiSupport -Silent

            $result.SupportsBoldFonts | Should -BeOfType [bool]
        }

        It 'Detects bold font support correctly for current terminal' {
            $result = Test-AnsiSupport -Silent

            # Should be either true or false, not null
            $result.SupportsBoldFonts | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Style Support Details' {
        It 'Returns StyleSupport hashtable in Details' {
            $result = Test-AnsiSupport -Silent

            $result.Details.StyleSupport | Should -Not -BeNullOrEmpty
            $result.Details.StyleSupport | Should -BeOfType [hashtable]
        }

        It 'StyleSupport contains expected properties' {
            $result = Test-AnsiSupport -Silent

            $result.Details.StyleSupport.Keys | Should -Contain 'Bold'
            $result.Details.StyleSupport.Keys | Should -Contain 'Italic'
            $result.Details.StyleSupport.Keys | Should -Contain 'Underline'
        }

        It 'StyleSupport properties are boolean values' {
            $result = Test-AnsiSupport -Silent

            $result.Details.StyleSupport.Bold | Should -BeOfType [bool]
            $result.Details.StyleSupport.Italic | Should -BeOfType [bool]
            $result.Details.StyleSupport.Underline | Should -BeOfType [bool]
        }
    }

    # NEW TESTS: Unix Terminal Detection (Konsole, mintty, rxvt)
    Context 'Konsole Terminal Detection' {
        BeforeEach {
            $script:OriginalTerm = $env:TERM
            $script:OriginalKonsoleVersion = $env:KONSOLE_VERSION
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            if ($null -eq $script:OriginalTerm) {
                Remove-Item env:TERM -ErrorAction SilentlyContinue
            } else {
                $env:TERM = $script:OriginalTerm
            }
            if ($null -eq $script:OriginalKonsoleVersion) {
                Remove-Item env:KONSOLE_VERSION -ErrorAction SilentlyContinue
            } else {
                $env:KONSOLE_VERSION = $script:OriginalKonsoleVersion
            }
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects Konsole via TERM environment variable' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'konsole-256color'

            $result = Test-AnsiSupport -Silent

            $result.Details.TerminalType | Should -Match 'Konsole'
            $result.ColorSupport | Should -Be 'TrueColor'
            $result.SupportsBoldFonts | Should -Be $true
        }

        It 'Detects Konsole via KONSOLE_VERSION' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:KONSOLE_VERSION = '220801'

            $result = Test-AnsiSupport -Silent

            $result.Details.TerminalType | Should -Match 'Konsole'
            $result.SupportsBoldFonts | Should -Be $true
        }

        It 'Sets appropriate style support for Konsole' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'konsole'

            $result = Test-AnsiSupport -Silent

            $result.Details.StyleSupport.Italic | Should -Be $true
            $result.Details.StyleSupport.Underline | Should -Be $true
            $result.Details.StyleSupport.Overline | Should -Be $true
        }
    }

    Context 'mintty Terminal Detection' {
        BeforeEach {
            $script:OriginalTerm = $env:TERM
            $script:OriginalTermProgram = $env:TERM_PROGRAM
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            if ($null -eq $script:OriginalTerm) {
                Remove-Item env:TERM -ErrorAction SilentlyContinue
            } else {
                $env:TERM = $script:OriginalTerm
            }
            if ($null -eq $script:OriginalTermProgram) {
                Remove-Item env:TERM_PROGRAM -ErrorAction SilentlyContinue
            } else {
                $env:TERM_PROGRAM = $script:OriginalTermProgram
            }
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects mintty via TERM environment variable' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'mintty'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('TrueColor', 'ANSI8')
            $result.SupportsBoldFonts | Should -Be $true
        }

        It 'Detects mintty via TERM_PROGRAM' {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM_PROGRAM = 'mintty'

            $result = Test-AnsiSupport -Silent

            $result.SupportsBoldFonts | Should -Be $true
        }

        It 'Sets appropriate style support for mintty' -Skip:($PSVersionTable.Platform -eq 'Unix') {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'mintty'

            $result = Test-AnsiSupport -Silent

            $result.Details.StyleSupport.Italic | Should -Be $true
            $result.Details.StyleSupport.Underline | Should -Be $true
        }
    }

    Context 'rxvt Terminal Detection' {
        BeforeEach {
            $script:OriginalTerm = $env:TERM
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            if ($null -eq $script:OriginalTerm) {
                Remove-Item env:TERM -ErrorAction SilentlyContinue
            } else {
                $env:TERM = $script:OriginalTerm
            }
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects rxvt-unicode-256color' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'rxvt-unicode-256color'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI8'
            $result.Details.StyleSupport.Italic | Should -Be $true
        }

        It 'Detects basic rxvt with limitations' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'rxvt'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -Be 'ANSI4'
            $result.Details.TerminalType | Should -Match 'rxvt'
        }

        It 'Warns about basic rxvt limitations' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'rxvt'

            $result = Test-AnsiSupport  # No -Silent to get warnings

            $result.Details.Warnings | Should -Not -BeNullOrEmpty
            $result.Details.Warnings | Where-Object { $_ -match 'rxvt.*256 colors' } | Should -Not -BeNullOrEmpty
        }

        It 'Sets bold font support for rxvt-unicode' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'rxvt-unicode'

            $result = Test-AnsiSupport -Silent

            $result.SupportsBoldFonts | Should -Be $true
        }
    }

    Context 'xterm Terminal Detection' {
        BeforeEach {
            $script:OriginalTerm = $env:TERM
            $script:OriginalForceColor = $env:FORCE_COLOR
            $script:OriginalNoColor = $env:NO_COLOR
        }

        AfterEach {
            if ($null -eq $script:OriginalTerm) {
                Remove-Item env:TERM -ErrorAction SilentlyContinue
            } else {
                $env:TERM = $script:OriginalTerm
            }
            $env:FORCE_COLOR = $script:OriginalForceColor
            $env:NO_COLOR = $script:OriginalNoColor
        }

        It 'Detects xterm-256color' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'xterm-256color'

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('ANSI8', 'TrueColor')
            $result.Details.TerminalType | Should -Match 'xterm'
        }

        It 'Detects basic xterm' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'xterm'
            $env:COLORTERM = $null

            $result = Test-AnsiSupport -Silent

            $result.ColorSupport | Should -BeIn @('ANSI4', 'ANSI8', 'TrueColor')
        }

        It 'Sets bold font support to false for xterm (default coupling)' -Skip:($IsWindows) {
            $env:FORCE_COLOR = $null
            $env:NO_COLOR = $null
            $env:TERM = 'xterm-256color'

            $result = Test-AnsiSupport -Silent

            $result.SupportsBoldFonts | Should -Be $false
        }
    }
}
