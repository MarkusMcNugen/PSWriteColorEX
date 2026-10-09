---
title: Style profiles
weight: 70
---

A style profile keeps colors, styles and layout under a name, so a script writes every heading,
warning or label the same way. The six message helpers are built on profiles of their own.

## The message helpers

Each helper writes its message with a built-in profile:

```powershell
PS> Write-ColorError 'Could not reach the database'
Could not reach the database
PS> Write-ColorWarning 'Disk at 91 percent'
Disk at 91 percent
PS> Write-ColorInfo 'Using the staging configuration'
Using the staging configuration
PS> Write-ColorSuccess 'Deployed version 2.4.1'
Deployed version 2.4.1
PS> Write-ColorCritical 'Data loss possible'
Data loss possible
PS> Write-ColorDebug 'Cache hit for key 42'
Cache hit for key 42
```

Critical blinks where the terminal blinks, and Debug is italic where it draws italics.

## Making a style

`New-ColorStyle` makes a style, and `-StyleProfile` writes text in it. A parameter given on the
command line takes the place of the style's own:

```powershell
PS> $heading = New-ColorStyle -Name 'Heading' -ForegroundColor Cyan -Bold -Underline
PS> Write-ColorEX -Text 'Inventory' -StyleProfile $heading
Inventory
PS> Write-ColorEX -Text 'Orders' -StyleProfile $heading -Color Magenta
Orders
```

A style holds layout as well as colors:

```powershell
PS> $column = New-ColorStyle -Name 'Column' -ForegroundColor White -AutoPad 12 -NoNewLine
PS> Write-ColorEX -Text 'Region' -StyleProfile $column; Write-ColorEX -Text 'Sales' -Color Cyan
Region      Sales
```

## The profiles

`-AddToProfiles` keeps a style in `[PSColorStyle]::Profiles` under its name, and
`Get-ColorProfiles` gets it back anywhere in the session:

```powershell
PS> $null = New-ColorStyle -Name 'Label' -ForegroundColor Black -BackgroundColor Yellow -AddToProfiles
PS> Write-ColorEX -Text ' NEW ' -StyleProfile (Get-ColorProfiles -Name Label)
 NEW
```

The helpers read their built-in profiles on each call, so changing one changes its helper:

```powershell
PS> [PSColorStyle]::Profiles['Info'].ForegroundColor = 'Magenta'
PS> Write-ColorInfo 'Info messages are magenta now'
Info messages are magenta now
```

## The default style

`Set-ColorDefault` sets the style `-Default` applies, and with no parameters makes it plain Gray
text again:

```powershell
PS> Set-ColorDefault -ForegroundColor Green -Italic
PS> Write-ColorEX -Text 'written in the default style' -Default
written in the default style
PS> Set-ColorDefault
PS> Write-ColorEX -Text 'plain Gray again' -Default
plain Gray again
```

## Keeping profiles

Profiles last for the session. `Export-ColorProfile` saves them to a file and
`Import-ColorProfile` reads them back; [Share style profiles](share-style-profiles.md) shows how,
and [Style profiles](style-profiles.md) in the reference lists every property of a style.

## Next

[Logging](logging.md) writes each line to a file as well.
