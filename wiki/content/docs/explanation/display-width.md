---
title: Display width
weight: 40
---

Padding has to count what the terminal draws, not the characters a string holds.

## Characters are not cells

`String.Length` counts UTF-16 code units. A CJK character is one unit and two cells; an emoji may
be two units and two cells; a family emoji is eight units joined into one picture two cells wide;
an accent may be a unit of its own drawn over the letter before it, taking no cell at all. Padding
by `Length` leaves every such column out of line.

```powershell
PS> '東京'.Length, (Measure-DisplayWidth '東京')
2
4
PS> '👨‍👩‍👧'.Length, (Measure-DisplayWidth '👨‍👩‍👧')
8
2
```

## Where the widths come from

`Measure-DisplayWidth` takes each character's width from the table of the Rust crate
unicode-width 0.2.2, the table terminals and Rust programs use, generated into both modules from
the same crate so they count alike. Wide characters take 2 cells, combining marks and joiners 0,
control characters 0, and the rest 1.

Emoji sequences follow what terminals draw: a character followed by the emoji presentation
selector U+FE0F takes 2 cells, as in the warning sign; a skin tone adds nothing to the emoji before
it; an emoji joined by U+200D adds nothing; and a pair of regional indicators, a flag, takes 2.
The string is walked by code point, so both PowerShell versions give the same answer.

These are the standard widths. A terminal whose font draws a character wider than its standard
width, or one that draws a joined emoji as its separate parts, shows that character wider, and a
terminal lays out right-to-left text in its own order; either can still put a column out of line.

## Ambiguous characters

East Asian Ambiguous characters, such as box drawing, arrows and some symbols like `●`, take one
cell in most terminals and two in terminals set for East Asian text. `-AmbiguousAsWide` counts them
as two:

```powershell
PS> Measure-DisplayWidth '●→╔═╗'
5
PS> Measure-DisplayWidth '●→╔═╗' -AmbiguousAsWide
10
```

## In padding

`-AutoPad`, `-PadLeft`, `-PadCenter`, `-Truncate` and `-Wrap` measure with it, so a column holding
wide characters lines up with one that holds none:

```powershell
PS> Write-ColorEX -Text 'Server ✅' -AutoPad 12 -NoNewLine; Write-ColorEX -Text 'up' -Color Green
Server ✅   up
PS> Write-ColorEX -Text 'Database' -AutoPad 12 -NoNewLine; Write-ColorEX -Text 'up' -Color Green
Database    up
```

A browser draws emoji in its own fonts, so a column on this page may sit a little out of line where
a terminal keeps it exact.
