@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSWriteColorEX.psm1'

    # Version number of this module.
    ModuleVersion = '1.2.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'a7b8f4e5-9c2d-4f16-8e3a-1b9d2c5e7f3a'

    # Author of this module
    Author = 'Mark Newton'

    # Company or vendor of this module
    CompanyName = 'Variably Constant'

    # Copyright statement for this module
    Copyright = '(c) 2026 Mark Newton'

    # Description of the functionality provided by this module
    Description = 'Colored and styled console output for PowerShell: TrueColor (24-bit RGB), ANSI 256 and 16 colors, gradients, markup, highlighting, links, text styles, style profiles, padding and wrapping that count wide characters, and logging to a file. Pure PowerShell, for Windows PowerShell 5.1 and PowerShell 7 on Windows, Linux and macOS.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Write-ColorEX',
        'Write-ColorError',
        'Write-ColorWarning',
        'Write-ColorInfo',
        'Write-ColorSuccess',
        'Write-ColorCritical',
        'Write-ColorDebug',
        'Set-ColorDefault',
        'Get-ColorProfiles',
        'New-ColorStyle',
        'Test-AnsiSupport',
        'Convert-HexToRGB',
        'Convert-RGBToANSI8',
        'Convert-RGBToANSI4',
        'Get-ColorTableWithRGB',
        'Measure-DisplayWidth',
        'Get-LighterRGBColor',
        'Get-LighterColorName',
        'Get-LighterANSI8Color',
        'Format-ColorEX',
        'Show-ColorTable',
        'Register-ColorName',
        'Unregister-ColorName',
        'Export-ColorProfile',
        'Import-ColorProfile',
        'Remove-ColorProfile'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        # Write-ColorEX aliases
        'Write-ColourEX', 'Write-Color', 'Write-Colour', 'WC', 'WCEX', 'wcolor', 'wcolour',
        # Write-ColorError aliases
        'WCE', 'Write-ErrorColor', 'Write-ErrorColour', 'Write-ColourError', 'WError', 'wcerror',
        # Write-ColorWarning aliases
        'WCW', 'Write-WarningColor', 'Write-WarningColour', 'Write-ColourWarning', 'WWarning', 'WCWarn', 'wcwarning',
        # Write-ColorInfo aliases
        'WCI', 'Write-InfoColor', 'Write-InfoColour', 'Write-ColourInfo', 'WInfo', 'wcinfo',
        # Write-ColorSuccess aliases
        'WCS', 'Write-SuccessColor', 'Write-SuccessColour', 'Write-ColourSuccess', 'WSuccess', 'wcok', 'wcsuccess',
        # Write-ColorCritical aliases
        'WCC', 'Write-CriticalColor', 'Write-CriticalColour', 'Write-ColourCritical', 'WCritical', 'wccritical',
        # Write-ColorDebug aliases
        'WCD', 'Write-DebugColor', 'Write-DebugColour', 'Write-ColourDebug', 'WDebug', 'wcdebug',
        # Set-ColorDefault aliases
        'SCD', 'Set-ColourDefault', 'Set-DefaultColor', 'Set-DefaultColour',
        # Get-ColorProfiles aliases
        'GCP', 'Get-ColourProfiles', 'Get-Profiles', 'gcprofiles',
        # New-ColorStyle aliases
        'NCS', 'New-ColourStyle', 'New-Style', 'ncstyle',
        # Test-AnsiSupport aliases
        'TAS', 'Test-ANSI',
        # Convert-HexToRGB aliases
        'CHR', 'Hex2RGB',
        # Convert-RGBToANSI8 aliases
        'CRA8', 'RGB2ANSI8',
        # Convert-RGBToANSI4 aliases
        'CRA4', 'RGB2ANSI4',
        # Get-ColorTableWithRGB aliases
        'GCT', 'Get-ColorTable', 'Get-ColourTable',
        # Measure-DisplayWidth aliases
        'MDW', 'Get-DisplayWidth',
        # Get-LighterRGBColor aliases
        'Lighten-RGBColor',
        # Get-LighterColorName aliases
        'Lighten-ColorName',
        # Get-LighterANSI8Color aliases
        'Lighten-ANSI8Color', 'LA8', 'Lighten-ANSI8',
        # Format-ColorEX aliases
        'Format-ColourEX', 'FCEX',
        # Show-ColorTable aliases
        'Show-ColourTable',
        # Register-ColorName and Unregister-ColorName aliases
        'Register-ColourName', 'Unregister-ColourName',
        # Export-ColorProfile, Import-ColorProfile and Remove-ColorProfile aliases
        'Export-ColourProfile', 'Import-ColourProfile', 'Remove-ColourProfile'
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                'Console',
                'Color',
                'Colour',
                'ANSI',
                'Terminal',
                'Output',
                'Formatting',
                'Logging',
                'TrueColor',
                'RGB',
                'CrossPlatform',
                'Windows',
                'Linux',
                'macOS',
                'PSEdition_Desktop',
                'PSEdition_Core'
            )

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/MarkusMcNugen/PSWriteColorEX/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/MarkusMcNugen/PSWriteColorEX'

            # ReleaseNotes of this module
            ReleaseNotes = @'
1.2.0

Added:
- Write-ColorEX -Markup: tags that color and style part of a string, such as '[bold red]Error:[/] file not found'.
- -Split, -SplitAround and -SplitEvenly color parts of a string without giving it in pieces.
- -Highlight colors and styles the text regular expressions match.
- -Link writes links that terminals open when clicked.
- -Reverse, -UnderlineStyle (single, double, curly, dotted, dashed) and -UnderlineColor.
- -BackGroundGradient, and -GradientSpace OKLab or RGB.
- -Truncate, -PadCenter and -Wrap.
- Colors in the forms #RGB, rgb(r, g, b) and hsl(h, s%, l%).
- Format-ColorEX answers colored text as strings; Show-ColorTable shows every color name.
- Register-ColorName and Unregister-ColorName; Export-ColorProfile, Import-ColorProfile and Remove-ColorProfile.
- Tab completion of color and profile names.
- Detection of Ghostty, WezTerm, Warp, Kitty, Alacritty, foot, JetBrains IDEs and tmux; CLICOLOR_FORCE and CLICOLOR.

Changed:
- Gradients blend in OKLab; -GradientSpace RGB gives the 1.1.0 colors.
- An unknown color name gives a warning and no color.
- -Gradient writes -BackGroundColor under the gradient.
- Write-ColorEX takes 38% to 60% less time per call than 1.1.0.
- FORCE_COLOR and CLICOLOR_FORCE write a line of color names as escape codes in every host, so the colors reach a CI log.

Fixed:
- -Color and -BackGroundColor take $null entries.
- Set-ColorDefault with no parameters makes the default style plain Gray.
- With -ANSI8 or -ANSI4, a hex, rgb() or hsl() color is written as the nearest color of that mode.
- PowerShell 7 in the Windows console host lightens -Bold colors, as Windows PowerShell 5.1 does there.

The full list is in CHANGELOG.md: https://github.com/MarkusMcNugen/PSWriteColorEX/blob/main/CHANGELOG.md
'@

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/MarkusMcNugen/PSWriteColorEX'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}