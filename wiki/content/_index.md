---
title: PSWriteColorEX
toc: false
---

Colored and styled console output for PowerShell, in two modules with the same commands and the
same output: PSWriteColorEX, written in PowerShell, and PWRSWriteColorEX, compiled from Rust.

```powershell
PS> Write-ColorEX -Text '  PSWriteColorEX  ' -Color White -BackGroundGradient '#7B2FF7', '#00C6FF' -Bold
  PSWriteColorEX
PS> Write-ColorEX -Text '[ ', 'OK', ' ] ', 'Database migrated' -Color DarkGray, Green, DarkGray, Gray
[ OK ] Database migrated
PS> Write-ColorEX -Markup '[bold]Deploy[/] to [cyan]staging[/]: [green]done[/] in [yellow]42s[/]'
Deploy to staging: done in 42s
PS> Write-ColorEX -Text '12:00:01 WARN cache misses at 31%' -Highlight @{ 'WARN' = 'bold yellow'; '\d+%' = 'magenta'; '^\S+' = 'DarkGray' }
12:00:01 WARN cache misses at 31%
PS> Write-ColorEX -Text 'Every color your terminal can show' -Gradient Red, Yellow, Green, Cyan, Blue, Magenta
Every color your terminal can show
```

Every example in this documentation ran through the module to make the page, and shows the colors
it wrote.

## Features

- TrueColor, 256 and 16 colors, chosen to suit the terminal, and falling back where it lacks a
  mode. See [Color modes](color-modes.md).
- 129 color names, hex codes, `rgb()`, `hsl()`, RGB arrays and ANSI numbers. See
  [Colors](colors.md).
- [Gradients](gradients.md) across the text and its background, blended in OKLab.
- [Markup tags](markup.md), regular-expression highlighting, strings split into colored parts,
  and links terminals open when clicked.
- Bold, italic, faint, blink, reverse, crossed-out, overline, and underlines single, double,
  curly, dotted or dashed in a color of their own. See [Text styles](styles.md).
- [Padding, centering, wrapping and cutting](layout.md) that count emoji and CJK characters as
  two cells.
- Message helpers and [style profiles](profiles.md), saved to and read from JSON.
- [Colored text as strings](build-colored-strings.md), for other strings, tables and files.
- [Logging to a file](logging.md) with a time and a level, and transcripts that record each line
  once.
- `NO_COLOR`, `FORCE_COLOR`, `CLICOLOR` and `TERM=dumb` honored. See
  [Turn colors off](turn-colors-off.md).
- Windows PowerShell 5.1 and PowerShell 7 on Windows, Linux and macOS, and PWRSWriteColorEX on
  FreeBSD as well.

## Start here

{{< cards >}}
  {{< card link="docs/tutorial/getting-started/" title="Getting started" subtitle="Install a module and write a first colored line." icon="academic-cap" >}}
  {{< card link="docs/reference/write-colorex/" title="Write-ColorEX" subtitle="Every parameter of the command you will use most." icon="document-text" >}}
  {{< card link="docs/explanation/pwrswritecolorex/" title="PWRSWriteColorEX" subtitle="The same commands, compiled from Rust." icon="light-bulb" >}}
{{< /cards >}}
