<#
.SYNOPSIS
    ANSI 8-bit (256-color) examples for PSWriteColorEX
.DESCRIPTION
    Demonstrates ANSI 8-bit color mode functionality (256 colors).
    Includes: 16 basic colors, 216 color cube (6x6x6), and 24 grayscale shades.
.NOTES
    ANSI 8-bit color codes:
    - 0-15:   Standard ANSI colors (same as ANSI4)
    - 16-231: 6x6x6 RGB color cube (216 colors)
    - 232-255: Grayscale ramp (24 shades from black to white)
#>

# Import module if not already loaded
if (-not (Get-Module PSWriteColorEX)) {
    Import-Module PSWriteColorEX -Force
}

Clear-Host
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        PSWriteColorEX - ANSI8 EXAMPLES (256-color)        ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

#region Terminal Capability Check
Write-Host "▼ Terminal Color Support Detection" -ForegroundColor Yellow
Write-Host "  Checking ANSI 8-bit support (256 colors)`n" -ForegroundColor Gray

$colorSupportInfo = Test-AnsiSupport -Silent
$colorSupport = $colorSupportInfo.ColorSupport
Write-ColorEX -Text "Detected color support level: ", $colorSupport -Color White, Yellow

switch ($colorSupport) {
    'TrueColor' {
        Write-ColorEX -Text "✓ TrueColor supported! ANSI8 will work perfectly." -Color Green
    }
    'ANSI8' {
        Write-ColorEX -Text "✓ ANSI8 (256 colors) is supported!" -Color Green
        Write-ColorEX -Text "  You have access to 256 colors from the ANSI palette" -Color Gray
    }
    'ANSI4' {
        Write-ColorEX -Text "⚠ Only 16 colors supported - ANSI8 colors will be approximated" -Color Yellow
    }
    default {
        Write-ColorEX -Text "⚠ ANSI not supported - using basic PowerShell colors" -Color Yellow
    }
}
#endregion

#region Basic 16 Colors (0-15)
Write-Host "`n▼ Basic 16 Colors (Codes 0-15)" -ForegroundColor Yellow
Write-Host "  The first 16 colors match ANSI4 palette`n" -ForegroundColor Gray

for ($i = 0; $i -lt 16; $i++) {
    $label = "{0,3}: " -f $i
    Write-ColorEX -Text $label, "████████" -Color White, $i -ANSI8 -NoNewLine

    # Add line break every 4 colors
    if (($i + 1) % 4 -eq 0) {
        Write-ColorEX -Text ""
    } else {
        Write-ColorEX -Text "  " -NoNewLine
    }
}
#endregion

#region Color Cube (16-231)
Write-Host "`n▼ 6x6x6 RGB Color Cube (Codes 16-231)" -ForegroundColor Yellow
Write-Host "  216 colors arranged in a 6x6x6 RGB cube`n" -ForegroundColor Gray

Write-ColorEX -Text "Red Levels (Green=0, Blue=0):" -Color White -Bold
$redRange = @(16, 52, 88, 124, 160, 196)
foreach ($color in $redRange) {
    Write-ColorEX -Text ("{0,3}: " -f $color), "████" -Color White, $color -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

Write-ColorEX -Text "`nGreen Levels (Red=0, Blue=0):" -Color White -Bold
$greenRange = @(16, 22, 28, 34, 40, 46)
foreach ($color in $greenRange) {
    Write-ColorEX -Text ("{0,3}: " -f $color), "████" -Color White, $color -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

Write-ColorEX -Text "`nBlue Levels (Red=0, Green=0):" -Color White -Bold
$blueRange = @(16, 17, 18, 19, 20, 21)
foreach ($color in $blueRange) {
    Write-ColorEX -Text ("{0,3}: " -f $color), "████" -Color White, $color -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

# Show color cube grid sample
Write-ColorEX -Text "`nColor Cube Sample (Red=Max, varying Green/Blue):" -Color White -Bold
$cubeStart = 196  # High red
for ($i = 0; $i -lt 36; $i++) {
    $color = $cubeStart + $i
    Write-ColorEX -Text "█" -Color $color -ANSI8 -NoNewLine
    if (($i + 1) % 6 -eq 0) {
        Write-ColorEX -Text ""
    }
}
#endregion

#region Grayscale Ramp (232-255)
Write-Host "`n▼ Grayscale Ramp (Codes 232-255)" -ForegroundColor Yellow
Write-Host "  24 shades of gray from nearly black to nearly white`n" -ForegroundColor Gray

# Display all 24 grayscale values
for ($i = 232; $i -le 255; $i++) {
    Write-ColorEX -Text ("{0,3}" -f $i) -Color $i -ANSI8 -NoNewLine
    if (($i - 231) % 8 -eq 0) {
        Write-ColorEX -Text ""
    } else {
        Write-ColorEX -Text " " -NoNewLine
    }
}

# Display grayscale as gradient
Write-ColorEX -Text "`nGrayscale Gradient:" -Color White -Bold
$grayscaleText = @("█") * 24
$grayscaleColors = 232..255
Write-ColorEX -Text $grayscaleText -Color $grayscaleColors -ANSI8
#endregion

#region Popular ANSI8 Colors
Write-Host "`n▼ Popular ANSI8 Colors" -ForegroundColor Yellow
Write-Host "  Commonly used colors from the 256-color palette`n" -ForegroundColor Gray

$popularColors = @(
    @("Orange (208)", 208),
    @("Hot Pink (205)", 205),
    @("Purple (135)", 135),
    @("Sky Blue (117)", 117),
    @("Lime Green (118)", 118),
    @("Gold (220)", 220),
    @("Salmon (209)", 209),
    @("Turquoise (80)", 80)
)

foreach ($color in $popularColors) {
    Write-ColorEX -Text $color[0], " ████████" -Color White, $color[1] -ANSI8
}
#endregion

#region Color Ranges
Write-Host "`n▼ Color Ranges and Variations" -ForegroundColor Yellow
Write-Host "  Explore color gradients within the 256-color palette`n" -ForegroundColor Gray

# Reds
Write-ColorEX -Text "Reds (52, 88, 124, 160, 196):" -Color White -Bold
$reds = @(52, 88, 124, 160, 196)
foreach ($c in $reds) {
    Write-ColorEX -Text "████ " -Color $c -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

# Greens
Write-ColorEX -Text "Greens (22, 28, 34, 40, 46):" -Color White -Bold
$greens = @(22, 28, 34, 40, 46)
foreach ($c in $greens) {
    Write-ColorEX -Text "████ " -Color $c -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

# Blues
Write-ColorEX -Text "Blues (17, 18, 19, 20, 21, 27):" -Color White -Bold
$blues = @(17, 18, 19, 20, 21, 27)
foreach ($c in $blues) {
    Write-ColorEX -Text "████ " -Color $c -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

# Purples
Write-ColorEX -Text "Purples (53, 54, 55, 56, 57, 93):" -Color White -Bold
$purples = @(53, 54, 55, 56, 57, 93)
foreach ($c in $purples) {
    Write-ColorEX -Text "████ " -Color $c -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""

# Oranges/Browns
Write-ColorEX -Text "Oranges (130, 136, 166, 172, 208, 214):" -Color White -Bold
$oranges = @(130, 136, 166, 172, 208, 214)
foreach ($c in $oranges) {
    Write-ColorEX -Text "████ " -Color $c -ANSI8 -NoNewLine
}
Write-ColorEX -Text ""
#endregion

#region Background Colors with ANSI8
Write-Host "`n▼ Background Colors with ANSI8" -ForegroundColor Yellow
Write-Host "  Use any of the 256 colors as backgrounds`n" -ForegroundColor Gray

Write-ColorEX -Text " Orange Background (208) " -Color 0 -BackGroundColor 208 -ANSI8
Write-ColorEX -Text " Purple Background (135) " -Color 15 -BackGroundColor 135 -ANSI8
Write-ColorEX -Text " Pink Background (205) " -Color 0 -BackGroundColor 205 -ANSI8
Write-ColorEX -Text " Teal Background (30) " -Color 15 -BackGroundColor 30 -ANSI8
Write-ColorEX -Text " Dark Gray Background (237) " -Color 15 -BackGroundColor 237 -ANSI8
#endregion

#region Using Style Profiles with ANSI8
Write-Host "`n▼ Style Profiles with ANSI8 Colors" -ForegroundColor Yellow
Write-Host "  Create styles using specific ANSI8 color codes`n" -ForegroundColor Gray

# Sunset theme (orange/pink)
$sunsetStyle = New-ColorStyle -Name "Sunset" `
                              -ForegroundColor 208 `
                              -BackgroundColor 52 `
                              -Bold

Write-ColorEX -Text "  Sunset Theme (208 on 52)  " -StyleProfile $sunsetStyle -ANSI8

# Ocean theme (blue/cyan)
$oceanStyle = New-ColorStyle -Name "Ocean" `
                             -ForegroundColor 117 `
                             -BackgroundColor 24

Write-ColorEX -Text "  Ocean Theme (117 on 24)  " -StyleProfile $oceanStyle -ANSI8

# Forest theme (green)
$forestStyle = New-ColorStyle -Name "Forest" `
                              -ForegroundColor 156 `
                              -BackgroundColor 22

Write-ColorEX -Text "  Forest Theme (156 on 22)  " -StyleProfile $forestStyle -ANSI8
#endregion

#region Practical Example - Enhanced Menu
Write-Host "`n▼ Practical Example: Enhanced Menu with ANSI8 (NEW: Unicode-Aware AutoPad)" -ForegroundColor Yellow
Write-Host "  Create a rich, colorful menu using 256 colors with emoji (AutoPad handles Unicode!)`n" -ForegroundColor Gray

Write-ColorEX -Text "╔══════════════════════════════════════════╗" -Color 117 -ANSI8 -Bold
Write-ColorEX -Text "║          APPLICATION CONTROL PANEL       ║" -Color 117 -ANSI8 -Bold
Write-ColorEX -Text "╠══════════════════════════════════════════╣" -Color 117 -ANSI8
Write-ColorEX -Text "║                                          ║" -Color 117 -ANSI8

Write-ColorEX -Text "║  [" -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "1" -Color 220 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "] " -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "🚀 Start Services" -AutoPad 36 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 117 -ANSI8

Write-ColorEX -Text "║  [" -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "2" -Color 220 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "] " -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "🛑 Stop Services" -AutoPad 36 -Color 196 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 117 -ANSI8

Write-ColorEX -Text "║  [" -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "3" -Color 220 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "] " -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "📊 View Dashboard" -AutoPad 36 -Color 141 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 117 -ANSI8

Write-ColorEX -Text "║  [" -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "4" -Color 220 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "] " -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "⚙️  Configuration" -AutoPad 36 -Color 246 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 117 -ANSI8

Write-ColorEX -Text "║  [" -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "5" -Color 220 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "] " -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "📁 Export Logs" -AutoPad 36 -Color 214 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 117 -ANSI8

Write-ColorEX -Text "║  [" -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "Q" -Color 196 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "] " -Color 117 -ANSI8 -NoNewLine
Write-ColorEX -Text "❌ Exit" -AutoPad 36 -Color 246 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 117 -ANSI8

Write-ColorEX -Text "║                                          ║" -Color 117 -ANSI8
Write-ColorEX -Text "╚══════════════════════════════════════════╝" -Color 117 -ANSI8 -Bold

Write-ColorEX -Text "`nEnter your choice: " -Color 220 -ANSI8 -Bold -NoNewLine
Write-ColorEX -Text "(Notice perfect alignment despite emoji taking 2 cells each!)" -Color 246 -ANSI8
#endregion

#region Practical Example - Rich Status Dashboard
Write-Host "`n`n▼ Practical Example: Rich Status Dashboard (NEW: AutoPad Alignment)" -ForegroundColor Yellow
Write-Host "  Display system status with detailed color coding and Unicode-aware padding`n" -ForegroundColor Gray

Write-ColorEX -Text "╔══════════════════════ ","SYSTEM STATUS"," ══════════════════════╗" `
              -Color 75 -ANSI8

Write-ColorEX -Text "║ Component        Status    CPU    Memory   Health         ║" `
              -Color 75 -ANSI8

Write-ColorEX -Text "╠═══════════════════════════════════════════════════════════╣" `
              -Color 75 -ANSI8

# Web Server - Good
Write-ColorEX -Text "║ " -Color 75 -ANSI8 -NoNewLine
Write-ColorEX -Text "Web Server" -AutoPad 17 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 46 -ANSI8 -NoNewLine  # Bright green, takes 2 cells
Write-ColorEX -Text " Active" -AutoPad 8 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "45%" -AutoPad 6 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "2.1GB" -AutoPad 8 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "█████████░ 90%" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " ║" -Color 75 -ANSI8

# Database - Warning
Write-ColorEX -Text "║ " -Color 75 -ANSI8 -NoNewLine
Write-ColorEX -Text "Database" -AutoPad 17 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 226 -ANSI8 -NoNewLine  # Yellow, takes 2 cells
Write-ColorEX -Text " Active" -AutoPad 8 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "89%" -AutoPad 6 -Color 208 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "4.5GB" -AutoPad 8 -Color 208 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "██████░░░░ 60%" -Color 226 -ANSI8 -NoNewLine
Write-ColorEX -Text " ║" -Color 75 -ANSI8

# Cache - Error
Write-ColorEX -Text "║ " -Color 75 -ANSI8 -NoNewLine
Write-ColorEX -Text "Cache Service" -AutoPad 17 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 196 -ANSI8 -NoNewLine  # Red, takes 2 cells
Write-ColorEX -Text " Failed" -AutoPad 8 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "0%" -AutoPad 6 -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "0MB" -AutoPad 8 -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "░░░░░░░░░░  0%" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text " ║" -Color 75 -ANSI8

# API Gateway - Good
Write-ColorEX -Text "║ " -Color 75 -ANSI8 -NoNewLine
Write-ColorEX -Text "API Gateway" -AutoPad 17 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " Active" -AutoPad 8 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "32%" -AutoPad 6 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "1.8GB" -AutoPad 8 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "██████████ 100%" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text "║" -Color 75 -ANSI8

# Load Balancer - Good
Write-ColorEX -Text "║ " -Color 75 -ANSI8 -NoNewLine
Write-ColorEX -Text "Load Balancer" -AutoPad 17 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " Active" -AutoPad 8 -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "28%" -AutoPad 6 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "1.2GB" -AutoPad 8 -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " " -NoNewLine
Write-ColorEX -Text "████████░░ 80%" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " ║" -Color 75 -ANSI8

Write-ColorEX -Text "╚═══════════════════════════════════════════════════════════╝" `
              -Color 75 -ANSI8

Write-Host "  ✅ Note: All rows stay perfectly aligned despite ● taking 2 cells!" -ForegroundColor DarkGray

# Summary
Write-ColorEX -Text "`nOverall Status: " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "4 OK" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " | " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "1 Warning" -Color 226 -ANSI8 -NoNewLine
Write-ColorEX -Text " | " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "1 Error" -Color 196 -ANSI8
#endregion

#region Practical Example - Log Viewer
Write-Host "`n▼ Practical Example: Enhanced Log Viewer" -ForegroundColor Yellow
Write-Host "  Color-coded log output with ANSI8 severity levels`n" -ForegroundColor Gray

Write-ColorEX -Text "[TRACE]   " -Color 240 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Entering function ProcessRequest()" -Color 245 -ANSI8

Write-ColorEX -Text "[DEBUG]   " -Color 117 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Request ID: 12345, Method: GET, Path: /api/users" -Color 152 -ANSI8

Write-ColorEX -Text "[INFO]    " -Color 156 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Processing request from 192.168.1.100" -Color 252 -ANSI8

Write-ColorEX -Text "[NOTICE]  " -Color 75 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Database query executed in 45ms" -Color 252 -ANSI8

Write-ColorEX -Text "[WARNING] " -Color 220 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Response time exceeds threshold (>100ms)" -Color 252 -ANSI8

Write-ColorEX -Text "[ERROR]   " -Color 208 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Failed to retrieve cached data, using database" -Color 252 -ANSI8

Write-ColorEX -Text "[CRITICAL]" -Color 196 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Service dependency unavailable!" -Color 252 -ANSI8 -Bold

Write-ColorEX -Text "[SUCCESS] " -Color 46 -ANSI8 -NoNewLine -ShowTime
Write-ColorEX -Text "Request completed successfully in 156ms" -Color 252 -ANSI8
#endregion

#region Practical Example - Heat Map
Write-Host "`n▼ Practical Example: Performance Heat Map" -ForegroundColor Yellow
Write-Host "  Visualize data with color-coded heat map`n" -ForegroundColor Gray

Write-ColorEX -Text "Server Response Times (ms) - Last 24 Hours:" -Color White -Bold

$hours = 0..23
$responseTimes = @(45, 42, 43, 47, 89, 145, 198, 234, 187, 156, 123, 98,
                   76, 67, 72, 88, 134, 176, 198, 165, 132, 98, 67, 51)

Write-ColorEX -Text "Hour: " -Color 246 -ANSI8 -NoNewLine

foreach ($hour in $hours) {
    $displayHour = "{0,2}" -f $hour
    Write-ColorEX -Text $displayHour -Color 246 -ANSI8 -NoNewLine
    if (($hour + 1) % 12 -eq 0 -and $hour -ne 23) {
        Write-ColorEX -Text "`n      " -NoNewLine
    } elseif ($hour -ne 23) {
        Write-ColorEX -Text " " -NoNewLine
    }
}
Write-ColorEX -Text ""

Write-ColorEX -Text "Time: " -Color 246 -ANSI8 -NoNewLine

foreach ($i in 0..23) {
    $time = $responseTimes[$i]

    # Color based on response time
    $color = if ($time -lt 50) { 46 }        # Green - Excellent
             elseif ($time -lt 100) { 156 }   # Light Green - Good
             elseif ($time -lt 150) { 226 }   # Yellow - Acceptable
             elseif ($time -lt 200) { 208 }   # Orange - Slow
             else { 196 }                     # Red - Critical

    Write-ColorEX -Text "██" -Color $color -ANSI8 -NoNewLine
    if (($i + 1) % 12 -eq 0 -and $i -ne 23) {
        Write-ColorEX -Text "`n      " -NoNewLine
    }
}
Write-ColorEX -Text ""

# Legend
Write-ColorEX -Text "`nLegend: " -Color White -Bold
Write-ColorEX -Text "██" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " <50ms  " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "██" -Color 156 -ANSI8 -NoNewLine
Write-ColorEX -Text " <100ms  " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "██" -Color 226 -ANSI8 -NoNewLine
Write-ColorEX -Text " <150ms  " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "██" -Color 208 -ANSI8 -NoNewLine
Write-ColorEX -Text " <200ms  " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "██" -Color 196 -ANSI8 -NoNewLine
Write-ColorEX -Text " >200ms" -Color 252 -ANSI8
#endregion

#region Practical Example - Progress with Gradient
Write-Host "`n▼ Practical Example: Multi-Stage Progress" -ForegroundColor Yellow
Write-Host "  Show detailed progress with gradient colors`n" -ForegroundColor Gray

Write-ColorEX -Text "Deployment Pipeline:" -Color White -Bold

# Stage 1 - Complete
Write-ColorEX -Text "├─ " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " Build      " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "[" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "██████████" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text "] " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "100% ✓" -Color 46 -ANSI8

# Stage 2 - Complete
Write-ColorEX -Text "├─ " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text " Test       " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "[" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "██████████" -Color 46 -ANSI8 -NoNewLine
Write-ColorEX -Text "] " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "100% ✓" -Color 46 -ANSI8

# Stage 3 - In Progress
Write-ColorEX -Text "├─ " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "●" -Color 226 -ANSI8 -NoNewLine
Write-ColorEX -Text " Deploy     " -Color 252 -ANSI8 -NoNewLine
Write-ColorEX -Text "[" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "██████" -Color 226 -ANSI8 -NoNewLine
Write-ColorEX -Text "░░░░" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "] " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "60% ..." -Color 226 -ANSI8

# Stage 4 - Pending
Write-ColorEX -Text "└─ " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "○" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text " Verify     " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "[" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "░░░░░░░░░░" -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "] " -Color 240 -ANSI8 -NoNewLine
Write-ColorEX -Text "0% Waiting" -Color 240 -ANSI8
#endregion

#region Gradient Effects in ANSI8
Write-Host "`n▼ Gradient Effects with ANSI8 (256-color)" -ForegroundColor Yellow
Write-Host "  Automatic gradient interpolation using the -Gradient parameter`n" -ForegroundColor Gray

# Simple two-color gradient (ANSI8)
Write-ColorEX -Text "Two-Color Gradient:" -Color White -Bold
Write-ColorEX -Text "RED TO BLUE GRADIENT IN 256 COLORS" -Gradient @('Red', 'Blue') -ANSI8

# Multi-stop gradient
Write-ColorEX -Text "`nMulti-Stop Rainbow Gradient:" -Color White -Bold
Write-ColorEX -Text "RED ORANGE YELLOW GREEN CYAN BLUE MAGENTA RAINBOW" `
              -Gradient @('Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta') `
              -ANSI8

# Grayscale gradient
Write-ColorEX -Text "`nGrayscale Gradient:" -Color White -Bold
Write-ColorEX -Text "BLACK TO WHITE SMOOTH GRAYSCALE TRANSITION" `
              -Gradient @('Black', 'Gray', 'White') `
              -ANSI8

# Fire gradient
Write-ColorEX -Text "`nFire Gradient (Warm Colors):" -Color White -Bold
Write-ColorEX -Text "HOT FLAME EFFECT WITH MULTIPLE COLOR STOPS" `
              -Gradient @('DarkRed', 'Red', 'Orange', 'Yellow') `
              -ANSI8 -Bold

# Ice gradient
Write-ColorEX -Text "`nIce Gradient (Cool Colors):" -Color White -Bold
Write-ColorEX -Text "COLD ICE EFFECT WITH BLUE TONES" `
              -Gradient @('DarkBlue', 'Blue', 'Cyan', 'White') `
              -ANSI8

# Gradient with specific ANSI8 codes
Write-ColorEX -Text "`nGradient with Named Colors:" -Color White -Bold
Write-ColorEX -Text "CUSTOM COLOR PALETTE GRADIENT" `
              -Gradient @('Magenta', 'Violet', 'Blue', 'Cyan') `
              -ANSI8

# Centered gradient header
Write-ColorEX -Text "`nCentered Gradient Header:" -Color White -Bold
Write-ColorEX -Text "═══ ANSI8 GRADIENT BANNER ═══" `
              -Gradient @('Cyan', 'Blue', 'Magenta') `
              -ANSI8 -Bold -HorizontalCenter

# Gradient style profile
Write-ColorEX -Text "`nGradient Style Profile:" -Color White -Bold
$rainbowStyle = New-ColorStyle -Name "Rainbow256" `
                               -Gradient @('Red','Yellow','Green','Cyan','Blue','Magenta') `
                               -Bold
Write-ColorEX -Text "STYLE PROFILE WITH GRADIENT IN ANSI8" -StyleProfile $rainbowStyle -ANSI8

Write-ColorEX -Text "`n💡 Note: ANSI8 gradients use 256-color palette, which may show slight banding." -Color Gray
Write-ColorEX -Text "   For smoothest gradients, use TrueColor mode (see 02-TrueColorExamples.ps1)" -Color Gray
#endregion

#region Complete Color Palette Display
Write-Host "`n▼ Complete ANSI8 Palette (Optional)" -ForegroundColor Yellow
Write-Host "  Uncomment below to see all 256 colors`n" -ForegroundColor Gray

<#
Write-ColorEX -Text "All 256 ANSI Colors:" -Color White -Bold
for ($i = 0; $i -lt 256; $i++) {
    $label = "{0,3} " -f $i
    Write-ColorEX -Text $label -Color $i -ANSI8 -NoNewLine

    if (($i + 1) % 16 -eq 0) {
        Write-ColorEX -Text ""
    }
}
#>

Write-ColorEX -Text "💡 Uncomment the code in the script to display all 256 colors" -Color 246 -ANSI8
#endregion

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           END OF ANSI8 EXAMPLES (256-color)               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Compatibility note
Write-ColorEX -Text "💡 Tip: " -Color Yellow -NoNewLine
Write-ColorEX -Text "ANSI8 (256-color) is supported by most modern terminals and provides excellent color range" -Color Gray
