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
    'ForegroundColor', 'BackgroundColor', 'Gradient', 'BackgroundGradient', 'GradientSpace',
    'GradientHue', 'GradientEasing', 'GradientRepeat', 'GradientDirection', 'GradientSteps', 'Style',
    'Bold', 'Italic', 'Underline', 'Blink', 'Faint', 'CrossedOut', 'DoubleUnderline', 'Overline',
    'Reverse', 'UnderlineColor', 'UnderlineStyle', 'StartTab', 'StartSpaces', 'LinesBefore',
    'LinesAfter', 'ShowTime', 'NoNewLine', 'HorizontalCenter', 'AutoPad', 'PadLeft', 'PadCenter',
    'PadChar', 'Truncate', 'Wrap'
)

function Get-PaletteTextColor {
    <#
    .SYNOPSIS
    The 256-color code of the number Show-ColorTable -Palette writes on a code: 16, black, or 231,
    white, whichever has the higher contrast on the code's color. On the 16 colors, which the
    terminal's scheme sets, white on 0-6 and 8 and black on the others.
    #>
    param([int]$Code)
    if ($Code -lt 16) {
        if ($Code -le 6 -or $Code -eq 8) {
            return 231
        }
        return 16
    }
    $rgb = [ColorMath]::Ansi8Rgb($Code)
    if ([ColorMath]::BlackTextReads($rgb[0], $rgb[1], $rgb[2])) {
        return 16
    }
    return 231
}

function Format-ColorSettingValue {
    <#
    .SYNOPSIS
    A color setting as Show-ColorTable -Profiles writes it: a name, hex code or number as it is, an
    RGB array as @(r, g, b), and a list of colors with commas between them.
    #>
    param([object]$Value)
    if ($null -eq $Value) {
        return ''
    }
    if ($Value -is [array]) {
        $numbers = $Value.Count -eq 3
        foreach ($item in $Value) {
            if (-not ($item -is [int] -or $item -is [long])) {
                $numbers = $false
            }
        }
        if ($numbers) {
            return '@(' + ($Value -join ', ') + ')'
        }
        return (@(foreach ($item in $Value) { Format-ColorSettingValue -Value $item }) -join ', ')
    }
    return [string]$Value
}

function Get-ColorStyleSummary {
    <#
    .SYNOPSIS
    A profile's settings in words, as Show-ColorTable -Profiles writes them: its colors ("White on
    DarkRed"), then each style and layout setting it has by property name, then "(the default
    style)" for the default style; "no settings" for a profile with none.
    #>
    param([PSColorStyle]$Style)
    $parts = [System.Collections.Generic.List[string]]::new()
    $foreground = Format-ColorSettingValue -Value $Style.ForegroundColor
    $background = Format-ColorSettingValue -Value $Style.BackgroundColor
    if ($foreground -and $background) {
        $parts.Add("$foreground on $background")
    } elseif ($foreground) {
        $parts.Add($foreground)
    } elseif ($background) {
        $parts.Add("on $background")
    }
    foreach ($property in 'Bold', 'Faint', 'Italic', 'Underline', 'DoubleUnderline', 'Blink', 'Reverse', 'CrossedOut', 'Overline') {
        if ($Style.$property) {
            $parts.Add($property)
        }
    }
    if ($Style.UnderlineStyle) {
        $parts.Add("UnderlineStyle $($Style.UnderlineStyle)")
    }
    if ($null -ne $Style.UnderlineColor) {
        $parts.Add("UnderlineColor $(Format-ColorSettingValue -Value $Style.UnderlineColor)")
    }
    if ($Style.Style.Count -gt 0) {
        $parts.Add("Style $($Style.Style -join ', ')")
    }
    if ($null -ne $Style.Gradient -and $Style.Gradient.Count -gt 0) {
        $parts.Add("Gradient $(Format-ColorSettingValue -Value $Style.Gradient)")
    }
    if ($null -ne $Style.BackgroundGradient -and $Style.BackgroundGradient.Count -gt 0) {
        $parts.Add("BackgroundGradient $(Format-ColorSettingValue -Value $Style.BackgroundGradient)")
    }
    foreach ($property in 'GradientSpace', 'GradientHue', 'GradientEasing', 'GradientRepeat', 'GradientDirection') {
        if ($Style.$property) {
            $parts.Add("$property $($Style.$property)")
        }
    }
    foreach ($property in 'GradientSteps', 'StartTab', 'StartSpaces', 'LinesBefore', 'LinesAfter', 'AutoPad') {
        if ($Style.$property -gt 0) {
            $parts.Add("$property $($Style.$property)")
        }
    }
    foreach ($property in 'ShowTime', 'NoNewLine', 'HorizontalCenter', 'PadLeft', 'PadCenter', 'Truncate', 'Wrap') {
        if ($Style.$property) {
            $parts.Add($property)
        }
    }
    if ($Style.PadChar -ne ' ') {
        $parts.Add("PadChar '$($Style.PadChar)'")
    }
    $text = $parts -join ', '
    if ([object]::ReferenceEquals($Style, [PSColorStyle]::Default)) {
        return ("$text (the default style)").TrimStart()
    }
    if ($parts.Count -eq 0) {
        return 'no settings'
    }
    return $text
}

function New-SgrStyleProperties {
    <#
    .SYNOPSIS
    The PSColorStyle properties ConvertFrom-SgrStyle sets, each with no color or style.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'It returns a new set of properties and changes nothing.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'It returns several properties, which the plural names.')]
    param()
    [ordered]@{
        ForegroundColor = $null; BackgroundColor = $null; UnderlineColor = $null
        Bold = $false; Faint = $false; Italic = $false; Underline = $false; DoubleUnderline = $false
        UnderlineStyle = ''; Blink = $false; Reverse = $false; CrossedOut = $false; Overline = $false
    }
}

function ConvertFrom-SgrColor {
    <#
    .SYNOPSIS
    The color of a 256-color number (Kind 5) or an RGB color (Kind 2, the last three values) in an
    escape code: a console color name for the numbers 0-15, otherwise '#RRGGBB'. $null for values
    that are not a color.
    #>
    param([string]$Kind, [string[]]$Values, [hashtable]$PaletteNames)
    if ($Kind -eq '5' -and $Values.Count -ge 1) {
        $number = 0
        if (-not [int]::TryParse($Values[0], [ref]$number) -or $number -lt 0 -or $number -gt 255) {
            return $null
        }
        if ($number -lt 16) {
            return $PaletteNames[$number]
        }
        $rgb = [ColorMath]::Ansi8Rgb($number)
        return '#{0:X2}{1:X2}{2:X2}' -f $rgb[0], $rgb[1], $rgb[2]
    }
    if ($Kind -eq '2' -and $Values.Count -ge 3) {
        $rgb = [int[]]::new(3)
        for ($i = 0; $i -lt 3; $i++) {
            $channel = 0
            if (-not [int]::TryParse($Values[$Values.Count - 3 + $i], [ref]$channel) -or $channel -lt 0 -or $channel -gt 255) {
                return $null
            }
            $rgb[$i] = $channel
        }
        return '#{0:X2}{1:X2}{2:X2}' -f $rgb[0], $rgb[1], $rgb[2]
    }
    return $null
}

function ConvertFrom-SgrStyle {
    <#
    .SYNOPSIS
    The colors and styles a string of SGR escape codes sets, as PSColorStyle property values, and
    the codes and text no property holds.

    .DESCRIPTION
    Returns @{ Properties; Ignored }: the properties New-SgrStyleProperties lists, and a list of
    what was left out. A 16-color code, or a 256-color number 0-15, becomes its console color name,
    which Write-ColorEX writes without a mode switch as that same code; a 256-color number 16-255
    or an RGB color becomes '#RRGGBB'. The codes apply in order, a later one over an earlier one,
    and 0 clears them all. An underline color is kept only with an underline, since Write-ColorEX
    underlines a segment that has an underline color.
    #>
    param([string]$Sequence)
    $consoleNames = @{}
    foreach ($name in [ColorCode]::ConsoleSgr.Keys) {
        $consoleNames[[int][ColorCode]::ConsoleSgr[$name]] = $name
    }
    $paletteNames = @{}
    foreach ($name in [ColorCode]::ConsoleAnsiIndex.Keys) {
        $paletteNames[[int][ColorCode]::ConsoleAnsiIndex[$name]] = $name
    }
    $properties = New-SgrStyleProperties
    $ignored = [System.Collections.Generic.List[string]]::new()
    if ([string]::IsNullOrEmpty($Sequence)) {
        return @{ Properties = $properties; Ignored = $ignored }
    }

    foreach ($match in [regex]::Matches($Sequence, '\x1b\[([0-9;:]*)m')) {
        $parameters = $match.Groups[1].Value.Split(';')
        $i = 0
        while ($i -lt $parameters.Count) {
            $parameter = $parameters[$i]
            $parts = $parameter.Split(':')
            $code = 0
            if ($parts[0].Length -gt 0 -and -not [int]::TryParse($parts[0], [ref]$code)) {
                $ignored.Add($parameter)
                $i++
                continue
            }
            $underline = $null
            if ($code -eq 0) {
                $properties = New-SgrStyleProperties
            } elseif ($code -eq 1) {
                $properties.Bold = $true
            } elseif ($code -eq 2) {
                $properties.Faint = $true
            } elseif ($code -eq 3) {
                $properties.Italic = $true
            } elseif ($code -eq 4) {
                $kind = '1'
                if ($parts.Count -gt 1) {
                    $kind = $parts[1]
                }
                switch ($kind) {
                    '0' { $underline = 'None' }
                    '1' { $underline = 'Single' }
                    '2' { $underline = 'Double' }
                    '3' { $underline = 'Curly' }
                    '4' { $underline = 'Dotted' }
                    '5' { $underline = 'Dashed' }
                    default { $ignored.Add($parameter) }
                }
            } elseif ($code -eq 5 -or $code -eq 6) {
                $properties.Blink = $true
            } elseif ($code -eq 7) {
                $properties.Reverse = $true
            } elseif ($code -eq 9) {
                $properties.CrossedOut = $true
            } elseif ($code -eq 21) {
                $underline = 'Double'
            } elseif ($code -eq 22) {
                $properties.Bold = $false
                $properties.Faint = $false
            } elseif ($code -eq 23) {
                $properties.Italic = $false
            } elseif ($code -eq 24) {
                $underline = 'None'
            } elseif ($code -eq 25) {
                $properties.Blink = $false
            } elseif ($code -eq 27) {
                $properties.Reverse = $false
            } elseif ($code -eq 29) {
                $properties.CrossedOut = $false
            } elseif (($code -ge 30 -and $code -le 37) -or ($code -ge 90 -and $code -le 97)) {
                $properties.ForegroundColor = $consoleNames[$code]
            } elseif ($code -eq 39) {
                $properties.ForegroundColor = $null
            } elseif (($code -ge 40 -and $code -le 47) -or ($code -ge 100 -and $code -le 107)) {
                $properties.BackgroundColor = $consoleNames[$code - 10]
            } elseif ($code -eq 49) {
                $properties.BackgroundColor = $null
            } elseif ($code -eq 53) {
                $properties.Overline = $true
            } elseif ($code -eq 55) {
                $properties.Overline = $false
            } elseif ($code -eq 59) {
                $properties.UnderlineColor = $null
            } elseif ($code -eq 38 -or $code -eq 48 -or $code -eq 58) {
                # 38;5;N and 38;2;R;G;B take the parameters after them; 38:5:N and 38:2:R:G:B,
                # with or without a color space before R, hold them in one
                $color = $null
                $taken = @($parameter)
                if ($parts.Count -gt 1) {
                    $color = ConvertFrom-SgrColor -Kind $parts[1] -Values ([string[]]@($parts | Select-Object -Skip 2)) -PaletteNames $paletteNames
                } elseif ($i + 2 -lt $parameters.Count -and $parameters[$i + 1] -eq '5') {
                    $taken = $parameters[$i..($i + 2)]
                    $color = ConvertFrom-SgrColor -Kind '5' -Values ([string[]]@($parameters[$i + 2])) -PaletteNames $paletteNames
                    $i += 2
                } elseif ($i + 4 -lt $parameters.Count -and $parameters[$i + 1] -eq '2') {
                    $taken = $parameters[$i..($i + 4)]
                    $color = ConvertFrom-SgrColor -Kind '2' -Values ([string[]]$parameters[($i + 2)..($i + 4)]) -PaletteNames $paletteNames
                    $i += 4
                }
                if ($null -eq $color) {
                    $ignored.Add($taken -join ';')
                } elseif ($code -eq 38) {
                    $properties.ForegroundColor = $color
                } elseif ($code -eq 48) {
                    $properties.BackgroundColor = $color
                } else {
                    $properties.UnderlineColor = $color
                }
            } else {
                $ignored.Add($parameter)
            }
            if ($null -ne $underline) {
                $properties.Underline = $underline -eq 'Single'
                $properties.DoubleUnderline = $underline -eq 'Double'
                $properties.UnderlineStyle = ''
                if ($underline -eq 'Curly' -or $underline -eq 'Dotted' -or $underline -eq 'Dashed') {
                    $properties.UnderlineStyle = $underline
                }
            }
            $i++
        }
    }

    $text = [regex]::Replace($Sequence, '\x1b\[[0-9;:]*m', '')
    if ($text.Length -gt 0) {
        $ignored.Add("'" + ($text -replace '\x1b', '`e') + "'")
    }
    if (-not ($properties.Underline -or $properties.DoubleUnderline -or $properties.UnderlineStyle)) {
        $properties.UnderlineColor = $null
    }
    return @{ Properties = $properties; Ignored = $ignored }
}

function ConvertFrom-HostColor {
    <#
    .SYNOPSIS
    A color setting of the host as a color Write-ColorEX takes: a console color as its name, a
    color with R, G and B properties, as the ISE's are, as '#RRGGBB', and $null for a transparent
    one or none.
    #>
    param([object]$Value)
    if ($null -eq $Value) {
        return $null
    }
    if ($Value -is [System.ConsoleColor]) {
        return $Value.ToString()
    }
    $members = $Value.PSObject.Properties
    if ($null -ne $members['R'] -and $null -ne $members['G'] -and $null -ne $members['B']) {
        if ($null -ne $members['A'] -and [int]$Value.A -eq 0) {
            return $null
        }
        return '#{0:X2}{1:X2}{2:X2}' -f [int]$Value.R, [int]$Value.G, [int]$Value.B
    }
    Write-Warning "The host's color '$Value' is not a color a profile takes, so it is left out."
    return $null
}

function Get-PowerShellColorSetting {
    <#
    .SYNOPSIS
    PowerShell's own color settings: @{ PSStyle; PrivateData }, $PSStyle $null where PowerShell has
    none (before 7.2).
    #>
    @{
        PSStyle = Get-Variable -Name PSStyle -ValueOnly -ErrorAction Ignore
        PrivateData = $Host.PrivateData
    }
}

function Get-PowerShellThemeStyle {
    <#
    .SYNOPSIS
    The profiles Import-ColorProfile -Theme PowerShell sets, each exactly one of PowerShell's own
    settings: from $PSStyle where there is one (PowerShell 7.2 and later), otherwise from the host's
    PrivateData.

    .DESCRIPTION
    With $PSStyle: Error, Warning, Info and Debug from $PSStyle.Formatting's Error, Warning,
    Verbose and Debug, Critical from ErrorAccent and Default from FormatAccent. Without it: Error,
    Warning, Info and Debug from the host's ErrorForegroundColor and ErrorBackgroundColor and the
    like. A setting the host lacks leaves its profile out, with a warning.
    #>
    param([object]$PSStyleValue, [object]$PrivateData)
    $styles = [System.Collections.Generic.List[object]]::new()
    if ($null -ne $PSStyleValue) {
        $settings = [ordered]@{ Error = 'Error'; Warning = 'Warning'; Info = 'Verbose'; Debug = 'Debug'; Critical = 'ErrorAccent'; Default = 'FormatAccent' }
        foreach ($name in $settings.Keys) {
            $setting = $settings[$name]
            $member = $null
            if ($null -ne $PSStyleValue.Formatting) {
                $member = $PSStyleValue.Formatting.PSObject.Properties[$setting]
            }
            if ($null -eq $member) {
                Write-Warning "PowerShell has no $setting setting here, so the $name profile keeps its colors."
                continue
            }
            $read = ConvertFrom-SgrStyle -Sequence ([string]$member.Value)
            if ($read.Ignored.Count -gt 0) {
                Write-Warning "PowerShell's $setting setting has codes no profile holds, left out of the $name profile: $($read.Ignored -join ', ')"
            }
            $style = [PSColorStyle]::new($name, $read.Properties.ForegroundColor, $read.Properties.BackgroundColor)
            foreach ($property in $read.Properties.Keys) {
                if ($property -ne 'ForegroundColor' -and $property -ne 'BackgroundColor') {
                    $style.$property = $read.Properties[$property]
                }
            }
            $styles.Add($style)
        }
        return ,$styles
    }

    $settings = [ordered]@{ Error = 'Error'; Warning = 'Warning'; Info = 'Verbose'; Debug = 'Debug' }
    foreach ($name in $settings.Keys) {
        $setting = $settings[$name]
        $foreground = $null
        $background = $null
        if ($null -ne $PrivateData) {
            $foreground = $PrivateData.PSObject.Properties["$($setting)ForegroundColor"]
            $background = $PrivateData.PSObject.Properties["$($setting)BackgroundColor"]
        }
        if ($null -eq $foreground -and $null -eq $background) {
            Write-Warning "The host has no $setting colors, so the $name profile keeps its colors."
            continue
        }
        $foregroundColor = $null
        $backgroundColor = $null
        if ($null -ne $foreground) {
            $foregroundColor = ConvertFrom-HostColor -Value $foreground.Value
        }
        if ($null -ne $background) {
            $backgroundColor = ConvertFrom-HostColor -Value $background.Value
        }
        $styles.Add([PSColorStyle]::new($name, $foregroundColor, $backgroundColor))
    }
    return ,$styles
}
