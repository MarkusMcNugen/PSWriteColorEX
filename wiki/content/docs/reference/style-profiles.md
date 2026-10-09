---
title: Style profiles
weight: 60
---

The `PSColorStyle` class, the built-in profiles, and the commands that make, keep, save and remove
styles: `New-ColorStyle`, `Set-ColorDefault`, `Get-ColorProfiles`, `Export-ColorProfile`,
`Import-ColorProfile` and `Remove-ColorProfile`.

## The PSColorStyle class

A `PSColorStyle` holds colors, styles and layout, which `Write-ColorEX -StyleProfile` applies; a
parameter given on the command line takes the place of the style's own. `[PSColorStyle]::new()`
makes an empty style, and `[PSColorStyle]::new(name, foreground, background)` one with a name and
colors.

| Properties | Type |
|---|---|
| `Name` | string |
| `ForegroundColor`, `BackgroundColor`, `UnderlineColor` | a color, in any [color form](colors-and-names.md) |
| `Gradient`, `BackgroundGradient` | colors |
| `GradientSpace` | `OKLab` or `RGB` |
| `Bold`, `Faint`, `Italic`, `Underline`, `DoubleUnderline`, `Blink`, `CrossedOut`, `Overline`, `Reverse` | bool |
| `Style` | string array, style names as `-Style` takes them |
| `UnderlineStyle` | `Single`, `Double`, `Curly`, `Dotted` or `Dashed` |
| `AutoPad`, `StartTab`, `StartSpaces`, `LinesBefore`, `LinesAfter` | int |
| `PadLeft`, `PadCenter`, `Truncate`, `Wrap`, `ShowTime`, `NoNewLine`, `HorizontalCenter` | bool |
| `PadChar` | char |

| Members | What it does |
|---|---|
| `ToWriteColorParams()` | Answers a hashtable of `Write-ColorEX` parameters from the current properties |
| `Clone()` | Answers a copy with arrays of its own |
| `AddToProfiles()` | Adds the style to `[PSColorStyle]::Profiles` under its name |
| `SetAsDefault()` | Makes the style the one `-Default` applies |
| `[PSColorStyle]::Profiles` | The profiles, a hashtable by name |
| `[PSColorStyle]::Default` | The style `-Default` applies |
| `[PSColorStyle]::GetProfile(name)` | The profile of that name, or `$null` |
| `[PSColorStyle]::InitializeDefaultProfiles()` | Puts back the seven built-in profiles |

The built-in profiles, which the message helpers and `-Default` use:

| Profile | Settings |
|---|---|
| Default | Gray |
| Error | Red, bold |
| Warning | Yellow |
| Info | Cyan |
| Success | Green |
| Critical | White on DarkRed, bold, blinking |
| Debug | DarkGray, italic |

```powershell
PS> $badge = New-ColorStyle -Name 'Badge' -ForegroundColor Black -BackgroundColor Cyan -Bold
PS> $params = $badge.ToWriteColorParams()
PS> Write-ColorEX -Text ' v1.2.0 ' @params
 v1.2.0
PS> Write-ColorEX -Text ' v1.2.0 ' -StyleProfile $badge -BackGroundColor Magenta
 v1.2.0
```

## New-ColorStyle

{{< syntax "New-ColorStyle" >}}

{{% parameters "New-ColorStyle" "new-colorstyle-" %}}

## Set-ColorDefault

{{< syntax "Set-ColorDefault" >}}

{{% parameters "Set-ColorDefault" "set-colordefault-" %}}

## Get-ColorProfiles

Answers every profile, or the one named, compared without regard to case.

{{< syntax "Get-ColorProfiles" >}}

```powershell
PS> Get-ColorProfiles | Sort-Object Name | Select-Object Name, ForegroundColor, BackgroundColor, Bold
Name     ForegroundColor BackgroundColor  Bold
----     --------------- ---------------  ----
Critical White           DarkRed          True
Debug    DarkGray                        False
Default  Gray                            False
Error    Red                              True
Info     Cyan                            False
Success  Green                           False
Warning  Yellow                          False
```

{{% parameters "Get-ColorProfiles" "get-colorprofiles-" %}}

## Export-ColorProfile

Saves profiles, and every name `Register-ColorName` added, to a JSON file. A profile holds the
properties that differ from a new `PSColorStyle`'s. The file is UTF-8 without a byte order mark,
with LF line ends, the same bytes from either module and either PowerShell.

{{< syntax "Export-ColorProfile" >}}

```powershell
PS> $null = New-ColorStyle -Name 'Badge' -ForegroundColor Black -BackgroundColor Cyan -Bold -AddToProfiles
PS> Register-ColorName -Name Brand -Color '#FF6B35'
PS> Export-ColorProfile -Path 'styles.json' -Name Badge
PS> Get-Content 'styles.json'
{
  "Colors": {
    "Brand": "#FF6B35"
  },
  "Profiles": [
    {
      "Name": "Badge",
      "ForegroundColor": "Black",
      "BackgroundColor": "Cyan",
      "Bold": true
    }
  ]
}
```

{{% parameters "Export-ColorProfile" "export-colorprofile-" %}}

## Import-ColorProfile

Registers the file's color names, adds its profiles, replacing profiles of the same name, and makes
the style the file names the default.

{{< syntax "Import-ColorProfile" >}}

{{% parameters "Import-ColorProfile" "import-colorprofile-" %}}

## Remove-ColorProfile

Removes profiles. A removed built-in profile leaves its helper with the colors it starts with, and
a name with no profile gives an error.

{{< syntax "Remove-ColorProfile" >}}

{{% parameters "Remove-ColorProfile" "remove-colorprofile-" %}}
