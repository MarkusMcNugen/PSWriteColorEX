---
title: Style names
weight: 80
---

Every text style, the names that ask for it, and the escape code it writes.

## Styles

| Style | Switch | `-Style` name | Markup name | Escape code |
|---|---|---|---|---|
| Bold | `-Bold` | `Bold` | `bold` | `ESC[1m` |
| Faint | `-Faint` | `Faint` | `faint`, `dim` | `ESC[2m` |
| Italic | `-Italic` | `Italic` | `italic` | `ESC[3m` |
| Underline | `-Underline` | `Underline` | `underline` | `ESC[4m` |
| Blink | `-Blink` | `Blink` | `blink` | `ESC[5m` |
| Reverse | `-Reverse` | `Reverse` | `reverse`, `invert` | `ESC[7m` |
| Crossed out | `-CrossedOut` | `CrossedOut` | `crossedout`, `strike`, `strikethrough` | `ESC[9m` |
| Double underline | `-DoubleUnderline` | `DoubleUnderline` | `doubleunderline` | `ESC[21m` |
| Overline | `-Overline` | `Overline` | `overline` | `ESC[53m` |

`-Style` takes `None` for a segment without a style.

## Underline styles

| `-UnderlineStyle` | Markup name | Escape code |
|---|---|---|
| `Single` | `underline` | `ESC[4m` |
| `Double` | `doubleunderline` | `ESC[21m` |
| `Curly` | `curly` | `ESC[4:3m` |
| `Dotted` | `dotted` | `ESC[4:4m` |
| `Dashed` | `dashed` | `ESC[4:5m` |

`-UnderlineColor` writes `ESC[58;2;R;G;Bm` in TrueColor and `ESC[58;5;Nm` otherwise, with N the
256-color number, or 0 to 15 in 16 colors.

## What terminals draw

A terminal draws the styles it supports and leaves out the rest. Most draw bold, underline,
reverse and crossed-out text; many leave out blink, double underlines and overlines; the Windows
console host (conhost.exe) draws no italics. A terminal without curly, dotted or dashed underlines
draws a single line, and one without underline colors draws the line in the text's color.

Some terminals draw bold as brighter colors rather than a bold font. There `-Bold` makes each color
lighter instead: the next lighter name, a lighter 256-color number, or the RGB value times 1.4.
`Test-AnsiSupport` reports which kind of terminal it is in `SupportsBoldFonts`, and which styles it
draws in `Details.StyleSupport`; see [Test-AnsiSupport](test-ansisupport.md).

```powershell
PS> Write-ColorEX -Text 'bold ', 'faint ', 'italic ', 'underline ', 'reverse ', 'crossed out ', 'overline' -Style Bold, Faint, Italic, Underline, Reverse, CrossedOut, Overline
bold faint italic underline reverse crossed out overline
PS> Write-ColorEX -Text '[underline]single[/] [doubleunderline]double[/] [curly]curly[/] [dotted]dotted[/] [dashed]dashed[/]' -Markup
single double curly dotted dashed
```
