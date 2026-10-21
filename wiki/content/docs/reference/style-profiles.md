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
| `GradientSpace` | `OKLab`, `RGB`, `LinearRGB`, `OKLCH`, `HSL`, `HSV`, `Lab` or `LCh` |
| `GradientHue`, `GradientEasing`, `GradientRepeat`, `GradientDirection` | a name, as the `Write-ColorEX` parameter of the same name takes it |
| `GradientSteps` | int, the bands of solid color; 0 blends smoothly |
| `Bold`, `Faint`, `Italic`, `Underline`, `DoubleUnderline`, `Blink`, `CrossedOut`, `Overline`, `Reverse` | bool |
| `Style` | string array, style names as `-Style` takes them |
| `UnderlineStyle` | `Single`, `Double`, `Curly`, `Dotted` or `Dashed` |
| `AutoPad`, `StartTab`, `StartSpaces`, `LinesBefore`, `LinesAfter` | int |
| `PadLeft`, `PadCenter`, `Truncate`, `Wrap`, `ShowTime`, `NoNewLine`, `HorizontalCenter` | bool |
| `PadChar` | char |

| Members | What it does |
|---|---|
| `ToWriteColorParams()` | Returns a hashtable of `Write-ColorEX` parameters from the current properties |
| `Clone()` | Returns a copy with arrays of its own |
| `AddToProfiles()` | Adds the style to `[PSColorStyle]::Profiles` under its name |
| `SetAsDefault()` | Makes the style the one `-Default` applies |
| `[PSColorStyle]::Profiles` | The profiles, a hashtable by name |
| `[PSColorStyle]::Default` | The style `-Default` applies |
| `[PSColorStyle]::GetProfile(name)` | The profile of that name, or `$null` |
| `[PSColorStyle]::InitializeDefaultProfiles()` | Puts back the seven built-in profiles |

The built-in profiles, which the message helpers and `-Default` use, and which
`Import-ColorProfile -Theme` restyles:

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

Returns every profile, or the one named, matched without regard to case.

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

### Themes

`-Theme` reads one of the module's themes in place of a file. A color theme registers its colors
under names that start with the theme's name, such as `DraculaPurple` or `Nord8`, and restyles
the seven profiles in its colors, with Default the default style. Each theme is a file in
`Export-ColorProfile`'s format in the module's `Themes` folder.

{{< themes >}}

`PowerShell` makes each profile it restyles exactly PowerShell's own setting: its text color, its
background and the styles it turns on, from `$PSStyle.Formatting` on PowerShell 7.2 and later and
from the host's `PrivateData` colors before that. Error, Warning and Debug take PowerShell's error,
warning and debug settings, Info its verbose setting, and on 7.2 and later Critical takes
`ErrorAccent` and Default `FormatAccent`. A console color in a setting is written as the
terminal's own color, as PowerShell writes it. `CSS` adds the CSS color names the table lacks;
[Colors and names](colors-and-names.md#css-color-names) has the details.

```powershell
PS> Import-ColorProfile -Theme Dracula
PS> Write-ColorError 'Build failed'
Build failed
PS> Write-ColorSuccess 'Tests passed'
Tests passed
PS> Write-ColorEX -Text 'Dracula pink' -Color DraculaPink
Dracula pink
```

[Use a theme](use-a-theme.md) shows the themes in a session, and the sources of their colors are
credited in the module's THIRD-PARTY-NOTICES file.

{{% parameters "Import-ColorProfile" "import-colorprofile-" %}}

## Remove-ColorProfile

Removes profiles. A removed built-in profile leaves its helper with the colors it starts with, and
a name with no profile gives an error.

{{< syntax "Remove-ColorProfile" >}}

{{% parameters "Remove-ColorProfile" "remove-colorprofile-" %}}
