---
title: Markup syntax
weight: 70
---

The tags `-Markup` reads in the text of `Write-ColorEX` and `Format-ColorEX`.

## Tags

A tag is words between `[` and `]`, apart by spaces, and colors and styles the text after it up to
the `[/]` that closes it:

| Word | Effect |
|---|---|
| A style name | `bold`, `faint` or `dim`, `italic`, `underline`, `doubleunderline`, `curly`, `dotted`, `dashed`, `blink`, `crossedout`, `strike` or `strikethrough`, `overline`, `reverse` or `invert` |
| A color | The text color, in any form a color parameter takes without spaces: a name, `#FF8800`, `rgb(255,136,0)`, `hsl(32,100%,50%)` |
| `on` and a color | The background color |
| `link=` and an address | Makes the text a link |

```powershell
PS> Write-ColorEX -Markup '[bold red]Error:[/] file not found'
Error: file not found
PS> Write-ColorEX -Markup '[black on #FFD700] WARN [/] [curly]check the spelling[/]'
 WARN  check the spelling
PS> Write-ColorEX -Markup '[link=https://example.com cyan underline]example.com[/]'
example.com
```

## Closing and nesting

`[/]` closes the tag opened last. A tag left open closes at the end of its string, since each
string of `-Text` is read on its own. An inner tag takes the colors and link it does not set from
the tag around it, and the styles of both:

```powershell
PS> Write-ColorEX -Markup '[green]outer [bold underline]inner[/] outer[/] plain'
outer inner outer plain
PS> Write-ColorEX -Markup '[yellow]open to the end', ' of its own string'
open to the end of its own string
```

A tag's colors take the place of `-Color`, `-BackGroundColor` and the gradients for its text:

```powershell
PS> Write-ColorEX -Markup 'gradient [white on DarkRed] FIXED [/] gradient' -Gradient Cyan, Magenta
gradient  FIXED  gradient
```

## Escapes and text that is not a tag

`[[` writes `[` and `]]` writes `]`. A tag holding a word that is not a style, color, `on` or
`link=` is written as text, and so is a `[/]` with no tag open, each with a warning that
`-Silent` leaves out:

```powershell
PS> Write-ColorEX -Markup 'Use [[bold]] for [bold]bold[/]'
Use [bold] for bold
PS> Write-ColorEX -Markup '[sparkly]text[/]'
WARNING: Markup tag [sparkly] is not a style; it is written as text.
WARNING: Markup tag [/] closes no tag; it is written as text.
[sparkly]text[/]
PS> Write-ColorEX -Markup '[sparkly]text[/]' -Silent
[sparkly]text[/]
```

## Styles in -Highlight

A `-Highlight` style is written as a tag's contents, without the brackets: `'bold red'`,
`'black on yellow'`, `'cyan underline'`.
