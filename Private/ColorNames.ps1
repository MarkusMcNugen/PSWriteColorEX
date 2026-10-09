# Helpers for the color name and style profile commands

function Get-ColorRegisterRgb {
    <#
    .SYNOPSIS
    The RGB color Register-ColorName takes a value as, or $null for a value that is not a color:
    a hex code, rgb(), hsl(), three numbers 0-255, or a name in the color table.
    #>
    param([object]$Value, [hashtable]$Table)
    if ($Value -is [array]) {
        if ($Value.Count -ne 3) {
            return $null
        }
        $rgb = [System.Collections.Generic.List[object]]::new()
        foreach ($channel in $Value) {
            if (-not ($channel -is [int] -or $channel -is [long] -or $channel -is [int16] -or $channel -is [byte]) -or $channel -lt 0 -or $channel -gt 255) {
                return $null
            }
            $rgb.Add([int]$channel)
        }
        return ,$rgb.ToArray()
    }
    if ($Value -isnot [string]) {
        return $null
    }
    $entry = $Table[$Value]
    if ($entry) {
        return ,@($entry[4][0], $entry[4][1], $entry[4][2])
    }
    $form = ConvertTo-ColorForm -Value $Value
    return ,[ColorCode]::HexToRgb($form)
}

function Get-ColorNameOrder {
    <#
    .SYNOPSIS
    Color names in family order: by the name without Dark or Light, then Dark, the name, Light.
    Names compare by their letters in upper case, ordinal, so the order is the same everywhere.
    #>
    param([string[]]$Names)
    if ($null -eq $Names -or $Names.Count -eq 0) {
        return
    }
    $keys = [string[]]::new($Names.Count)
    for ($i = 0; $i -lt $Names.Count; $i++) {
        $name = $Names[$i]
        $variant = 1
        $family = $name
        if ($name -match '^(?i)dark(.+)$') {
            $variant = 0
            $family = $Matches[1]
        } elseif ($name -match '^(?i)light(.+)$') {
            $variant = 2
            $family = $Matches[1]
        }
        $keys[$i] = '{0}|{1}|{2}' -f $family.ToUpperInvariant(), $variant, $name.ToUpperInvariant()
    }
    $sorted = [string[]]$Names.Clone()
    [Array]::Sort($keys, $sorted, [System.StringComparer]::Ordinal)
    $sorted
}

function ConvertTo-ColorJson {
    <#
    .SYNOPSIS
    A value as JSON, indented two spaces: an ordered dictionary as an object, an array as an
    array, and strings, integers, booleans and $null. Written here rather than with
    ConvertTo-Json, whose layout differs between Windows PowerShell 5.1 and PowerShell 7, so a
    profile file has the same bytes everywhere.
    #>
    param([object]$Value, [int]$Depth = 0)
    $indent = '  ' * ($Depth + 1)
    $close = '  ' * $Depth
    if ($null -eq $Value) {
        return 'null'
    }
    if ($Value -is [bool]) {
        return $(if ($Value) { 'true' } else { 'false' })
    }
    if ($Value -is [int] -or $Value -is [long]) {
        return $Value.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    }
    if ($Value -is [string] -or $Value -is [char]) {
        $builder = [System.Text.StringBuilder]::new('"')
        foreach ($character in ([string]$Value).ToCharArray()) {
            switch ($character) {
                '"' { [void]$builder.Append('\"'); continue }
                '\' { [void]$builder.Append('\\'); continue }
                "`n" { [void]$builder.Append('\n'); continue }
                "`r" { [void]$builder.Append('\r'); continue }
                "`t" { [void]$builder.Append('\t'); continue }
                default {
                    if ([int]$character -lt 0x20) {
                        [void]$builder.Append(('\u{0:x4}' -f [int]$character))
                    } else {
                        [void]$builder.Append($character)
                    }
                }
            }
        }
        return $builder.Append('"').ToString()
    }
    if ($Value -is [System.Collections.IDictionary]) {
        if ($Value.Count -eq 0) {
            return '{}'
        }
        $members = foreach ($key in $Value.Keys) {
            $indent + (ConvertTo-ColorJson -Value ([string]$key)) + ': ' + (ConvertTo-ColorJson -Value $Value[$key] -Depth ($Depth + 1))
        }
        return "{`n" + ($members -join ",`n") + "`n$close}"
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @($Value)
        if ($items.Count -eq 0) {
            return '[]'
        }
        # A list of numbers, such as an RGB color, stays on one line
        $simple = $true
        foreach ($item in $items) {
            if ($item -isnot [int] -and $item -isnot [long]) { $simple = $false }
        }
        if ($simple) {
            return '[' + (@(foreach ($item in $items) { ConvertTo-ColorJson -Value $item }) -join ', ') + ']'
        }
        $members = foreach ($item in $items) {
            $indent + (ConvertTo-ColorJson -Value $item -Depth ($Depth + 1))
        }
        return "[`n" + ($members -join ",`n") + "`n$close]"
    }
    return ConvertTo-ColorJson -Value ([string]$Value) -Depth $Depth
}

function ConvertFrom-ColorJsonValue {
    <#
    .SYNOPSIS
    A value ConvertFrom-Json read, with whole numbers as [int] as Write-ColorEX takes them, and
    arrays as object arrays. PowerShell 7 reads whole numbers as [long].
    #>
    param([object]$Value)
    if ($Value -is [long] -and $Value -ge [int]::MinValue -and $Value -le [int]::MaxValue) {
        return [int]$Value
    }
    if ($Value -is [array]) {
        $items = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $Value) {
            $items.Add((ConvertFrom-ColorJsonValue -Value $item))
        }
        return ,$items.ToArray()
    }
    return $Value
}

# The PSColorStyle properties a profile file holds, in the order it holds them
$script:ColorProfileProperties = @(
    'ForegroundColor', 'BackgroundColor', 'Gradient', 'BackgroundGradient', 'GradientSpace', 'Style',
    'Bold', 'Italic', 'Underline', 'Blink', 'Faint', 'CrossedOut', 'DoubleUnderline', 'Overline',
    'Reverse', 'UnderlineColor', 'UnderlineStyle', 'StartTab', 'StartSpaces', 'LinesBefore',
    'LinesAfter', 'ShowTime', 'NoNewLine', 'HorizontalCenter', 'AutoPad', 'PadLeft', 'PadCenter',
    'PadChar', 'Truncate', 'Wrap'
)
