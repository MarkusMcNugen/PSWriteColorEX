# Write-ColorError

> ❌ **Display error messages with predefined styling**

## Synopsis

Outputs error messages using the Error style profile (red, bold text by default).

## Syntax

```powershell
Write-ColorError
    [-Text] <String[]>
    [-NoNewLine]
    [-LogFile <String>]
    [-PassThru]
    [<CommonParameters>]
```

## Description

`Write-ColorError` is a helper function that simplifies displaying error messages with consistent formatting. It uses the "Error" style profile from PSColorStyle, which by default displays text in bold red.

## Parameters

### `-Text`
> **Type:** `String[]`  
> **Position:** 0  
> **Pipeline:** Yes

The error message text to display.

### `-NoNewLine`
> **Type:** `Switch`

Suppress the newline after output.

### `-LogFile`
> **Type:** `String`

Path to a log file for recording the error.

### `-PassThru`
> **Type:** `Switch`

Return the text after displaying it.

## Examples

### Example 1: Simple Error Message
```powershell
Write-ColorError "Failed to connect to database"
```
**Output:** Bold red text displaying the error message

### Example 2: Multi-part Error
```powershell
Write-ColorError "Error Code:", " 0x80070005", " - Access Denied"
```

### Example 3: Error with Logging
```powershell
Write-ColorError "Critical failure in module" -LogFile "errors.log"
```

### Example 4: Pipeline Usage
```powershell
$errors | Write-ColorError
```

### Example 5: PassThru for Further Processing
```powershell
$errorMsg = Write-ColorError "Validation failed" -PassThru
Send-MailMessage -Body $errorMsg -Subject "Error Alert"
```

## Notes

- Uses the "Error" style profile (red, bold by default)
- Automatically inherits terminal color support detection
- Integrates with Write-ColorEX's logging capabilities

## Related Commands

- [`Write-ColorWarning`](Write-ColorWarning.md)
- [`Write-ColorCritical`](Write-ColorCritical.md)
- [`Write-ColorEX`](Write-ColorEX.md)