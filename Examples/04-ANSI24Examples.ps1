<#
.SYNOPSIS
    TrueColor (24-bit RGB) examples for PSWriteColorEX
.DESCRIPTION
    Demonstrates TrueColor functionality including hex colors, RGB arrays,
    gradients, and advanced color effects.
.NOTES
    TrueColor support requires compatible terminal (Windows Terminal, iTerm2, etc.)
    Colors will gracefully degrade to ANSI 256 or 16 colors if not supported.
#>

# Import module if not already loaded
if (-not (Get-Module PSWriteColorEX)) {
    Import-Module PSWriteColorEX -Force
}

Clear-Host
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        PSWriteColorEX - TRUECOLOR EXAMPLES (24-bit)       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

#region Terminal Capability Check
Write-Host "▼ Terminal Color Support Detection" -ForegroundColor Yellow
Write-Host "  Checking what color modes your terminal supports`n" -ForegroundColor Gray

$colorSupportInfo = Test-AnsiSupport -Silent
$colorSupport = $colorSupportInfo.ColorSupport
Write-ColorEX -Text "Detected color support level: ", $colorSupport -Color White, Yellow

switch ($colorSupport) {
    'TrueColor' {
        Write-ColorEX -Text "✓ TrueColor (16.7 million colors) is supported!" -Color @(0, 255, 0) -TrueColor
        Write-ColorEX -Text "  All examples will display with full color fidelity" -Color @(128, 128, 128) -TrueColor
    }
    'ANSI8' {
        Write-ColorEX -Text "⚠ Only 256 colors supported - TrueColor will degrade" -Color Yellow
        Write-ColorEX -Text "  Examples will automatically convert to nearest 256-color match" -Color Gray
    }
    'ANSI4' {
        Write-ColorEX -Text "⚠ Only 16 colors supported - TrueColor will degrade significantly" -Color Yellow
        Write-ColorEX -Text "  Examples will convert to nearest 16-color match" -Color Gray
    }
    default {
        Write-ColorEX -Text "✗ ANSI colors not supported - using basic PowerShell colors" -Color Red
    }
}
#endregion

#region Hex Color Format
Write-Host "`n▼ Hex Color Format" -ForegroundColor Yellow
Write-Host "  Use hex color codes like #RRGGBB for precise colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Orange (#FF8000)" -Color "#FF8000" -TrueColor
Write-ColorEX -Text "Hot Pink (#FF69B4)" -Color "#FF69B4" -TrueColor
Write-ColorEX -Text "Medium Purple (#9370DB)" -Color "#9370DB" -TrueColor
Write-ColorEX -Text "Dark Cyan (#008B8B)" -Color "#008B8B" -TrueColor
Write-ColorEX -Text "Crimson (#DC143C)" -Color "#DC143C" -TrueColor

# Different hex formats are supported
Write-ColorEX -Text "`nSupported hex formats:" -Color White -Bold
Write-ColorEX -Text "  Standard: " -Color Gray -NoNewLine
Write-ColorEX -Text "#FF8000" -Color "#FF8000" -TrueColor

Write-ColorEX -Text "  With 0x: " -Color Gray -NoNewLine
Write-ColorEX -Text "0xFF8000" -Color "0xFF8000" -TrueColor

Write-ColorEX -Text "  No prefix: " -Color Gray -NoNewLine
Write-ColorEX -Text "FF8000" -Color "FF8000" -TrueColor
#endregion

#region RGB Array Format
Write-Host "`n▼ RGB Array Format" -ForegroundColor Yellow
Write-Host "  Use RGB arrays @(Red, Green, Blue) for precise control (0-255 per channel)`n" -ForegroundColor Gray

Write-ColorEX -Text "Crimson Red @(220, 20, 60)" -Color @(220, 20, 60) -TrueColor
Write-ColorEX -Text "Lime Green @(50, 205, 50)" -Color @(50, 205, 50) -TrueColor
Write-ColorEX -Text "Dodger Blue @(30, 144, 255)" -Color @(30, 144, 255) -TrueColor
Write-ColorEX -Text "Gold @(255, 215, 0)" -Color @(255, 215, 0) -TrueColor
Write-ColorEX -Text "Coral @(255, 127, 80)" -Color @(255, 127, 80) -TrueColor
#endregion

#region Mixing Hex and RGB - Multi-Color Arrays
Write-Host "`n▼ Multi-Color Arrays - Mix Any Format!" -ForegroundColor Yellow
Write-Host "  Combine different color formats seamlessly in arrays`n" -ForegroundColor Gray

# Multiple hex codes in array
Write-ColorEX -Text "Multiple Hex Codes:" -Color White -Bold
Write-ColorEX -Text "RED", " | ", "GREEN", " | ", "BLUE" `
              -Color @("#FF0000", "#FFFFFF", "#00FF00", "#FFFFFF", "#0000FF") `
              -TrueColor

# Multiple RGB arrays
Write-ColorEX -Text "`nMultiple RGB Arrays:" -Color White -Bold
Write-ColorEX -Text "ORANGE", " | ", "PURPLE", " | ", "CYAN" `
              -Color @(@(255,128,0), @(255,255,255), @(128,0,255), @(255,255,255), @(0,255,255)) `
              -TrueColor

# Mixed: color names, hex, and RGB in one array
Write-ColorEX -Text "`nMixed Formats in One Array:" -Color White -Bold
Write-ColorEX -Text "Name: ", "Red", " | Hex: ", "#FF8000", " | RGB: ", "@(0,255,0)" `
              -Color @("Gray", "Red", "Gray", "#FF8000", "Gray", @(0,255,0)) `
              -TrueColor

# Practical example: Color-coded table header
Write-ColorEX -Text "`nPractical - Table Header with Multiple Hex Colors:" -Color White -Bold
Write-ColorEX -Text "║ ", "ID", " │ ", "Name", " │ ", "Status", " │ ", "Score", " ║" `
              -Color @("#00D9FF", "#FFD700", "#00D9FF", "#FFD700", "#00D9FF", "#FFD700", "#00D9FF", "#FFD700", "#00D9FF") `
              -TrueColor
#endregion

#region Gradient Effects (New Feature!)
Write-Host "`n▼ Gradient Effects - Automatic Color Interpolation" -ForegroundColor Yellow
Write-Host "  Create smooth color transitions with the -Gradient parameter`n" -ForegroundColor Gray

# Simple two-color gradient
Write-ColorEX -Text "Two-Color Gradient:" -Color White -Bold
Write-ColorEX -Text "RED TO BLUE SMOOTH TRANSITION" -Gradient @('Red', 'Blue') -TrueColor

# RGB array gradient
Write-ColorEX -Text "`nRGB Gradient:" -Color White -Bold
Write-ColorEX -Text "GREEN TO MAGENTA GRADIENT" -Gradient @(@(0,255,0), @(255,0,255)) -TrueColor

# Hex color gradient
Write-ColorEX -Text "`nHex Color Gradient:" -Color White -Bold
Write-ColorEX -Text "ORANGE TO PURPLE" -Gradient @('#FF8000', '#8000FF') -TrueColor

# Multi-stop gradient (rainbow)
Write-ColorEX -Text "`nMulti-Stop Rainbow Gradient:" -Color White -Bold
Write-ColorEX -Text "RED ORANGE YELLOW GREEN CYAN BLUE MAGENTA RAINBOW" `
              -Gradient @('Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta') `
              -TrueColor

# Fire gradient (warm colors)
Write-ColorEX -Text "`nFire Gradient (Warm Colors):" -Color White -Bold
Write-ColorEX -Text "FLAME EFFECT WITH MULTIPLE STOPS" `
              -Gradient @('#8B0000', '#FF0000', '#FF8000', '#FFD700') `
              -TrueColor

# Ice gradient (cool colors)
Write-ColorEX -Text "`nIce Gradient (Cool Colors):" -Color White -Bold
Write-ColorEX -Text "FROZEN EFFECT WITH COOL TONES" `
              -Gradient @('#0000FF', '#00BFFF', '#00FFFF', '#F0FFFF') `
              -TrueColor

# Gradient with styling
Write-ColorEX -Text "`nGradient with Bold Styling:" -Color White -Bold
Write-ColorEX -Text "BOLD GRADIENT TEXT" -Gradient @('Cyan', 'Magenta') -Bold -Underline

# Centered gradient header
Write-ColorEX -Text "`nCentered Gradient Header:" -Color White -Bold
Write-ColorEX -Text "═══ CENTERED GRADIENT BANNER ═══" `
              -Gradient @('#FF0000', '#FF8000', '#0000FF') `
              -Bold -HorizontalCenter

# Gradient with multiple segments
Write-ColorEX -Text "`nMulti-Segment Gradient:" -Color White -Bold
Write-ColorEX -Text "First ", "Second ", "Third" `
              -Gradient @('Red', 'Yellow', 'Blue') `
              -TrueColor
Write-ColorEX -Text "  (Each segment gets part of the gradient)" -Color Gray
#endregion

#region Rainbow Text
Write-Host "`n▼ Rainbow Text" -ForegroundColor Yellow
Write-Host "  Classic rainbow color spectrum`n" -ForegroundColor Gray

$rainbowText = "R", "A", "I", "N", "B", "O", "W"
$rainbowColors = @(
    "#FF0000",  # Red
    "#FF7F00",  # Orange
    "#FFFF00",  # Yellow
    "#00FF00",  # Green
    "#0000FF",  # Blue
    "#4B0082",  # Indigo
    "#9400D3"   # Violet
)
Write-ColorEX -Text $rainbowText -Color $rainbowColors -TrueColor

# Rainbow separator using gradient
$separatorText = "═" * 50
Write-ColorEX -Text $separatorText -Gradient @('Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta') -TrueColor
#endregion

#region Background Gradients
Write-Host "`n▼ Background Color Gradients" -ForegroundColor Yellow
Write-Host "  Apply gradients to background colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Light to Dark Red Gradient:" -Color White -Bold
$bgText = @(" TEXT ") * 8
$bgColors = @(
    @(255, 200, 200),
    @(255, 175, 175),
    @(255, 150, 150),
    @(255, 125, 125),
    @(255, 100, 100),
    @(255, 75, 75),
    @(255, 50, 50),
    @(255, 25, 25)
)
$blackColors = @()
for ($i = 0; $i -lt 8; $i++) { $blackColors += ,@(0, 0, 0) }
Write-ColorEX -Text $bgText -Color $blackColors -BackGroundColor $bgColors -TrueColor

# Blue to Cyan background
Write-ColorEX -Text "`nBlue to Cyan Background:" -Color White -Bold
$blueToCyanBG = @(
    @(0, 0, 255),
    @(0, 32, 255),
    @(0, 64, 255),
    @(0, 96, 255),
    @(0, 128, 255),
    @(0, 160, 255),
    @(0, 192, 255),
    @(0, 224, 255)
)
$whiteColors = @()
for ($i = 0; $i -lt 8; $i++) { $whiteColors += ,@(255, 255, 255) }
Write-ColorEX -Text $bgText -Color $whiteColors -BackGroundColor $blueToCyanBG -TrueColor
#endregion

#region Corporate/Brand Colors
Write-Host "`n▼ Corporate Brand Colors" -ForegroundColor Yellow
Write-Host "  Use exact brand colors from style guides`n" -ForegroundColor Gray

Write-ColorEX -Text "Microsoft Azure " -Color "#0078D4" -TrueColor -NoNewLine
Write-ColorEX -Text "Google Blue " -Color "#4285F4" -TrueColor -NoNewLine
Write-ColorEX -Text "Amazon Orange " -Color "#FF9900" -TrueColor -NoNewLine
Write-ColorEX -Text "Spotify Green" -Color "#1DB954" -TrueColor

Write-ColorEX -Text "Facebook " -Color "#1877F2" -TrueColor -NoNewLine
Write-ColorEX -Text "Twitter " -Color "#1DA1F2" -TrueColor -NoNewLine
Write-ColorEX -Text "LinkedIn " -Color "#0A66C2" -TrueColor -NoNewLine
Write-ColorEX -Text "YouTube Red" -Color "#FF0000" -TrueColor

# Brand with background
Write-ColorEX -Text " GitHub " -Color "#FFFFFF" -BackGroundColor "#24292E" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text " Slack " -Color "#FFFFFF" -BackGroundColor "#4A154B" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text " Discord " -Color "#FFFFFF" -BackGroundColor "#5865F2" -TrueColor
#endregion

#region Using Style Profiles with TrueColor
Write-Host "`n▼ TrueColor Style Profiles" -ForegroundColor Yellow
Write-Host "  Create reusable TrueColor style configurations`n" -ForegroundColor Gray

# Create custom TrueColor styles
$sunsetStyle = New-ColorStyle -Name "Sunset" `
                              -ForegroundColor "#FF6B35" `
                              -BackgroundColor "#1A1A2E" `
                              -Bold

Write-ColorEX -Text "  Sunset themed text  " -StyleProfile $sunsetStyle -TrueColor

$oceanStyle = New-ColorStyle -Name "Ocean" `
                             -ForegroundColor "#00D9FF" `
                             -BackgroundColor "#001F3F" `
                             -Italic

Write-ColorEX -Text "  Ocean themed text  " -StyleProfile $oceanStyle -TrueColor

$forestStyle = New-ColorStyle -Name "Forest" `
                              -ForegroundColor "#90EE90" `
                              -BackgroundColor "#0B6623"

Write-ColorEX -Text "  Forest themed text  " -StyleProfile $forestStyle -TrueColor

# Create gradient style profiles
Write-ColorEX -Text "`nGradient Style Profiles:" -Color White -Bold
$rainbowHeader = New-ColorStyle -Name "RainbowHeader" `
                                -Gradient @('Red','Orange','Yellow','Green','Cyan','Blue','Magenta') `
                                -Bold -HorizontalCenter
Write-ColorEX -Text "RAINBOW HEADER STYLE" -StyleProfile $rainbowHeader -TrueColor

$fireStyle = New-ColorStyle -Name "FireGradient" `
                            -Gradient @('#8B0000', '#FF0000', '#FF8000') `
                            -Bold
Write-ColorEX -Text "FIRE GRADIENT STYLE" -StyleProfile $fireStyle -TrueColor

# Customize helper function profiles with gradients
Write-ColorEX -Text "`nCustomizing Helper Function Profiles with Gradients:" -Color White -Bold -TrueColor
Write-ColorEX -Text "(Helper functions use their predefined profiles automatically)" -Color Gray -TrueColor

# Modify the Error profile to add gradient
$errorProfile = Get-ColorProfiles -Name "Error"
$errorProfile.Gradient = @('Red', 'DarkRed')
Write-ColorError "Error with gradient effect!"

# Modify the Success profile to add gradient
$successProfile = Get-ColorProfiles -Name "Success"
$successProfile.Gradient = @('Green', 'DarkGreen')
Write-ColorSuccess "Success with gradient effect!"

# Modify the Info profile to add gradient
$infoProfile = Get-ColorProfiles -Name "Info"
$infoProfile.Gradient = @('Cyan', 'DarkCyan')
Write-ColorInfo "Info with gradient effect!"

# Note: Reset profiles by removing gradients
$errorProfile.Gradient = $null
$successProfile.Gradient = $null
$infoProfile.Gradient = $null
#endregion

#region Practical Example - Color-Coded Log Levels
Write-Host "`n▼ Practical Example: Color-Coded Log Levels" -ForegroundColor Yellow
Write-Host "  Use distinct TrueColor shades for different log severities`n" -ForegroundColor Gray

Write-ColorEX -Text "[TRACE] " -Color "#B0B0B0" -TrueColor -NoNewLine -ShowTime
Write-ColorEX -Text "Detailed trace information" -Color "#D0D0D0" -TrueColor

Write-ColorEX -Text "[DEBUG] " -Color "#00CED1" -TrueColor -NoNewLine -ShowTime
Write-ColorEX -Text "Debug information for developers" -Color "#E0FFFF" -TrueColor

Write-ColorEX -Text "[INFO]  " -Color "#00FF00" -TrueColor -NoNewLine -ShowTime
Write-ColorEX -Text "Informational message" -Color "#90EE90" -TrueColor

Write-ColorEX -Text "[WARN]  " -Color "#FFA500" -TrueColor -NoNewLine -ShowTime
Write-ColorEX -Text "Warning - attention needed" -Color "#FFD700" -TrueColor

Write-ColorEX -Text "[ERROR] " -Color "#FF4500" -TrueColor -NoNewLine -ShowTime
Write-ColorEX -Text "Error occurred" -Color "#FF6347" -TrueColor

Write-ColorEX -Text "[FATAL] " -Color "#8B0000" -TrueColor -NoNewLine -ShowTime
Write-ColorEX -Text "Critical system failure" -Color "#DC143C" -TrueColor
#endregion

#region Practical Example - Status Dashboard with AutoPad
Write-Host "`n▼ Practical Example: Color Status Dashboard (NEW: Unicode-Aware AutoPad)" -ForegroundColor Yellow
Write-Host "  Create a visually appealing status dashboard with perfect alignment`n" -ForegroundColor Gray
Write-Host "  🎯 Uses AutoPad for Unicode-aware padding (supports emoji, CJK, box-drawing)" -ForegroundColor DarkGray

Write-ColorEX -Text "╔═══════════════════════════════════════════════════════════════════╗" `
              -Color "#00D9FF" -TrueColor

Write-ColorEX -Text "║"," Service Name           Status       CPU     Memory    Uptime      ","║" `
              -Color @("#00D9FF", "#FFFFFF", "#00D9FF") -TrueColor

Write-ColorEX -Text "╠═══════════════════════════════════════════════════════════════════╣" `
              -Color "#00D9FF" -TrueColor

# Healthy service - use AutoPad for Unicode-aware formatting
Write-ColorEX -Text "║ " -Color "#00D9FF" -TrueColor -NoNewLine
Write-ColorEX -Text "Web Server" -AutoPad 22 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text "[OK] " -Color "#00FF00" -TrueColor -NoNewLine
Write-ColorEX -Text "Running" -AutoPad 12 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "45%" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "2.1GB" -AutoPad 9 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "12d" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " ║" -Color "#00D9FF" -TrueColor

# Warning service with Unicode bullet (demonstrates Unicode-aware padding)
Write-ColorEX -Text "║ " -Color "#00D9FF" -TrueColor -NoNewLine
Write-ColorEX -Text "Database ●" -AutoPad 22 -Color "#FFFFFF" -TrueColor -NoNewLine  # ● = 2 cells
Write-ColorEX -Text "[!!] " -Color "#FFA500" -TrueColor -NoNewLine
Write-ColorEX -Text "High CPU" -AutoPad 12 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "89%" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "4.5GB" -AutoPad 9 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "12d" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " ║" -Color "#00D9FF" -TrueColor

# Error service
Write-ColorEX -Text "║ " -Color "#00D9FF" -TrueColor -NoNewLine
Write-ColorEX -Text "Cache Service" -AutoPad 22 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text "[XX] " -Color "#FF0000" -TrueColor -NoNewLine
Write-ColorEX -Text "Failed" -AutoPad 12 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "0%" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "0MB" -AutoPad 9 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "N/A" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " ║" -Color "#00D9FF" -TrueColor

# Healthy service
Write-ColorEX -Text "║ " -Color "#00D9FF" -TrueColor -NoNewLine
Write-ColorEX -Text "API Gateway" -AutoPad 22 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text "[OK] " -Color "#00FF00" -TrueColor -NoNewLine
Write-ColorEX -Text "Running" -AutoPad 12 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "32%" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "1.8GB" -AutoPad 9 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "12d" -AutoPad 7 -Color "#FFFFFF" -TrueColor -NoNewLine
Write-ColorEX -Text " ║" -Color "#00D9FF" -TrueColor

Write-ColorEX -Text "╚═══════════════════════════════════════════════════════════════════╝" `
              -Color "#00D9FF" -TrueColor

Write-Host "  ✅ Note: 'Database ●' row stays perfectly aligned despite ● taking 2 cells!" -ForegroundColor DarkGray
#endregion

#region Practical Example - Progress Indicator
Write-Host "`n▼ Practical Example: Color Progress Bar" -ForegroundColor Yellow
Write-Host "  Visual progress indication with gradient colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Download Progress:" -Color White -Bold

# Progress at 30%
$progress30Text = @("█") * 3 + @("░") * 7
$progress30Colors = @()
for ($i = 0; $i -lt 3; $i++) { $progress30Colors += ,@(255, 0, 0) }
for ($i = 0; $i -lt 7; $i++) { $progress30Colors += ,@(50, 50, 50) }
Write-ColorEX -Text "30%  " -Color "#FFD700" -TrueColor -NoNewLine
Write-ColorEX -Text $progress30Text -Color $progress30Colors -TrueColor -NoNewLine
Write-ColorEX -Text " (3 / 10 MB)" -Color Gray

# Progress at 60%
$progress60Text = @("█") * 6 + @("░") * 4
$progress60Colors = @()
for ($i = 0; $i -lt 6; $i++) { $progress60Colors += ,@(255, 165, 0) }
for ($i = 0; $i -lt 4; $i++) { $progress60Colors += ,@(50, 50, 50) }
Write-ColorEX -Text "60%  " -Color "#FFD700" -TrueColor -NoNewLine
Write-ColorEX -Text $progress60Text -Color $progress60Colors -TrueColor -NoNewLine
Write-ColorEX -Text " (6 / 10 MB)" -Color Gray

# Progress at 100%
$progress100Text = @("█") * 10
$progress100Colors = @()
for ($i = 0; $i -lt 10; $i++) { $progress100Colors += ,@(0, 255, 0) }
Write-ColorEX -Text "100% " -Color "#00FF00" -TrueColor -NoNewLine
Write-ColorEX -Text $progress100Text -Color $progress100Colors -TrueColor -NoNewLine
Write-ColorEX -Text " (10 / 10 MB) ✓" -Color @(0, 255, 0) -TrueColor
#endregion

#region Practical Example - Color Temperature Scale
Write-Host "`n▼ Practical Example: Temperature Heat Map" -ForegroundColor Yellow
Write-Host "  Show data with intuitive color temperature coding`n" -ForegroundColor Gray

Write-ColorEX -Text "Temperature Scale (°C):" -Color White -Bold

# Cold to Hot color scale
$temps = @(-20, -10, 0, 10, 20, 30, 40, 50, 60, 70)
$tempColors = @(
    @(0, 0, 139),     # Dark Blue (cold)
    @(0, 0, 255),     # Blue
    @(0, 128, 255),   # Light Blue
    @(0, 255, 255),   # Cyan
    @(0, 255, 0),     # Green
    @(128, 255, 0),   # Yellow-Green
    @(255, 255, 0),   # Yellow
    @(255, 165, 0),   # Orange
    @(255, 69, 0),    # Red-Orange
    @(255, 0, 0)      # Red (hot)
)

for ($i = 0; $i -lt $temps.Count; $i++) {
    $temp = $temps[$i]
    $color = $tempColors[$i]
    $displayTemp = "{0,4}°C " -f $temp
    Write-ColorEX -Text $displayTemp, "███" -Color @(200, 200, 200), $color -TrueColor -NoNewLine
}
Write-ColorEX -Text "" # Newline
#endregion

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           END OF TRUECOLOR EXAMPLES (24-bit)              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Reminder about terminal compatibility
Write-ColorEX -Text "💡 Tip: " -Color "#FFD700" -TrueColor -NoNewLine
Write-ColorEX -Text "For best results, use Windows Terminal, iTerm2, or other TrueColor-compatible terminals" `
              -Color "#B0B0B0" -TrueColor
