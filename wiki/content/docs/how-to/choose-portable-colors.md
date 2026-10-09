---
title: Choose colors that work everywhere
weight: 90
---

To make a script look right in every terminal, choose colors that stay apart in 256 and 16 colors
as well as in TrueColor. A terminal with fewer colors shows the nearest one it has, and close
colors can become the same one.

## See each color in every mode

`Show-ColorTable` writes each name with a sample in TrueColor, 256 colors, 16 colors and the
console's colors, in your own terminal:

```powershell
PS> Show-ColorTable -Name Coral, Salmon, Peach
Name    TrueColor  256     16      Console  Hex      ANSI8  Console color
Coral   ██████     ██████  ██████  ██████   #FF7F50    209  Red
Peach   ██████     ██████  ██████  ██████   #FFDAB9    216  Yellow
Salmon  ██████     ██████  ██████  ██████   #FA8072    174  Red
```

Coral, Salmon and Peach are three colors in TrueColor, but Coral and Salmon are both Red in 16
colors. A name alone, with
no TrueColor color in the call, is written as its 16-color console color, so the second line here
shows what a 16-color terminal shows:

```powershell
PS> Write-ColorEX -Text 'Coral ', 'Salmon ', 'Peach' -Color Coral, Salmon, Peach -TrueColor
Coral Salmon Peach
PS> Write-ColorEX -Text 'Coral ', 'Salmon ', 'Peach' -Color Coral, Salmon, Peach
Coral Salmon Peach
```

## Test a script in fewer colors

Set `FORCE_COLOR` to see a script as a 256-color or 16-color terminal would show it:

```powershell,detect
PS> $env:FORCE_COLOR = '2'; Write-ColorEX -Text 'OK ', 'WARN ', 'FAIL' -Color '#2ECC71', '#F1C40F', '#E74C3C'
OK WARN FAIL
PS> $env:FORCE_COLOR = '1'; Write-ColorEX -Text 'OK ', 'WARN ', 'FAIL' -Color '#2ECC71', '#F1C40F', '#E74C3C'
OK WARN FAIL
```

## Choose names that stay apart

- For states that must not be mistaken, use colors from different families, such as Green,
  Yellow and Red, rather than three shades of one.
- Within a family, Dark and Light variants often share a console color. Check them with
  `Show-ColorTable` before you rely on them.
- A gradient needs 256 colors or more; in 16 colors the text is written without it.
- Do not carry meaning in color alone: a word such as OK or FAIL still reads where colors are off.
