---
title: Build colored strings
weight: 40
---

To use colored text inside another string, a table or a file, make it with `Format-ColorEX`. It
takes the same parameters as `Write-ColorEX`, but answers each line as a string instead of
writing it.

## Inside another string

```powershell
PS> $state = Format-ColorEX -Text 'running' -Color Green
PS> "The web service is $state since 08:00"
The web service is running since 08:00
```

The string holds the escape codes that make the color, so it shows in color wherever it is
written to the terminal.

## In a table

PowerShell 7.2 and later leave escape codes out when they measure column widths, so colored cells
stay in line:

```powershell
PS> $services = @(
>>   [pscustomobject]@{ Name = 'web'; State = Format-ColorEX -Text 'running' -Color Green }
>>   [pscustomobject]@{ Name = 'db'; State = Format-ColorEX -Text 'stopped' -Color Red }
>> )
PS> $services | Format-Table
Name State
---- -----
web  running
db   stopped
```

## In a file

The escape codes go into the file as well, and show as color when the file is printed in a
terminal:

```powershell
PS> Format-ColorEX -Text 'Build ', 'passed' -Color Gray, Green | Set-Content 'report.txt'
PS> Get-Content 'report.txt'
Build passed
```

## When colors are off

With colors turned off, for example by `NO_COLOR`, the strings are the text alone, so a file
or a log gets no escape codes:

```powershell,none
PS> $state = Format-ColorEX -Text 'running' -Color Green
PS> "The web service is $state since 08:00"
The web service is running since 08:00
```

[Format-ColorEX](format-colorex.md) lists its parameters.
