---
title: Get-GradientColor
weight: 45
---

Returns the colors of a gradient as RGB arrays: one for each of a number of characters, or the
color at each of several places along it.

{{< syntax "Get-GradientColor" >}}

## Description

`Get-GradientColor` blends a gradient as `Write-ColorEX`'s `-Gradient` does and returns its
colors, each an array of three values from 0 to 255, the form `-Color` and `-Gradient` take. It
takes the same colors, named gradients, placed colors and gradient options.

`-Count` returns the colors of that many characters, as `Write-ColorEX` draws the gradient across
a line of that length. `-Place` returns the color at each place given, from 0, the start, to 1,
the end, in the order given, for a single color that moves along the gradient, as a progress
bar's does; colors placed with `@` keep their exact places there, since there are no characters
to move them to. A place below 0 is 0 and above 1 is 1.

## Examples

The colors `Write-ColorEX` draws across three characters:

```powershell
PS> Get-GradientColor -Gradient Red, Blue -Count 3 | ForEach-Object { $_ -join ', ' }
255, 0, 0
140, 83, 162
0, 0, 255
```

One color from each of three words, round the hue wheel:

```powershell
PS> $colors = Get-GradientColor -Gradient Red, Blue -Count 3 -GradientSpace OKLCH
PS> Write-ColorEX -Text 'one ', 'two ', 'three' -Color $colors
one two three
```

The color at one place:

```powershell
PS> (Get-GradientColor -Gradient Progress -Place 0.75) -join ', '
255, 255, 0
```

The colors at several places, in the order given, from one call:

```powershell
PS> Get-GradientColor -Gradient Progress -Place 0, 0.5, 1 | ForEach-Object { $_ -join ', ' }
255, 0, 0
255, 165, 0
0, 255, 0
```

## Parameters

{{% parameters "Get-GradientColor" %}}
