# Write-ColorEX with the built-in profiles, and the commands that manage profiles

function Write-ColorError {
    <#
    .SYNOPSIS
        Writes an error message with the Error profile (red, bold)

    .DESCRIPTION
        Write-ColorError calls Write-ColorEX with the built-in Error profile, which starts as
        red, bold text. A change to [PSColorStyle]::Profiles['Error'] applies to the next call.

    .PARAMETER Text
        The message. Several strings are written on one line; strings piped in are written one
        line each.

    .PARAMETER NoNewLine
        Leaves the line open, so the next output continues it.

    .PARAMETER LogFile
        Writes the message to this log file as well. A file name alone goes in the folder of the
        calling script, or the current location when called from the prompt.

    .PARAMETER NoConsoleOutput
        Writes nothing to the host, only to the log file.

    .PARAMETER PassThru
        Writes the text to the pipeline after writing it to the host.

    .INPUTS
        System.String[]
        Strings piped in are written one line each.

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorError "Operation failed"

        Writes "Operation failed" in red, bold.

    .EXAMPLE
        Write-ColorError "Critical error" -LogFile "errors.log"

        Writes the message to the host and to errors.log.

    .EXAMPLE
        $result = Write-ColorError "Warning" -PassThru
        # $result contains "Warning" for further processing

    .NOTES
        Author: Mark Newton
        License: MIT
        Requires: PowerShell 5.1 or later

        Uses the Error profile, [PSColorStyle]::Profiles['Error'].

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

    begin {
        # A bare -LogFile name goes in the folder of the script that called this function
        $callerScriptRoot = $MyInvocation.PSScriptRoot
    }

    process {
        $params = Get-ColorHelperParams -Name 'Error'
        $params['Text'] = $Text
        if ($NoNewLine) { $params['NoNewLine'] = $true }
        if ($LogFile) {
            $params['LogFile'] = $LogFile
            $params['LogPath'] = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
        }
        if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

        Write-ColorEX @params

        if ($PassThru) {
            $Text
        }
    }
}

function Write-ColorWarning {
    <#
    .SYNOPSIS
        Writes a warning message with the Warning profile (yellow)

    .DESCRIPTION
        Write-ColorWarning calls Write-ColorEX with the built-in Warning profile, which starts
        as yellow text. A change to [PSColorStyle]::Profiles['Warning'] applies to the next call.

    .PARAMETER Text
        The message. Several strings are written on one line; strings piped in are written one
        line each.

    .PARAMETER NoNewLine
        Leaves the line open, so the next output continues it.

    .PARAMETER LogFile
        Writes the message to this log file as well. A file name alone goes in the folder of the
        calling script, or the current location when called from the prompt.

    .PARAMETER NoConsoleOutput
        Writes nothing to the host, only to the log file.

    .PARAMETER PassThru
        Writes the text to the pipeline after writing it to the host.

    .INPUTS
        System.String[]

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorWarning "This action may cause data loss"

    .EXAMPLE
        Write-ColorWarning "Deprecated function used" -LogFile "warnings.log"

    .NOTES
        Author: Mark Newton
        License: MIT

        Uses the Warning profile, [PSColorStyle]::Profiles['Warning'].

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

    begin {
        # A bare -LogFile name goes in the folder of the script that called this function
        $callerScriptRoot = $MyInvocation.PSScriptRoot
    }

    process {
        $params = Get-ColorHelperParams -Name 'Warning'
        $params['Text'] = $Text
        if ($NoNewLine) { $params['NoNewLine'] = $true }
        if ($LogFile) {
            $params['LogFile'] = $LogFile
            $params['LogPath'] = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
        }
        if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

        Write-ColorEX @params

        if ($PassThru) {
            $Text
        }
    }
}

function Write-ColorInfo {
    <#
    .SYNOPSIS
        Writes an informational message with the Info profile (cyan)

    .DESCRIPTION
        Write-ColorInfo calls Write-ColorEX with the built-in Info profile, which starts as cyan text.
        A change to [PSColorStyle]::Profiles['Info'] applies to the next call.

    .PARAMETER Text
        The message. Several strings are written on one line; strings piped in are written one
        line each.

    .PARAMETER NoNewLine
        Leaves the line open, so the next output continues it.

    .PARAMETER LogFile
        Writes the message to this log file as well. A file name alone goes in the folder of the
        calling script, or the current location when called from the prompt.

    .PARAMETER NoConsoleOutput
        Writes nothing to the host, only to the log file.

    .PARAMETER PassThru
        Writes the text to the pipeline after writing it to the host.

    .INPUTS
        System.String[]
        Strings piped in are written one line each.

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorInfo "Processing started..."

    .EXAMPLE
        Write-ColorInfo "User logged in" -LogFile "activity.log"

    .NOTES
        Author: Mark Newton
        License: MIT

        Uses the Info profile, [PSColorStyle]::Profiles['Info'].

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

    begin {
        # A bare -LogFile name goes in the folder of the script that called this function
        $callerScriptRoot = $MyInvocation.PSScriptRoot
    }

    process {
        $params = Get-ColorHelperParams -Name 'Info'
        $params['Text'] = $Text
        if ($NoNewLine) { $params['NoNewLine'] = $true }
        if ($LogFile) {
            $params['LogFile'] = $LogFile
            $params['LogPath'] = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
        }
        if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

        Write-ColorEX @params

        if ($PassThru) {
            $Text
        }
    }
}

function Write-ColorSuccess {
    <#
    .SYNOPSIS
        Writes a success message with the Success profile (green)

    .DESCRIPTION
        Write-ColorSuccess calls Write-ColorEX with the built-in Success profile, which starts as green text.
        A change to [PSColorStyle]::Profiles['Success'] applies to the next call.

    .PARAMETER Text
        The message. Several strings are written on one line; strings piped in are written one
        line each.

    .PARAMETER NoNewLine
        Leaves the line open, so the next output continues it.

    .PARAMETER LogFile
        Writes the message to this log file as well. A file name alone goes in the folder of the
        calling script, or the current location when called from the prompt.

    .PARAMETER NoConsoleOutput
        Writes nothing to the host, only to the log file.

    .PARAMETER PassThru
        Writes the text to the pipeline after writing it to the host.

    .INPUTS
        System.String[]
        Strings piped in are written one line each.

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorSuccess "Operation completed successfully"

    .EXAMPLE
        Write-ColorSuccess "Backup created" -LogFile "backup.log"

    .NOTES
        Author: Mark Newton
        License: MIT

        Uses the Success profile, [PSColorStyle]::Profiles['Success'].

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

    begin {
        # A bare -LogFile name goes in the folder of the script that called this function
        $callerScriptRoot = $MyInvocation.PSScriptRoot
    }

    process {
        $params = Get-ColorHelperParams -Name 'Success'
        $params['Text'] = $Text
        if ($NoNewLine) { $params['NoNewLine'] = $true }
        if ($LogFile) {
            $params['LogFile'] = $LogFile
            $params['LogPath'] = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
        }
        if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

        Write-ColorEX @params

        if ($PassThru) {
            $Text
        }
    }
}

function Write-ColorCritical {
    <#
    .SYNOPSIS
        Writes a critical message with the Critical profile (white on dark red, bold, blinking)

    .DESCRIPTION
        Write-ColorCritical calls Write-ColorEX with the built-in Critical profile, which starts as bold, blinking white text on dark red. Many terminals do not blink.
        A change to [PSColorStyle]::Profiles['Critical'] applies to the next call.

    .PARAMETER Text
        The message. Several strings are written on one line; strings piped in are written one
        line each.

    .PARAMETER NoNewLine
        Leaves the line open, so the next output continues it.

    .PARAMETER LogFile
        Writes the message to this log file as well. A file name alone goes in the folder of the
        calling script, or the current location when called from the prompt.

    .PARAMETER NoConsoleOutput
        Writes nothing to the host, only to the log file.

    .PARAMETER PassThru
        Writes the text to the pipeline after writing it to the host.

    .INPUTS
        System.String[]
        Strings piped in are written one line each.

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorCritical "SYSTEM FAILURE - IMMEDIATE ACTION REQUIRED"

    .EXAMPLE
        Write-ColorCritical "Security breach detected" -LogFile "security.log"

    .NOTES
        Author: Mark Newton
        License: MIT

        Uses the Critical profile, [PSColorStyle]::Profiles['Critical'].

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

    begin {
        # A bare -LogFile name goes in the folder of the script that called this function
        $callerScriptRoot = $MyInvocation.PSScriptRoot
    }

    process {
        $params = Get-ColorHelperParams -Name 'Critical'
        $params['Text'] = $Text
        if ($NoNewLine) { $params['NoNewLine'] = $true }
        if ($LogFile) {
            $params['LogFile'] = $LogFile
            $params['LogPath'] = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
        }
        if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

        Write-ColorEX @params

        if ($PassThru) {
            $Text
        }
    }
}

function Write-ColorDebug {
    <#
    .SYNOPSIS
        Writes a debug message with the Debug profile (dark gray, italic)

    .DESCRIPTION
        Write-ColorDebug calls Write-ColorEX with the built-in Debug profile, which starts as dark gray italic text. The Windows console host (conhost.exe) does not show italics.
        A change to [PSColorStyle]::Profiles['Debug'] applies to the next call.

    .PARAMETER Text
        The message. Several strings are written on one line; strings piped in are written one
        line each.

    .PARAMETER NoNewLine
        Leaves the line open, so the next output continues it.

    .PARAMETER LogFile
        Writes the message to this log file as well. A file name alone goes in the folder of the
        calling script, or the current location when called from the prompt.

    .PARAMETER NoConsoleOutput
        Writes nothing to the host, only to the log file.

    .PARAMETER PassThru
        Writes the text to the pipeline after writing it to the host.

    .INPUTS
        System.String[]
        Strings piped in are written one line each.

    .OUTPUTS
        None (default) or System.String[] (with -PassThru)

    .EXAMPLE
        Write-ColorDebug "Variable value: $myVar"

    .EXAMPLE
        Write-ColorDebug "Function entered: ProcessData" -LogFile "debug.log"

    .NOTES
        Author: Mark Newton
        License: MIT

        Uses the Debug profile, [PSColorStyle]::Profiles['Debug'].

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

    begin {
        # A bare -LogFile name goes in the folder of the script that called this function
        $callerScriptRoot = $MyInvocation.PSScriptRoot
    }

    process {
        $params = Get-ColorHelperParams -Name 'Debug'
        $params['Text'] = $Text
        if ($NoNewLine) { $params['NoNewLine'] = $true }
        if ($LogFile) {
            $params['LogFile'] = $LogFile
            $params['LogPath'] = Resolve-ColorLogFolder -ScriptRoot $callerScriptRoot
        }
        if ($NoConsoleOutput) { $params['NoConsoleOutput'] = $true }

        Write-ColorEX @params

        if ($PassThru) {
            $Text
        }
    }
}

function Set-ColorDefault {
    <#
    .SYNOPSIS
    Sets the default color style for Write-ColorEX

    .DESCRIPTION
    Sets the style Write-ColorEX -Default applies. With -Style, the style given becomes
    [PSColorStyle]::Default. With the other parameters, or with none, a new style named Default
    is made from them, becomes the default and replaces the Default profile; with none it is
    plain Gray text.

    .PARAMETER Style
    A PSColorStyle to make the default.

    .PARAMETER ForegroundColor
    The text color of the new default style: a color name, a hex code, an RGB array or an ANSI
    color number. Gray when left out.

    .PARAMETER BackgroundColor
    The background color of the new default style.

    .PARAMETER Bold
    Makes the default style bold.

    .PARAMETER Italic
    Makes the default style italic.

    .PARAMETER Underline
    Underlines the default style.

    .PARAMETER ShowTime
    Writes the time before the text with the default style.

    .PARAMETER StartTab
    The number of tabs before the text with the default style.

    .PARAMETER StartSpaces
    The number of spaces before the text with the default style.

    .EXAMPLE
    Set-ColorDefault -ForegroundColor Cyan -Bold
    
    .EXAMPLE
    $style = [PSColorStyle]::new("MyDefault", "Green", $null)
    Set-ColorDefault -Style $style

    .EXAMPLE
    Set-ColorDefault

    Makes the default style plain Gray text again.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Properties')]
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
    Creates a PSColorStyle from its parameters. Write-ColorEX -StyleProfile writes text in a
    style, and -AddToProfiles keeps the style in [PSColorStyle]::Profiles under its name.

    .PARAMETER Name
    The name of the style, its key in [PSColorStyle]::Profiles.

    .PARAMETER ForegroundColor
    The text color: a color name, a hex code, an RGB array or an ANSI color number. Gray when
    left out.

    .PARAMETER BackgroundColor
    The background color, in the same forms as -ForegroundColor.

    .PARAMETER Gradient
    Two or more colors to blend across the text, in place of -ForegroundColor.

    .PARAMETER Bold
    Bold text.

    .PARAMETER Italic
    Italic text.

    .PARAMETER Underline
    Underlined text.

    .PARAMETER Blink
    Blinking text, where the terminal supports it.

    .PARAMETER Faint
    Faint (dimmed) text.

    .PARAMETER CrossedOut
    Text struck through.

    .PARAMETER DoubleUnderline
    Text underlined twice, where the terminal supports it.

    .PARAMETER Overline
    A line above the text, where the terminal supports it.

    .PARAMETER ShowTime
    The time before the text.

    .PARAMETER NoNewLine
    The line left open, so the next output continues it.

    .PARAMETER HorizontalCenter
    The text centered in the console window.

    .PARAMETER StartTab
    The number of tabs before the text.

    .PARAMETER StartSpaces
    The number of spaces before the text.

    .PARAMETER LinesBefore
    The number of blank lines before the text.

    .PARAMETER LinesAfter
    The number of blank lines after the text.

    .PARAMETER AutoPad
    The display width to pad the text to, counting wide characters as two cells. 0 pads nothing.

    .PARAMETER PadLeft
    Pads on the left, right-aligning the text.

    .PARAMETER PadChar
    The character to pad with. A space when left out.

    .PARAMETER BackgroundGradient
    Two or more colors to blend across the background. It replaces -BackgroundColor.

    .PARAMETER GradientSpace
    How the gradients blend their colors: OKLab or RGB. Without it, Write-ColorEX's default, OKLab.

    .PARAMETER Reverse
    Swaps the text and background colors.

    .PARAMETER UnderlineColor
    The color of the underline.

    .PARAMETER UnderlineStyle
    The kind of underline: Single, Double, Curly, Dotted or Dashed.

    .PARAMETER PadCenter
    With -AutoPad, centers the text.

    .PARAMETER Truncate
    With -AutoPad, cuts text wider than -AutoPad, ending it with an ellipsis.

    .PARAMETER Wrap
    Breaks text wider than the line into lines.

    .PARAMETER AddToProfiles
    Adds the style to [PSColorStyle]::Profiles under its name.

    .PARAMETER SetAsDefault
    Makes the style the one -Default applies.

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

        [object[]]$BackgroundGradient = $null,
        [ValidateSet('OKLab', 'RGB')][string]$GradientSpace,
        [switch]$Reverse,
        [object]$UnderlineColor = $null,
        [ValidateSet('Single', 'Double', 'Curly', 'Dotted', 'Dashed')][string]$UnderlineStyle,
        [switch]$PadCenter,
        [switch]$Truncate,
        [switch]$Wrap,

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
    $style.BackgroundGradient = $BackgroundGradient
    $style.GradientSpace = $GradientSpace
    $style.Reverse = $Reverse
    $style.UnderlineColor = $UnderlineColor
    $style.UnderlineStyle = $UnderlineStyle
    $style.PadCenter = $PadCenter
    $style.Truncate = $Truncate
    $style.Wrap = $Wrap

    if ($AddToProfiles) {
        $style.AddToProfiles()
    }

    if ($SetAsDefault) {
        $style.SetAsDefault()
    }

    return $style
}