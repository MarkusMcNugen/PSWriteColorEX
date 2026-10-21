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
$script:CustomColors = [ordered]@{}  # The color names Register-ColorName added, by name
$script:CaptureLines = $null        # The list Format-ColorEX collects Write-ColorEX's lines in

if ($script:DebugMode) {
    Write-Verbose "PSWriteColorEX Debug Mode Enabled" -Verbose
}

function Get-ColorSourceScript {
    <#
    .SYNOPSIS
        Parses one of the module's files for this import alone and returns it as a script block
    .DESCRIPTION
        PowerShell compiles a file dot-sourced by its path once for the whole process and gives
        every runspace that imports the module that one compiled copy, classes and all. Parsing
        each file here gives this runspace a copy of its own, so nothing it defines runs in, or
        waits on, another runspace.
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param([Parameter(Mandatory)][string] $Path)

    $tokens = $null
    $errors = $null
    $syntax = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) {
        throw "$($errors[0].Message) (line $($errors[0].Extent.StartLineNumber))"
    }
    return $syntax.GetScriptBlock()
}

# Classes load before the functions that use them
$ClassFiles = @(
    [System.IO.Path]::Combine($PSScriptRoot, 'Classes', 'ColorMath.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Classes', 'ColorCode.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Classes', 'PSColorStyle.ps1')
)

foreach ($file in $ClassFiles) {
    if (Test-Path -LiteralPath $file) {
        try {
            . (Get-ColorSourceScript -Path $file)
            if ($script:DebugMode) {
                Write-Verbose "Loaded class file: $file" -Verbose
            }
        } catch {
            Write-Error "Failed to load class file: $file. Error: $_"
        }
    }
}

# PSColorStyle: one type for the whole process, named [PSColorStyle] in every session
$StyleType = Get-ColorStyleType
$StyleKey = Register-ColorStyleType -Type $StyleType

$PrivateFunctions = @(
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'DisplayWidthTable.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'ColorHost.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'Get-ColorHelperParams.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'New-GradientColorArray.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'GradientNames.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'WriteColorCore.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'ColorNames.ps1')
    [System.IO.Path]::Combine($PSScriptRoot, 'Private', 'ArgumentCompleters.ps1')
)

foreach ($file in $PrivateFunctions) {
    if (Test-Path -LiteralPath $file) {
        try {
            . (Get-ColorSourceScript -Path $file)
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
    [System.IO.Path]::Combine($PSScriptRoot, 'Public', 'Get-GradientColor.ps1')
)

foreach ($file in $PublicFunctions) {
    if (Test-Path -LiteralPath $file) {
        try {
            . (Get-ColorSourceScript -Path $file)
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
        'Remove-ColorProfile',
        'Get-GradientColor',
        'Get-ColorContrast'
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
        'Export-ColourProfile', 'Import-ColourProfile', 'Remove-ColourProfile',
        # Get-GradientColor aliases
        'Get-GradientColour',
        # Get-ColorContrast aliases
        'Get-ColourContrast'
    )

    Variable = @()
}

Export-ModuleMember @ExportParams

# Removing the module drops this runspace's script block for PSColorStyle's methods; the last
# import in the process to go takes the name [PSColorStyle] away
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [System.AppDomain]::CurrentDomain.SetData($StyleKey, $null)
    $imports = $StyleType.GetMethod('Leave', [System.Reflection.BindingFlags]'NonPublic, Static').Invoke($null, $null)
    $accelerators = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $named = $accelerators::Get
    if ($imports -le 0 -and $named.ContainsKey('PSColorStyle') -and [object]::ReferenceEquals($named['PSColorStyle'], $StyleType)) {
        $null = $accelerators::Remove('PSColorStyle')
    }
}.GetNewClosure()
