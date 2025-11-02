# Helper functions for common Write-ColorEX operations with style profiles

function Write-ColorError {
    <#
    .SYNOPSIS
        Displays error messages using the Error style profile (red, bold)

    .DESCRIPTION
        Write-ColorError is a convenience wrapper for Write-ColorEX that applies the
        built-in Error style profile. This provides consistent error message formatting
        across your scripts with minimal code.

        The Error style uses red foreground color and bold text by default.
        Style parameters are cached for performance (2-5x faster than creating styles repeatedly).

    .PARAMETER Text
        The error message text to display. Accepts an array of strings.
        Can be passed via pipeline.

    .PARAMETER NoNewLine
        Suppresses the newline character at the end of the output.
        Useful for building output across multiple calls.

    .PARAMETER LogFile
        Path to log file for writing the error message.
        If only a filename is provided, uses current directory or $LogPath.

    .PARAMETER NoConsoleOutput
        Suppresses console output and only writes to log file.
        Only active when LogFile is specified.
        Aliases: HideConsole, NoConsole, LogOnly, LO

    .PARAMETER PassThru
        Returns the text that was written, allowing for pipeline chaining.

    .INPUTS
        System.String[]
        You can pipe text strings to this function.

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorError "Operation failed"

        Displays "Operation failed" in red bold text.

    .EXAMPLE
        Write-ColorError "Critical error" -LogFile "errors.log"

        Displays error on console and writes to errors.log file.

    .EXAMPLE
        $result = Write-ColorError "Warning" -PassThru
        # $result contains "Warning" for further processing

    .NOTES
        Author: MarkusMcNugen
        License: MIT
        Requires: PowerShell 5.1 or later

        This function uses the Error profile from [PSColorStyle]::Profiles['Error'].
        Style parameters are cached on first use for improved performance.

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX

    .LINK
        Write-ColorWarning

    .LINK
        New-ColorStyle
    #>
    [CmdletBinding()]
    [Alias('WCE', 'Write-ErrorColor', 'Write-ErrorColour', 'Write-ColourError', 'WError', 'wcerror')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [switch]$NoNewLine,
        [string]$LogFile,
        [switch]$NoConsoleOutput,
        [switch]$PassThru
    )

    # Use cached params for performance
    $cachedStyle = $script:CachedHelperStyles['Error']
    if (-not $cachedStyle) {
        $style = [PSColorStyle]::GetProfile("Error")
        if (-not $style) {
            $style = [PSColorStyle]::new("Error", "Red", $null)
            $style.Bold = $true
        }
        $script:CachedHelperStyles['Error'] = $style.ToWriteColorParams()
    }

    # Clone cached params to avoid modification
    $params = $script:CachedHelperStyles['Error'].Clone()
    $params['Text'] = $Text
    if ($NoNewLine) { $params['NoNewLine'] = $true }
    if ($LogFile) { $params['LogFile'] = $LogFile }
    if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

    Write-ColorEX @params

    if ($PassThru) {
        return $Text
    }
}

function Write-ColorWarning {
    <#
    .SYNOPSIS
        Displays warning messages using the Warning style profile (yellow)

    .DESCRIPTION
        Write-ColorWarning is a convenience wrapper for Write-ColorEX that applies the
        built-in Warning style profile for consistent warning message formatting.

        The Warning style uses yellow foreground color by default.
        Style parameters are cached for performance (2-5x faster than creating styles repeatedly).

    .PARAMETER Text
        The warning message text to display. Accepts an array of strings.
        Can be passed via pipeline.

    .PARAMETER NoNewLine
        Suppresses the newline character at the end of the output.

    .PARAMETER LogFile
        Path to log file for writing the warning message.

    .PARAMETER NoConsoleOutput
        Suppresses console output and only writes to log file.

    .PARAMETER PassThru
        Returns the text that was written.

    .INPUTS
        System.String[]

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorWarning "This action may cause data loss"

    .EXAMPLE
        Write-ColorWarning "Deprecated function used" -LogFile "warnings.log"

    .NOTES
        Author: MarkusMcNugen
        License: MIT

        Uses Warning profile from [PSColorStyle]::Profiles['Warning'].

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('WCW', 'Write-WarningColor', 'Write-WarningColour', 'Write-ColourWarning', 'WWarning', 'WCWarn', 'wcwarning')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [switch]$NoNewLine,
        [string]$LogFile,
        [switch]$NoConsoleOutput,
        [switch]$PassThru
    )

    # Use cached params for performance
    $cachedStyle = $script:CachedHelperStyles['Warning']
    if (-not $cachedStyle) {
        $style = [PSColorStyle]::GetProfile("Warning")
        if (-not $style) {
            $style = [PSColorStyle]::new("Warning", "Yellow", $null)
        }
        $script:CachedHelperStyles['Warning'] = $style.ToWriteColorParams()
    }

    # Clone cached params to avoid modification
    $params = $script:CachedHelperStyles['Warning'].Clone()
    $params['Text'] = $Text
    if ($NoNewLine) { $params['NoNewLine'] = $true }
    if ($LogFile) { $params['LogFile'] = $LogFile }
    if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

    Write-ColorEX @params

    if ($PassThru) {
        return $Text
    }
}

function Write-ColorInfo {
    <#
    .SYNOPSIS
        Displays informational messages using the Info style profile (cyan)

    .DESCRIPTION
        Write-ColorInfo applies the built-in Info style profile for consistent
        informational message formatting. Uses cyan foreground color by default.

    .PARAMETER Text
        The informational message text. Accepts string array, supports pipeline input.

    .PARAMETER NoNewLine
        Suppresses newline at end of output.

    .PARAMETER LogFile
        Log file path for writing the message.

    .PARAMETER NoConsoleOutput
        Suppresses console output, writes to log file only.

    .PARAMETER PassThru
        Returns the written text.

    .INPUTS
        System.String[]

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorInfo "Processing started..."

    .EXAMPLE
        Write-ColorInfo "User logged in" -LogFile "activity.log"

    .NOTES
        Author: MarkusMcNugen
        License: MIT

        Uses Info profile from [PSColorStyle]::Profiles['Info'].

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('WCI', 'Write-InfoColor', 'Write-InfoColour', 'Write-ColourInfo', 'WInfo', 'wcinfo')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [switch]$NoNewLine,
        [string]$LogFile,
        [switch]$NoConsoleOutput,
        [switch]$PassThru
    )

    # Use cached params for performance
    $cachedStyle = $script:CachedHelperStyles['Info']
    if (-not $cachedStyle) {
        $style = [PSColorStyle]::GetProfile("Info")
        if (-not $style) {
            $style = [PSColorStyle]::new("Info", "Cyan", $null)
        }
        $script:CachedHelperStyles['Info'] = $style.ToWriteColorParams()
    }

    # Clone cached params to avoid modification
    $params = $script:CachedHelperStyles['Info'].Clone()
    $params['Text'] = $Text
    if ($NoNewLine) { $params['NoNewLine'] = $true }
    if ($LogFile) { $params['LogFile'] = $LogFile }
    if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

    Write-ColorEX @params

    if ($PassThru) {
        return $Text
    }
}

function Write-ColorSuccess {
    <#
    .SYNOPSIS
        Displays success messages using the Success style profile (green)

    .DESCRIPTION
        Write-ColorSuccess applies the built-in Success style profile for consistent
        success message formatting. Uses green foreground color by default.

    .PARAMETER Text
        The success message text. Accepts string array, supports pipeline input.

    .PARAMETER NoNewLine
        Suppresses newline at end of output.

    .PARAMETER LogFile
        Log file path.

    .PARAMETER NoConsoleOutput
        Suppresses console output.

    .PARAMETER PassThru
        Returns the text.

    .INPUTS
        System.String[]

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorSuccess "Operation completed successfully"

    .EXAMPLE
        Write-ColorSuccess "Backup created" -LogFile "backup.log"

    .NOTES
        Author: MarkusMcNugen
        License: MIT

        Uses Success profile from [PSColorStyle]::Profiles['Success'].

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('WCS', 'Write-SuccessColor', 'Write-SuccessColour', 'Write-ColourSuccess', 'WSuccess', 'wcok', 'wcsuccess')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [switch]$NoNewLine,
        [string]$LogFile,
        [switch]$NoConsoleOutput,
        [switch]$PassThru
    )

    # Use cached params for performance
    $cachedStyle = $script:CachedHelperStyles['Success']
    if (-not $cachedStyle) {
        $style = [PSColorStyle]::GetProfile("Success")
        if (-not $style) {
            $style = [PSColorStyle]::new("Success", "Green", $null)
        }
        $script:CachedHelperStyles['Success'] = $style.ToWriteColorParams()
    }

    # Clone cached params to avoid modification
    $params = $script:CachedHelperStyles['Success'].Clone()
    $params['Text'] = $Text
    if ($NoNewLine) { $params['NoNewLine'] = $true }
    if ($LogFile) { $params['LogFile'] = $LogFile }
    if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

    Write-ColorEX @params

    if ($PassThru) {
        return $Text
    }
}

function Write-ColorCritical {
    <#
    .SYNOPSIS
        Displays critical messages using the Critical style profile (white on dark red, bold, blink)

    .DESCRIPTION
        Write-ColorCritical applies the built-in Critical style profile for high-priority alerts.
        Uses white foreground on dark red background with bold and blink styling.

    .PARAMETER Text
        The critical message text. Accepts string array, supports pipeline input.

    .PARAMETER NoNewLine
        Suppresses newline.

    .PARAMETER LogFile
        Log file path.

    .PARAMETER NoConsoleOutput
        Suppresses console output.

    .PARAMETER PassThru
        Returns the text.

    .INPUTS
        System.String[]

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorCritical "SYSTEM FAILURE - IMMEDIATE ACTION REQUIRED"

    .EXAMPLE
        Write-ColorCritical "Security breach detected" -LogFile "security.log"

    .NOTES
        Author: MarkusMcNugen
        License: MIT

        Uses Critical profile from [PSColorStyle]::Profiles['Critical'].
        Note: Blink may not work in all terminals.

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('WCC', 'Write-CriticalColor', 'Write-CriticalColour', 'Write-ColourCritical', 'WCritical', 'wccritical')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [switch]$NoNewLine,
        [string]$LogFile,
        [switch]$NoConsoleOutput,
        [switch]$PassThru
    )

    # Use cached params for performance
    $cachedStyle = $script:CachedHelperStyles['Critical']
    if (-not $cachedStyle) {
        $style = [PSColorStyle]::GetProfile("Critical")
        if (-not $style) {
            $style = [PSColorStyle]::new("Critical", "White", "DarkRed")
            $style.Bold = $true
            $style.Blink = $true
        }
        $script:CachedHelperStyles['Critical'] = $style.ToWriteColorParams()
    }

    # Clone cached params to avoid modification
    $params = $script:CachedHelperStyles['Critical'].Clone()
    $params['Text'] = $Text
    if ($NoNewLine) { $params['NoNewLine'] = $true }
    if ($LogFile) { $params['LogFile'] = $LogFile }
    if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

    Write-ColorEX @params

    if ($PassThru) {
        return $Text
    }
}

function Write-ColorDebug {
    <#
    .SYNOPSIS
        Displays debug messages using the Debug style profile (dark gray, italic)

    .DESCRIPTION
        Write-ColorDebug applies the built-in Debug style profile for debug output.
        Uses dark gray foreground with italic styling for subtle debug messages.

    .PARAMETER Text
        The debug message text. Accepts string array, supports pipeline input.

    .PARAMETER NoNewLine
        Suppresses newline.

    .PARAMETER LogFile
        Log file path.

    .PARAMETER NoConsoleOutput
        Suppresses console output.

    .PARAMETER PassThru
        Returns the text.

    .INPUTS
        System.String[]

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorDebug "Variable value: $myVar"

    .EXAMPLE
        Write-ColorDebug "Function entered: ProcessData" -LogFile "debug.log"

    .NOTES
        Author: MarkusMcNugen
        License: MIT

        Uses Debug profile from [PSColorStyle]::Profiles['Debug'].
        Note: Italic may not work in PowerShell Console (conhost.exe).

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
        Write-ColorEX
    #>
    [CmdletBinding()]
    [Alias('WCD', 'Write-DebugColor', 'Write-DebugColour', 'Write-ColourDebug', 'WDebug', 'wcdebug')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [switch]$NoNewLine,
        [string]$LogFile,
        [switch]$NoConsoleOutput,
        [switch]$PassThru
    )

    # Use cached params for performance
    $cachedStyle = $script:CachedHelperStyles['Debug']
    if (-not $cachedStyle) {
        $style = [PSColorStyle]::GetProfile("Debug")
        if (-not $style) {
            $style = [PSColorStyle]::new("Debug", "DarkGray", $null)
            $style.Italic = $true
        }
        $script:CachedHelperStyles['Debug'] = $style.ToWriteColorParams()
    }

    # Clone cached params to avoid modification
    $params = $script:CachedHelperStyles['Debug'].Clone()
    $params['Text'] = $Text
    if ($NoNewLine) { $params['NoNewLine'] = $true }
    if ($LogFile) { $params['LogFile'] = $LogFile }
    if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

    Write-ColorEX @params

    if ($PassThru) {
        return $Text
    }
}

function Set-ColorDefault {
    <#
    .SYNOPSIS
    Sets the default color style for Write-ColorEX
    
    .DESCRIPTION
    Configures the default style that will be used when Write-ColorEX is called with the -Default switch
    
    .PARAMETER Style
    A PSColorStyle object to set as default
    
    .PARAMETER ForegroundColor
    The default foreground color
    
    .PARAMETER BackgroundColor
    The default background color
    
    .PARAMETER Bold
    Make default text bold
    
    .PARAMETER Italic
    Make default text italic
    
    .EXAMPLE
    Set-ColorDefault -ForegroundColor Cyan -Bold
    
    .EXAMPLE
    $style = [PSColorStyle]::new("MyDefault", "Green", $null)
    Set-ColorDefault -Style $style
    #>
    [CmdletBinding()]
    [Alias('SCD', 'Set-ColourDefault', 'Set-DefaultColor', 'Set-DefaultColour')]
    param(
        [Parameter(ParameterSetName = 'Object')]
        [PSColorStyle]$Style,
        
        [Parameter(ParameterSetName = 'Properties')]
        [object]$ForegroundColor = "Gray",
        
        [Parameter(ParameterSetName = 'Properties')]
        [object]$BackgroundColor = $null,
        
        [Parameter(ParameterSetName = 'Properties')]
        [switch]$Bold,
        
        [Parameter(ParameterSetName = 'Properties')]
        [switch]$Italic,
        
        [Parameter(ParameterSetName = 'Properties')]
        [switch]$Underline,
        
        [Parameter(ParameterSetName = 'Properties')]
        [switch]$ShowTime,
        
        [Parameter(ParameterSetName = 'Properties')]
        [int]$StartTab = 0,
        
        [Parameter(ParameterSetName = 'Properties')]
        [int]$StartSpaces = 0
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'Object') {
        $Style.SetAsDefault()
    } else {
        $newDefault = [PSColorStyle]::new("Default", $ForegroundColor, $BackgroundColor)
        $newDefault.Bold = $Bold
        $newDefault.Italic = $Italic
        $newDefault.Underline = $Underline
        $newDefault.ShowTime = $ShowTime
        $newDefault.StartTab = $StartTab
        $newDefault.StartSpaces = $StartSpaces
        $newDefault.SetAsDefault()
        $newDefault.AddToProfiles()
    }
}

function Get-ColorProfiles {
    <#
    .SYNOPSIS
    Gets available color profiles
    
    .DESCRIPTION
    Returns all registered color profiles or a specific profile by name
    
    .PARAMETER Name
    The name of a specific profile to retrieve
    
    .EXAMPLE
    Get-ColorProfiles
    
    .EXAMPLE
    Get-ColorProfiles -Name "Error"
    #>
    [CmdletBinding()]
    [Alias('GCP', 'Get-ColourProfiles', 'Get-Profiles', 'gcprofiles')]
    param(
        [string]$Name
    )
    
    if ($Name) {
        return [PSColorStyle]::GetProfile($Name)
    } else {
        return [PSColorStyle]::Profiles.Values
    }
}

function New-ColorStyle {
    <#
    .SYNOPSIS
    Creates a new color style
    
    .DESCRIPTION
    Creates a new PSColorStyle object with specified properties
    
    .PARAMETER Name
    The name of the style
    
    .PARAMETER ForegroundColor
    The foreground color
    
    .PARAMETER BackgroundColor
    The background color
    
    .PARAMETER Bold
    Make text bold
    
    .PARAMETER Italic
    Make text italic
    
    .PARAMETER Underline
    Underline text

    .PARAMETER AutoPad
    Target display width for Unicode-aware text padding (0 = disabled)

    .PARAMETER PadLeft
    Pad on left side (right-align) instead of right side (left-align)

    .PARAMETER PadChar
    Character to use for padding (default: space)

    .PARAMETER AddToProfiles
    Add this style to the profiles collection

    .PARAMETER SetAsDefault
    Set this style as the default

    .EXAMPLE
    $style = New-ColorStyle -Name "Custom" -ForegroundColor Magenta -Bold -AddToProfiles

    .EXAMPLE
    New-ColorStyle -Name "MyDefault" -ForegroundColor Green -SetAsDefault

    .EXAMPLE
    $tableStyle = New-ColorStyle -Name "TableColumn" -ForegroundColor Cyan -AutoPad 30 -AddToProfiles
    #>
    [CmdletBinding()]
    [Alias('NCS', 'New-ColourStyle', 'New-Style', 'ncstyle')]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [object]$ForegroundColor = "Gray",

        [object]$BackgroundColor = $null,

        [object[]]$Gradient = $null,

        [switch]$Bold,
        [switch]$Italic,
        [switch]$Underline,
        [switch]$Blink,
        [switch]$Faint,
        [switch]$CrossedOut,
        [switch]$DoubleUnderline,
        [switch]$Overline,
        [switch]$ShowTime,
        [switch]$NoNewLine,
        [switch]$HorizontalCenter,

        [int]$StartTab = 0,
        [int]$StartSpaces = 0,
        [int]$LinesBefore = 0,
        [int]$LinesAfter = 0,

        [int]$AutoPad = 0,
        [switch]$PadLeft,
        [char]$PadChar = ' ',

        [switch]$AddToProfiles,
        [switch]$SetAsDefault
    )

    $style = [PSColorStyle]::new($Name, $ForegroundColor, $BackgroundColor)
    $style.Gradient = $Gradient
    $style.Bold = $Bold
    $style.Italic = $Italic
    $style.Underline = $Underline
    $style.Blink = $Blink
    $style.Faint = $Faint
    $style.CrossedOut = $CrossedOut
    $style.DoubleUnderline = $DoubleUnderline
    $style.Overline = $Overline
    $style.ShowTime = $ShowTime
    $style.NoNewLine = $NoNewLine
    $style.HorizontalCenter = $HorizontalCenter
    $style.StartTab = $StartTab
    $style.StartSpaces = $StartSpaces
    $style.LinesBefore = $LinesBefore
    $style.LinesAfter = $LinesAfter
    $style.AutoPad = $AutoPad
    $style.PadLeft = $PadLeft
    $style.PadChar = $PadChar

    if ($AddToProfiles) {
        $style.AddToProfiles()
    }

    if ($SetAsDefault) {
        $style.SetAsDefault()
    }

    return $style
}