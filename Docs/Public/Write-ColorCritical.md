# Write-ColorCritical

> 🚨 **Display critical messages with maximum visibility**

## Synopsis

Outputs critical messages using the Critical style profile (white text on dark red background, bold and blinking by default).

## Syntax

```powershell
Write-ColorCritical
    [-Text] <String[]>
    [-NoNewLine]
    [-LogFile <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

`Write-ColorCritical` displays critical alert messages with maximum visibility using white text on a dark red background with bold and blink effects.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Text` | `String[]` | Critical message text (pipeline input) |
| `-NoNewLine` | `Switch` | Suppress newline after output |
| `-LogFile` | `String` | Log file path |
| `-PassThru` | `Switch` | Return text after display |

## Examples

### Critical Alert
```powershell
Write-ColorCritical "SYSTEM FAILURE - IMMEDIATE ACTION REQUIRED"
```

### Critical with Context
```powershell
Write-ColorCritical "CRITICAL:", " Database corruption detected"
```

### Logged Critical Event
```powershell
Write-ColorCritical "Security breach detected" -LogFile "security.log"
```

## Style Profile

- **Default Foreground:** White
- **Default Background:** DarkRed
- **Default Effects:** Bold, Blink
- **Use Case:** System failures, security alerts

## Notes

> [!WARNING]
> Use sparingly - reserved for truly critical situations requiring immediate attention.

## Related Commands

- [`Write-ColorError`](Write-ColorError.md)
- [`Write-ColorWarning`](Write-ColorWarning.md)
- [`Write-ColorEX`](Write-ColorEX.md)