---
title: Colors and names
weight: 50
---

Every form a color parameter takes, the commands that add and remove color names, and the color
table. The forms hold for `-Color`, `-BackGroundColor`, `-UnderlineColor`, `-Gradient`,
`-BackGroundGradient`, the colors in markup tags and `-Highlight` styles, and the colors of a
`PSColorStyle`.

## Color forms

| Form | Examples | Rules |
|---|---|---|
| Name | `Red`, `darkteal`, `LightCoral` | One of the names in the table below, or one `Register-ColorName` added; case does not matter |
| Hex code | `'#FF8800'`, `'0xff8800'`, `'#F80'`, `'0xF80'` | `#` or `0x`, then 6 or 3 hex digits in either case; 3 digits double each one |
| `rgb()` | `'rgb(255, 136, 0)'`, `'RGB(255 136 0)'` | Three whole numbers apart by commas or spaces; a value outside 0 to 255 is clamped, with a warning |
| `hsl()` | `'hsl(32, 100%, 50%)'`, `'hsl(390deg 100 50)'` | Hue in degrees (decimals, negative values and `deg` allowed), then saturation and lightness in percent, the `%` optional |
| RGB array | `@(255, 136, 0)` with `-TrueColor`; `@(@(255, 136, 0), @(0, 120, 255))` | Three numbers make one color only with `-TrueColor`; an array of arrays gives each segment one |
| Number | `12`, `208 -ANSI8`, `96 -ANSI4` | A console color 0 to 15, a 256-color number 0 to 255 with `-ANSI8`, or a 16-color code with `-ANSI4` |
| No color | `$null`, `'None'` | The segment keeps the terminal's color, or the gradient's |

A name is written in the mode the call uses: its console color in a call without a color mode,
style, gradient or TrueColor color; its RGB value with `-TrueColor` or beside a TrueColor color; its
256-color number with `-ANSI8`. A hex code, `rgb()` or `hsl()` color is written in TrueColor where
the terminal has it, and otherwise, or with `-ANSI8` or `-ANSI4`, as the nearest color of the mode.

A name the table lacks gives a warning and no color, and so does a string that starts with `#` or
`0x` but is not a hex code. An `rgb()` value out of range is clamped:

```powershell
PS> Write-ColorEX -Text 'x' -Color '#GGGGGG'
WARNING: Invalid hex color format: GGGGGG. Expected format: #RRGGBB or RRGGBB
x
PS> Write-ColorEX -Text 'x' -Color 'rgb(300, -5, 128)'
WARNING: RGB values out of range (0-255). Original: @(300,-5,128). Clamped to: @(255,0,128)
x
```

## Register-ColorName

Adds a color name that every command takes, until the session ends. A name holds letters, digits,
`-` and `_`, starting with a letter, and cannot be `None`, `on` or a style name markup reads. A
name in use, built-in or registered, is replaced only with `-Force`.

{{< syntax "Register-ColorName" >}}

```powershell
PS> Register-ColorName -Name Brand -Color '#FF6B35'
PS> Write-ColorEX -Text 'Brand orange' -Color Brand -TrueColor
Brand orange
PS> Write-ColorEX -Markup '[brand bold]also in markup[/]'
also in markup
```

{{% parameters "Register-ColorName" "register-colorname-" %}}

## Unregister-ColorName

Removes names `Register-ColorName` added. A built-in name it replaced takes its built-in color
again.

{{< syntax "Unregister-ColorName" >}}

```powershell
PS> Register-ColorName -Name Brand -Color '#FF6B35'
PS> Unregister-ColorName -Name Brand
PS> Write-ColorEX -Text 'x' -Color Brand
WARNING: Unknown color 'Brand'.
x
```

{{% parameters "Unregister-ColorName" "unregister-colorname-" %}}

## Color table

Each name with its color in TrueColor, the nearest of the 256 colors, the nearest of the 16, and
its console color, the last three drawn in Windows Terminal's default scheme.
`Get-ColorTableWithRGB` answers the same table, and `Show-ColorTable` writes it in your terminal.

{{< colors >}}
