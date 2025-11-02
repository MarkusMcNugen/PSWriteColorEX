# Write-ColorWarning

> ⚠️ **Display warning messages with predefined styling**

## Synopsis

Outputs warning messages using the Warning style profile (yellow text by default).

## Syntax

```powershell
Write-ColorWarning
    [-Text] <String[]>
    [-NoNewLine]
    [-LogFile <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

`Write-ColorWarning` displays warning messages with consistent yellow formatting using the "Warning" style profile.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Text` | `String[]` | Warning message text (pipeline input) |
| `-NoNewLine` | `Switch` | Suppress newline after output |
| `-LogFile` | `String` | Log file path |
| `-PassThru` | `Switch` | Return text after display |

## Examples

### Basic Warning
```powershell
Write-ColorWarning "Disk space running low"
```

### Warning with Context
```powershell
Write-ColorWarning "Warning:", " Configuration file missing, using defaults"
```

### Logged Warning
```powershell
Write-ColorWarning "Memory usage at 85%" -LogFile "system.log"
```

## Style Profile

- **Default Color:** Yellow
- **Default Style:** Normal (not bold)
- **Customizable:** Via PSColorStyle profiles

## Related Commands

- [`Write-ColorError`](Write-ColorError.md)
- [`Write-ColorInfo`](Write-ColorInfo.md)
- [`Write-ColorEX`](Write-ColorEX.md)