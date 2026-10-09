---
title: Switch to PWRSWriteColorEX
weight: 110
---

To run a script on PWRSWriteColorEX instead of PSWriteColorEX, install it and change the module
the script imports. The commands, parameters and output are the same, so nothing else changes.

## Install and import

```powershell
Install-Module PWRSWriteColorEX -Scope CurrentUser
```

Replace the import at the top of the script:

```powershell
# Import-Module PSWriteColorEX
Import-Module PWRSWriteColorEX
```

## Check the requirements

- In PowerShell 7 it needs 7.4 or later. Windows PowerShell 5.1 works.
- It runs on Windows x64 and arm64, Linux x64 and arm64 with glibc 2.35 or later, macOS arm64 and
  x64, and FreeBSD x64.

## Things to know

- The two modules cannot be loaded in one session, since each defines `[PSColorStyle]`. Remove one
  before importing the other, or start a new session.
- A style profile file is the same in both, so `Import-ColorProfile` reads files the other module
  wrote.
- A color a parameter does not take is refused with a message of its own, and a log file that
  cannot be written gives its reason in its own words.
- `-Debugging` messages go to the host as verbose lines unless `-Verbose` is given.

[PWRSWriteColorEX](pwrswritecolorex.md) explains how the two are kept the same.
