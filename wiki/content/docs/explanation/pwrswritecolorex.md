---
title: PWRSWriteColorEX
weight: 60
---

PWRSWriteColorEX is PSWriteColorEX's commands compiled from Rust with
[PWRS](https://github.com/Variably-Constant/PWRS), PoWerRuSt, a framework for writing PowerShell
cmdlets in Rust. It has the same command names, parameters, aliases and `PSColorStyle` class, and
writes the same output.

## Why it exists

The same work costs less in compiled code: a call takes a fraction of the time, which matters for
a script that writes thousands of lines; see [Performance](performance.md). Its version always
matches the PSWriteColorEX release whose commands and output it has.

## How the two stay the same

Three test suites hold PWRSWriteColorEX to PSWriteColorEX, and its CI runs them on every platform
it builds:

- The surface test compares every command, parameter (type, position, aliases, valid values,
  parameter sets), alias and `PSColorStyle` member with what PSWriteColorEX declares.
- The parity suite runs 495 calls against both modules, each in a process of its own, under eight
  color environments: TrueColor, 256 colors, 16 colors, `NO_COLOR`, `TERM=dumb`, `CLICOLOR=0`,
  `CLICOLOR_FORCE` with `TERM=dumb`, and the support the terminal reports. It compares each write
  to the host with its colors, each warning, error and object, and the bytes of each log file.
- The transcript test checks that a transcript records each line once.

Beyond the suites, a profile file is the same bytes from either module, so each reads the other's,
and gradients use the same constants and steps, so their colors match to the last bit.

## What differs

- In PowerShell 7 it needs 7.4 or later, since its PowerShell 7 half is built for .NET 8. Windows
  PowerShell 5.1 works as with PSWriteColorEX.
- A color `-Color` or `-BackGroundColor` does not take is refused with a message of its own.
- `-Debugging` writes the same messages; without `-Verbose` they go to the host as verbose lines,
  which `4>` does not redirect.
- When a log file cannot be written, the warning gives the reason in its own words.
- The two modules cannot be imported into one session, since each defines `[PSColorStyle]`.

## Platforms

One module folder holds the native library for Windows x64 and arm64, Linux x64 and arm64 (glibc
2.35 or later), macOS arm64 and x64, and FreeBSD x64, for PowerShell 7.4 or later and Windows
PowerShell 5.1.

```powershell
Install-Module PWRSWriteColorEX -Scope CurrentUser
Import-Module PWRSWriteColorEX
Write-ColorEX -Text 'Same ', 'commands' -Color Cyan, Green
```

## How it is built

`cargo pwrs build` compiles the library and writes the module folder, with the PowerShell 7 and
Windows PowerShell 5.1 halves PWRS generates; the crate and the `cargo-pwrs` tool move to a new
PWRS release together. The source and the build steps are in the
[PWRSWriteColorEX repository](https://github.com/Variably-Constant/PWRSWriteColorEX), and
[Switch to PWRSWriteColorEX](switch-to-pwrswritecolorex.md) covers moving a script.
