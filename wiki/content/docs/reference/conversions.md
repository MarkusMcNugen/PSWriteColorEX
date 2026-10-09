---
title: Color conversions
weight: 110
---

The commands that convert colors between forms and modes, and lighten them:
`Convert-HexToRGB`, `Convert-RGBToANSI8`, `Convert-RGBToANSI4`, `Get-ColorTableWithRGB`,
`Get-LighterRGBColor`, `Get-LighterColorName` and `Get-LighterANSI8Color`. `Write-ColorEX` uses
them itself; [Color modes](color-modes.md) explains how a color is matched to the nearest of 256 or
16.

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

Answers the nearest of the 256 colors.

{{< syntax "Convert-RGBToANSI8" >}}

```powershell
PS> Convert-RGBToANSI8 255, 136, 0
208
PS> Convert-RGBToANSI8 128, 128, 128
244
```

{{% parameters "Convert-RGBToANSI8" "convert-rgbtoansi8-" %}}

## Convert-RGBToANSI4

Answers the nearest of the 16 colors, as its text code: 30 to 37 or 90 to 97.

{{< syntax "Convert-RGBToANSI4" >}}

```powershell
PS> Convert-RGBToANSI4 255, 136, 0
93
```

{{% parameters "Convert-RGBToANSI4" "convert-rgbtoansi4-" %}}

## Get-ColorTableWithRGB

Answers the color table: a hashtable of every name, registered names among them, each with its
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

Answers the next lighter name in a family: DarkRed to Red, Red to LightRed. A name with no lighter
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

Answers a lighter 256-color number, in each part of the table: the 16 standard colors, the
6x6x6 cube and the gray ramp.

{{< syntax "Get-LighterANSI8Color" >}}

```powershell
PS> Get-LighterANSI8Color 130
209
```

{{% parameters "Get-LighterANSI8Color" "get-lighteransi8color-" %}}
