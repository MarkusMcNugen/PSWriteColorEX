---
title: Text styles
weight: 30
---

Styles change how text is drawn: bold, faint, italic, underlined, blinking, struck through,
overlined, or with its colors swapped. A terminal draws the styles it supports and leaves out the
rest; [Style names](style-names.md) lists which terminals draw which.

## Styles for the whole line

Each style has a switch that styles every segment:

```powershell
PS> Write-ColorEX -Text 'bold' -Bold
bold
PS> Write-ColorEX -Text 'faint' -Faint
faint
PS> Write-ColorEX -Text 'italic' -Italic
italic
PS> Write-ColorEX -Text 'underlined' -Underline
underlined
PS> Write-ColorEX -Text 'struck through' -CrossedOut
struck through
PS> Write-ColorEX -Text 'overlined' -Overline
overlined
PS> Write-ColorEX -Text 'blinking' -Blink
blinking
```

Styles combine with each other and with colors:

```powershell
PS> Write-ColorEX -Text 'Release ', 'v2.0' -Color White, Green -Bold -Underline
Release v2.0
```

## Styles for each segment

`-Style` gives the segments their styles in turn: a style name, an array of names, or `None`.
It styles only the segments it lists, and a single name styles the first segment:

```powershell
PS> Write-ColorEX -Text 'Name: ', 'Ada', ' (admin)' -Style Bold, Italic
Name: Ada (admin)
PS> Write-ColorEX -Text 'one ', 'two ', 'three' -Style @('Bold', 'Underline'), None, Faint
one two three
```

The names are Bold, Faint, Italic, Underline, Blink, CrossedOut, DoubleUnderline, Overline and
Reverse.

## Reverse

Reverse swaps the text and background colors, which makes a label out of a text color alone:

```powershell
PS> Write-ColorEX -Text ' WARN ', ' low disk space' -Color Yellow, Gray -Style Reverse
 WARN  low disk space
```

## Underlines

`-UnderlineStyle` draws a single, double, curly, dotted or dashed line, and `-UnderlineColor`
colors it apart from the text:

```powershell
PS> Write-ColorEX -Text 'single' -UnderlineStyle Single
single
PS> Write-ColorEX -Text 'double' -UnderlineStyle Double
double
PS> Write-ColorEX -Text 'curly' -UnderlineStyle Curly -UnderlineColor Red
curly
PS> Write-ColorEX -Text 'dotted' -UnderlineStyle Dotted -UnderlineColor Cyan
dotted
PS> Write-ColorEX -Text 'dashed' -UnderlineStyle Dashed -UnderlineColor Yellow
dashed
```

`-UnderlineColor` takes a color for each segment, and a segment with an underline color is
underlined even without `-Underline`:

```powershell
PS> Write-ColorEX -Text 'Spelled ', 'recieve', ' wrong' -UnderlineColor $null, Red, $null
Spelled recieve wrong
```

A terminal without curly, dotted or dashed underlines draws a single line, and one without
underline colors draws the line in the text's color.

## Next

[Gradients](gradients.md) blend colors across the text and its background.
