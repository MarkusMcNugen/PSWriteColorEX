---
title: Gradients in OKLab
weight: 20
---

A gradient needs a color for every character between the stops. How those colors are found
decides whether the gradient looks even.

## Blending each channel

The simple way blends red, green and blue each on their own, a straight line through RGB. But RGB
values are not spaced the way eyes see them. Halfway from red (255, 0, 0) to green (0, 255, 0) is
(128, 128, 0), a dark olive, darker than either end; halfway from blue to yellow is a flat gray.

## Blending in OKLab

OKLab is a color space built so that equal steps look equally far apart: one channel for
lightness and two for the color around it. A gradient that blends in OKLab keeps its lightness
even, and passes through the colors between its stops: red to green through a golden yellow, blue
to yellow through a light blue. It is the default, and `-GradientSpace RGB` gives the channel blend:

```powershell
PS> Write-ColorEX -Text 'OKLab, red to green  ' -Gradient Red, Green
OKLab, red to green
PS> Write-ColorEX -Text 'RGB,   red to green  ' -Gradient Red, Green -GradientSpace RGB
RGB,   red to green
PS> Write-ColorEX -Text 'OKLab, blue to yellow' -Gradient Blue, Yellow
OKLab, blue to yellow
PS> Write-ColorEX -Text 'RGB,   blue to yellow' -Gradient Blue, Yellow -GradientSpace RGB
RGB,   blue to yellow
```

## How the colors are computed

Each stop is converted from RGB to OKLab, the characters are spread evenly between the stops, and
each character's color is mixed in OKLab and converted back to RGB, rounded to whole values. A
character is what a reader sees as one: an emoji sequence or a letter with its accent takes one
color. With more than two stops, the gradient runs from each stop to the next in equal shares of
the text.

The work is done in the `ColorMath` class, a loop of arithmetic per step rather than calls to
functions, so a long gradient costs little. PWRSWriteColorEX computes the same steps with the same
constants, so both modules write the same colors to the last bit.

## In 256 colors

In 256 colors each character takes the nearest 256-color of its TrueColor value, so neighboring
characters may share a color where the steps fall between two of them:

```powershell,ansi8
PS> Write-ColorEX -Text 'OKLab, red to green  ' -Gradient Red, Green
OKLab, red to green
```

A gradient needs at least 256 colors; in 16 colors the text is written without it, with a warning.
