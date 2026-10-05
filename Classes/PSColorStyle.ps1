<#
.SYNOPSIS
    PSColorStyle class for managing reusable color and style configurations

.DESCRIPTION
    A PSColorStyle holds the colors, styles and layout settings of a Write-ColorEX call, so
    they can be reused with -StyleProfile.

    - [PSColorStyle]::Default is the style -Default applies
    - [PSColorStyle]::Profiles holds named styles
    - Built-in profiles: Default, Error, Warning, Info, Success, Critical, Debug
    - ToWriteColorParams() answers the Write-ColorEX parameters a style sets, read from its
      properties on each call, so a change to a style applies to its next use
    - Clone() copies a style

    USAGE PATTERN:
    - Create custom styles with New-ColorStyle function
    - Access built-in profiles: [PSColorStyle]::Profiles['Error']
    - Set default style: $style.SetAsDefault()
    - Register profiles: $style.AddToProfiles()

.NOTES
    Author: MarkusMcNugen
    License: MIT
    Requires: PowerShell 5.1 or later

    Importing the module defines the class, makes [PSColorStyle] usable in the session, and
    creates the built-in profiles with InitializeDefaultProfiles().

.LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

.LINK
    New-ColorStyle

.LINK
    Set-ColorDefault

.EXAMPLE
    # Create and register a custom style
    $style = [PSColorStyle]::new("Header", "Cyan", $null)
    $style.Bold = $true
    $style.Underline = $true
    $style.HorizontalCenter = $true
    $style.AddToProfiles()

.EXAMPLE
    # Use a built-in profile
    $errorStyle = [PSColorStyle]::Profiles['Error']
    Write-ColorEX -Text "Failed!" -StyleProfile $errorStyle

.EXAMPLE
    # Clone and modify a profile
    $customError = [PSColorStyle]::Profiles['Error'].Clone()
    $customError.Name = "MyError"
    $customError.Italic = $true
#>

class PSColorStyle {
    [string]$Name
    [object]$ForegroundColor
    [object]$BackgroundColor
    [object[]]$Gradient
    [string[]]$Style
    [int]$StartTab
    [int]$StartSpaces
    [int]$LinesBefore
    [int]$LinesAfter
    [bool]$Bold
    [bool]$Italic
    [bool]$Underline
    [bool]$Blink
    [bool]$Faint
    [bool]$CrossedOut
    [bool]$DoubleUnderline
    [bool]$Overline
    [bool]$ShowTime
    [bool]$NoNewLine
    [bool]$HorizontalCenter
    [int]$AutoPad = 0
    [bool]$PadLeft = $false
    [char]$PadChar = ' '

    # The style -Default applies
    static [PSColorStyle]$Default

    # Named styles
    static [hashtable]$Profiles = @{}

    PSColorStyle() {
        $this.Initialize("Custom", "Gray", $null)
    }
    
    PSColorStyle([string]$name) {
        $this.Initialize($name, "Gray", $null)
    }
    
    PSColorStyle([string]$name, [object]$foreground, [object]$background) {
        $this.Initialize($name, $foreground, $background)
    }
    
    hidden [void]Initialize([string]$name, [object]$foreground, [object]$background) {
        $this.Name = $name
        $this.ForegroundColor = $foreground
        $this.BackgroundColor = $background
        $this.Gradient = $null
        $this.Style = @()
        $this.StartTab = 0
        $this.StartSpaces = 0
        $this.LinesBefore = 0
        $this.LinesAfter = 0
        $this.Bold = $false
        $this.Italic = $false
        $this.Underline = $false
        $this.Blink = $false
        $this.Faint = $false
        $this.CrossedOut = $false
        $this.DoubleUnderline = $false
        $this.Overline = $false
        $this.ShowTime = $false
        $this.NoNewLine = $false
        $this.HorizontalCenter = $false
        $this.AutoPad = 0
        $this.PadLeft = $false
        $this.PadChar = ' '
    }
    
    [void]SetAsDefault() {
        [PSColorStyle]::Default = $this
    }
    
    [void]AddToProfiles() {
        [PSColorStyle]::Profiles[$this.Name] = $this
    }
    
    static [PSColorStyle]GetProfile([string]$name) {
        $styleProfile = [PSColorStyle]::Profiles[$name]
        if ($styleProfile) {
            return $styleProfile
        }
        return $null
    }
    
    # The built-in profiles
    static [void]InitializeDefaultProfiles() {
        $defaultProfile = [PSColorStyle]::new("Default", "Gray", $null)
        [PSColorStyle]::Default = $defaultProfile
        [PSColorStyle]::Profiles["Default"] = $defaultProfile

        $errorProfile = [PSColorStyle]::new("Error", "Red", $null)
        $errorProfile.Bold = $true
        $errorProfile.AddToProfiles()

        $warningProfile = [PSColorStyle]::new("Warning", "Yellow", $null)
        $warningProfile.AddToProfiles()

        $infoProfile = [PSColorStyle]::new("Info", "Cyan", $null)
        $infoProfile.AddToProfiles()

        $successProfile = [PSColorStyle]::new("Success", "Green", $null)
        $successProfile.AddToProfiles()

        $criticalProfile = [PSColorStyle]::new("Critical", "White", "DarkRed")
        $criticalProfile.Bold = $true
        $criticalProfile.Blink = $true
        $criticalProfile.AddToProfiles()

        $debugProfile = [PSColorStyle]::new("Debug", "DarkGray", $null)
        $debugProfile.Italic = $true
        $debugProfile.AddToProfiles()
    }

    # The Write-ColorEX parameters this style sets, read from its properties
    [hashtable]ToWriteColorParams() {
        $params = @{}

        # A gradient replaces the foreground color
        if ($this.Gradient -and $this.Gradient.Count -ge 2) {
            $params['Gradient'] = $this.Gradient
        } elseif ($this.ForegroundColor) {
            $params['Color'] = $this.ForegroundColor
        }
        if ($this.BackgroundColor) { $params['BackGroundColor'] = $this.BackgroundColor }
        if ($this.Style.Count -gt 0) { $params['Style'] = $this.Style }
        if ($this.StartTab -gt 0) { $params['StartTab'] = $this.StartTab }
        if ($this.StartSpaces -gt 0) { $params['StartSpaces'] = $this.StartSpaces }
        if ($this.LinesBefore -gt 0) { $params['LinesBefore'] = $this.LinesBefore }
        if ($this.LinesAfter -gt 0) { $params['LinesAfter'] = $this.LinesAfter }
        if ($this.Bold) { $params['Bold'] = $true }
        if ($this.Italic) { $params['Italic'] = $true }
        if ($this.Underline) { $params['Underline'] = $true }
        if ($this.Blink) { $params['Blink'] = $true }
        if ($this.Faint) { $params['Faint'] = $true }
        if ($this.CrossedOut) { $params['CrossedOut'] = $true }
        if ($this.DoubleUnderline) { $params['DoubleUnderline'] = $true }
        if ($this.Overline) { $params['Overline'] = $true }
        if ($this.ShowTime) { $params['ShowTime'] = $true }
        if ($this.NoNewLine) { $params['NoNewLine'] = $true }
        if ($this.HorizontalCenter) { $params['HorizontalCenter'] = $true }
        if ($this.AutoPad -gt 0) { $params['AutoPad'] = $this.AutoPad }
        if ($this.PadLeft) { $params['PadLeft'] = $true }
        if ($this.PadChar -ne ' ') { $params['PadChar'] = $this.PadChar }

        return $params
    }

    # Does nothing: ToWriteColorParams reads the properties on each call. Kept so scripts
    # that call it after changing a style keep working.
    hidden [void]InvalidateCache() {
    }

    # A copy named with _Copy, property by property, which Windows PowerShell 5.1 classes need
    [PSColorStyle]Clone() {
        $newStyle = [PSColorStyle]::new($this.Name + "_Copy", $this.ForegroundColor, $this.BackgroundColor)
        $newStyle.Gradient = $this.Gradient
        $newStyle.Style = $this.Style
        $newStyle.StartTab = $this.StartTab
        $newStyle.StartSpaces = $this.StartSpaces
        $newStyle.LinesBefore = $this.LinesBefore
        $newStyle.LinesAfter = $this.LinesAfter
        $newStyle.Bold = $this.Bold
        $newStyle.Italic = $this.Italic
        $newStyle.Underline = $this.Underline
        $newStyle.Blink = $this.Blink
        $newStyle.Faint = $this.Faint
        $newStyle.CrossedOut = $this.CrossedOut
        $newStyle.DoubleUnderline = $this.DoubleUnderline
        $newStyle.Overline = $this.Overline
        $newStyle.ShowTime = $this.ShowTime
        $newStyle.NoNewLine = $this.NoNewLine
        $newStyle.HorizontalCenter = $this.HorizontalCenter
        $newStyle.AutoPad = $this.AutoPad
        $newStyle.PadLeft = $this.PadLeft
        $newStyle.PadChar = $this.PadChar
        return $newStyle
    }
}