---
title: Test-AnsiSupport
weight: 90
---

Detects the terminal's color support, whether it draws bold as a bold font, and which styles it
draws.

{{< syntax "Test-AnsiSupport" >}}

## Description

`Test-AnsiSupport` reads the environment and the host and answers one of `TrueColor`, `ANSI8`
(256 colors), `ANSI4` (16 colors) or `None`. `Write-ColorEX` runs it once, when the module is
imported, and falls back to the mode it reports. It decides in this order:

1. The color variables, the first one set deciding: `FORCE_COLOR`, `NO_COLOR`, `CLICOLOR_FORCE`,
   `CLICOLOR`, then `TERM=dumb`. See [Environment variables](environment.md).
2. On PowerShell 7.2 and later, a host without virtual terminal support answers `None`, since
   PowerShell removes escape codes from its output.
3. `COLORTERM`, `TERM` and the variables each terminal sets, compared without regard to case.

It recognizes, on Windows, Windows Terminal, the console host (conhost), ConEmu, VS Code, WezTerm,
the JetBrains IDEs, the PowerShell ISE and Git Bash; on macOS, iTerm2, Terminal.app, VS Code,
Ghostty, WezTerm, Kitty, Alacritty, Warp and the JetBrains IDEs; on Linux, GNOME Terminal and the
other VTE terminals, Konsole, xterm, rxvt-unicode, Ghostty, WezTerm, Kitty, Alacritty, foot, Warp,
the JetBrains IDEs, and Windows Terminal under WSL; and tmux, taking the colors its `TERM` and
`COLORTERM` name. In Windows PowerShell 5.1 on Windows 10 build 10586 or later, it switches on
virtual terminal processing in the console host for the session when it is off. The console host
draws bold as brighter colors, in any PowerShell, so `SupportsBoldFonts` is `$false` there.
[Terminal compatibility](terminals.md) lists what each terminal shows.

## The result

| Property | Holds |
|---|---|
| `ColorSupport` | `TrueColor`, `ANSI8`, `ANSI4` or `None` |
| `SupportsBoldFonts` | `$true` where bold is a bold font, `$false` where it is brighter colors |
| `Details` | A hashtable: `TerminalType`, `OperatingSystem`, `PowerShellVersion`, `IsPSCore`, `IsConsoleHost`, `HasVirtualTerminalProcessing`, `HasCompatibleTerminalEnv`, `StyleSupport` (a hashtable of style names and whether the terminal draws them), `Warnings`, and `EnableInstructions` on Windows |

Without `-Silent` it writes a warning for each limitation it finds, such as a terminal that does not
draw italics.

## Examples

The answer follows the color variables:

```powershell
PS> (Test-AnsiSupport -Silent).ColorSupport
TrueColor
PS> $env:FORCE_COLOR = '1'; (Test-AnsiSupport -Silent).ColorSupport
ANSI4
PS> $env:FORCE_COLOR = '0'; (Test-AnsiSupport -Silent).ColorSupport
None
```

The details depend on the machine; in PowerShell 7.6 in Windows Terminal:

```powershell,norun
PS> Test-AnsiSupport -Silent | Select-Object ColorSupport, SupportsBoldFonts
ColorSupport SupportsBoldFonts
------------ -----------------
TrueColor                 True
PS> (Test-AnsiSupport -Silent).Details.TerminalType
Windows Terminal
```

## Parameters

{{% parameters "Test-AnsiSupport" %}}
