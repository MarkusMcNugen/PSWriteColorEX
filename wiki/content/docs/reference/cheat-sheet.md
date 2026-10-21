---
title: Cheat sheet
weight: 5
description: The commands and parameters of PSWriteColorEX used most, by task, each with an example.
---

The commands and parameters used most, by task, each with an example. The same sheet is in
PowerShell's help: `Get-Help about_PSWriteColorEX`, or `Get-Help about_PWRSWriteColorEX` with
PWRSWriteColorEX.

## Writing

Each string of `-Text` is a segment, and `-Color` and `-BackGroundColor` give the segments their
colors in turn. The message helpers write in the style profiles of their names.

```powershell
PS> Write-ColorEX -Text 'Saved ', 'report.txt' -Color Green, Cyan
Saved report.txt
PS> Write-ColorEX -Text ' ERROR ', ' disk full ' -Color White, Red -BackGroundColor DarkRed, Black
 ERROR  disk full
PS> Write-ColorEX -Text 'Name: ' -NoNewLine; Write-ColorEX -Text 'Ada' -Color Green
Name: Ada
PS> Write-ColorError 'Build failed'
Build failed
PS> Write-ColorWarning 'Disk at 91 percent'
Disk at 91 percent
PS> Write-ColorInfo 'Using the cache'
Using the cache
PS> Write-ColorSuccess 'Deployed'
Deployed
PS> Write-ColorCritical 'Service down'
Service down
PS> Write-ColorDebug 'Retry 2 of 3'
Retry 2 of 3
```

## Colors

A color is a name, a hex code, `rgb()` or `hsl()`, an RGB array, or a number with `-ANSI8` or
`-ANSI4`. `-ANSI4`, `-ANSI8` and `-TrueColor` choose the color mode for one call.

```powershell
PS> Write-ColorEX -Text 'a name' -Color Orange
a name
PS> Write-ColorEX -Text 'hex', ' short hex' -Color '#FF8800', '#F80'
hex short hex
PS> Write-ColorEX -Text 'rgb()', ' hsl()' -Color 'rgb(255, 136, 0)', 'hsl(32, 100%, 50%)'
rgb() hsl()
PS> Write-ColorEX -Text 'an RGB array' -Color @(255, 136, 0) -TrueColor
an RGB array
PS> Write-ColorEX -Text '256-color 208' -Color 208 -ANSI8
256-color 208
PS> Write-ColorEX -Text '16-color 93' -Color 93 -ANSI4
16-color 93
PS> Write-ColorEX -Text ' on a background ' -Color Black -BackGroundColor '#FFD700'
 on a background
```

## Styles

The style switches style every segment, and `-Style` one segment at a time.

```powershell
PS> Write-ColorEX -Text 'bold and italic' -Bold -Italic
bold and italic
PS> Write-ColorEX -Text 'bold', ' italic', ' underlined' -Style 'Bold', 'Italic', 'Underline'
bold italic underlined
PS> Write-ColorEX -Text 'misspeled' -UnderlineStyle Curly -UnderlineColor Red
misspeled
PS> Write-ColorEX -Text ' reversed ' -Color Cyan -Reverse
 reversed
PS> Write-ColorEX -Text 'crossed out', ' overlined' -Style 'CrossedOut', 'Overline'
crossed out overlined
PS> Show-ColorTable -Styles
Style            Sample       Parameter               Markup
Bold             Sample text  -Bold                   [bold]
Faint            Sample text  -Faint                  [faint] [dim]
Italic           Sample text  -Italic                 [italic]
Underline        Sample text  -Underline              [underline]
DoubleUnderline  Sample text  -DoubleUnderline        [doubleunderline]
Curly            Sample text  -UnderlineStyle Curly   [curly]
Dotted           Sample text  -UnderlineStyle Dotted  [dotted]
Dashed           Sample text  -UnderlineStyle Dashed  [dashed]
Blink            Sample text  -Blink                  [blink]
Reverse          Sample text  -Reverse                [reverse] [invert]
CrossedOut       Sample text  -CrossedOut             [crossedout] [strike]
                                                      [strikethrough]
Overline         Sample text  -Overline               [overline]
```

## Markup

`-Markup` reads tags in the text: style names, a text color, `on` and a background, and `link=`.
`[/]` closes the tag opened last, and `[[` writes `[`.

```powershell
PS> Write-ColorEX -Markup '[bold red]Error:[/] file not found'
Error: file not found
PS> Write-ColorEX -Markup '[black on #FFD700] WARN [/] [curly]check the spelling[/]'
 WARN  check the spelling
PS> Write-ColorEX -Markup '[green]outer [bold underline]inner[/] outer[/] plain'
outer inner outer plain
PS> Write-ColorEX -Markup '[link=https://example.com cyan underline]example.com[/]'
example.com
PS> Write-ColorEX -Markup 'Use [[bold]] for [bold]bold[/]'
Use [bold] for bold
```

## Gradients

`-Gradient` blends its colors across the text and `-BackGroundGradient` across the background, in
OKLab unless `-GradientSpace` names another space: RGB, LinearRGB, OKLCH, HSL, HSV, Lab or LCh.
Either takes the name of a named gradient in place of its colors, and a color may give its place as
a percent after an `@`. `-GradientHue`, `-GradientEasing`, `-GradientSteps`, `-GradientRepeat` and
`-GradientDirection` pick the way round the hue wheel, a curve along the text, bands of solid
color, repeats past placed colors and the way across the text. `Get-GradientColor` returns a
gradient's colors.

```powershell
PS> Write-ColorEX -Text 'Deploying to production' -Gradient '#00C6FF', '#7B2FF7'
Deploying to production
PS> Write-ColorEX -Text 'red, yellow and green' -Gradient Red, Yellow, Green
red, yellow and green
PS> Write-ColorEX -Text 'Sunset over the bay' -Gradient Sunset
Sunset over the bay
PS> Write-ColorEX -Text 'channel by channel' -Gradient Red, Green -GradientSpace RGB
channel by channel
PS> Write-ColorEX -Text '   a banner   ' -Color White -BackGroundGradient DarkBlue, DarkMagenta
   a banner
PS> Write-ColorEX -Text '   on ice   ' -Color Black -BackGroundGradient Ice
   on ice
PS> Write-ColorEX -Text 'Gold sits forty percent along' -Gradient 'Red', 'Gold@40', 'Blue'
Gold sits forty percent along
PS> Write-ColorEX -Text 'round the hue wheel' -Gradient Red, Blue -GradientSpace OKLCH -GradientHue Longer
round the hue wheel
PS> Write-ColorEX -Text 'eased in and out' -Gradient Black, White -GradientEasing InOutSine
eased in and out
PS> Write-ColorEX -Text 'three bands' -Gradient Green, Yellow, Red -GradientSteps 3
three bands
PS> Get-GradientColor -Gradient Red, Blue -Count 3 | ForEach-Object { $_ -join ', ' }
255, 0, 0
140, 83, 162
0, 0, 255
```

The named gradients: {{< gradient-names >}}.

## Highlighting and splitting

`-Highlight` styles what regular expressions match. `-Split`, `-SplitAround` and `-SplitEvenly`
cut a string into segments, so the colors fall on its parts.

```powershell
PS> Write-ColorEX -Text 'GET /api/users 200 12ms' -Highlight @{ '\b\d{3}\b' = 'bold yellow'; '\d+ms' = 'cyan' }
GET /api/users 200 12ms
PS> Write-ColorEX -Text 'one,two,three' -Split ',' -Color Red, Green, Blue
one,two,three
PS> Write-ColorEX -Text 'key=value' -SplitAround '=' -Color Cyan, DarkGray, White
key=value
PS> Write-ColorEX -Text 'STATUS' -SplitEvenly -Color Red, Yellow, Green
STATUS
```

## Layout

`-AutoPad` pads to a width in display cells, with `-PadLeft`, `-PadCenter` and `-PadChar` to
place the text and fill the rest; `-Truncate` and `-Wrap` fit longer text.

```powershell
PS> Write-ColorEX -Text 'Name' -AutoPad 12 -NoNewLine -Color Cyan; Write-ColorEX -Text 'Status' -Color Cyan
Name        Status
PS> Write-ColorEX -Text '42' -AutoPad 8 -PadLeft
      42
PS> Write-ColorEX -Text 'Release' -AutoPad 24 -PadCenter -PadChar '='
========Release=========
PS> Write-ColorEX -Text 'A description too long for its column' -AutoPad 20 -Truncate
A description too l…
PS> Write-ColorEX -Text 'the quick brown fox jumps over the lazy dog' -AutoPad 20 -Wrap
the quick brown fox
jumps over the lazy
dog
PS> Write-ColorEX -Text 'four spaces in' -StartSpaces 4
    four spaces in
PS> Write-ColorEX -Text 'a line before' -LinesBefore 1

a line before
```

`-StartTab` indents by tabs, `-LinesAfter` adds lines after, and `-HorizontalCenter` centers the
text in the window.

## Links

`-Link` makes each segment a link in terminals that open links, and plain text elsewhere.

```powershell
PS> Write-ColorEX -Text 'the documentation' -Link 'https://markusmcnugen.github.io/PSWriteColorEX/' -Color Cyan -Underline
the documentation
```

## Profiles and themes

A style profile holds colors, styles and layout. `-StyleProfile` writes with one, `-Default` with
the default style, and a theme restyles the profiles.

```powershell
PS> $badge = New-ColorStyle -Name 'Badge' -ForegroundColor Black -BackgroundColor Cyan -Bold
PS> Write-ColorEX -Text ' v1.2.0 ' -StyleProfile $badge
 v1.2.0
PS> Set-ColorDefault -ForegroundColor Cyan -Italic
PS> Write-ColorEX -Text 'in the default style' -Default
in the default style
PS> Import-ColorProfile -Theme Dracula
PS> Write-ColorError 'Build failed, in Dracula red'
Build failed, in Dracula red
PS> Write-ColorEX -Text 'Dracula purple' -Color DraculaPurple
Dracula purple
PS> Import-ColorProfile -Theme PowerShell
PS> Write-ColorWarning 'as PowerShell writes a warning'
as PowerShell writes a warning
PS> Export-ColorProfile -Path 'colors.json'
PS> Import-ColorProfile -Path 'colors.json'
```

The themes: {{< theme-names >}}.

## Color names and views

`Register-ColorName` adds a color name and `-Theme CSS` the CSS names. `Get-ColorContrast` gives
the contrast ratio of a color on a background, from 1 to 21. `Show-ColorTable` writes the names, or
with `-Styles`, `-Palette` or `-Profiles` a view of the styles, the 256 colors or the profiles.

```powershell
PS> Register-ColorName -Name Brand -Color '#FF6B35'
PS> Write-ColorEX -Text 'Acme' -Color Brand -Bold
Acme
PS> Get-ColorContrast Brand Black
7.40648631866113
PS> Import-ColorProfile -Theme CSS
PS> Write-ColorEX -Text 'Tomato', ' and RebeccaPurple' -Color Tomato, RebeccaPurple
Tomato and RebeccaPurple
PS> Show-ColorTable -Name *Teal
Name       TrueColor  256     16      Console  Hex      ANSI8  Console color
DarkTeal   ██████     ██████  ██████  ██████   #008080     30  DarkCyan
Teal       ██████     ██████  ██████  ██████   #009696     30  DarkCyan
LightTeal  ██████     ██████  ██████  ██████   #40E0D0     44  Cyan
PS> Show-ColorTable -Profiles -Name Error, Warning
Profile  Sample       Settings
Error    Sample text  Red, Bold
Warning  Sample text  Yellow
PS> Show-ColorTable -Palette
  0   1   2   3   4   5   6   7
  8   9  10  11  12  13  14  15

 16  17  18  19  20  21    52  53  54  55  56  57    88  89  90  91  92  93
 22  23  24  25  26  27    58  59  60  61  62  63    94  95  96  97  98  99
 28  29  30  31  32  33    64  65  66  67  68  69   100 101 102 103 104 105
 34  35  36  37  38  39    70  71  72  73  74  75   106 107 108 109 110 111
 40  41  42  43  44  45    76  77  78  79  80  81   112 113 114 115 116 117
 46  47  48  49  50  51    82  83  84  85  86  87   118 119 120 121 122 123

124 125 126 127 128 129   160 161 162 163 164 165   196 197 198 199 200 201
130 131 132 133 134 135   166 167 168 169 170 171   202 203 204 205 206 207
136 137 138 139 140 141   172 173 174 175 176 177   208 209 210 211 212 213
142 143 144 145 146 147   178 179 180 181 182 183   214 215 216 217 218 219
148 149 150 151 152 153   184 185 186 187 188 189   220 221 222 223 224 225
154 155 156 157 158 159   190 191 192 193 194 195   226 227 228 229 230 231

232 233 234 235 236 237 238 239 240 241 242 243
244 245 246 247 248 249 250 251 252 253 254 255
```

## Logging

`-LogFile` writes each line to a file as well, as plain text, with `-LogTime` and `-LogLevel` in
front when asked for. `-ShowTime` writes the time on the console.

```powershell,clock
PS> Write-ColorEX -Text 'Service ', 'started' -Color Gray, Green -LogFile 'service.log'
Service started
PS> Write-ColorEX -Text 'Disk at 91 percent' -Color Yellow -LogFile 'service.log' -LogTime -LogLevel 'WARN'
Disk at 91 percent
PS> Write-ColorEX -Text 'written to the file only' -LogFile 'service.log' -NoConsoleOutput
PS> Get-Content 'service.log'
Service started
[2026-10-09 14:30:00][WARN] Disk at 91 percent
written to the file only
PS> Write-ColorEX -Text 'with the time' -ShowTime
[2026-10-09 14:30:00] with the time
```

## Strings

`Format-ColorEX` returns the line as a string with its escape codes, to build on or write later.
`-ColorSupport` makes it for the support named, whatever the terminal and the variables.

```powershell
PS> $ok = Format-ColorEX 'OK' -Color Green -Bold
PS> "Status: $ok"
Status: OK
PS> Format-ColorEX 'for 16 colors' -Color '#FF8800' -ColorSupport ANSI4
for 16 colors
PS> Measure-DisplayWidth -Text 'Tokyo 東京'
10
```

## Environment variables

The first one set decides, on every call:

| Variable | Effect |
|---|---|
| `FORCE_COLOR=1`, `2` or `3` | Colors on, in 16 colors, 256 colors or TrueColor, whatever the terminal |
| `FORCE_COLOR=0` | Colors and styles off |
| `NO_COLOR`, any value | Colors and styles off |
| `CLICOLOR_FORCE`, anything but `0` | Colors on, in the mode detected, or 16 colors where none was |
| `CLICOLOR=0` | Colors and styles off |
| `TERM=dumb` | Colors and styles off |

`-ColorSupport None`, `ANSI4`, `ANSI8` or `TrueColor` takes the place of all of them for one call.
`WRITECOLOREX_UNICODE=true` or `false` sets `Test-AnsiSupport`'s `SupportsUnicode`.

## Commands

{{< command-list >}}
