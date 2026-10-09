---
title: Environment variables
weight: 120
---

The environment variables that turn colors off, force them on, or choose a color mode, and the
ones that name the terminal.

## The color variables

`Write-ColorEX` and `Format-ColorEX` read these on each call, so a change takes effect at once.
The first one set, in this order, decides:

| Variable | Value | Effect |
|---|---|---|
| `FORCE_COLOR` | `1`, `2` or `3` | Colors on, in 16 colors, 256 colors or TrueColor, whatever the terminal |
| `FORCE_COLOR` | `0` | Colors and styles off |
| `NO_COLOR` | any value | Colors and styles off |
| `CLICOLOR_FORCE` | anything but `0` | Colors on, in the mode detected, or 16 colors where none was |
| `CLICOLOR` | `0` | Colors and styles off |
| `TERM` | `dumb` | Colors and styles off |

With colors off, each line goes to the host as plain text in one call. `FORCE_COLOR` and
`CLICOLOR_FORCE` write a line whose colors are all names as escape codes too, where it would
otherwise go out as console colors, so the colors reach a log or a pipe. The sessions below run in
a terminal with TrueColor and no color variable set:

```powershell,detect
PS> Write-ColorEX -Text 'colors on' -Color Green -Bold
colors on
PS> $env:NO_COLOR = '1'; Write-ColorEX -Text 'NO_COLOR turns them off' -Color Green -Bold
NO_COLOR turns them off
PS> $env:FORCE_COLOR = '2'; Write-ColorEX -Text 'FORCE_COLOR=2 decides first: 256 colors' -Color '#FF8800'
FORCE_COLOR=2 decides first: 256 colors
```

```powershell,detect
PS> $env:TERM = 'dumb'; Write-ColorEX -Text 'TERM=dumb turns colors off' -Color Cyan -Italic
TERM=dumb turns colors off
PS> $env:CLICOLOR_FORCE = '1'; Write-ColorEX -Text 'CLICOLOR_FORCE=1 comes before TERM' -Color Cyan -Italic
CLICOLOR_FORCE=1 comes before TERM
```

`-ANSI4`, `-ANSI8` and `-TrueColor` choose a mode for one call, below the color variables:
`NO_COLOR` turns off colors the call asks for.

## The terminal variables

`Test-AnsiSupport` reads these, after the color variables, to find what the terminal supports,
and `Write-ColorEX` takes its answer when the module is imported:

| Variable | Read as |
|---|---|
| `COLORTERM` | `truecolor` or `24bit`: TrueColor |
| `TERM` | a name holding `256`: 256 colors; any other name: 16 colors; some names also name the terminal, such as `xterm-kitty`, `xterm-ghostty`, `alacritty`, `foot`, `mintty` and `konsole` |
| `TERM_PROGRAM` | the terminal: `iTerm.app`, `Apple_Terminal`, `vscode`, `WezTerm`, `ghostty`, `WarpTerminal`, `mintty`, `tmux` |
| `WT_SESSION` | Windows Terminal, on Windows and under WSL |
| `ConEmuANSI` | ConEmu |
| `VTE_VERSION` | GNOME Terminal and other VTE terminals |
| `KONSOLE_VERSION` | Konsole |
| `KITTY_WINDOW_ID`, `ALACRITTY_WINDOW_ID` | Kitty, Alacritty |
| `TERMINAL_EMULATOR` | `JetBrains-JediTerm`: the JetBrains IDEs |
| `TMUX` | tmux, which passes on the colors its own `TERM` and `COLORTERM` name |

[Test-AnsiSupport](test-ansisupport.md) gives the whole detection order, and the values are
compared without regard to case. [Terminal compatibility](terminals.md) lists what each terminal
shows.
