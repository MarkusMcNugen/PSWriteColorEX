# Write-ColorDebug

> 🔍 **Display debug messages with subtle styling**

## Synopsis

Outputs debug messages using the Debug style profile (dark gray italic text by default).

## Syntax

```powershell
Write-ColorDebug
    [-Text] <String[]>
    [-NoNewLine]
    [-LogFile <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

`Write-ColorDebug` displays debug information with subtle formatting using dark gray italic text, making it visually distinct from normal output.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Text` | `String[]` | Debug message text (pipeline input) |
| `-NoNewLine` | `Switch` | Suppress newline after output |
| `-LogFile` | `String` | Log file path |
| `-PassThru` | `Switch` | Return text after display |

## Examples

### Debug Information
```powershell
Write-ColorDebug "Variable state: $($var | ConvertTo-Json -Compress)"
```

### Debug with Timestamp
```powershell
Write-ColorDebug "[$(Get-Date -Format 'HH:mm:ss.fff')] Function entered"
```

### Conditional Debug
```powershell
if ($DebugPreference -eq 'Continue') {
    Write-ColorDebug "Processing item $i of $total"
}
```

## Style Profile

- **Default Color:** DarkGray
- **Default Style:** Italic
- **Use Case:** Development, troubleshooting, verbose output

## Related Commands

- [`Write-ColorInfo`](Write-ColorInfo.md)
- [`Write-Verbose`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-verbose)
- [`Write-ColorEX`](Write-ColorEX.md)