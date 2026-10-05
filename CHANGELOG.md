# Changelog

All notable changes to PSWriteColorEX are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-10-05

### Added

- `-Encoding` takes `utf8BOM`, `utf8NoBOM`, `bigendianutf32` and `ansi`.
- `TERM=dumb` turns colors and styles off in `Write-ColorEX`, and
  `Test-AnsiSupport` answers `None` for it.
- `Test-AnsiSupport` detects Windows Terminal running a WSL shell from
  `WT_SESSION` on Linux and macOS, as `TrueColor`.
- Tests for `Measure-DisplayWidth`, for what `Write-ColorEX` hands to
  `Write-Host`, for transcripts and for the log file, and a GitHub Actions
  workflow that runs the tests in Windows PowerShell 5.1 and in PowerShell 7
  on Windows, Linux and macOS.

### Changed

- `Write-ColorEX` writes each line in as few `Write-Host` calls as its colors
  allow, with the line end on the last call. On PowerShell 7.2 and later,
  where the host shows escape codes, a line of console colors goes out as one
  call with the colors as escape codes. Windows PowerShell 5.1 keeps escape
  codes in transcripts, so there each color is still its own call. Each
  segment was its own call, followed by an empty call to end the line, before.
- The log file is UTF-8 without a byte order mark by default, and each
  `-Encoding` name writes the same bytes in Windows PowerShell 5.1 and
  PowerShell 7. A byte order mark goes only into a new or empty file. In 5.1,
  `Get-Content -Encoding UTF8` reads such a file's non-ASCII text, or
  `-Encoding utf8BOM` writes a file that 5.1 reads without it. The default was
  `unicode` (UTF-16) before, and `utf8` wrote a byte order mark in 5.1 only.
- Importing the module writes nothing to the host. It wrote the version and
  the detected color support before.
- The lightening functions are `Get-LighterRGBColor`, `Get-LighterColorName`
  and `Get-LighterANSI8Color`. `Lighten-RGBColor`, `Lighten-ColorName`,
  `Lighten-ANSI8Color`, `Lighten-ANSI8` and `LA8` stay as aliases. Importing
  the module warned about the unapproved verb `Lighten` before.
- `PSColorStyle.ToWriteColorParams()` builds the parameters from the current
  properties on each call. `InvalidateCache()` does nothing and stays for
  scripts that call it. The parameters were cached until `InvalidateCache()`
  was called before.
- `Measure-DisplayWidth` takes each character's width from the table of the
  Rust crate unicode-width 0.2.2, and measures emoji sequences (U+FE0F,
  U+FE0E, skin tones, U+200D joins and flags) as terminals draw them. It walks
  the text by code point, so Windows PowerShell 5.1 and PowerShell 7 give the
  same width. East Asian Ambiguous characters such as `●` and box drawing are
  1 cell, or 2 with `-AmbiguousAsWide`; `●` was 2 cells before.
- On PowerShell 7.2 and later, `Test-AnsiSupport` answers `None` for a host
  without virtual terminal support, since PowerShell removes escape codes
  from its output, and `Write-ColorEX` writes console colors there.
- `NO_COLOR`, `FORCE_COLOR=0` and `TERM=dumb` give one plain `Write-Host`
  call per line, with no colors or styles.

### Fixed

- A transcript records each line `Write-ColorEX` writes as one line, with no
  blank line after it, and as many blank lines as `-LinesBefore` and
  `-LinesAfter` ask for
  ([#2](https://github.com/MarkusMcNugen/PSWriteColorEX/issues/2)). In
  Windows PowerShell 5.1 a line of several console colors is still one
  transcript line per color. A transcript split each line into one line per
  segment, added an empty line after each, and recorded the blank lines of
  `-LinesBefore` and `-LinesAfter` as one line, before.
- Every string piped to `Write-ColorEX` or to a `Write-Color*` helper is
  written, each as its own line. Only the last one was written before.
- A `-LogFile` given as a file name alone goes in the folder of the script
  that called `Write-ColorEX` or the helper, or in the current location when
  called from the prompt. It went in the module's own `Public` folder before.
- A `-LogFile` path whose folder is missing creates the folder. The write
  failed after its retries before.
- `-LogRetry` tries 50 ms apart, and a write that fails warns with
  `-LogRetry 0` too. The tries ran back to back, and `-LogRetry 0` failed
  without a warning, before.
- `-BackGroundColor 'None'` leaves its segment on the terminal background.
  `Write-ColorEX` stopped with "The variable cannot be validated" before.
- Text without `-Color` takes the terminal's default color. It was Gray
  before.
- `-Gradient` without `-TrueColor` or `-ANSI8` writes the gradient in the
  best mode the terminal supports. It wrote plain text and a stray reset code
  before.
- A gradient steps by the characters a terminal draws, so an emoji, an emoji
  sequence or a letter with an accent takes one color. A gradient put a color
  code between the two halves of a surrogate pair before, which broke emoji
  outside the Basic Multilingual Plane into two replacement characters.
- `-BlankLine` with output redirected, where the console width is unknown,
  writes an empty line. It stopped with an error before.
- Color names outside the 16 console colors, such as `Orange` and
  `LightRed`, keep working for the session after a call that used a color
  name without `-ANSI4`, `-ANSI8` or `-TrueColor`. That call left a table of
  only the 16 console colors in place for the session before, and the other
  names wrote no color.
- `-Bold` on `White`, where the terminal shows bold as brighter colors,
  keeps the text white. `Lighten-ColorName` turned `White` into `LightWhite`,
  which the color table does not have, and the text lost its color before.
  `Get-LighterColorName` answers only names the color table has.
- A hex code or an RGB array in `-Color` or `-BackGroundColor` without
  `-TrueColor`, `-ANSI8` or `-ANSI4` is written in the best mode the terminal
  has, as for a style made with `New-ColorStyle -ForegroundColor '#FF6B35'`.
  It wrote no color before.
- An `-ANSI8` color number on a terminal with 16 colors takes the nearest of
  the 16 colors. It went out as a 16-color code before, so 9 struck the text
  through and 208 did nothing.
- `-ANSI4` and `-ANSI8` color numbers on a terminal without ANSI support take
  the nearest console color. They were Gray before, and `-ANSI8 1` was
  DarkBlue.
- `-Color 0` and `-BackGroundColor 0` write black. They were ignored before.
- `-Style 'Bold'`, one style alone, styles the first segment, as an array of
  one does. It styled nothing before, since PowerShell read the string's
  letters as the styles.
- `Convert-RGBToANSI8` clamps values outside 0-255. `@(300, 0, 0)` answered
  16 (black) before.
- `[PSColorStyle]` resolves after `Import-Module PSWriteColorEX`, as the
  examples use it. It needed `using module PSWriteColorEX` before.
- The `Write-Color*` helpers use their profile in `[PSColorStyle]::Profiles`
  as it is at each call. They used the profile as it was at import before.
- `PSColorStyle.Clone()` copies the `Gradient` and `Style` arrays and RGB
  colors, so changing an element of the copy leaves the original alone. The
  copy shared those arrays with the original before.
- The help examples of `Convert-RGBToANSI4` and the lightening functions
  give the values the functions return, and the help counts 129 color names
  in 44 families. It claimed 70+ families before.

## [1.0.0] - 2025-11-02

The first release.
