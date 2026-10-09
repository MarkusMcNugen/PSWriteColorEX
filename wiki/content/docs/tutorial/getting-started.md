---
title: Getting started
weight: 10
---

Install the module, write a first line in color, and give each part of a line its own color and
style. Every example on these pages ran through the module to make the page, so the colors you
see are the ones it writes.

## Install

PSWriteColorEX and PWRSWriteColorEX have the same commands, parameters and output. Install one of
them.

{{< tabs >}}
{{< tab name="PSWriteColorEX" >}}
Pure PowerShell, for Windows PowerShell 5.1 and PowerShell 7 on Windows, Linux and macOS.

```powershell
Install-Module PSWriteColorEX -Scope CurrentUser
```
{{< /tab >}}
{{< tab name="PWRSWriteColorEX" >}}
The same commands compiled from Rust, for Windows PowerShell 5.1 and PowerShell 7.4 or later on
Windows, Linux, macOS and FreeBSD. See [PWRSWriteColorEX](pwrswritecolorex.md).

```powershell
Install-Module PWRSWriteColorEX -Scope CurrentUser
```
{{< /tab >}}
{{< /tabs >}}

## A first line

`Write-ColorEX` writes text to the host, as `Write-Host` does, in the colors you give it:

```powershell
PS> Import-Module PSWriteColorEX
PS> Write-ColorEX -Text 'Hello, world' -Color Cyan
Hello, world
```

## Segments

`-Text` takes several strings. Each one is a segment, and `-Color` gives each segment its color in
turn. The segments are written on one line, with nothing added between them:

```powershell
PS> Write-ColorEX -Text 'Disk ', 'C:', ' is ', '91%', ' full' -Color Gray, White, Gray, Red, Gray
Disk C: is 91% full
```

With fewer colors than segments, the colors repeat from the first:

```powershell
PS> Write-ColorEX -Text 'one ', 'two ', 'three' -Color Green, Yellow
one two three
```

`-BackGroundColor` colors the background behind each segment the same way:

```powershell
PS> Write-ColorEX -Text ' PASS ', ' 12 tests ' -Color Black, White -BackGroundColor Green, DarkGray
 PASS  12 tests
```

## Styles

`-Bold`, `-Italic` and `-Underline` style the whole line. `-Style` styles one segment at a time,
with a style name or a list of them for each:

```powershell
PS> Write-ColorEX -Text 'Build ', 'failed', ': 3 errors' -Color Gray, Red, Gray -Bold
Build failed: 3 errors
PS> Write-ColorEX -Text 'plain ', 'bold ', 'italic and underlined' -Style None, Bold, @('Italic', 'Underline')
plain bold italic and underlined
```

## Short forms

The first parameters take their values by position, so the text, its color and its background
can go without their names. `WC` is one of the command's aliases:

```powershell
PS> Write-ColorEX 'Ready' Green
Ready
PS> WC 'Warning' Black Yellow
Warning
```

## Where to go next

- [Colors](colors.md): names, hex codes, `rgb()` and `hsl()`, and what changes in 256 and 16
  colors.
- [Text styles](styles.md): every style, underline styles and colors.
- [Gradients](gradients.md), [markup and highlighting](markup.md), and [layout](layout.md).
- The [Write-ColorEX reference](write-colorex.md) lists every parameter.
