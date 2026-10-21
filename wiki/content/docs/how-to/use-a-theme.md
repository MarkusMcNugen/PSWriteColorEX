---
title: Use a theme
weight: 65
---

A theme restyles the style profiles, and with them the message helpers and `-Default`, in the
colors of a color scheme you may already use in an editor or a terminal.

## Pick a theme

`Import-ColorProfile -Theme` takes the theme's name, and Tab completion lists the names.
`Show-ColorTable -Profiles` shows what the theme set:

```powershell
PS> Import-ColorProfile -Theme CatppuccinMocha
PS> Write-ColorError 'Build failed'
Build failed
PS> Write-ColorWarning 'Disk at 91 percent'
Disk at 91 percent
PS> Show-ColorTable -Profiles -Name Error, Warning, Info
Profile  Sample       Settings
Error    Sample text  #F38BA8, Bold
Info     Sample text  #89DCEB
Warning  Sample text  #F9E2AF
```

The themes: {{< theme-names >}}. [Style profiles](style-profiles.md#themes) shows each
theme's colors.

## Write in the theme's colors

A theme also registers its colors under names that start with the theme's name, for text of your
own:

```powershell
PS> Import-ColorProfile -Theme Nord
PS> Write-ColorEX -Text 'Nord frost', ' and aurora' -Color Nord8, Nord15
Nord frost and aurora
PS> Write-ColorEX -Markup '[Nord13]markup takes them too[/]'
markup takes them too
```

## Match PowerShell's own colors

`-Theme PowerShell` makes Write-ColorError, Write-ColorWarning, Write-ColorInfo and
Write-ColorDebug write as PowerShell writes its own errors, warnings, verbose and debug messages,
with any changes made to `$PSStyle`:

```powershell
PS> Import-ColorProfile -Theme PowerShell
PS> Write-ColorWarning 'as PowerShell writes a warning'
as PowerShell writes a warning
```

## Add the CSS color names

`-Theme CSS` registers the CSS color names the color table lacks, and leaves the names it has:

```powershell
PS> Import-ColorProfile -Theme CSS
PS> Write-ColorEX -Text 'Coral', ' and Tomato' -Color Coral, Tomato
Coral and Tomato
```

## Keep a theme in every session

```powershell
# In $PROFILE
Import-ColorProfile -Theme TokyoNight
```

## Change a theme

Restyle a profile after the theme, then save the result to read back later:

```powershell
PS> Import-ColorProfile -Theme GruvboxDark
PS> $null = New-ColorStyle -Name Warning -ForegroundColor GruvboxDarkOrange -Bold -AddToProfiles
PS> Export-ColorProfile -Path 'my-gruvbox.json'
PS> Import-ColorProfile -Path 'my-gruvbox.json'
PS> Write-ColorWarning 'in Gruvbox orange'
in Gruvbox orange
```

## Go back to the built-in profiles

`[PSColorStyle]::InitializeDefaultProfiles()` puts back the seven built-in profiles. A theme's
color names stay registered until `Unregister-ColorName` removes them or the session ends.
