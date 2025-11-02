@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSWriteColorEX.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'a7b8f4e5-9c2d-4f16-8e3a-1b9d2c5e7f3a'

    # Author of this module
    Author = 'MarkusMcNugen'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = '(c) 2024 MarkusMcNugen. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Advanced PowerShell module for colored console output with comprehensive ANSI support including TrueColor (24-bit RGB), style profiles, cross-platform compatibility, and extensive logging capabilities.'

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
        'Lighten-RGBColor',
        'Lighten-ColorName',
        'Lighten-ANSI8Color'
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
        # Lighten-ANSI8Color aliases
        'LA8', 'Lighten-ANSI8'
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

            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/MarkusMcNugen/PSWriteColorEX/main/icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = @'
PSWriteColorEX - Advanced colored console output with comprehensive ANSI support

FEATURES:
- TrueColor (24-bit RGB) support with 16.7 million colors
- Multi-stop gradient colors with character-by-character interpolation
- Unicode-aware text padding (AutoPad) for perfect table alignment
- Style profiles: Error, Warning, Info, Success, Critical, Debug
- Automatic terminal detection with graceful color degradation
- Cross-platform: Windows, Linux, macOS
- Bold font support detection with automatic color lightening
- Comprehensive logging with timestamps and log levels
- Performance optimized with extensive caching (1000x-18000x improvements)
- Helper functions: Write-ColorError, Write-ColorWarning, Write-ColorInfo, Write-ColorSuccess, Write-ColorCritical, Write-ColorDebug
- 70+ color families with Dark/Normal/Light variants
- Hex color support (#RRGGBB format)
- RGB array support @(R, G, B)
- Default style configuration with Set-ColorDefault
- Compatible with PowerShell 5.1+ (Desktop and Core editions)

TERMINAL SUPPORT:
- Windows: Windows Terminal, PowerShell Console (conhost), ConEmu, VS Code, Git Bash
- macOS: iTerm2, Terminal.app, VS Code
- Linux: GNOME Terminal, Konsole, xterm, rxvt-unicode, Kitty

For full documentation visit: https://github.com/MarkusMcNugen/PSWriteColorEX
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