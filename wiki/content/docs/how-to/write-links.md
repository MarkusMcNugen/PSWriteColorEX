---
title: Write links
weight: 100
---

To write text that opens a web page when it is clicked, give it an address with `-Link`, or with
`link=` in a markup tag. Terminals that support links, such as Windows Terminal, iTerm2, WezTerm,
Kitty and GNOME Terminal, open it; other terminals show the text alone.

## A link for a segment

`-Link` takes an address for each segment, in turn. `$null` leaves a segment without a link:

```powershell
PS> Write-ColorEX -Text 'Read ', 'the documentation' -Link $null, 'https://markusmcnugen.github.io/PSWriteColorEX/' -Color Gray, Cyan
Read the documentation
```

## A link in markup

```powershell
PS> Write-ColorEX -Markup 'Report bugs on [link=https://github.com/MarkusMcNugen/PSWriteColorEX/issues cyan underline]GitHub[/].'
Report bugs on GitHub.
```

## How it works

A link is an escape code (OSC 8) around the text, which the terminal turns into a link. Links are
written only where colors are, so `NO_COLOR` and the other variables that turn colors off also
leave links out. On this site, a link in a terminal block opens when it is clicked, as it would in
a terminal.

## The whole script

```powershell
$docs = 'https://markusmcnugen.github.io/PSWriteColorEX/'
Write-ColorEX -Text 'Read ', 'the documentation' -Link $null, $docs -Color Gray, Cyan
```
