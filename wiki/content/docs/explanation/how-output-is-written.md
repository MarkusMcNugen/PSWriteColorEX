---
title: How output reaches the host
weight: 30
---

`Write-ColorEX` writes through `Write-Host`, so its output goes where `Write-Host` output goes: to
the host, to the information stream, and into transcripts.

## One call per line

Each line goes to the host in as few `Write-Host` calls as its colors allow, with the line end on
the last call. Where escape codes reach the screen, a line is one call holding its escape codes:
always on PowerShell 7.2 and later, and on Windows PowerShell 5.1 when the line uses styles or an
ANSI mode. With `FORCE_COLOR` or `CLICOLOR_FORCE` set, every line is one call holding its escape
codes, wherever the output goes. Otherwise each color is a call of its own with
`-ForegroundColor` and `-BackgroundColor`.

Each call is an information record tagged `PSHOST`, which is how `Write-Host` works:

```powershell
PS> Write-ColorEX -Text 'one ', 'call ', 'per line' -Color Red, Green, Blue -InformationVariable written
one call per line
PS> $written.Count
1
PS> $written[0].Tags
PSHOST
```

So `6>` redirects the output, `-InformationVariable` keeps it, and `$InformationPreference` does
not hide it, as with `Write-Host`.

## Escape codes and the host

PowerShell 7.2 and later remove escape codes from a host's output when the host has no virtual
terminal support, or when `$PSStyle.OutputRendering` is `PlainText`, which PowerShell sets when it
starts with `NO_COLOR` set. The module checks both before it writes escape codes, and writes
console colors instead, unless `FORCE_COLOR` or `CLICOLOR_FORCE` is set. Windows PowerShell 5.1
passes escape codes through; on Windows 10 build
10586 and later the module switches on virtual terminal processing in the console host for the
session, so they are drawn.

## Transcripts

A transcript records each `Write-Host` call as one line. Since a line is one call wherever escape
codes reach the screen, a transcript records it as one line. PowerShell 7.2 and later remove the
escape codes from the transcript; Windows PowerShell 5.1 keeps them, and records a line of several
console colors as one line per color unless `FORCE_COLOR` or `CLICOLOR_FORCE` is set.
[Record output in a transcript](record-output.md) shows it.

## Writing nothing, or collecting instead

`-NoConsoleOutput` writes nothing to the host, for a call that only writes its log file.
`Format-ColorEX` builds the same lines and answers them as strings instead of writing them, with
escape codes wherever the host would show them; see [Format-ColorEX](format-colorex.md).
