---
title: Record output in a transcript
weight: 80
---

To keep a record of what a script wrote, start a transcript with `Start-Transcript`, or log each
line to a file with `-LogFile`.

## With a transcript

A transcript records everything the host shows, from every command, until `Stop-Transcript`:

```powershell
Start-Transcript -Path 'run.txt'
Write-ColorEX -Text 'Build ', 'passed' -Color Gray, Green
Write-ColorEX -Text 'Deploy ', 'skipped' -Color Gray, Yellow
Stop-Transcript
```

The transcript holds each line once, as one line. In PowerShell 7.2 and later it holds the text
without colors. Windows PowerShell 5.1 keeps the escape codes in the transcript, and records a line
of several console colors as one line per color. Each transcript also starts with a header that
names the machine, the user and the PowerShell version.

## With a log file

`-LogFile` writes just the text of each line, with a time and a level if you ask for them, and
nothing from other commands. It suits a record a script keeps for itself:

```powershell,clock
PS> Write-ColorEX -Text 'Build ', 'passed' -Color Gray, Green -LogFile 'run.log' -LogTime
Build passed
PS> Write-ColorEX -Text 'Deploy ', 'skipped' -Color Gray, Yellow -LogFile 'run.log' -LogTime
Deploy skipped
PS> Get-Content 'run.log'
[2026-10-09 14:30:00] Build passed
[2026-10-09 14:30:00] Deploy skipped
```

[Logging](logging.md) covers `-LogFile` in full.

## With colors

To keep the colors, write the lines with `Format-ColorEX` and save the strings; they hold the
escape codes, and show in color when the file is printed in a terminal:

```powershell
Format-ColorEX -Text 'Build ', 'passed' -Color Gray, Green | Add-Content 'colored.txt'
```
