---
title: Gradients
weight: 40
---

A gradient blends two or more colors across the characters of the text: each color given falls on
a character of its own, and the characters between take the colors in between. `-Gradient` blends
the text color, leaving out the spaces, which show no text color, and `-BackGroundGradient` the
background, spaces included.

## Text gradients

Two colors, then several stops, then hex codes:

```powershell
PS> Write-ColorEX -Text 'Two colors, red to blue' -Gradient Red, Blue
Two colors, red to blue
PS> Write-ColorEX -Text 'Six stops make a rainbow' -Gradient Red, Yellow, Green, Cyan, Blue, Magenta
Six stops make a rainbow
PS> Write-ColorEX -Text 'Hex stops work as well' -Gradient '#FF5F6D', '#FFC371'
Hex stops work as well
```

The gradient runs across the whole line, over every segment:

```powershell
PS> Write-ColorEX -Text 'Segments ', 'share ', 'one gradient' -Gradient Cyan, Magenta
Segments share one gradient
```

A segment with a color in `-Color` keeps that color, and a `$null` entry leaves its segment to the
gradient:

```powershell
PS> Write-ColorEX -Text 'gradient ', 'FIXED', ' gradient' -Gradient Cyan, Magenta -Color $null, Yellow, $null
gradient FIXED gradient
```

## Named gradients

Twenty-one gradients have names. `-Gradient` and `-BackGroundGradient` take one name in place of
its colors, and Tab completion lists the names:

```powershell
PS> Write-ColorEX -Text 'Sunset over the bay' -Gradient Sunset
Sunset over the bay
PS> Write-ColorEX -Text 'Ocean blues and teals' -Gradient Ocean
Ocean blues and teals
PS> Write-ColorEX -Text 'Fire from red to gold' -Gradient Fire
Fire from red to gold
PS> Write-ColorEX -Text 'Instagram purple to orange' -Gradient Instagram
Instagram purple to orange
PS> Write-ColorEX -Text '   a banner on ice   ' -Color Black -BackGroundGradient Ice
   a banner on ice
```

[Colors and names](colors-and-names.md#named-gradients) lists every named gradient with its
colors.

## Background gradients

`-BackGroundGradient` blends the background the same way, under any text color:

```powershell
PS> Write-ColorEX -Text '   a banner across the background   ' -Color White -BackGroundGradient '#1D976C', '#93F9B9'
   a banner across the background
PS> Write-ColorEX -Text '   text and background   ' -Gradient Yellow, White -BackGroundGradient DarkBlue, DarkMagenta -Bold
   text and background
```

## How the colors blend

Gradients blend in the OKLab color space, where equal steps look equally far apart. Red to green
then passes through a golden yellow; blended channel by channel, with `-GradientSpace RGB`, it
passes through a dark olive:

```powershell
PS> Write-ColorEX -Text 'OKLab: red to green through gold ' -Gradient Red, Green
OKLab: red to green through gold
PS> Write-ColorEX -Text 'RGB:   red to green through olive' -Gradient Red, Green -GradientSpace RGB
RGB:   red to green through olive
```

[Gradients in OKLab](gradients-in-oklab.md) explains the difference.

`-GradientSpace` takes six more spaces: LinearRGB, which mixes light as light mixes, Lab, and four
that go round the hue wheel, OKLCH, HSL, HSV and LCh. Round the wheel, the colors between two hues
stay as vivid as the ends, and `-GradientHue` picks the way round: Shorter, the default, Longer,
Increasing or Decreasing.

```powershell
PS> Write-ColorEX -Text 'OKLCH keeps the middle vivid' -Gradient Red, Blue -GradientSpace OKLCH
OKLCH keeps the middle vivid
PS> Write-ColorEX -Text 'HSL the long way round the wheel' -Gradient Red, Blue -GradientSpace HSL -GradientHue Longer
HSL the long way round the wheel
```

## Placing colors

A color can give its place along the text after an `@`, as a percent. The colors without a place
spread evenly between the placed ones, and two colors at one place make a hard edge:

```powershell
PS> Write-ColorEX -Text 'Gold sits forty percent along' -Gradient 'Red', 'Gold@40', 'Blue'
Gold sits forty percent along
PS> Write-ColorEX -Text 'A hard edge halfway across' -Gradient 'Navy', 'Navy@50', 'Gold@50', 'Gold'
A hard edge halfway across
```

## Easing, bands, repeats and direction

`-GradientEasing` moves the colors along the text by a curve: Linear, or the In, Out and InOut
forms of Sine, Quad, Cubic, Quart, Quint, Expo, Circ, Back, Elastic and Bounce. An In curve holds
the first colors longer and an Out curve reaches the last ones sooner:

```powershell
PS> Write-ColorEX -Text 'InOutSine eases in and out' -Gradient Black, White -GradientEasing InOutSine
InOutSine eases in and out
PS> Write-ColorEX -Text 'OutBounce bounces at the end' -Gradient Navy, Cyan -GradientEasing OutBounce
OutBounce bounces at the end
```

`-GradientSteps` cuts the gradient into bands of solid color, the first band in the first color
and the last in the last:

```powershell
PS> Write-ColorEX -Text 'Three bands: green, yellow, red' -Gradient Green, Yellow, Red -GradientSteps 3
Three bands: green, yellow, red
```

With its colors placed short of the end, `-GradientRepeat` draws the gradient again, or back and
forth with Mirror, and `-GradientDirection` runs it in reverse, from the middle out or from the
ends in:

```powershell
PS> Write-ColorEX -Text 'Mirrored every quarter of the line' -Gradient 'Magenta@0', 'Cyan@25' -GradientRepeat Mirror
Mirrored every quarter of the line
PS> Write-ColorEX -Text 'From the middle out to both ends' -Gradient White, Blue -GradientDirection CenterOut
From the middle out to both ends
```

## A gradient's colors in your own code

`Get-GradientColor` returns the colors of a gradient as RGB arrays, the form `-Color` takes, with
every option above: one for each of `-Count` characters, or the one color at `-Place`, from 0 to 1:

```powershell
PS> Get-GradientColor -Gradient Red, Blue -Count 3 | ForEach-Object { $_ -join ', ' }
255, 0, 0
140, 83, 162
0, 0, 255
PS> (Get-GradientColor -Gradient Progress -Place 0.75) -join ', '
255, 255, 0
```

## In 256 and 16 colors

A gradient needs 256 colors or TrueColor. In 256 colors each character takes the one of them that
looks nearest:

```powershell,ansi8
PS> Write-ColorEX -Text 'Six stops make a rainbow' -Gradient Red, Yellow, Green, Cyan, Blue, Magenta
Six stops make a rainbow
```

A terminal with 16 colors writes the text without the gradient, and says so:

```powershell,ansi4
PS> Write-ColorEX -Text 'No gradient in 16 colors' -Gradient Red, Blue
WARNING: Gradient requires ANSI 256-color or TrueColor support. Terminal supports: ANSI4 (16 colors). Gradient disabled.
No gradient in 16 colors
```

## Next

[Markup and highlighting](markup.md) colors parts of a string without cutting it into segments.
