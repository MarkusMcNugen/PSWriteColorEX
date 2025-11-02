<#
.SYNOPSIS
    ANSI 4-bit (16-color) examples for PSWriteColorEX
.DESCRIPTION
    Demonstrates ANSI 4-bit color mode functionality (16 colors).
    This mode is widely supported across most terminals and provides basic color output.
.NOTES
    ANSI 4-bit includes: 8 standard colors + 8 bright variants
    Color codes: 30-37 (standard), 90-97 (bright) for foreground
                 40-47 (standard), 100-107 (bright) for background
#>

# Import module if not already loaded
if (-not (Get-Module PSWriteColorEX)) {
    Import-Module PSWriteColorEX -Force
}

Clear-Host
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         PSWriteColorEX - ANSI4 EXAMPLES (16-color)        ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

#region Terminal Capability Check
Write-Host "▼ Terminal Color Support Detection" -ForegroundColor Yellow
Write-Host "  Checking ANSI 4-bit support (16 colors)`n" -ForegroundColor Gray

$colorSupportInfo = Test-AnsiSupport -Silent
$colorSupport = $colorSupportInfo.ColorSupport
Write-ColorEX -Text "Detected color support level: ", $colorSupport -Color White, Yellow

if ($colorSupport -eq 'None') {
    Write-ColorEX -Text "⚠ ANSI not supported - examples will use basic PowerShell colors" -Color Yellow
} else {
    Write-ColorEX -Text "✓ ANSI colors are supported!" -Color Green
    Write-ColorEX -Text "  ANSI4 mode provides 16 colors: 8 standard + 8 bright variants" -Color Gray
}
#endregion

#region Standard 8 Colors (ANSI Codes 30-37)
Write-Host "`n▼ Standard 8 Colors (ANSI Codes 30-37)" -ForegroundColor Yellow
Write-Host "  The original 8 ANSI colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Black     (30)" -Color 30 -ANSI4
Write-ColorEX -Text "Red       (31)" -Color 31 -ANSI4
Write-ColorEX -Text "Green     (32)" -Color 32 -ANSI4
Write-ColorEX -Text "Yellow    (33)" -Color 33 -ANSI4
Write-ColorEX -Text "Blue      (34)" -Color 34 -ANSI4
Write-ColorEX -Text "Magenta   (35)" -Color 35 -ANSI4
Write-ColorEX -Text "Cyan      (36)" -Color 36 -ANSI4
Write-ColorEX -Text "White     (37)" -Color 37 -ANSI4
#endregion

#region Bright 8 Colors (ANSI Codes 90-97)
Write-Host "`n▼ Bright 8 Colors (ANSI Codes 90-97)" -ForegroundColor Yellow
Write-Host "  Brighter/lighter versions of the standard 8 colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Bright Black/Gray  (90)" -Color 90 -ANSI4
Write-ColorEX -Text "Bright Red         (91)" -Color 91 -ANSI4
Write-ColorEX -Text "Bright Green       (92)" -Color 92 -ANSI4
Write-ColorEX -Text "Bright Yellow      (93)" -Color 93 -ANSI4
Write-ColorEX -Text "Bright Blue        (94)" -Color 94 -ANSI4
Write-ColorEX -Text "Bright Magenta     (95)" -Color 95 -ANSI4
Write-ColorEX -Text "Bright Cyan        (96)" -Color 96 -ANSI4
Write-ColorEX -Text "Bright White       (97)" -Color 97 -ANSI4
#endregion

#region All 16 Colors Side by Side
Write-Host "`n▼ All 16 Colors Comparison" -ForegroundColor Yellow
Write-Host "  Standard vs Bright variants`n" -ForegroundColor Gray

$colorPairs = @(
    @("Black  ", 30, 90),
    @("Red    ", 31, 91),
    @("Green  ", 32, 92),
    @("Yellow ", 33, 93),
    @("Blue   ", 34, 94),
    @("Magenta", 35, 95),
    @("Cyan   ", 36, 96),
    @("White  ", 37, 97)
)

foreach ($pair in $colorPairs) {
    Write-ColorEX -Text "$($pair[0]) Standard: " -Color White -ANSI4 -NoNewLine
    Write-ColorEX -Text "████" -Color $pair[1] -ANSI4 -NoNewLine
    Write-ColorEX -Text "  Bright: " -Color White -ANSI4 -NoNewLine
    Write-ColorEX -Text "████" -Color $pair[2] -ANSI4
}
#endregion

#region Background Colors (ANSI Codes 40-47, 100-107)
Write-Host "`n▼ Background Colors" -ForegroundColor Yellow
Write-Host "  Apply colors to the background (codes 40-47 standard, 100-107 bright)`n" -ForegroundColor Gray

# Standard backgrounds
Write-ColorEX -Text " Black BG (40)   " -Color 97 -BackGroundColor 40 -ANSI4
Write-ColorEX -Text " Red BG (41)     " -Color 97 -BackGroundColor 41 -ANSI4
Write-ColorEX -Text " Green BG (42)   " -Color 30 -BackGroundColor 42 -ANSI4
Write-ColorEX -Text " Yellow BG (43)  " -Color 30 -BackGroundColor 43 -ANSI4
Write-ColorEX -Text " Blue BG (44)    " -Color 97 -BackGroundColor 44 -ANSI4
Write-ColorEX -Text " Magenta BG (45) " -Color 97 -BackGroundColor 45 -ANSI4
Write-ColorEX -Text " Cyan BG (46)    " -Color 30 -BackGroundColor 46 -ANSI4
Write-ColorEX -Text " White BG (47)   " -Color 30 -BackGroundColor 47 -ANSI4

Write-Host ""

# Bright backgrounds
Write-ColorEX -Text " Bright Black BG (100)   " -Color 30 -BackGroundColor 100 -ANSI4
Write-ColorEX -Text " Bright Red BG (101)     " -Color 30 -BackGroundColor 101 -ANSI4
Write-ColorEX -Text " Bright Green BG (102)   " -Color 30 -BackGroundColor 102 -ANSI4
Write-ColorEX -Text " Bright Yellow BG (103)  " -Color 30 -BackGroundColor 103 -ANSI4
Write-ColorEX -Text " Bright Blue BG (104)    " -Color 30 -BackGroundColor 104 -ANSI4
Write-ColorEX -Text " Bright Magenta BG (105) " -Color 30 -BackGroundColor 105 -ANSI4
Write-ColorEX -Text " Bright Cyan BG (106)    " -Color 30 -BackGroundColor 106 -ANSI4
Write-ColorEX -Text " Bright White BG (107)   " -Color 30 -BackGroundColor 107 -ANSI4
#endregion

#region Combining Foreground and Background
Write-Host "`n▼ Foreground + Background Combinations" -ForegroundColor Yellow
Write-Host "  Create contrast with foreground and background colors`n" -ForegroundColor Gray

Write-ColorEX -Text " White on Red " -Color 97 -BackGroundColor 41 -ANSI4 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text " Black on Yellow " -Color 30 -BackGroundColor 43 -ANSI4 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text " White on Blue " -Color 97 -BackGroundColor 44 -ANSI4

Write-ColorEX -Text " Green on Black " -Color 92 -BackGroundColor 40 -ANSI4 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text " Yellow on Red " -Color 93 -BackGroundColor 41 -ANSI4 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text " Cyan on Magenta " -Color 96 -BackGroundColor 45 -ANSI4
#endregion

#region Text Styles with ANSI4
Write-Host "`n▼ Text Styles with ANSI4 Colors" -ForegroundColor Yellow
Write-Host "  Combine ANSI4 colors with text styling`n" -ForegroundColor Gray

Write-ColorEX -Text "Bold Red" -Color 91 -ANSI4 -Bold
Write-ColorEX -Text "Italic Cyan" -Color 96 -ANSI4 -Italic
Write-ColorEX -Text "Underline Green" -Color 92 -ANSI4 -Underline
Write-ColorEX -Text "Bold + Underline Yellow" -Color 93 -ANSI4 -Bold -Underline
#endregion

#region Using Named Colors with ANSI4 Mode
Write-Host "`n▼ Using Named Colors in ANSI4 Mode" -ForegroundColor Yellow
Write-Host "  PSWriteColorEX automatically maps named colors to ANSI4 codes`n" -ForegroundColor Gray

Write-ColorEX -Text "Red (named)" -Color Red -ANSI4
Write-ColorEX -Text "Green (named)" -Color Green -ANSI4
Write-ColorEX -Text "DarkYellow (named)" -Color DarkYellow -ANSI4
Write-ColorEX -Text "Cyan (named)" -Color Cyan -ANSI4
Write-ColorEX -Text "DarkMagenta (named)" -Color DarkMagenta -ANSI4
#endregion

#region Style Profiles with ANSI4
Write-Host "`n▼ Style Profiles with ANSI4" -ForegroundColor Yellow
Write-Host "  Create reusable style configurations using ANSI4 colors`n" -ForegroundColor Gray

# Create ANSI4 alert style
$alertStyle = New-ColorStyle -Name "Alert" `
                             -ForegroundColor 97 `
                             -BackgroundColor 41 `
                             -Bold

Write-ColorEX -Text " ⚠ ALERT: System requires attention " -StyleProfile $alertStyle -ANSI4

# Create success style
$successStyle = New-ColorStyle -Name "Success" `
                               -ForegroundColor 92 `
                               -Bold

Write-ColorEX -Text "✓ Operation completed successfully" -StyleProfile $successStyle -ANSI4

# Create info box style
$infoBoxStyle = New-ColorStyle -Name "InfoBox" `
                               -ForegroundColor 30 `
                               -BackgroundColor 106 `
                               -StartSpaces 2

Write-ColorEX -Text " ℹ Information: Data processed " -StyleProfile $infoBoxStyle -ANSI4
#endregion

#region Practical Example - Colored Menu with ANSI4
Write-Host "`n▼ Practical Example: ANSI4 Menu (NEW: AutoPad Alignment)" -ForegroundColor Yellow
Write-Host "  Create a menu using ANSI 16-color palette with perfect alignment`n" -ForegroundColor Gray

Write-ColorEX -Text "╔═══════════════════════════════════╗" -Color 96 -ANSI4
Write-ColorEX -Text "║         SYSTEM MENU               ║" -Color 96 -ANSI4 -Bold
Write-ColorEX -Text "╠═══════════════════════════════════╣" -Color 96 -ANSI4
Write-ColorEX -Text "║                                   ║" -Color 96 -ANSI4

Write-ColorEX -Text "║  [" -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "1" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "] " -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "Start Service" -AutoPad 29 -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "║" -Color 96 -ANSI4

Write-ColorEX -Text "║  [" -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "2" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "] " -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "Stop Service" -AutoPad 29 -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "║" -Color 96 -ANSI4

Write-ColorEX -Text "║  [" -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "3" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "] " -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "View Status" -AutoPad 29 -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "║" -Color 96 -ANSI4

Write-ColorEX -Text "║  [" -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "4" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "] " -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "Configuration" -AutoPad 29 -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "║" -Color 96 -ANSI4

Write-ColorEX -Text "║  [" -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "Q" -Color 91 -ANSI4 -NoNewLine
Write-ColorEX -Text "] " -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "Quit" -AutoPad 29 -Color 96 -ANSI4 -NoNewLine
Write-ColorEX -Text "║" -Color 96 -ANSI4

Write-ColorEX -Text "║                                   ║" -Color 96 -ANSI4
Write-ColorEX -Text "╚═══════════════════════════════════╝" -Color 96 -ANSI4

Write-ColorEX -Text "Select option: " -Color 93 -ANSI4 -NoNewLine
#endregion

#region Practical Example - Status Messages with ANSI4
Write-Host "`n`n▼ Practical Example: Status Output" -ForegroundColor Yellow
Write-Host "  Show process status with ANSI4 color coding`n" -ForegroundColor Gray

Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "●" -Color 92 -ANSI4 -NoNewLine
Write-ColorEX -Text "] Web Server      " -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "Running" -Color 92 -ANSI4

Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "●" -Color 92 -ANSI4 -NoNewLine
Write-ColorEX -Text "] Database        " -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "Running" -Color 92 -ANSI4

Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "●" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "] Cache Service   " -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "Warning - High Memory" -Color 93 -ANSI4

Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "●" -Color 91 -ANSI4 -NoNewLine
Write-ColorEX -Text "] API Gateway     " -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "Stopped" -Color 91 -ANSI4

Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "●" -Color 92 -ANSI4 -NoNewLine
Write-ColorEX -Text "] Load Balancer   " -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "Running" -Color 92 -ANSI4
#endregion

#region Practical Example - Log Output with ANSI4
Write-Host "`n▼ Practical Example: Colored Log Output" -ForegroundColor Yellow
Write-Host "  Format log messages with ANSI4 color levels`n" -ForegroundColor Gray

Write-ColorEX -Text "[INFO] " -Color 96 -ANSI4 -NoNewLine -ShowTime
Write-ColorEX -Text "Application started successfully" -Color 97 -ANSI4

Write-ColorEX -Text "[DEBUG] " -Color 90 -ANSI4 -NoNewLine -ShowTime
Write-ColorEX -Text "Loading configuration from file" -Color 37 -ANSI4

Write-ColorEX -Text "[WARN] " -Color 93 -ANSI4 -NoNewLine -ShowTime
Write-ColorEX -Text "Configuration file missing, using defaults" -Color 97 -ANSI4

Write-ColorEX -Text "[ERROR] " -Color 91 -ANSI4 -NoNewLine -ShowTime
Write-ColorEX -Text "Failed to connect to remote server" -Color 97 -ANSI4

Write-ColorEX -Text "[INFO] " -Color 96 -ANSI4 -NoNewLine -ShowTime
Write-ColorEX -Text "Retrying connection in 5 seconds..." -Color 97 -ANSI4

Write-ColorEX -Text "[SUCCESS] " -Color 92 -ANSI4 -NoNewLine -ShowTime
Write-ColorEX -Text "Connection established" -Color 97 -ANSI4
#endregion

#region Practical Example - Progress Indicator
Write-Host "`n▼ Practical Example: Progress Indicator" -ForegroundColor Yellow
Write-Host "  Show progress with ANSI4 colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Installation Progress:" -Color 97 -ANSI4 -Bold

# 0%
Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "░░░░░░░░░░" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "] 0%   Initializing..." -Color 90 -ANSI4

Start-Sleep -Milliseconds 300

# 30%
Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "███" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "░░░░░░░" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "] 30%  Downloading files..." -Color 93 -ANSI4

Start-Sleep -Milliseconds 300

# 60%
Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "██████" -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text "░░░░" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "] 60%  Installing..." -Color 93 -ANSI4

Start-Sleep -Milliseconds 300

# 100%
Write-ColorEX -Text "[" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "██████████" -Color 92 -ANSI4 -NoNewLine
Write-ColorEX -Text "] 100% Complete!" -Color 92 -ANSI4
#endregion

#region Practical Example - Data Table with ANSI4
Write-Host "`n▼ Practical Example: Data Table" -ForegroundColor Yellow
Write-Host "  Format tabular data with ANSI4 colors`n" -ForegroundColor Gray

Write-ColorEX -Text "┌─────────────┬────────┬──────────┬─────────┐" -Color 96 -ANSI4
Write-ColorEX -Text "│ User        │ Status │ Last Login│ Role    │" -Color 96 -ANSI4 -Bold
Write-ColorEX -Text "├─────────────┼────────┼──────────┼─────────┤" -Color 96 -ANSI4

Write-ColorEX -Text "│ alice       │ " -Color 97 -ANSI4 -NoNewLine
Write-ColorEX -Text "Active" -Color 92 -ANSI4 -NoNewLine
Write-ColorEX -Text " │ 2h ago   │ Admin   │" -Color 97 -ANSI4

Write-ColorEX -Text "│ bob         │ " -Color 97 -ANSI4 -NoNewLine
Write-ColorEX -Text "Active" -Color 92 -ANSI4 -NoNewLine
Write-ColorEX -Text " │ 5m ago   │ User    │" -Color 97 -ANSI4

Write-ColorEX -Text "│ charlie     │ " -Color 97 -ANSI4 -NoNewLine
Write-ColorEX -Text "Away  " -Color 93 -ANSI4 -NoNewLine
Write-ColorEX -Text " │ 1d ago   │ User    │" -Color 97 -ANSI4

Write-ColorEX -Text "│ dana        │ " -Color 97 -ANSI4 -NoNewLine
Write-ColorEX -Text "Offline" -Color 90 -ANSI4 -NoNewLine
Write-ColorEX -Text "│ 3d ago   │ Guest   │" -Color 97 -ANSI4

Write-ColorEX -Text "└─────────────┴────────┴──────────┴─────────┘" -Color 96 -ANSI4
#endregion

#region Practical Example - Diff-Style Output
Write-Host "`n▼ Practical Example: Diff-Style Output" -ForegroundColor Yellow
Write-Host "  Show additions and deletions like git diff`n" -ForegroundColor Gray

Write-ColorEX -Text "File: config.json" -Color 97 -ANSI4 -Bold
Write-ColorEX -Text "─────────────────────────────" -Color 90 -ANSI4

Write-ColorEX -Text "  {" -Color 97 -ANSI4
Write-ColorEX -Text "    `"host`": `"localhost`"," -Color 97 -ANSI4
Write-ColorEX -Text "-   `"port`": 8080," -Color 91 -ANSI4
Write-ColorEX -Text "+   `"port`": 8443," -Color 92 -ANSI4
Write-ColorEX -Text "    `"ssl`": true," -Color 97 -ANSI4
Write-ColorEX -Text "-   `"debug`": false" -Color 91 -ANSI4
Write-ColorEX -Text "+   `"debug`": true" -Color 92 -ANSI4
Write-ColorEX -Text "  }" -Color 97 -ANSI4
#endregion

#region Practical Example - Alert Banner
Write-Host "`n▼ Practical Example: Alert Banner" -ForegroundColor Yellow
Write-Host "  Create attention-grabbing alerts with ANSI4`n" -ForegroundColor Gray

Write-ColorEX -BlankLine -BackGroundColor 41
Write-ColorEX -Text "    ⚠  CRITICAL ALERT ⚠    " -Color 97 -BackGroundColor 41 -Bold -HorizontalCenter
Write-ColorEX -Text "  System maintenance in 10 minutes  " -Color 97 -BackGroundColor 41 -HorizontalCenter
Write-ColorEX -BlankLine -BackGroundColor 41

Write-Host ""

Write-ColorEX -BlankLine -BackGroundColor 42
Write-ColorEX -Text "    ✓ SUCCESS ✓    " -Color 30 -BackGroundColor 42 -Bold -HorizontalCenter
Write-ColorEX -Text "  Backup completed successfully  " -Color 30 -BackGroundColor 42 -HorizontalCenter
Write-ColorEX -BlankLine -BackGroundColor 42
#endregion

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║            END OF ANSI4 EXAMPLES (16-color)               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Compatibility note
Write-ColorEX -Text "💡 Tip: " -Color Yellow -NoNewLine
Write-ColorEX -Text "ANSI4 (16-color) mode is supported by most terminals and provides excellent compatibility" -Color Gray
