---
title: Format-ColorEX
weight: 30
---

Answers text with its colors and styles as escape codes, one string per line, as `Write-ColorEX`
would write it.

{{< syntax "Format-ColorEX" >}}

## Description

`Format-ColorEX` takes `Write-ColorEX`'s text, color, style and width parameters and answers each
line as a string instead of writing it to the host, for a string built from several pieces, a
table column, a file or another command.

The strings hold escape codes wherever the host shows them, by the same detection and color
variables `Write-ColorEX` uses. Where `Write-ColorEX` would write console colors instead, or with
colors turned off, the strings are the text alone. `-Wrap` answers one string per line, and a
style profile's `-LinesBefore` and `-LinesAfter` answer empty strings.

It takes no logging, time or console-window parameters: `-LogFile`, `-ShowTime`,
`-HorizontalCenter`, `-BlankLine` and `-NoNewLine` belong to writing to the host.

## Examples

A colored word inside another string:

```powershell
PS> $ok = Format-ColorEX -Text 'OK' -Color Green -Bold
PS> "Status: $ok, 3 checks passed"
Status: OK, 3 checks passed
```

Each line is one string, and the escape codes are part of it:

```powershell
PS> $lines = Format-ColorEX -Text 'Wrapped text answers one string for each line' -AutoPad 20 -Wrap
PS> $lines.Count
3
PS> $lines
Wrapped text answers
one string for each
line
```

With colors off, the strings are the text alone:

```powershell,none
PS> Format-ColorEX -Text 'plain' -Color Red
plain
```

[Build colored strings](build-colored-strings.md) puts them in tables and files.

## Parameters

{{% parameters "Format-ColorEX" %}}
