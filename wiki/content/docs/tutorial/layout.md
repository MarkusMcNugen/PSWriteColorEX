---
title: Layout
weight: 60
---

Padding, alignment, cutting, wrapping, indentation, blank lines and timestamps: the parameters
that place text on the line.

## Padding to a width

`-AutoPad` pads the text with spaces to a display width, so columns line up. `-NoNewLine` leaves
the line open for the next column:

```powershell
PS> Write-ColorEX -Text 'Host' -AutoPad 10 -NoNewLine -Color Cyan; Write-ColorEX -Text 'State' -Color Cyan
Host      State
PS> Write-ColorEX -Text 'web01' -AutoPad 10 -NoNewLine; Write-ColorEX -Text 'running' -Color Green
web01     running
PS> Write-ColorEX -Text 'db01' -AutoPad 10 -NoNewLine; Write-ColorEX -Text 'stopped' -Color Red
db01      stopped
```

`-PadLeft` pads on the left, which right-aligns numbers, and `-PadCenter` pads both sides.
`-PadChar` pads with another character:

```powershell
PS> Write-ColorEX -Text '42' -AutoPad 8 -PadLeft
      42
PS> Write-ColorEX -Text '1337' -AutoPad 8 -PadLeft
    1337
PS> Write-ColorEX -Text ' Menu ' -AutoPad 20 -PadCenter -PadChar '=' -Color Yellow
======= Menu =======
```

## Wide characters

The width counts what a terminal draws: most emoji and CJK characters take two cells, so a column
holding them stays aligned with one that does not:

```powershell
PS> Write-ColorEX -Text 'Tokyo 東京' -AutoPad 14 -NoNewLine; Write-ColorEX -Text '|'
Tokyo 東京    |
PS> Write-ColorEX -Text 'Paris' -AutoPad 14 -NoNewLine; Write-ColorEX -Text '|'
Paris         |
```

[Display width](display-width.md) explains how the width is counted.

## Cutting and wrapping

`-Truncate` cuts text wider than `-AutoPad` and ends it with an ellipsis. `-Wrap` breaks it into
lines no wider than `-AutoPad`, at the last space that fits:

```powershell
PS> Write-ColorEX -Text 'C:\a\very\long\path\to\a\file.txt' -AutoPad 20 -Truncate
C:\a\very\long\path…
PS> Write-ColorEX -Text 'Wrapping breaks a long line at the last space that fits in the width.' -AutoPad 28 -Wrap -Color Gray
Wrapping breaks a long line
at the last space that fits
in the width.
```

Without `-AutoPad`, `-Wrap` wraps at the width of the console window.

## Indentation and blank lines

`-StartSpaces` and `-StartTab` put spaces or tab characters before the text, and `-LinesBefore`
and `-LinesAfter` put blank lines around it:

```powershell
PS> Write-ColorEX -Text 'Step 1: ', 'download' -StartSpaces 4 -Color Gray, White
    Step 1: download
PS> Write-ColorEX -Text 'Results' -Color Cyan -LinesBefore 1 -LinesAfter 1

Results

PS> Write-ColorEX -Text '12 passed, 0 failed'
12 passed, 0 failed
```

`-HorizontalCenter` centers the text in the console window, and `-BlankLine` writes a line of
spaces as wide as the window, which `-BackGroundColor` colors. Both need a window, so they do
nothing when output goes to a file.

## Building a line from several calls

`-NoNewLine` leaves the line open, so the next call continues it:

```powershell
PS> Write-ColorEX -Text 'Copying files... ' -NoNewLine; Write-ColorEX -Text 'done' -Color Green
Copying files... done
```

## The time

`-ShowTime` writes the time before the text in dark gray, and `-DateTimeFormat` sets its format:

```powershell,clock
PS> Write-ColorEX -Text 'Backup started' -ShowTime
[2026-10-09 14:30:00] Backup started
PS> Write-ColorEX -Text 'Backup finished' -ShowTime -DateTimeFormat 'HH:mm:ss'
[14:42:07] Backup finished
```

## Next

[Style profiles](profiles.md) keeps a set of colors, styles and layout under a name.
