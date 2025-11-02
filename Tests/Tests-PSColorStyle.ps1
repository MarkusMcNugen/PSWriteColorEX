#Requires -Modules Pester

BeforeAll {
    # Import the module first
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force

    # Dot-source the class file directly into test scope (same as module does)
    . "$ModuleRoot\Classes\PSColorStyle.ps1"
}

Describe 'PSColorStyle Class' -Tag 'Unit', 'Class' {

    Context 'Constructors' {
        It 'Creates instance with default constructor' {
            $style = [PSColorStyle]::new()

            $style | Should -Not -BeNullOrEmpty
            $style.Name | Should -Be 'Custom'
            $style.ForegroundColor | Should -Be 'Gray'
            $style.BackgroundColor | Should -BeNullOrEmpty
        }

        It 'Creates instance with name only' {
            $style = [PSColorStyle]::new('TestStyle')

            $style.Name | Should -Be 'TestStyle'
            $style.ForegroundColor | Should -Be 'Gray'
            $style.BackgroundColor | Should -BeNullOrEmpty
        }

        It 'Creates instance with name, foreground, and background' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', 'Blue')

            $style.Name | Should -Be 'TestStyle'
            $style.ForegroundColor | Should -Be 'Red'
            $style.BackgroundColor | Should -Be 'Blue'
        }

        It 'Accepts null background color' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)

            $style.Name | Should -Be 'TestStyle'
            $style.ForegroundColor | Should -Be 'Red'
            $style.BackgroundColor | Should -BeNullOrEmpty
        }
    }

    Context 'Property Initialization' {
        BeforeAll {
            $style = [PSColorStyle]::new('TestStyle', 'Red', 'Blue')
        }

        It 'Initializes boolean properties to false' {
            $style.Bold | Should -Be $false
            $style.Italic | Should -Be $false
            $style.Underline | Should -Be $false
            $style.Blink | Should -Be $false
            $style.Faint | Should -Be $false
            $style.CrossedOut | Should -Be $false
            $style.DoubleUnderline | Should -Be $false
            $style.Overline | Should -Be $false
            $style.ShowTime | Should -Be $false
            $style.NoNewLine | Should -Be $false
            $style.HorizontalCenter | Should -Be $false
        }

        It 'Initializes numeric properties to zero' {
            $style.StartTab | Should -Be 0
            $style.StartSpaces | Should -Be 0
            $style.LinesBefore | Should -Be 0
            $style.LinesAfter | Should -Be 0
        }

        It 'Initializes Style as empty or null' {
            # Style can be null or empty array
            if ($style.Style) {
                $style.Style.Count | Should -Be 0
            } else {
                $style.Style | Should -BeNullOrEmpty
            }
        }

        It 'Initializes Gradient as null' {
            $style.Gradient | Should -BeNullOrEmpty
        }
    }

    Context 'Property Modification' {
        BeforeEach {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
        }

        It 'Allows setting Bold to true' {
            $style.Bold = $true
            $style.Bold | Should -Be $true
        }

        It 'Allows setting multiple style properties' {
            $style.Bold = $true
            $style.Italic = $true
            $style.Underline = $true

            $style.Bold | Should -Be $true
            $style.Italic | Should -Be $true
            $style.Underline | Should -Be $true
        }

        It 'Allows setting numeric properties' {
            $style.StartTab = 2
            $style.StartSpaces = 4
            $style.LinesBefore = 1
            $style.LinesAfter = 1

            $style.StartTab | Should -Be 2
            $style.StartSpaces | Should -Be 4
            $style.LinesBefore | Should -Be 1
            $style.LinesAfter | Should -Be 1
        }

        It 'Allows setting Gradient array' {
            $style.Gradient = @('Red', 'Blue', 'Green')

            $style.Gradient | Should -Not -BeNullOrEmpty
            $style.Gradient.Count | Should -Be 3
            $style.Gradient[0] | Should -Be 'Red'
        }

        It 'Allows setting Style array' {
            $style.Style = @('Bold', 'Italic')

            $style.Style.Count | Should -Be 2
            $style.Style[0] | Should -Be 'Bold'
            $style.Style[1] | Should -Be 'Italic'
        }
    }

    Context 'Static Default Property' {
        It 'Has a Default static property' {
            [PSColorStyle]::Default | Should -Not -BeNullOrEmpty
        }

        It 'Default property is of type PSColorStyle' {
            [PSColorStyle]::Default.GetType().Name | Should -Be 'PSColorStyle'
        }
    }

    Context 'Static Profiles Property' {
        It 'Has a Profiles static property' {
            [PSColorStyle]::Profiles | Should -Not -BeNullOrEmpty
        }

        It 'Profiles is a hashtable' {
            [PSColorStyle]::Profiles | Should -BeOfType [hashtable]
        }

        It 'Profiles contains default profiles' {
            [PSColorStyle]::Profiles.ContainsKey('Default') | Should -Be $true
            [PSColorStyle]::Profiles.ContainsKey('Error') | Should -Be $true
            [PSColorStyle]::Profiles.ContainsKey('Warning') | Should -Be $true
            [PSColorStyle]::Profiles.ContainsKey('Info') | Should -Be $true
            [PSColorStyle]::Profiles.ContainsKey('Success') | Should -Be $true
            [PSColorStyle]::Profiles.ContainsKey('Critical') | Should -Be $true
            [PSColorStyle]::Profiles.ContainsKey('Debug') | Should -Be $true
        }
    }

    Context 'SetAsDefault Method' {
        It 'Sets the style as default' {
            $originalDefault = [PSColorStyle]::Default
            $newStyle = [PSColorStyle]::new('NewDefault', 'Magenta', $null)

            $newStyle.SetAsDefault()

            [PSColorStyle]::Default.Name | Should -Be 'NewDefault'
            [PSColorStyle]::Default.ForegroundColor | Should -Be 'Magenta'

            # Restore original default
            $originalDefault.SetAsDefault()
        }
    }

    Context 'AddToProfiles Method' {
        It 'Adds style to profiles collection' {
            $style = [PSColorStyle]::new('CustomProfile', 'Orange', $null)
            $style.AddToProfiles()

            [PSColorStyle]::Profiles.ContainsKey('CustomProfile') | Should -Be $true
            [PSColorStyle]::Profiles['CustomProfile'].Name | Should -Be 'CustomProfile'
        }

        It 'Overwrites existing profile with same name' {
            $style1 = [PSColorStyle]::new('TestProfile', 'Red', $null)
            $style1.AddToProfiles()

            $style2 = [PSColorStyle]::new('TestProfile', 'Blue', $null)
            $style2.AddToProfiles()

            [PSColorStyle]::Profiles['TestProfile'].ForegroundColor | Should -Be 'Blue'
        }
    }

    Context 'GetProfile Static Method' {
        BeforeAll {
            $testStyle = [PSColorStyle]::new('GetProfileTest', 'Cyan', $null)
            $testStyle.AddToProfiles()
        }

        It 'Retrieves existing profile by name' {
            $retrieved = [PSColorStyle]::GetProfile('GetProfileTest')

            $retrieved | Should -Not -BeNullOrEmpty
            $retrieved.Name | Should -Be 'GetProfileTest'
            $retrieved.ForegroundColor | Should -Be 'Cyan'
        }

        It 'Returns null for non-existent profile' {
            $retrieved = [PSColorStyle]::GetProfile('NonExistentProfile')

            $retrieved | Should -BeNullOrEmpty
        }

        It 'Retrieves built-in Error profile' {
            $errorProfile = [PSColorStyle]::GetProfile('Error')

            $errorProfile | Should -Not -BeNullOrEmpty
            $errorProfile.Name | Should -Be 'Error'
            $errorProfile.ForegroundColor | Should -Be 'Red'
            $errorProfile.Bold | Should -Be $true
        }
    }

    Context 'ToWriteColorParams Method' {
        It 'Returns hashtable with color properties' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', 'Blue')
            $params = $style.ToWriteColorParams()

            $params | Should -BeOfType [hashtable]
            $params['Color'] | Should -Be 'Red'
            $params['BackGroundColor'] | Should -Be 'Blue'
        }

        It 'Includes Bold when set to true' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.Bold = $true
            $params = $style.ToWriteColorParams()

            $params.ContainsKey('Bold') | Should -Be $true
            $params['Bold'] | Should -Be $true
        }

        It 'Excludes Bold when set to false' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.Bold = $false
            $params = $style.ToWriteColorParams()

            $params.ContainsKey('Bold') | Should -Be $false
        }

        It 'Includes multiple style properties' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.Bold = $true
            $style.Italic = $true
            $style.Underline = $true
            $params = $style.ToWriteColorParams()

            $params['Bold'] | Should -Be $true
            $params['Italic'] | Should -Be $true
            $params['Underline'] | Should -Be $true
        }

        It 'Includes formatting properties when set' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.StartTab = 2
            $style.LinesBefore = 1
            $style.LinesAfter = 1
            $params = $style.ToWriteColorParams()

            $params['StartTab'] | Should -Be 2
            $params['LinesBefore'] | Should -Be 1
            $params['LinesAfter'] | Should -Be 1
        }

        It 'Excludes formatting properties when zero' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $params = $style.ToWriteColorParams()

            $params.ContainsKey('StartTab') | Should -Be $false
            $params.ContainsKey('LinesBefore') | Should -Be $false
            $params.ContainsKey('LinesAfter') | Should -Be $false
        }

        It 'Includes Gradient when set' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.Gradient = @('Red', 'Blue')
            $params = $style.ToWriteColorParams()

            $params.ContainsKey('Gradient') | Should -Be $true
            $params['Gradient'].Count | Should -Be 2
        }

        It 'Excludes Gradient when less than 2 colors' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.Gradient = @('Red')
            $params = $style.ToWriteColorParams()

            $params.ContainsKey('Gradient') | Should -Be $false
        }

        It 'Caches parameters for performance' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $style.Bold = $true

            $params1 = $style.ToWriteColorParams()
            $params2 = $style.ToWriteColorParams()

            # Both should have the same values but be different instances (cloned)
            $params1['Bold'] | Should -Be $params2['Bold']
            $params1 -eq $params2 | Should -Be $false
        }

        It 'Returns clone to prevent external modification' {
            $style = [PSColorStyle]::new('TestStyle', 'Red', $null)
            $params = $style.ToWriteColorParams()

            # Modify returned params
            $params['Color'] = 'Blue'

            # Original should still be Red
            $params2 = $style.ToWriteColorParams()
            $params2['Color'] | Should -Be 'Red'
        }
    }

    Context 'Clone Method' {
        It 'Creates a copy of the style' {
            $original = [PSColorStyle]::new('Original', 'Red', 'Blue')
            $original.Bold = $true
            $original.StartTab = 2

            $clone = $original.Clone()

            $clone.Name | Should -Be 'Original_Copy'
            $clone.ForegroundColor | Should -Be 'Red'
            $clone.BackgroundColor | Should -Be 'Blue'
            $clone.Bold | Should -Be $true
            $clone.StartTab | Should -Be 2
        }

        It 'Creates independent copy that can be modified' {
            $original = [PSColorStyle]::new('Original', 'Red', $null)
            $clone = $original.Clone()

            $clone.ForegroundColor = 'Blue'

            $original.ForegroundColor | Should -Be 'Red'
            $clone.ForegroundColor | Should -Be 'Blue'
        }

        It 'Clone does not share cached parameters' {
            $original = [PSColorStyle]::new('Original', 'Red', $null)
            $original.Bold = $true

            # Warm cache
            $null = $original.ToWriteColorParams()

            $clone = $original.Clone()

            # Clone should have null cache initially
            $clone.Bold = $false
            $params = $clone.ToWriteColorParams()
            $params.ContainsKey('Bold') | Should -Be $false
        }

        It 'Copies all style properties' {
            $original = [PSColorStyle]::new('Original', 'Red', 'Blue')
            $original.Bold = $true
            $original.Italic = $true
            $original.Underline = $true
            $original.Blink = $true
            $original.Faint = $true
            $original.CrossedOut = $true
            $original.DoubleUnderline = $true
            $original.Overline = $true

            $clone = $original.Clone()

            $clone.Bold | Should -Be $true
            $clone.Italic | Should -Be $true
            $clone.Underline | Should -Be $true
            $clone.Blink | Should -Be $true
            $clone.Faint | Should -Be $true
            $clone.CrossedOut | Should -Be $true
            $clone.DoubleUnderline | Should -Be $true
            $clone.Overline | Should -Be $true
        }

        It 'Copies Gradient array' {
            $original = [PSColorStyle]::new('Original', 'Red', $null)
            $original.Gradient = @('Red', 'Blue', 'Green')

            $clone = $original.Clone()

            $clone.Gradient.Count | Should -Be 3
            $clone.Gradient[0] | Should -Be 'Red'
            $clone.Gradient[1] | Should -Be 'Blue'
            $clone.Gradient[2] | Should -Be 'Green'
        }
    }

    Context 'InitializeDefaultProfiles Static Method' {
        It 'Initializes all default profiles' {
            # This is called during module load, so profiles should exist
            [PSColorStyle]::Profiles.Count | Should -BeGreaterOrEqual 7
        }

        It 'Error profile has correct properties' {
            $errorProfile = [PSColorStyle]::GetProfile('Error')

            $errorProfile.Name | Should -Be 'Error'
            $errorProfile.ForegroundColor | Should -Be 'Red'
            $errorProfile.Bold | Should -Be $true
        }

        It 'Warning profile has correct properties' {
            $warningProfile = [PSColorStyle]::GetProfile('Warning')

            $warningProfile.Name | Should -Be 'Warning'
            $warningProfile.ForegroundColor | Should -Be 'Yellow'
        }

        It 'Info profile has correct properties' {
            $infoProfile = [PSColorStyle]::GetProfile('Info')

            $infoProfile.Name | Should -Be 'Info'
            $infoProfile.ForegroundColor | Should -Be 'Cyan'
        }

        It 'Success profile has correct properties' {
            $successProfile = [PSColorStyle]::GetProfile('Success')

            $successProfile.Name | Should -Be 'Success'
            $successProfile.ForegroundColor | Should -Be 'Green'
        }

        It 'Critical profile has correct properties' {
            $criticalProfile = [PSColorStyle]::GetProfile('Critical')

            $criticalProfile.Name | Should -Be 'Critical'
            $criticalProfile.ForegroundColor | Should -Be 'White'
            $criticalProfile.BackgroundColor | Should -Be 'DarkRed'
            $criticalProfile.Bold | Should -Be $true
            $criticalProfile.Blink | Should -Be $true
        }

        It 'Debug profile has correct properties' {
            $debugProfile = [PSColorStyle]::GetProfile('Debug')

            $debugProfile.Name | Should -Be 'Debug'
            $debugProfile.ForegroundColor | Should -Be 'DarkGray'
            $debugProfile.Italic | Should -Be $true
        }

        It 'Default profile cache is pre-warmed' {
            # Default profiles should have cached params
            $defaultProfile = [PSColorStyle]::GetProfile('Default')
            $params = $defaultProfile.ToWriteColorParams()

            $params | Should -Not -BeNullOrEmpty
        }
    }

    # NEW TESTS: InvalidateCache Method
    Context 'Cache Invalidation' {
        It 'InvalidateCache clears cached parameters' {
            $style = [PSColorStyle]::new('Test', 'Red', $null)

            # Force cache population by calling ToWriteColorParams
            $null = $style.ToWriteColorParams()

            # Verify cache was populated (internal property)
            $style._cachedParams | Should -Not -BeNullOrEmpty

            # Invalidate cache
            $style.InvalidateCache()

            # Verify cache is cleared
            $style._cachedParams | Should -BeNullOrEmpty
        }

        It 'Cache regenerates after invalidation' {
            $style = [PSColorStyle]::new('Test', 'Blue', 'Yellow')

            # Populate cache
            $params1 = $style.ToWriteColorParams()
            $params1 | Should -Not -BeNullOrEmpty

            # Invalidate cache
            $style.InvalidateCache()

            # Cache should regenerate on next call
            $params2 = $style.ToWriteColorParams()
            $params2 | Should -Not -BeNullOrEmpty
            $params2.Count | Should -BeGreaterThan 0
        }

        It 'Changing property and invalidating cache allows regeneration' {
            $style = [PSColorStyle]::new('Test', 'Red', $null)

            # Populate cache
            $params1 = $style.ToWriteColorParams()
            $params1.ContainsKey('Bold') | Should -Be $false

            # Change a property and invalidate
            $style.Bold = $true
            $style.InvalidateCache()

            # Cache should regenerate with new value
            $params2 = $style.ToWriteColorParams()
            $params2.ContainsKey('Bold') | Should -Be $true
            $params2.Bold | Should -Be $true
        }

        It 'Changing ForegroundColor and invalidating cache works' {
            $style = [PSColorStyle]::new('Test', 'Red', $null)

            # Populate cache
            $params1 = $style.ToWriteColorParams()
            $params1.Color | Should -Be 'Red'

            # Change ForegroundColor and invalidate
            $style.ForegroundColor = 'Blue'
            $style.InvalidateCache()

            # Cache should regenerate
            $params2 = $style.ToWriteColorParams()
            $params2.Color | Should -Be 'Blue'
        }

        It 'Changing BackgroundColor and invalidating cache works' {
            $style = [PSColorStyle]::new('Test', 'Red', 'Yellow')

            # Populate cache
            $params1 = $style.ToWriteColorParams()
            $params1.BackGroundColor | Should -Be 'Yellow'

            # Change BackgroundColor and invalidate
            $style.BackgroundColor = 'Green'
            $style.InvalidateCache()

            # Cache should regenerate
            $params2 = $style.ToWriteColorParams()
            $params2.BackGroundColor | Should -Be 'Green'
        }

        It 'Changing multiple properties and invalidating cache works' {
            $style = [PSColorStyle]::new('Test', 'Red', $null)

            # Populate cache
            $params1 = $style.ToWriteColorParams()

            # Change multiple properties and invalidate
            $style.Bold = $true
            $style.Italic = $true
            $style.Underline = $true
            $style.StartTab = 2
            $style.InvalidateCache()

            # Cache should regenerate with all new values
            $params2 = $style.ToWriteColorParams()
            $params2.Bold | Should -Be $true
            $params2.Italic | Should -Be $true
            $params2.Underline | Should -Be $true
            $params2.StartTab | Should -Be 2
        }

        It 'SetAsDefault does not break cache' {
            $style = [PSColorStyle]::new('Test', 'Cyan', $null)
            $style.Bold = $true

            # Populate cache
            $params1 = $style.ToWriteColorParams()

            # Set as default
            $style.SetAsDefault()

            # Cache should still work
            $params2 = $style.ToWriteColorParams()
            $params2 | Should -Not -BeNullOrEmpty
            $params2.Bold | Should -Be $true
        }

        It 'AddToProfiles does not break cache' {
            $style = [PSColorStyle]::new('CacheTest', 'Magenta', $null)
            $style.Italic = $true

            # Populate cache
            $params1 = $style.ToWriteColorParams()

            # Add to profiles
            $style.AddToProfiles()

            # Cache should still work
            $params2 = $style.ToWriteColorParams()
            $params2 | Should -Not -BeNullOrEmpty
            $params2.Italic | Should -Be $true

            # Cleanup
            [PSColorStyle]::Profiles.Remove('CacheTest')
        }

        It 'Clone creates new instance without shared cache' {
            $original = [PSColorStyle]::new('Original', 'Red', $null)
            $original.Bold = $true

            # Populate original cache
            $null = $original.ToWriteColorParams()
            $original._cachedParams | Should -Not -BeNullOrEmpty

            # Clone should have null cache initially
            $clone = $original.Clone()
            $clone._cachedParams | Should -BeNullOrEmpty

            # Changing clone and invalidating should not affect original cache
            $clone.Bold = $false
            $clone.InvalidateCache()
            $cloneParams = $clone.ToWriteColorParams()

            # Original cache should still have Bold = true
            $originalParams = $original.ToWriteColorParams()
            $originalParams.Bold | Should -Be $true
            $cloneParams.ContainsKey('Bold') | Should -Be $false  # Bold = $false means key not included
        }
    }
}
