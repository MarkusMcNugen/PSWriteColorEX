<#
.SYNOPSIS
    Basic usage examples for PSWriteColorEX
.DESCRIPTION
    Demonstrates fundamental colored output functionality including basic colors,
    text formatting, helper functions, and style profiles.
.NOTES
    These examples work with native PowerShell colors (no ANSI required)
#>

# Import module if not already loaded
if (-not (Get-Module PSWriteColorEX)) {
    Import-Module PSWriteColorEX -Force
}

Clear-Host
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          PSWriteColorEX - BASIC USAGE EXAMPLES            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

#region Simple Colored Text
Write-Host "▼ Simple Colored Text" -ForegroundColor Yellow
Write-Host "  Basic color output using standard PowerShell color names`n" -ForegroundColor Gray

Write-ColorEX -Text "This is red text" -Color Red
Write-ColorEX -Text "This is blue text" -Color Blue
Write-ColorEX -Text "This is green text" -Color Green
Write-ColorEX -Text "This is yellow text" -Color Yellow

# Using shortened parameter names
Write-ColorEX -T "Cyan with shortened parameters" -C Cyan
#endregion

#region Multiple Colors in One Line
Write-Host "`n▼ Multiple Colors in One Line" -ForegroundColor Yellow
Write-Host "  Combine multiple colored text segments seamlessly`n" -ForegroundColor Gray

Write-ColorEX -Text "Red ", "Green ", "Blue ", "Yellow" -Color Red, Green, Blue, Yellow
Write-ColorEX -Text "Status: ", "OK", " | Errors: ", "0" -Color Gray, Green, Gray, Cyan
Write-ColorEX -Text "[", "INFO", "] ", "System initialized successfully" -Color Gray, Cyan, Gray, White
#endregion

#region Background Colors
Write-Host "`n▼ Background Colors" -ForegroundColor Yellow
Write-Host "  Add background colors for emphasis or highlighting`n" -ForegroundColor Gray

Write-ColorEX -Text "White text on Blue background" -Color White -BackGroundColor Blue
Write-ColorEX -Text "Yellow text on DarkRed background" -Color Yellow -BackGroundColor DarkRed
Write-ColorEX -Text "  HIGHLIGHTED TEXT  " -Color Black -BackGroundColor Yellow
Write-ColorEX -Text " WARNING ZONE " -Color White -BackGroundColor DarkRed -Bold
#endregion

#region Color Cycling
Write-Host "`n▼ Color Cycling" -ForegroundColor Yellow
Write-Host "  Colors automatically cycle when you have more text segments than colors`n" -ForegroundColor Gray

Write-ColorEX -Text "A ", "B ", "C ", "D ", "E ", "F ", "G ", "H" -Color Red, Blue
Write-ColorEX -Text "1 ", "2 ", "3 ", "4 ", "5" -Color Green, Yellow, Magenta
#endregion

#region Helper Functions
Write-Host "`n▼ Helper Functions" -ForegroundColor Yellow
Write-Host "  Pre-configured functions for common message types`n" -ForegroundColor Gray

Write-ColorError "This is an error message - Red and Bold"
Write-ColorWarning "This is a warning message - Yellow"
Write-ColorInfo "This is an info message - Cyan"
Write-ColorSuccess "This is a success message - Green"
Write-ColorCritical "This is a critical message - White on DarkRed with Blink"
Write-ColorDebug "This is a debug message - DarkGray and Italic"
#endregion

#region Text Formatting - Indentation
Write-Host "`n▼ Text Formatting - Indentation" -ForegroundColor Yellow
Write-Host "  Control spacing and indentation of your output`n" -ForegroundColor Gray

Write-ColorEX -Text "Normal position" -Color White
Write-ColorEX -Text "Indented with 1 tab" -Color Cyan -StartTab 1
Write-ColorEX -Text "Indented with 2 tabs" -Color Cyan -StartTab 2
Write-ColorEX -Text "Indented with 10 spaces" -Color Magenta -StartSpaces 10
Write-ColorEX -Text "Indented with 20 spaces" -Color Magenta -StartSpaces 20
#endregion

#region Text Formatting - Spacing
Write-Host "`n▼ Text Formatting - Line Spacing" -ForegroundColor Yellow
Write-Host "  Add blank lines before and after text`n" -ForegroundColor Gray

Write-ColorEX -Text "Text with 1 line before" -Color Yellow -LinesBefore 1
Write-ColorEX -Text "Text with 1 line after" -Color Yellow -LinesAfter 1
Write-ColorEX -Text "Text with lines before AND after" -Color Cyan -LinesBefore 1 -LinesAfter 1
#endregion

#region Text Formatting - Centering
Write-Host "`n▼ Text Centering" -ForegroundColor Yellow
Write-Host "  Center text horizontally in the console`n" -ForegroundColor Gray

Write-ColorEX -Text "═══════════════════════════════════" -Color DarkGray -HorizontalCenter
Write-ColorEX -Text "CENTERED HEADER" -Color Green -Bold -HorizontalCenter
Write-ColorEX -Text "═══════════════════════════════════" -Color DarkGray -HorizontalCenter
#endregion

#region Blank Lines and Separators
Write-Host "`n▼ Blank Lines and Separators" -ForegroundColor Yellow
Write-Host "  Create visual separators with colored blank lines`n" -ForegroundColor Gray

Write-ColorEX -BlankLine -BackGroundColor DarkGray
Write-ColorEX -Text "Content between separators" -Color White
Write-ColorEX -BlankLine -BackGroundColor DarkBlue
Write-ColorEX -Text "More content" -Color White
Write-ColorEX -BlankLine -BackGroundColor DarkGreen
#endregion

#region Timestamps
Write-Host "`n▼ Timestamps" -ForegroundColor Yellow
Write-Host "  Add timestamps to your output (useful for logging)`n" -ForegroundColor Gray

Write-ColorEX -Text "Message with default timestamp" -Color Cyan -ShowTime
Write-ColorEX -Text "Another timed message" -Color Green -ShowTime
Write-ColorEX -Text "Custom format timestamp" -Color Yellow -ShowTime -DateTimeFormat "HH:mm:ss.fff"
#endregion

#region Style Profiles
Write-Host "`n▼ Using Style Profiles" -ForegroundColor Yellow
Write-Host "  Create reusable style configurations with New-ColorStyle`n" -ForegroundColor Gray

# Create a custom style profile
$headerStyle = New-ColorStyle -Name "Header" `
                              -ForegroundColor Cyan `
                              -Bold `
                              -HorizontalCenter `
                              -LinesBefore 1

Write-ColorEX -Text "USING A STYLE PROFILE" -StyleProfile $headerStyle

# Create and use a notification style
$notificationStyle = New-ColorStyle -Name "Notification" `
                                    -ForegroundColor Black `
                                    -BackgroundColor Yellow `
                                    -StartSpaces 2

Write-ColorEX -Text "⚡ This is a notification using a style profile" -StyleProfile $notificationStyle

# Create a code block style
$codeStyle = New-ColorStyle -Name "CodeBlock" `
                            -ForegroundColor Green `
                            -BackgroundColor DarkGray `
                            -StartSpaces 4

Write-ColorEX -Text "function Get-Example { 'code' }" -StyleProfile $codeStyle
#endregion

#region Setting Default Styles
Write-Host "`n▼ Default Styles" -ForegroundColor Yellow
Write-Host "  Set a default style for all Write-ColorEX calls`n" -ForegroundColor Gray

Write-ColorEX -Text "Normal text without default style" -Color Gray

# Set a default style (Cyan and Bold)
Write-Host "`nSetting default style: -ForegroundColor Cyan -Bold" -ForegroundColor DarkGray
Set-ColorDefault -ForegroundColor Cyan -Bold

Write-ColorEX -Text "This uses the default style (should be Cyan and Bold)" -Default
Write-ColorEX -Text "This also uses the default style" -Default

# You can still override the default
Write-ColorEX -Text "But you can override with explicit colors" -Color Magenta

# Reset default to Gray
Write-Host "`nResetting default to Gray" -ForegroundColor DarkGray
Set-ColorDefault -ForegroundColor Gray

Write-ColorEX -Text "Back to Gray default" -Default
#endregion

#region Practical Example - Simple Menu
Write-Host "`n▼ Practical Example: Simple Menu (NEW: AutoPad Alignment)" -ForegroundColor Yellow
Write-Host "  Create an interactive-looking menu with perfect alignment`n" -ForegroundColor Gray

Write-ColorEX -Text "╔═══════════════════════════════════╗" -Color Cyan
Write-ColorEX -Text "║","             MAIN MENU             ","║" -Color Cyan
Write-ColorEX -Text "╠═══════════════════════════════════╣" -Color Cyan
Write-ColorEX -Text "║                                   ║" -Color Cyan

Write-ColorEX -Text "║  [" -Color Cyan -NoNewLine
Write-ColorEX -Text "1" -Color Yellow -NoNewLine
Write-ColorEX -Text "] " -Color Cyan -NoNewLine
Write-ColorEX -Text "View Reports" -AutoPad 29 -Color White -NoNewLine
Write-ColorEX -Text "║" -Color Cyan

Write-ColorEX -Text "║  [" -Color Cyan -NoNewLine
Write-ColorEX -Text "2" -Color Yellow -NoNewLine
Write-ColorEX -Text "] " -Color Cyan -NoNewLine
Write-ColorEX -Text "Export Data" -AutoPad 29 -Color White -NoNewLine
Write-ColorEX -Text "║" -Color Cyan

Write-ColorEX -Text "║  [" -Color Cyan -NoNewLine
Write-ColorEX -Text "3" -Color Yellow -NoNewLine
Write-ColorEX -Text "] " -Color Cyan -NoNewLine
Write-ColorEX -Text "Settings" -AutoPad 29 -Color White -NoNewLine
Write-ColorEX -Text "║" -Color Cyan

Write-ColorEX -Text "║  [" -Color Cyan -NoNewLine
Write-ColorEX -Text "Q" -Color Red -NoNewLine
Write-ColorEX -Text "] " -Color Cyan -NoNewLine
Write-ColorEX -Text "Quit" -AutoPad 29 -Color White -NoNewLine
Write-ColorEX -Text "║" -Color Cyan

Write-ColorEX -Text "║                                   ║" -Color Cyan
Write-ColorEX -Text "╚═══════════════════════════════════╝" -Color Cyan

Write-ColorEX -Text "`nEnter your choice: " -Color Cyan -NoNewLine
#endregion

#region Practical Example - Status Messages
Write-Host "`n`n▼ Practical Example: Status Messages" -ForegroundColor Yellow
Write-Host "  Simulate process status output`n" -ForegroundColor Gray

Write-ColorEX -Text "[", "●", "] ", "Connecting to server..." -Color Gray, Yellow, Gray, White -ShowTime
Start-Sleep -Milliseconds 500
Write-ColorEX -Text "[", "✓", "] ", "Connected successfully" -Color Gray, Green, Gray, White -ShowTime
Write-ColorEX -Text "[", "●", "] ", "Downloading data..." -Color Gray, Yellow, Gray, White -ShowTime
Start-Sleep -Milliseconds 500
Write-ColorEX -Text "[", "✓", "] ", "Download complete" -Color Gray, Green, Gray, White -ShowTime
Write-ColorEX -Text "[", "●", "] ", "Processing records..." -Color Gray, Yellow, Gray, White -ShowTime
Start-Sleep -Milliseconds 500
Write-ColorEX -Text "[", "✓", "] ", "Processing complete" -Color Gray, Green, Gray, White -ShowTime
#endregion

#region Practical Example - Log-Style Output
Write-Host "`n▼ Practical Example: Log-Style Output" -ForegroundColor Yellow
Write-Host "  Format output like a log file`n" -ForegroundColor Gray

Write-ColorEX -Text "[INFO]  " -Color Cyan -NoNewLine -ShowTime
Write-ColorEX -Text "Application started" -Color White

Write-ColorEX -Text "[WARN]  " -Color Yellow -NoNewLine -ShowTime
Write-ColorEX -Text "Configuration file not found, using defaults" -Color White

Write-ColorEX -Text "[ERROR] " -Color Red -NoNewLine -ShowTime
Write-ColorEX -Text "Failed to connect to database" -Color White

Write-ColorEX -Text "[INFO]  " -Color Cyan -NoNewLine -ShowTime
Write-ColorEX -Text "Retrying connection..." -Color White

Write-ColorEX -Text "[INFO]  " -Color Cyan -NoNewLine -ShowTime
Write-ColorEX -Text "Connection successful" -Color White
#endregion

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              END OF BASIC USAGE EXAMPLES                  ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
