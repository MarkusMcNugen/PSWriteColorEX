---
title: Gradients
weight: 40
---

A gradient blends two or more colors across the characters of the text, each character taking a
color between the ones given. `-Gradient` blends the text color and `-BackGroundGradient` the
background.

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

## In 256 and 16 colors

A gradient needs 256 colors or TrueColor. In 256 colors each character takes the nearest of
them:

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
