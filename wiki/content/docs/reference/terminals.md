---
title: Terminal compatibility
weight: 95
---

The colors and text styles each terminal shows, and what the module does in each. In the tables,
yes means the terminal draws the style, no means it does not, and partial means it depends on the
terminal's version or settings. [Test-AnsiSupport](test-ansisupport.md) reports what it finds in
the terminal you are in.

## Windows

| Terminal | Colors | Bold | Italic | Underline | Blink | Faint | Overline | Crossed out | Double underline |
|---|---|---|---|---|---|---|---|---|---|
| Windows Terminal | TrueColor | yes | yes | yes | yes | yes | yes | yes | partial |
| Windows console host (conhost) | TrueColor | yes | no | yes | yes | yes | yes | no | no |
| ConEmu and Cmder | TrueColor, partial | yes | yes | yes | no | no | no | no | no |
| VS Code terminal | TrueColor | yes | yes | partial | no | yes | no | partial | no |
| Git Bash (mintty) | TrueColor | yes | yes | yes | partial | partial | yes | yes | yes |
| PowerShell ISE | console colors only | no | no | no | no | no | no | no | no |

- Escape codes need Windows 10 build 10586 or later, and TrueColor build 14931 or later. In Windows
  PowerShell 5.1, `Test-AnsiSupport` switches on escape codes in the console host for the session
  when they are off. To switch them on in every console window for good, set
  `VirtualTerminalLevel` under `HKCU:\Console` to 1:
  `Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1`.
- Windows Terminal draws crossed-out text from its version 1.3.
- ConEmu shows TrueColor only in the bottom part of its buffer, with scrolling turned off.
- The VS Code terminal is built on xterm.js, which draws underline and crossed-out text fully from
  its version 5.
- mintty, the terminal of Git Bash, Cygwin and MSYS2, shows TrueColor from its version 2.0.1.
- The PowerShell ISE shows no escape codes, so the module writes console colors there.

## Linux

| Terminal | Colors | Bold | Italic | Underline | Blink | Faint | Overline | Crossed out | Double underline |
|---|---|---|---|---|---|---|---|---|---|
| GNOME Terminal 3.28 or later (VTE 0.52) | TrueColor | yes | yes | yes | yes | yes | yes | yes | no |
| GNOME Terminal 3.52 or later (VTE 0.76) | TrueColor | yes | yes | yes | yes | yes | yes | yes | yes |
| Konsole | TrueColor | yes | yes | yes | no | partial | yes | yes | no |
| xterm | 256 colors | yes | yes | yes | partial | partial | no | yes | no |
| rxvt-unicode (urxvt) | 256 colors | yes | yes | yes | yes | partial | no | no | no |
| rxvt | 16 colors | yes | no | yes | no | no | no | no | no |
| Kitty | TrueColor | yes | yes | yes | yes | yes | partial | yes | yes |
| Other VTE terminals | TrueColor | yes | yes | yes | varies | varies | varies | varies | varies |

- GNOME Terminal draws curly and colored underlines from 3.28 (VTE 0.52, Ubuntu 18.04), and dotted
  and dashed ones from 3.52 (VTE 0.76, Ubuntu 24.04).
- Other VTE terminals, such as Xfce Terminal, Tilix, Terminator and Guake, draw what their version
  of VTE draws.
- rxvt-unicode draws italics when it is built with `--enable-font-styles`, and blinks when it is
  built with `--enable-text-blink`. Plain rxvt has neither 256 colors nor italics.
- Older versions of xterm draw blink as bold.
- Windows Terminal running a WSL shell passes `WT_SESSION` through, and the module finds it by
  that.

## macOS

| Terminal | Colors | Bold | Italic | Underline | Blink | Faint | Overline | Crossed out | Double underline |
|---|---|---|---|---|---|---|---|---|---|
| iTerm2 3.5 or later | TrueColor | yes | yes | yes | partial | partial | yes | yes | partial |
| iTerm2 3.0 to 3.4 | TrueColor | yes | yes | yes | partial | partial | partial | no | no |
| Terminal.app | 256 colors | yes | yes | yes | no | no | no | no | no |
| VS Code terminal | TrueColor | yes | yes | partial | no | yes | no | partial | no |

- Terminal.app shows at most 256 colors, never TrueColor, so the module writes each TrueColor color
  as the nearest of the 256. It draws italics from macOS 10.12.
- iTerm2 shows TrueColor from its version 3.0, and sets `COLORTERM=truecolor`.

## Other terminals the module finds

`Test-AnsiSupport` also finds these terminals by the variables they set, on Linux and macOS, and
WezTerm and the JetBrains IDEs on Windows too. For each it reports TrueColor, a bold font, and
italic, underline and crossed-out text, plus the styles in the last column:

| Terminal | Found by | Also reports |
|---|---|---|
| Ghostty | `TERM_PROGRAM=ghostty` or `TERM=xterm-ghostty` | double underline, overline |
| WezTerm | `TERM_PROGRAM=WezTerm` | double underline, overline, blink |
| Kitty | `TERM=xterm-kitty` or `KITTY_WINDOW_ID` | double underline |
| Alacritty | `TERM=alacritty` or `ALACRITTY_WINDOW_ID` | none |
| foot | `TERM` starting with `foot` | none |
| Warp | `TERM_PROGRAM=WarpTerminal` | none |
| JetBrains IDEs | `TERMINAL_EMULATOR=JetBrains-JediTerm` | none |

tmux shows the colors its own `TERM` and `COLORTERM` name, 256 at least, and passes bold to the
terminal it runs in. Set `COLORTERM=truecolor` inside tmux when the terminal outside it shows
TrueColor.

## Bold

A terminal draws bold either as a bold font or as brighter colors, and brighter colors exist only
among the 16. Where a terminal draws brighter colors, the module lightens the colors of bold text
itself, as [Style names](style-names.md) describes, so bold shows in every color. `Test-AnsiSupport`
reports which kind of terminal it is in `SupportsBoldFonts`.

- A bold font: Windows Terminal in PowerShell 7, ConEmu, the VS Code terminal, mintty, iTerm2,
  Konsole, rxvt and rxvt-unicode, GNOME Terminal 3.32 or later (VTE 0.56), Windows Terminal under
  WSL, tmux, the terminals in the table above, and any other Windows terminal running PowerShell 7.
- Brighter colors: the Windows console host in any PowerShell, Windows Terminal in Windows
  PowerShell 5.1, GNOME Terminal 3.28 to 3.31 and older VTE terminals, xterm, Terminal.app, and
  other terminals on Linux and macOS.

## CI systems

| System | Shows in its log |
|---|---|
| GitHub Actions | 256 colors |
| Azure Pipelines | 256 colors |
| GitLab CI | 256 colors |
| CircleCI | TrueColor |
| Travis CI | 256 colors |
| AppVeyor | 256 colors |
| Jenkins | colors with the AnsiColor plugin, set with `ansiColor('xterm')` |

A CI job writes to a log rather than a terminal. On Windows with no terminal, PowerShell 7 writes
TrueColor and Windows PowerShell 5.1 writes plain text. Set `FORCE_COLOR` in the job to the colors
its log shows, 2 for 256 colors or 3 for TrueColor, and every call writes its colors as escape
codes, in any PowerShell; see [Turn colors off or force them](turn-colors-off.md).

## Styles that vary most

- Blink: many terminals leave it out on purpose. Windows Terminal and the console host blink to the
  lighter color that bold would show.
- In 16 colors, bold and blink can only brighten the dark colors (DarkRed to Red), and faint can
  only dim the bright ones (Red to DarkRed).
- Double underline: its code, 21, also means bold off in the older standard (ECMA-48), so few
  terminals draw it.
- A terminal that does not draw a style ignores its code, and shows the text with the styles it
  does draw.

## When a terminal has less

The module falls back one mode at a time, from TrueColor to 256 colors, 16 colors and then the
console's own colors, and converts each color to the nearest one the mode has.
[Color modes](color-modes.md) explains how each color is converted.
