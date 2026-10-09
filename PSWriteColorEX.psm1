#Requires -Version 5.1

<#
.SYNOPSIS
    PSWriteColorEX - colored and styled console output with ANSI and TrueColor support

.DESCRIPTION
    PSWriteColorEX writes colored and styled text through Write-Host:

    - TrueColor (24-bit RGB), ANSI 256-color and 16-color modes, and the console's own colors
    - Gradients across the characters of a line
    - Padding to a display width (AutoPad) that counts emoji and CJK characters as 2 cells
    - Style profiles: Error, Warning, Info, Success, Critical, Debug, and custom ones
    - Detection of the terminal's color support, falling back to the modes it has
    - Windows, Linux and macOS, in Windows PowerShell 5.1 and PowerShell 7
    - Logging to a file, with timestamps and levels

.NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later
    Compatible: PowerShell Desktop and Core editions

    Importing the module detects the terminal's color support once and keeps the result.

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

$script:ModuleRoot = $PSScriptRoot
$script:DebugMode = $env:PSWRITECOLOREX_DEBUG -eq 'true'
$script:CachedANSISupport = $null   # The terminal's color support, detected at import
$script:SupportsBoldFonts = $false  # Whether the terminal draws bold as a bold font
$script:CachedColorTable = $null    # The color table, built on first use
$script:RGB6LevelLookup = $null     # Each 0-255 channel value's step in the 6-step RGB cube
$script:CustomColors = [ordered]@{}  # The color names Register-ColorName added, by name
$script:CaptureLines = $null        # The list Format-ColorEX collects Write-ColorEX's lines in

if ($script:DebugMode) {
    Write-Verbose "PSWriteColorEX Debug Mode Enabled" -Verbose
}

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

Initialize-RGB6LevelLookup

# Classes load before the functions that use them
$ClassFiles = @(
    [System.IO.Path]::Combine($PSScriptRoot, 'Classes', 'ColorMath.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Classes', 'ColorCode.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Classes', 'PSColorStyle.ps1')
)

foreach ($file in $ClassFiles) {
    if (Test-Path -LiteralPath $file) {
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

$PrivateFunctions = @(
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'DisplayWidthTable.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'ColorHost.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'Get-ColorHelperParams.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'New-GradientColorArray.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'WriteColorCore.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'ColorNames.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'ArgumentCompleters.ps1')
)

foreach ($file in $PrivateFunctions) {
    if (Test-Path -LiteralPath $file) {
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

$PublicFunctions = @(
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Test-AnsiSupport.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Convert-ColorValue.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Write-ColorEX.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Format-ColorEX.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'ColorNames.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'ColorProfiles.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Write-ColorHelpers.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Measure-DisplayWidth.ps1')
)

foreach ($file in $PublicFunctions) {
    if (Test-Path -LiteralPath $file) {
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

try {
    [PSColorStyle]::InitializeDefaultProfiles()
    if ($script:DebugMode) {
        Write-Verbose "Initialized default color profiles" -Verbose
    }
} catch {
    Write-Warning "Could not initialize default color profiles: $_"
}

# A class defined in a module is not visible to the session that imports it, only to scripts
# with 'using module'. A type accelerator makes [PSColorStyle] resolve after Import-Module too,
# and is removed with the module.
$TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$ExportableTypes = @([PSColorStyle])
foreach ($Type in $ExportableTypes) {
    $TypeAcceleratorsClass::Add($Type.FullName, $Type)
}

$script:ModuleInitialized = $false

function Initialize-PSWriteColorEX {
    <#
    .SYNOPSIS
        Detects the terminal's color support once and keeps the result for Write-ColorEX
    #>
    [CmdletBinding()]
    param()

    if ($script:ModuleInitialized) {
        return
    }

    $ansiResult = Test-AnsiSupport -Silent
    $script:CachedANSISupport = $ansiResult.ColorSupport
    $script:SupportsBoldFonts = $ansiResult.SupportsBoldFonts

    if ($script:DebugMode) {
        Write-Verbose "Module initialized with ANSI support level: $script:CachedANSISupport" -Verbose
        Write-Verbose "Bold font support: $script:SupportsBoldFonts" -Verbose
    }

    $script:ModuleInitialized = $true
}

Initialize-PSWriteColorEX

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

    Variable = @()
}

Export-ModuleMember @ExportParams

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach ($Type in $ExportableTypes) {
        $null = $TypeAcceleratorsClass::Remove($Type.FullName)
    }
}.GetNewClosure()
