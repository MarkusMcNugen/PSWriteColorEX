---
title: Write-Color helpers
weight: 20
---

Six commands that write a message with a built-in style profile: `Write-ColorError`,
`Write-ColorWarning`, `Write-ColorInfo`, `Write-ColorSuccess`, `Write-ColorCritical` and
`Write-ColorDebug`.

## Description

Each helper calls `Write-ColorEX` with the profile of its name in `[PSColorStyle]::Profiles`, read
on each call, so a change to the profile applies to the next message. The profiles start as:

| Helper | Profile | Starts as |
|---|---|---|
| `Write-ColorError` | Error | Red, bold |
| `Write-ColorWarning` | Warning | Yellow |
| `Write-ColorInfo` | Info | Cyan |
| `Write-ColorSuccess` | Success | Green |
| `Write-ColorCritical` | Critical | White on DarkRed, bold, blinking |
| `Write-ColorDebug` | Debug | DarkGray, italic |

A removed profile leaves its helper with the colors and styles it starts with. Several strings are
written on one line, and strings piped in are written one line each.

## Examples

```powershell
PS> Write-ColorError 'Could not reach the database'
Could not reach the database
PS> Write-ColorWarning 'Disk at 91 percent'
Disk at 91 percent
PS> Write-ColorInfo 'Using the staging configuration'
Using the staging configuration
PS> Write-ColorSuccess 'Deployed version 2.4.1'
Deployed version 2.4.1
PS> Write-ColorCritical 'Data loss possible'
Data loss possible
PS> Write-ColorDebug 'Cache hit for key 42'
Cache hit for key 42
```

Strings piped in, each on its own line, and a message passed on with `-PassThru`:

```powershell
PS> 'first warning', 'second warning' | Write-ColorWarning
first warning
second warning
PS> $text = Write-ColorSuccess 'Saved' -PassThru
Saved
PS> $text
Saved
```

## Syntax

### Write-ColorError

{{< syntax "Write-ColorError" >}}

### Write-ColorWarning

{{< syntax "Write-ColorWarning" >}}

### Write-ColorInfo

{{< syntax "Write-ColorInfo" >}}

### Write-ColorSuccess

{{< syntax "Write-ColorSuccess" >}}

### Write-ColorCritical

{{< syntax "Write-ColorCritical" >}}

### Write-ColorDebug

{{< syntax "Write-ColorDebug" >}}

## Parameters

The six helpers take the same parameters.

{{% parameters "Write-ColorError" %}}
