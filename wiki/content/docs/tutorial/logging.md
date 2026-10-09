---
title: Logging
weight: 80
---

`-LogFile` writes each line to a file as well as to the host: the text alone, without colors or
escape codes, with a time and a level when you ask for them.

## A first log file

```powershell
PS> Write-ColorEX -Text 'Service ', 'started' -Color Gray, Green -LogFile 'service.log'
Service started
PS> Get-Content 'service.log'
Service started
```

A file name alone goes in the folder of the script that calls `Write-ColorEX`, or in the current
location when it is called from the prompt, as here. `-LogPath` names another folder, and a path
with a folder is used as it is given. A name without an extension gets `.log`, and a missing folder
is created.

## Time and level

`-LogTime` writes the time before each line, in the `-DateTimeFormat` format, and `-LogLevel`
writes a level:

```powershell,clock
PS> Write-ColorEX -Text 'Disk at 91 percent' -Color Yellow -LogFile 'service.log' -LogTime -LogLevel 'WARN'
Disk at 91 percent
PS> Write-ColorEX -Text 'Backup done' -LogFile 'service.log' -LogTime -DateTimeFormat 'HH:mm:ss' -LogLevel 'INFO'
Backup done
PS> Get-Content 'service.log'
[2026-10-09 14:30:00][WARN] Disk at 91 percent
[14:30:05][INFO] Backup done
```

## Logging without writing

`-NoConsoleOutput` writes to the file only:

```powershell
PS> Write-ColorEX -Text 'written to the file only' -LogFile 'quiet.log' -NoConsoleOutput
PS> Get-Content 'quiet.log'
written to the file only
```

The message helpers take `-LogFile` and `-NoConsoleOutput` too:

```powershell
PS> Write-ColorError 'Payment failed for order 1001' -LogFile 'orders.log'
Payment failed for order 1001
PS> Get-Content 'orders.log'
Payment failed for order 1001
```

## Encoding and locked files

The file is UTF-8 without a byte order mark. `-Encoding` takes another encoding by name, and each
name writes the same bytes in Windows PowerShell 5.1 and PowerShell 7; a byte order mark goes only
into a new or empty file. When the file is locked, `-LogRetry` sets how many times the write is
tried, 50 milliseconds apart.

## Next

That is the end of the tutorial. [Record output in a transcript](record-output.md) compares a log
file with `Start-Transcript`, and the [how-to guides](align-columns.md) solve one task each.
