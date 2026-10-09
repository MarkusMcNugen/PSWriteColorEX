---
title: Write-ColorEX
weight: 10
---

Writes colored and styled text to the host, with padding, alignment, wrapping, markup,
highlighting, links and logging to a file.

{{< syntax "Write-ColorEX" >}}

## Description

`Write-ColorEX` writes through `Write-Host`. Each string of `-Text` is a segment, written one
after another on one line. `-Color`, `-BackGroundColor`, `-UnderlineColor` and `-Link` give each
segment its value in turn, and with fewer values than segments they repeat from the first.
`-Style` styles only the segments it lists.

A color is a name, a hex code, an `rgb()` or `hsl()` form, an RGB array or an ANSI number; see
[Colors and names](colors-and-names.md). The color mode is detected when the module is imported and can be
forced with `-ANSI4`, `-ANSI8` or `-ANSI24`, or with the environment variables in
[Environment variables](environment.md); a mode the terminal lacks falls back to the next one
down, as [Color modes](color-modes.md) explains. Each line goes to the host in as few
`Write-Host` calls as its colors allow, which [How output reaches the host](how-output-is-written.md)
explains along with transcripts.

## Parameters by purpose

| Purpose | Parameters |
|---|---|
| Text and color | [`-Text`](#text), [`-Color`](#color), [`-BackGroundColor`](#backgroundcolor), [`-Gradient`](#gradient), [`-BackGroundGradient`](#backgroundgradient), [`-GradientSpace`](#gradientspace) |
| Color mode | [`-ANSI4`](#ansi4), [`-ANSI8`](#ansi8), [`-ANSI24`](#ansi24) |
| Styles | [`-Style`](#style), [`-Bold`](#bold), [`-Faint`](#faint), [`-Italic`](#italic), [`-Underline`](#underline), [`-UnderlineStyle`](#underlinestyle), [`-UnderlineColor`](#underlinecolor), [`-DoubleUnderline`](#doubleunderline), [`-Blink`](#blink), [`-CrossedOut`](#crossedout), [`-Overline`](#overline), [`-Reverse`](#reverse) |
| Parts of a string | [`-Markup`](#markup), [`-Highlight`](#highlight), [`-Split`](#split), [`-SplitAround`](#splitaround), [`-SplitEvenly`](#splitevenly), [`-Link`](#link) |
| Layout | [`-AutoPad`](#autopad), [`-PadLeft`](#padleft), [`-PadCenter`](#padcenter), [`-PadChar`](#padchar), [`-Truncate`](#truncate), [`-Wrap`](#wrap), [`-StartTab`](#starttab), [`-StartSpaces`](#startspaces), [`-LinesBefore`](#linesbefore), [`-LinesAfter`](#linesafter), [`-HorizontalCenter`](#horizontalcenter), [`-NoNewLine`](#nonewline), [`-BlankLine`](#blankline), [`-ShowTime`](#showtime) |
| Style profiles | [`-StyleProfile`](#styleprofile), [`-Default`](#default) |
| Logging | [`-LogFile`](#logfile), [`-LogPath`](#logpath), [`-LogLevel`](#loglevel), [`-LogTime`](#logtime), [`-DateTimeFormat`](#datetimeformat), [`-LogRetry`](#logretry), [`-Encoding`](#encoding), [`-NoConsoleOutput`](#noconsoleoutput) |
| Diagnostics | [`-Debugging`](#debugging), [`-Silent`](#silent) |

## Examples

Segments, each with its own color and background:

```powershell
PS> Write-ColorEX -Text '[', 'OK', '] ', 'Service started' -Color Gray, Green, Gray, White
[OK] Service started
PS> Write-ColorEX -Text ' ERROR ', ' disk full ' -Color White, Red -BackGroundColor DarkRed, Black
 ERROR  disk full
```

Hex codes, `rgb()` and `hsl()`, styled:

```powershell
PS> Write-ColorEX -Text 'Orange ', 'teal ', 'violet' -Color '#FF8800', 'rgb(0, 160, 160)', 'hsl(270, 80%, 65%)' -Bold
Orange teal violet
```

A gradient across the text, and one across the background:

```powershell
PS> Write-ColorEX -Text 'Deploying to production' -Gradient '#00C6FF', '#7B2FF7'
Deploying to production
PS> Write-ColorEX -Text '      a background gradient      ' -Color White -BackGroundGradient DarkBlue, DarkMagenta
      a background gradient
```

Markup tags, and patterns colored where they match:

```powershell
PS> Write-ColorEX -Markup '[bold green]PASS[/] 41 tests, [bold red]FAIL[/] 2 tests'
PASS 41 tests, FAIL 2 tests
PS> Write-ColorEX -Text 'GET /api/users 200 12ms' -Highlight @{ '\b\d{3}\b' = 'bold yellow'; '\d+ms' = 'cyan' }
GET /api/users 200 12ms
```

Columns padded to a display width, a centered title, and text cut to fit:

```powershell
PS> Write-ColorEX -Text 'Name' -AutoPad 12 -NoNewLine -Color Cyan; Write-ColorEX -Text 'Status' -Color Cyan
Name        Status
PS> Write-ColorEX -Text 'Release' -AutoPad 24 -PadCenter -PadChar '=' -Color Yellow
========Release=========
PS> Write-ColorEX -Text 'A description too long for its column' -AutoPad 20 -Truncate
A description too l…
```

## Parameters

{{% parameters "Write-ColorEX" %}}
