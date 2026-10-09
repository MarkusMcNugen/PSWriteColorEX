---
title: Color log output
weight: 30
---

To make log lines easier to read, color the parts that matter, such as levels, times and
addresses, with `-Highlight`. Each pattern is a regular expression, and each takes a style
written the way a markup tag is.

## Patterns for a log line

Use `[ordered]@{ }` so the patterns keep their order. Where two patterns match the same text, the
one listed first wins:

```powershell
PS> $patterns = [ordered]@{
>>   '\bERROR\b' = 'bold red'
>>   '\bWARN\b' = 'yellow'
>>   '^\S+ \S+' = 'DarkGray'
>>   '\b\d{1,3}(\.\d{1,3}){3}\b' = 'cyan'
>> }
PS> Write-ColorEX -Text '2026-10-09 12:00:01 ERROR login failed from 10.0.0.7' -Highlight $patterns
2026-10-09 12:00:01 ERROR login failed from 10.0.0.7
PS> Write-ColorEX -Text '2026-10-09 12:00:02 WARN slow reply from 10.0.0.9' -Highlight $patterns
2026-10-09 12:00:02 WARN slow reply from 10.0.0.9
```

Matching ignores case, so `\bERROR\b` matches `error` too.

## Every line of a file

Pass each line of the file to `Write-ColorEX`:

```powershell
PS> Set-Content 'app.log' '2026-10-09 12:00:01 INFO started', '2026-10-09 12:00:05 ERROR crashed on 10.0.0.3'
PS> $patterns = [ordered]@{ '\bERROR\b' = 'bold red'; '\bINFO\b' = 'green'; '^\S+ \S+' = 'DarkGray'; '\b\d{1,3}(\.\d{1,3}){3}\b' = 'cyan' }
PS> Get-Content 'app.log' | ForEach-Object { Write-ColorEX -Text $_ -Highlight $patterns }
2026-10-09 12:00:01 INFO started
2026-10-09 12:00:05 ERROR crashed on 10.0.0.3
```

## The whole script

To color a log as it grows, read it with `-Wait`:

```powershell
$patterns = [ordered]@{
    '\bERROR\b' = 'bold red'
    '\bWARN\b' = 'yellow'
    '\bINFO\b' = 'green'
    '^\S+ \S+' = 'DarkGray'
    '\b\d{1,3}(\.\d{1,3}){3}\b' = 'cyan'
}
Get-Content 'app.log' -Wait | ForEach-Object { Write-ColorEX -Text $_ -Highlight $patterns }
```

A pattern that is not a valid regular expression stops the command with an error, and a style
that is not a style skips its pattern with a warning.
