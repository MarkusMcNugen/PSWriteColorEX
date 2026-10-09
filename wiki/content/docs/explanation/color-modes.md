---
title: Color modes
weight: 10
---

A terminal shows colors in one of four ways, and the module writes each color in the best of them
the terminal has.

## The four modes

| Mode | Colors | How it is written |
|---|---|---|
| TrueColor | 16.7 million | `ESC[38;2;R;G;Bm`, any RGB value |
| ANSI8 | 256 | `ESC[38;5;Nm`: 16 standard colors, a 6x6x6 cube, 24 grays |
| ANSI4 | 16 | `ESC[30m` to `ESC[37m` and `ESC[90m` to `ESC[97m` |
| Console colors | 16 | `Write-Host -ForegroundColor`, where escape codes do not reach the screen |

The 16 colors of ANSI4 and the console are the terminal's own palette, so the same code looks
different from one color scheme to another; this site draws them in Windows Terminal's default
scheme. The cube and the grays of ANSI8, and every TrueColor value, look the same everywhere.

## Finding the mode

`Test-AnsiSupport` finds the mode when the module is imported, from the color variables, the
host, and the variables each terminal sets; [Test-AnsiSupport](test-ansisupport.md) gives the
order. `Write-ColorEX` keeps that answer for the session, but reads the color variables
(`FORCE_COLOR`, `NO_COLOR`, `CLICOLOR_FORCE`, `CLICOLOR` and `TERM=dumb`) on each call, so a script
can force a mode or turn colors off at any point.

A call asks for a mode with `-TrueColor`, `-ANSI8` or `-ANSI4`, or by holding a TrueColor color: a
hex code, an `rgb()` or `hsl()` color, an RGB array or a gradient. Given more than one of the
switches, the call warns and takes the highest, `-TrueColor` before `-ANSI8`. A call that asks for none and
holds only names and console colors is written as console colors, which needs no conversion at
all. A mode the terminal lacks falls back to the next one down, TrueColor to ANSI8 to ANSI4 to
console colors, with a warning when the call asked for the mode by name.

## One color in each mode

A TrueColor color is matched to the nearest color of the mode in use:

```powershell
PS> Write-ColorEX -Text 'Coral ', 'Teal ', 'Gold ', '#7B2FF7' -Color Coral, Teal, Gold, '#7B2FF7'
Coral Teal Gold #7B2FF7
```

```powershell,ansi8
PS> Write-ColorEX -Text 'Coral ', 'Teal ', 'Gold ', '#7B2FF7' -Color Coral, Teal, Gold, '#7B2FF7'
Coral Teal Gold #7B2FF7
```

```powershell,ansi4
PS> Write-ColorEX -Text 'Coral ', 'Teal ', 'Gold ', '#7B2FF7' -Color Coral, Teal, Gold, '#7B2FF7'
Coral Teal Gold #7B2FF7
```

## The nearest of 256

`Convert-RGBToANSI8` matches a color to the 256 colors in two ways:

- A color whose red, green and blue are within 10 of each other is a gray. Its average below 8 is
  black (16), above 248 white (231), and otherwise the nearest of the 24 grays, 232 to 255, which
  step by 10 from 8.
- Any other color takes the nearest step of the 6x6x6 cube in each channel, the steps falling at
  48, 115, 155, 195 and 235, and is 16 + 36 x red + 6 x green + blue.

```powershell
PS> Convert-RGBToANSI8 255, 136, 0
208
PS> Convert-RGBToANSI8 130, 128, 126
244
```

## The nearest of 16

`Convert-RGBToANSI4` works from the strongest channels:

- A color whose channels are within 30 of each other is a gray: black, dark gray, gray or white
  by its brightness, in steps of 64.
- Any other color is red, yellow, green, cyan, blue or magenta by which channels are strongest,
  and the bright variant when its strongest channel is 200 or more.

```powershell
PS> Convert-RGBToANSI4 255, 136, 0
93
PS> Convert-RGBToANSI4 120, 60, 0
33
```

A color name skips both: the color table holds each name's 256-color number, 16-color codes and
console color, chosen for it, which [Colors and names](colors-and-names.md) lists.
