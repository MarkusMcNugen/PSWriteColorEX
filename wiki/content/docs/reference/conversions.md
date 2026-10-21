---
title: Color conversions
weight: 110
---

The commands that convert colors between forms and modes, lighten them and measure their contrast:
`Convert-HexToRGB`, `Convert-RGBToANSI8`, `Convert-RGBToANSI4`, `Get-ColorTableWithRGB`,
`Get-LighterRGBColor`, `Get-LighterColorName`, `Get-LighterANSI8Color` and `Get-ColorContrast`.
`Write-ColorEX` uses the conversions itself; [Color modes](color-modes.md) explains how a color is
matched to the nearest of 256 or 16.

## Convert-HexToRGB

Converts a hex code to an array of red, green and blue.

{{< syntax "Convert-HexToRGB" >}}

```powershell
PS> Convert-HexToRGB '#FF8800'
255
136
0
```

{{% parameters "Convert-HexToRGB" "convert-hextorgb-" %}}

## Convert-RGBToANSI8

Returns the 256-color code, from 16 to 255, that looks nearest to the color.

{{< syntax "Convert-RGBToANSI8" >}}

```powershell
PS> Convert-RGBToANSI8 255, 136, 0
208
PS> Convert-RGBToANSI8 128, 128, 128
244
```

{{% parameters "Convert-RGBToANSI8" "convert-rgbtoansi8-" %}}

## Convert-RGBToANSI4

Returns the nearest of the 16 colors, as its text code: 30 to 37 or 90 to 97.

{{< syntax "Convert-RGBToANSI4" >}}

```powershell
PS> Convert-RGBToANSI4 255, 136, 0
93
```

{{% parameters "Convert-RGBToANSI4" "convert-rgbtoansi4-" %}}

## Get-ColorTableWithRGB

Returns the color table: a hashtable of every name, registered names among them, each with its
console color, its 16-color text and background codes, its 256-color number and its RGB value.

{{< syntax "Get-ColorTableWithRGB" >}}

```powershell
PS> $table = Get-ColorTableWithRGB
PS> $table.Count
129
PS> $table['Coral'][0..3] -join ', '
Red, 31, 41, 209
PS> $table['Coral'][4] -join ', '
255, 127, 80
```

{{% parameters "Get-ColorTableWithRGB" "get-colortablewithrgb-" %}}

## Get-LighterRGBColor

Multiplies each channel by a factor, with a floor so black becomes dark gray.

{{< syntax "Get-LighterRGBColor" >}}

```powershell
PS> (Get-LighterRGBColor 128, 64, 0) -join ', '
179, 102, 102
```

{{% parameters "Get-LighterRGBColor" "get-lighterrgbcolor-" %}}

## Get-LighterColorName

Returns the next lighter name in a family: DarkRed to Red, Red to LightRed. A name with no lighter
name comes back as it is.

{{< syntax "Get-LighterColorName" >}}

```powershell
PS> Get-LighterColorName DarkRed
Red
PS> Get-LighterColorName LightRed
LightRed
```

{{% parameters "Get-LighterColorName" "get-lightercolorname-" %}}

## Get-LighterANSI8Color

Returns a lighter 256-color number, in each part of the table: the 16 standard colors, the
6x6x6 cube and the gray ramp.

{{< syntax "Get-LighterANSI8Color" >}}

```powershell
PS> Get-LighterANSI8Color 130
209
```

{{% parameters "Get-LighterANSI8Color" "get-lighteransi8color-" %}}

## Get-ColorContrast

Returns the contrast ratio WCAG 2 defines for text in one color on a background in another, from 1
for two colors of the same luminance to 21 for black and white, the same either way round. WCAG asks
for at least 4.5 for body text and 3 for large text. Both modules return the same ratio to the last
bit.

{{< syntax "Get-ColorContrast" >}}

```powershell
PS> Get-ColorContrast White '#1E1E2E'
16.4015791932821
PS> Get-ColorContrast Gold White
1.40260178089369
PS> Get-ColorContrast Gold '#1E1E2E'
11.6936819963479
```

{{% parameters "Get-ColorContrast" "get-colorcontrast-" %}}
