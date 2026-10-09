---
title: Measure-DisplayWidth
weight: 100
---

Measures how many terminal cells a string takes.

{{< syntax "Measure-DisplayWidth" >}}

## Description

`String.Length` counts UTF-16 code units, which is not what a terminal draws. `Measure-DisplayWidth`
takes each character's width from the table of the Rust crate unicode-width 0.2.2, which
PWRSWriteColorEX uses, so both modules measure alike:

- Wide characters, CJK and most emoji, take 2 cells.
- Combining marks, zero-width spaces and joiners, and control characters take 0 cells.
- East Asian Ambiguous characters, such as box drawing, arrows and some symbols, take 1 cell, or 2
  with `-AmbiguousAsWide`.
- Everything else takes 1 cell.

Emoji sequences count as the cells a terminal draws for them: a character followed by U+FE0F
takes 2, a wide emoji followed by U+FE0E takes 1 (2 with `-AmbiguousAsWide`), a skin tone after an
emoji adds nothing, an emoji joined by U+200D adds nothing, and a flag takes 2. The string is
walked by code point, so Windows PowerShell 5.1 and PowerShell 7 give the same answer.
`-AutoPad` and `-Truncate` measure with it. [Display width](display-width.md) explains why.

## Examples

```powershell
PS> Measure-DisplayWidth 'Hello'
5
PS> Measure-DisplayWidth '東京'
4
PS> Measure-DisplayWidth '✅ done'
7
PS> Measure-DisplayWidth '👨‍👩‍👧'
2
PS> '👨‍👩‍👧'.Length
8
```

An ambiguous character takes one cell, or two where the terminal draws it wide:

```powershell
PS> Measure-DisplayWidth '●'
1
PS> Measure-DisplayWidth '●' -AmbiguousAsWide
2
```

## Parameters

{{% parameters "Measure-DisplayWidth" %}}
