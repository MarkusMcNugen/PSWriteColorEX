---
title: Markup and highlighting
weight: 50
---

Four ways to color part of a string without cutting it into segments yourself: markup tags,
patterns, separators and links.

## Markup tags

With `-Markup`, a tag in square brackets colors and styles the text up to `[/]`. A tag holds
style names, a text color, and `on` with a background color:

```powershell
PS> Write-ColorEX -Markup '[bold red]Error:[/] file not found'
Error: file not found
PS> Write-ColorEX -Markup '[white on DarkBlue] INFO [/] service [green]started[/] on port [cyan]8080[/]'
 INFO  service started on port 8080
```

A tag's colors take every form a color parameter takes:

```powershell
PS> Write-ColorEX -Markup '[#FF8800]orange[/], [rgb(0,160,160)]teal[/] and [hsl(270,70%,60%) italic]violet[/]'
orange, teal and violet
```

Tags nest. An inner tag keeps the colors of the tag around it that it does not set, and adds its
styles to the outer ones:

```powershell
PS> Write-ColorEX -Markup '[blue]outer [bold]inner and bold[/] outer again[/]'
outer inner and bold outer again
```

`[[` and `]]` write a bracket, and a tag that is not a style is written as text, with a warning:

```powershell
PS> Write-ColorEX -Markup 'An array is written [[1, 2, 3]] in [cyan]PowerShell[/]'
An array is written [1, 2, 3] in PowerShell
PS> Write-ColorEX -Markup '[shiny]is not a style'
WARNING: Markup tag [shiny] is not a style; it is written as text.
[shiny]is not a style
```

[Markup syntax](markup-syntax.md) gives every rule.

## Patterns

`-Highlight` colors and styles the text regular expressions match, anywhere on the line. Each
pattern takes a style written as a tag's contents, and matching ignores case:

```powershell
PS> Write-ColorEX -Text 'ERROR: disk full on /dev/sda1' -Highlight @{ 'error' = 'bold red'; '/dev/\w+' = 'cyan underline' }
ERROR: disk full on /dev/sda1
```

Where two patterns match the same text, the one listed first wins. A hashtable has no order of its
own, so give `[ordered]@{ }` when the patterns overlap:

```powershell
PS> Write-ColorEX -Text 'warning: 3 warnings' -Highlight ([ordered]@{ 'warning:' = 'bold yellow'; 'warnings?' = 'DarkYellow' })
warning: 3 warnings
```

## Separators

`-Split` cuts the text after each separator, so `-Color` colors the parts in turn. `-SplitAround`
cuts before and after it, so the separator takes a color of its own, and `-SplitEvenly` cuts the
text into as many equal parts as there are colors:

```powershell
PS> Write-ColorEX -Text 'one,two,three' -Split ',' -Color Red, Green, Blue
one,two,three
PS> Write-ColorEX -Text 'key=value' -SplitAround '=' -Color Cyan, DarkGray, White
key=value
PS> Write-ColorEX -Text 'STATUS' -SplitEvenly -Color Red, Yellow, Green
STATUS
```

## Links

`-Link` makes each segment a link that terminals with link support open when it is clicked, and a
markup tag takes `link=` with an address:

```powershell
PS> Write-ColorEX -Text 'See ', 'the documentation' -Link $null, 'https://markusmcnugen.github.io/PSWriteColorEX/' -Color Gray, Cyan
See the documentation
PS> Write-ColorEX -Markup 'Read [link=https://github.com/MarkusMcNugen/PSWriteColorEX underline]the source[/]'
Read the source
```

[Write links](write-links.md) lists the terminals that open them.

## Next

[Layout](layout.md) pads, aligns, wraps and indents the text.
