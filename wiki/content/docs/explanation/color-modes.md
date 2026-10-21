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
order. `Write-ColorEX` keeps that result for the session, but reads the color variables
(`FORCE_COLOR`, `NO_COLOR`, `CLICOLOR_FORCE`, `CLICOLOR` and `TERM=dumb`) on each call, so a script
can force a mode or turn colors off at any point.

`-ColorSupport` names the support for one call of `Write-ColorEX` or `Format-ColorEX`, in place of
all of this: `None`, `ANSI4`, `ANSI8` or `TrueColor`, the values `Test-AnsiSupport` reports. The
call writes what a terminal of that support gets, whatever the host and the variables, which suits
output made for somewhere other than the terminal at hand. `-Bold` lightens the colors where bold
cannot show: always with `None`, whose console colors carry no bold, and with the others where the
terminal draws bold as brighter colors.

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

`Convert-RGBToANSI8` returns the code from the cube or the grays, 16 to 255, that looks nearest to
the color. It measures how far apart two colors are in OKLab, a color space where equal distances
look equally different, and counts the difference in lightness at 0.6 of its size. That way a dark
blue or brown keeps a code of its own hue instead of turning gray. It never returns codes 0 to 15,
because the terminal's scheme sets their colors.

```powershell
PS> Convert-RGBToANSI8 255, 136, 0
208
PS> Convert-RGBToANSI8 0, 51, 102
17
PS> Convert-RGBToANSI8 130, 128, 126
244
```

Windows PowerShell 5.1, PowerShell 7 and PWRSWriteColorEX do the same arithmetic, so all three
return the same code for every color.

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

A color name gets the same 256-color code as its hex code, except the 17 names on codes 0 to 15,
which follow the terminal's scheme. Each name's 16-color codes and console color are set in the
color table, which [Colors and names](colors-and-names.md) lists.
