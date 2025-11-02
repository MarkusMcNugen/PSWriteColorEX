# Write-ColorSuccess

> ✅ **Display success messages with predefined styling**

## Synopsis

Outputs success messages using the Success style profile (green text by default).

## Syntax

```powershell
Write-ColorSuccess
    [-Text] <String[]>
    [-NoNewLine]
    [-LogFile <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

`Write-ColorSuccess` displays success messages with consistent green formatting using the "Success" style profile.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Text` | `String[]` | Success message text (pipeline input) |
| `-NoNewLine` | `Switch` | Suppress newline after output |
| `-LogFile` | `String` | Log file path |
| `-PassThru` | `Switch` | Return text after display |

## Examples

### Operation Success
```powershell
Write-ColorSuccess "Database connection established"
```

### Success with Details
```powershell
Write-ColorSuccess "✓ All tests passed:", " 147/147"
```

### Logged Success
```powershell
Write-ColorSuccess "Backup completed successfully" -LogFile "backup.log"
```

## Style Profile

- **Default Color:** Green
- **Default Style:** Normal
- **Icon Suggestion:** ✓, ✔, ✅

## Related Commands

- [`Write-ColorError`](Write-ColorError.md)
- [`Write-ColorInfo`](Write-ColorInfo.md)
- [`Write-ColorEX`](Write-ColorEX.md)