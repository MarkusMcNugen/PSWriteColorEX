@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSWriteColorEX.psm1'

    # Version number of this module.
    ModuleVersion = '1.1.0'

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
    Description = 'Colored and styled console output for PowerShell: TrueColor (24-bit RGB), ANSI 256 and 16 colors, gradients, text styles, style profiles, padding that counts wide characters, and logging to a file. Pure PowerShell, for Windows PowerShell 5.1 and PowerShell 7 on Windows, Linux and macOS.'

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
        'Get-LighterANSI8Color'
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
        'Lighten-ANSI8Color', 'LA8', 'Lighten-ANSI8'
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
1.1.0

Fixed:
- A transcript (Start-Transcript) records each line as one line, with no blank line after it, and as many blank lines as -LinesBefore and -LinesAfter ask for (issue #2). In Windows PowerShell 5.1 a line of several console colors is still one transcript line per color, as PowerShell records each Write-Host call.
- Every string piped to Write-ColorEX or a Write-Color* helper is written; only the last one was before.
- -LogFile given as a file name alone goes in the calling script's folder, or the current location at the prompt; it went in the module's own folder before. A missing log folder is created.
- -BlankLine works with output redirected, -BackGroundColor 'None' works, -Gradient alone draws the gradient, -Color 0 is black, -Style 'Bold' alone styles the first segment, and text without -Color takes the terminal's default color.
- A gradient keeps emoji whole: each character a terminal draws takes one color.
- Hex colors work without -TrueColor, color names such as Orange keep working after a call without a color mode, and -Bold keeps White text white.
- -ANSI8 color numbers take the nearest of the 16 colors on a 16-color terminal, and -ANSI4 and -ANSI8 numbers the nearest console color where the terminal has no ANSI support.
- [PSColorStyle] can be used after Import-Module, and a change to a style profile applies to its next use.

Changed:
- On PowerShell 7.2 and later, where escape codes reach the screen, each line goes to the host in one Write-Host call.
- Log files are UTF-8 without a byte order mark by default, and each -Encoding name writes the same bytes in Windows PowerShell 5.1 and PowerShell 7.
- Measure-DisplayWidth uses the table of the Rust crate unicode-width 0.2.2 and the emoji sequence rules terminals follow, with the same widths in 5.1 and 7. Characters such as a filled circle and box drawing are 1 cell, 2 with -AmbiguousAsWide.
- Importing the module prints nothing.
- Lighten-RGBColor, Lighten-ColorName and Lighten-ANSI8Color are Get-LighterRGBColor, Get-LighterColorName and Get-LighterANSI8Color, with the old names as aliases.

Added:
- TERM=dumb turns colors off, Windows Terminal under WSL is detected as TrueColor, and -Encoding takes utf8BOM, utf8NoBOM, bigendianutf32 and ansi.

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