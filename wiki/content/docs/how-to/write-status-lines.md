---
title: Write status lines
weight: 20
---

To show the state of each step a script takes, write a short colored tag in front of a message.

## A status tag

A function picks the tag's color from the state, so every line looks the same:

```powershell
PS> function Write-Status($State, $Message) {
>>   $color = @{ OK = 'Green'; WARN = 'Yellow'; FAIL = 'Red' }[$State]
>>   Write-ColorEX -Text '[', $State.PadRight(4), '] ', $Message -Color DarkGray, $color, DarkGray, Gray
>> }
PS> Write-Status OK 'Database migrated'
[OK  ] Database migrated
PS> Write-Status WARN 'Cache is cold'
[WARN] Cache is cold
PS> Write-Status FAIL 'Mail server unreachable'
[FAIL] Mail server unreachable
```

## A step that finishes later

`-NoNewLine` writes the step and leaves the line open, so its result can follow on the same line:

```powershell
PS> Write-ColorEX -Text 'Installing packages... ' -NoNewLine; Write-ColorEX -Text 'done' -Color Green
Installing packages... done
```

## A small dashboard

A style profile keeps the label's color and width, so each line takes one short call for the
label and one for the value:

```powershell
PS> $label = New-ColorStyle -Name Label -ForegroundColor DarkGray -AutoPad 10 -NoNewLine
PS> Write-ColorEX -Text 'CPU' -StyleProfile $label; Write-ColorEX -Text '23%' -Color Green
CPU       23%
PS> Write-ColorEX -Text 'Memory' -StyleProfile $label; Write-ColorEX -Text '81%' -Color Yellow
Memory    81%
PS> Write-ColorEX -Text 'Disk' -StyleProfile $label; Write-ColorEX -Text '97%' -Color Red -Bold
Disk      97%
```

## The whole script

```powershell
function Write-Status($State, $Message) {
    $color = @{ OK = 'Green'; WARN = 'Yellow'; FAIL = 'Red' }[$State]
    Write-ColorEX -Text '[', $State.PadRight(4), '] ', $Message -Color DarkGray, $color, DarkGray, Gray
}

Write-Status OK 'Database migrated'
Write-Status WARN 'Cache is cold'
Write-Status FAIL 'Mail server unreachable'
```

The message helpers, such as `Write-ColorError`, give a whole line one profile; see
[Style profiles](profiles.md).
