# Write-ColorInfo

> ℹ️ **Display informational messages with predefined styling**

## Synopsis

Outputs informational messages using the Info style profile (cyan text by default).

## Syntax

```powershell
Write-ColorInfo
    [-Text] <String[]>
    [-NoNewLine]
    [-LogFile <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

`Write-ColorInfo` displays informational messages with consistent cyan formatting using the "Info" style profile.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Text` | `String[]` | Info message text (pipeline input) |
| `-NoNewLine` | `Switch` | Suppress newline after output |
| `-LogFile` | `String` | Log file path |
| `-PassThru` | `Switch` | Return text after display |

## Examples

### Simple Information
```powershell
Write-ColorInfo "Process started at $(Get-Date)"
```

### Multi-part Info
```powershell
Write-ColorInfo "Server:", " online", " | Users:", " 42"
```

### Logged Information
```powershell
Write-ColorInfo "Configuration loaded successfully" -LogFile "app.log"
```

## Style Profile

- **Default Color:** Cyan
- **Default Style:** Normal
- **Use Case:** General information, status updates

## Related Commands

- [`Write-ColorSuccess`](Write-ColorSuccess.md)
- [`Write-ColorDebug`](Write-ColorDebug.md)
- [`Write-ColorEX`](Write-ColorEX.md)