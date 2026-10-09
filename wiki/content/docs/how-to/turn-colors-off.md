---
title: Turn colors off or force them
weight: 70
---

To turn colors off, or to keep them on where they would be off, set one of the color variables.
The module reads them on every call, so a change takes effect at once.

## Turn colors off

`NO_COLOR`, set to anything, turns colors and styles off. So do `FORCE_COLOR=0`, `CLICOLOR=0` and
`TERM=dumb`:

```powershell,detect
PS> $env:NO_COLOR = '1'
PS> Write-ColorEX -Text 'plain text' -Color Red -Bold
plain text
PS> Remove-Item Env:NO_COLOR
PS> Write-ColorEX -Text 'red and bold again' -Color Red -Bold
red and bold again
```

## Force colors on

`FORCE_COLOR` set to 1, 2 or 3 keeps colors on in 16 colors, 256 colors or TrueColor, whatever the
terminal reports. `CLICOLOR_FORCE` keeps them on in the mode the terminal reports:

```powershell,detect
PS> $env:FORCE_COLOR = '1'; Write-ColorEX -Text 'forced to 16 colors' -Color '#FF8800'
forced to 16 colors
PS> $env:FORCE_COLOR = '2'; Write-ColorEX -Text 'forced to 256 colors' -Color '#FF8800'
forced to 256 colors
PS> $env:FORCE_COLOR = '3'; Write-ColorEX -Text 'forced to TrueColor' -Color '#FF8800'
forced to TrueColor
```

When several are set, the first in this order decides: `FORCE_COLOR`, `NO_COLOR`,
`CLICOLOR_FORCE`, `CLICOLOR`, then `TERM`. [Environment variables](environment.md) has the table.

## For one call

`-ANSI4`, `-ANSI8` and `-TrueColor` choose the mode for one call. The color variables still come
first, so `NO_COLOR` turns off even a call that asks for a mode.

## In CI and in files

A CI job writes to a log rather than a terminal. On Windows with no terminal, PowerShell 7 writes
TrueColor and Windows PowerShell 5.1 writes plain text. Most CI systems show colors in their logs,
so set `FORCE_COLOR` in the job to the colors the log shows: every call then writes its colors as
escape codes, in any PowerShell. [Terminal compatibility](terminals.md) lists what each CI system
shows.

`Write-ColorEX` writes to the host, not to the output stream, so `>` does not redirect it; `6>` or
`*>` does. PowerShell 7.2 and later remove the escape codes from output redirected to a file,
unless `$PSStyle.OutputRendering` is `Ansi`; Windows PowerShell 5.1 keeps them. To keep the colors
in a file in any PowerShell, [build colored strings](build-colored-strings.md) and write them with
`Set-Content`.

## The whole script

```powershell
# At the top of a script that must write plain text
$env:NO_COLOR = '1'

# In a CI job whose log shows colors
$env:FORCE_COLOR = '3'
```
