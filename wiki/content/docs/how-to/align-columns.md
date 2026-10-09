---
title: Align columns with wide characters
weight: 10
---

To line up a table whose cells hold emoji or Chinese, Japanese or Korean text, pad each cell with
`-AutoPad`. It counts the cells a terminal draws, so a wide character counts as two.

## Pad each cell

Write each cell with `-AutoPad` and `-NoNewLine`, and the last cell of the row without
`-NoNewLine`. A small function keeps the widths in one place. `-PadLeft` right-aligns the numbers:

```powershell
PS> function Write-Row($City, $State, $Load, $Color = 'Gray') {
>>   Write-ColorEX -Text $City -AutoPad 14 -NoNewLine
>>   Write-ColorEX -Text $State -AutoPad 10 -NoNewLine -Color $Color
>>   Write-ColorEX -Text $Load -AutoPad 6 -PadLeft
>> }
PS> Write-Row 'City' 'State' 'Load' Cyan
City          State       Load
PS> Write-Row 'Tokyo 東京' '✅ up' '42%' Green
Tokyo 東京    ✅ up        42%
PS> Write-Row 'Paris' '⚠️ slow' '91%' Yellow
Paris         ⚠️ slow      91%
PS> Write-Row 'São Paulo' '❌ down' '0%' Red
São Paulo     ❌ down       0%
```

## Check a width

`Measure-DisplayWidth` tells you how wide a cell will be, which helps you choose the widths:

```powershell
PS> Measure-DisplayWidth 'Tokyo 東京'
10
PS> Measure-DisplayWidth '⚠️ slow'
7
```

Text wider than its `-AutoPad` width is not padded, so the columns after it move right. Add
`-Truncate` to cut such text to the width instead, ending it with an ellipsis.

## The whole script

```powershell
function Write-Row($City, $State, $Load, $Color = 'Gray') {
    Write-ColorEX -Text $City -AutoPad 14 -NoNewLine
    Write-ColorEX -Text $State -AutoPad 10 -NoNewLine -Color $Color -Truncate
    Write-ColorEX -Text $Load -AutoPad 6 -PadLeft
}

Write-Row 'City' 'State' 'Load' Cyan
Write-Row 'Tokyo 東京' '✅ up' '42%' Green
Write-Row 'Paris' '⚠️ slow' '91%' Yellow
```

A browser draws emoji in its own fonts, so the columns on this page may sit a little out of line;
in a terminal they line up. [Display width](display-width.md) explains how the width is counted.
