---
title: Colors
weight: 20
---

A color can be a name, a hex code, an `rgb()` or `hsl()` form, an RGB array or an ANSI color
number. Every parameter that takes a color takes all of these: `-Color`, `-BackGroundColor`,
`-UnderlineColor`, the gradients, and the colors in markup tags.

## Color names

The color table has 129 names in 44 families, the 16 console colors among them. Most families
have a Dark and a Light variant.

A name is written in the color mode the call uses. In a call with no color mode, no style that
needs one and no TrueColor color, each name is its console color, one of the 16, which keeps a
plain call fast: DarkTeal and Teal are both DarkCyan there. `-TrueColor`, a hex code or a
gradient in the same call writes each name from its own RGB value:

```powershell
PS> Write-ColorEX -Text 'DarkTeal ', 'Teal ', 'LightTeal' -Color DarkTeal, Teal, LightTeal
DarkTeal Teal LightTeal
PS> Write-ColorEX -Text 'DarkTeal ', 'Teal ', 'LightTeal' -Color DarkTeal, Teal, LightTeal -TrueColor
DarkTeal Teal LightTeal
PS> Write-ColorEX -Text 'DarkCoral ', 'Coral ', 'LightCoral' -Color DarkCoral, Coral, LightCoral -TrueColor
DarkCoral Coral LightCoral
```

Case does not matter in a name:

```powershell
PS> Write-ColorEX -Text 'amber ', 'AMBER' -Color amber, AMBER -TrueColor
amber AMBER
```

[Colors and names](colors-and-names.md) shows every name with a sample of its color, and
`Show-ColorTable` writes them in your own terminal.

## Hex codes, rgb() and hsl()

A hex code has six digits or three, after `#` or `0x`. Quote it, since `#` starts a comment in
PowerShell:

```powershell
PS> Write-ColorEX -Text '#FF8800 ', '#F80 ', '0x00A0A0' -Color '#FF8800', '#F80', '0x00A0A0'
#FF8800 #F80 0x00A0A0
```

`rgb()` takes red, green and blue from 0 to 255; `hsl()` takes a hue in degrees, then saturation
and lightness in percent:

```powershell
PS> Write-ColorEX -Text 'tomato ', 'sky' -Color 'rgb(255, 99, 71)', 'hsl(200, 80%, 55%)'
tomato sky
```

## RGB arrays

An array of three numbers is one RGB color with `-TrueColor`, the alias of `-ANSI24`. Without
it, the three numbers are three colors, one for each segment. An array of arrays gives each
segment an RGB color of its own:

```powershell
PS> Write-ColorEX -Text 'one RGB color' -Color @(255, 128, 0) -TrueColor
one RGB color
PS> Write-ColorEX -Text 'orange ', 'blue' -Color @(@(255, 128, 0), @(0, 120, 255))
orange blue
```

## Color numbers

A number names a color in the mode in use: a console color from 0 to 15, a 256-color number
with `-ANSI8`, and an ANSI 16-color code with `-ANSI4`:

```powershell
PS> Write-ColorEX -Text 'console color 12' -Color 12
console color 12
PS> Write-ColorEX -Text '256-color 208' -Color 208 -ANSI8
256-color 208
PS> Write-ColorEX -Text 'ANSI code 96' -Color 96 -ANSI4
ANSI code 96
```

## No color

A `$null` or `'None'` entry leaves its segment in the terminal's own color. Here the two colors
repeat over three segments:

```powershell
PS> Write-ColorEX -Text 'red ', 'plain ', 'red' -Color Red, $null
red plain red
```

A name the color table lacks gives a warning, and its segment keeps the terminal's color:

```powershell
PS> Write-ColorEX -Text 'Mauve' -Color Mauve
WARNING: Unknown color 'Mauve'.
Mauve
```

## In 256 and 16 colors

A name, a hex code, an `rgb()` or `hsl()` color and an RGB array are written in the best mode the
terminal has. In a terminal with 256 colors each becomes the nearest of them, and in a terminal
with 16 colors the nearest of those. The same command in TrueColor, then 256 colors, then 16:

```powershell
PS> Write-ColorEX -Text 'Coral ', 'Teal ', '#FF8800 ', 'hsl(270, 70%, 60%)' -Color Coral, Teal, '#FF8800', 'hsl(270, 70%, 60%)'
Coral Teal #FF8800 hsl(270, 70%, 60%)
```

```powershell,ansi8
PS> Write-ColorEX -Text 'Coral ', 'Teal ', '#FF8800 ', 'hsl(270, 70%, 60%)' -Color Coral, Teal, '#FF8800', 'hsl(270, 70%, 60%)'
Coral Teal #FF8800 hsl(270, 70%, 60%)
```

```powershell,ansi4
PS> Write-ColorEX -Text 'Coral ', 'Teal ', '#FF8800 ', 'hsl(270, 70%, 60%)' -Color Coral, Teal, '#FF8800', 'hsl(270, 70%, 60%)'
Coral Teal #FF8800 hsl(270, 70%, 60%)
```

`-ANSI8` and `-ANSI4` choose the mode for one call, and `-TrueColor` asks for TrueColor. A mode
the terminal lacks falls back to the next one down, as [Color modes](color-modes.md) explains.
To set the mode for every call, see [Turn colors off or force them](turn-colors-off.md).

```powershell
PS> Write-ColorEX -Text 'forced to 16 colors' -Color '#FF8800' -ANSI4
forced to 16 colors
```

## Next

[Text styles](styles.md) adds bold, italic, underlines and the other styles.
