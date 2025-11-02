#Requires -Version 5.1

<#
.SYNOPSIS
    PSWriteColorEX - Advanced colored console output module with comprehensive ANSI support

.DESCRIPTION
    PSWriteColorEX is an advanced PowerShell module providing enhanced colored console output
    with comprehensive ANSI support including TrueColor (24-bit RGB), style profiles,
    cross-platform compatibility, and extensive logging capabilities.

    KEY FEATURES:
    - TrueColor (24-bit RGB) support for 16.7 million colors
    - Multi-stop gradient colors with smooth transitions
    - Unicode-aware text padding (AutoPad) for perfect table alignment
    - Style profiles for consistent output (Error, Warning, Info, Success, Critical, Debug)
    - Automatic terminal detection with graceful color degradation
    - Cross-platform: Windows, Linux, macOS
    - Bold font support detection and automatic color lightening
    - Comprehensive logging with timestamps and log levels
    - Performance optimized with caching (1000x-18000x improvements)

    TERMINAL SUPPORT:
    - Windows: Windows Terminal, PowerShell Console, ConEmu, VS Code, Git Bash
    - macOS: iTerm2, Terminal.app, VS Code
    - Linux: GNOME Terminal, Konsole, xterm, rxvt-unicode, Kitty

.NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later
    Compatible: PowerShell Desktop and Core editions

    Module initialization automatically detects terminal capabilities and caches results
    for optimal performance.

.LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

.EXAMPLE
    Import-Module PSWriteColorEX
    Write-ColorEX "Hello World" -Color Green -Bold

.EXAMPLE
    Write-ColorError "Operation failed"
    Write-ColorSuccess "Completed successfully"

.EXAMPLE
    Write-ColorEX "GRADIENT" -Gradient @('Red','Yellow','Green','Cyan','Blue','Magenta')
#>

# Module variables
$script:ModuleRoot = $PSScriptRoot
$script:ModuleVersion = '1.0.0'
$script:DebugMode = $false
$script:CachedANSISupport = $null  # Cached ANSI support level for performance
$script:SupportsBoldFonts = $false  # Cached bold font support detection
$script:CachedColorTable = $null  # Cached color table for performance
$script:CachedHelperStyles = @{}  # Cached helper function style params
$script:RGB6LevelLookup = $null   # Lookup table for RGB to 6-level conversion

# Enable debug mode if requested
if ($env:PSWRITECOLOREX_DEBUG -eq 'true') {
    $script:DebugMode = $true
    Write-Verbose "PSWriteColorEX Debug Mode Enabled" -Verbose
}

# Initialize RGB to 6-level lookup table for ANSI8 conversion
function Initialize-RGB6LevelLookup {
    if ($null -eq $script:RGB6LevelLookup) {
        $script:RGB6LevelLookup = [int[]]::new(256)
        for ($i = 0; $i -lt 256; $i++) {
            $script:RGB6LevelLookup[$i] = if ($i -lt 48) { 0 }
                elseif ($i -lt 115) { 1 }
                elseif ($i -lt 155) { 2 }
                elseif ($i -lt 195) { 3 }
                elseif ($i -lt 235) { 4 }
                else { 5 }
        }
    }
}

# Initialize the lookup table
Initialize-RGB6LevelLookup

# Load classes first (they need to be loaded before functions that use them)
$ClassFiles = @(
    "$PSScriptRoot\Classes\PSColorStyle.ps1"
)

foreach ($file in $ClassFiles) {
    if (Test-Path $file) {
        try {
            . $file
            if ($script:DebugMode) {
                Write-Verbose "Loaded class file: $file" -Verbose
            }
        } catch {
            Write-Error "Failed to load class file: $file. Error: $_"
        }
    }
}

# Load private functions (hardcoded for faster loading)
$PrivateFunctions = @(
    "$PSScriptRoot\Private\New-GradientColorArray.ps1"
)

foreach ($file in $PrivateFunctions) {
    if (Test-Path $file) {
        try {
            . $file
            if ($script:DebugMode) {
                Write-Verbose "Loaded private function: $(Split-Path $file -Leaf)" -Verbose
            }
        } catch {
            Write-Error "Failed to load private function: $(Split-Path $file -Leaf). Error: $_"
        }
    } else {
        Write-Warning "Private function file not found: $file"
    }
}

# Load public functions (hardcoded for faster loading)
$PublicFunctions = @(
    "$PSScriptRoot\Public\Test-AnsiSupport.ps1"
    "$PSScriptRoot\Public\Convert-ColorValue.ps1"
    "$PSScriptRoot\Public\Write-ColorEX.ps1"
    "$PSScriptRoot\Public\Write-ColorHelpers.ps1"
    "$PSScriptRoot\Public\Measure-DisplayWidth.ps1"
)

foreach ($file in $PublicFunctions) {
    if (Test-Path $file) {
        try {
            . $file
            if ($script:DebugMode) {
                Write-Verbose "Loaded public function: $(Split-Path $file -Leaf)" -Verbose
            }
        } catch {
            Write-Error "Failed to load public function: $(Split-Path $file -Leaf). Error: $_"
        }
    } else {
        Write-Warning "Public function file not found: $file"
    }
}

# Initialize default color profiles
try {
    [PSColorStyle]::InitializeDefaultProfiles()
    if ($script:DebugMode) {
        Write-Verbose "Initialized default color profiles" -Verbose
    }
} catch {
    Write-Warning "Could not initialize default color profiles: $_"
}

# Module initialization
$script:ModuleInitialized = $false

function Initialize-PSWriteColorEX {
    <#
    .SYNOPSIS
        Initializes the PSWriteColorEX module
    .DESCRIPTION
        Performs module initialization tasks including ANSI support detection
    #>
    [CmdletBinding()]
    param()
    
    if ($script:ModuleInitialized) {
        return
    }
    
    # Detect initial ANSI support and cache it
    $ansiResult = Test-AnsiSupport -Silent
    $script:CachedANSISupport = $ansiResult.ColorSupport
    $script:SupportsBoldFonts = $ansiResult.SupportsBoldFonts

    if ($script:DebugMode) {
        Write-Verbose "Module initialized with ANSI support level: $script:CachedANSISupport" -Verbose
        Write-Verbose "Bold font support: $script:SupportsBoldFonts" -Verbose
    }

    # Set module initialization flag
    $script:ModuleInitialized = $true

    # Display module banner if in interactive mode and not suppressed
    if ($Host.UI.RawUI -and -not $env:PSWRITECOLOREX_NO_BANNER) {
        Write-ColorEX -Text "PSWriteColorEX v$script:ModuleVersion loaded" -Color Cyan -Italic

        if ($script:CachedANSISupport -eq 'TrueColor') {
            Write-ColorEX -Text "TrueColor support detected - 16.7 million colors available!" -Color @(0, 255, 128) -TrueColor
        } elseif ($script:CachedANSISupport -eq 'ANSI8') {
            Write-ColorEX -Text "256-color support detected" -Color 208 -ANSI8
        } elseif ($script:CachedANSISupport -eq 'ANSI4') {
            Write-ColorEX -Text "16-color ANSI support detected" -Color Yellow -ANSI4
        } else {
            Write-Host "Basic console colors available" -ForegroundColor Gray
        }
    }
}

# Initialize module
Initialize-PSWriteColorEX

# Export module members
$ExportParams = @{
    Function = @(
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
    
    Alias = @(
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
    
    Variable = @()
}

Export-ModuleMember @ExportParams

# Module removal cleanup
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    # Clean up any module resources
    if ($script:DebugMode) {
        Write-Verbose "PSWriteColorEX module removed" -Verbose
    }
}