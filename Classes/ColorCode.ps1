<#
.SYNOPSIS
    The escape codes and pieces of text Write-ColorEX builds for each line.

.DESCRIPTION
    A call to a static method or to a method of an object costs a fraction of a function call, so
    the work Write-ColorEX does for every segment of every line is done here. The methods read
    nothing from the caller: every value comes in as a parameter or a property. The functions in
    Private/WriteColorCore.ps1 do the work that writes warnings and debug messages.

    - ColorCode: the escape code tables, and static methods for color and style codes, console
      color names, color forms and segments
    - ColorLine: the colors of one Write-ColorEX call, with methods that write a line as escape
      codes or as pieces for Write-Host's -ForegroundColor and -BackgroundColor

.NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later
#>

class ColorCode {
    static [string] $Esc = [string][char]27
    static [string] $Reset = "$([char]27)[0m"

    # The ANSI4 text code of each console color; a background code is 10 more
    static [hashtable] $ConsoleSgr = @{
        Black = 30; DarkRed = 31; DarkGreen = 32; DarkYellow = 33
        DarkBlue = 34; DarkMagenta = 35; DarkCyan = 36; Gray = 37
        DarkGray = 90; Red = 91; Green = 92; Yellow = 93
        Blue = 94; Magenta = 95; Cyan = 96; White = 97
    }

    # The ANSI color number 0-15 of each console color, for an underline color in 16 colors
    static [hashtable] $ConsoleAnsiIndex = @{
        Black = 0; DarkRed = 1; DarkGreen = 2; DarkYellow = 3; DarkBlue = 4; DarkMagenta = 5; DarkCyan = 6; Gray = 7
        DarkGray = 8; Red = 9; Green = 10; Yellow = 11; Blue = 12; Magenta = 13; Cyan = 14; White = 15
    }

    # The escape code of each style name
    static [hashtable] $StyleSgr = @{
        'Reset' = "$([char]27)[0m"
        'Bold' = "$([char]27)[1m"
        'Faint' = "$([char]27)[2m"
        'Italic' = "$([char]27)[3m"
        'Underline' = "$([char]27)[4m"
        'Blink' = "$([char]27)[5m"
        'CrossedOut' = "$([char]27)[9m"
        'DoubleUnderline' = "$([char]27)[21m"
        'Overline' = "$([char]27)[53m"
        'Reverse' = "$([char]27)[7m"
        'Curly' = "$([char]27)[4:3m"
        'Dotted' = "$([char]27)[4:4m"
        'Dashed' = "$([char]27)[4:5m"
        'None' = ''
    }

    # The escape code of each -UnderlineStyle
    static [hashtable] $UnderlineStyleSgr = @{
        'Single' = "$([char]27)[4m"
        'Double' = "$([char]27)[21m"
        'Curly' = "$([char]27)[4:3m"
        'Dotted' = "$([char]27)[4:4m"
        'Dashed' = "$([char]27)[4:5m"
    }

    # The escape code that sets a color in the color mode in use, or '' for none. A string is a
    # name in the color table, an integer a code of the mode, an array of three an RGB color.
    # Without an ANSI mode the color is the console color as an ANSI4 code.
    static [string] ColorSequence([object] $Value, [bool] $Background, [bool] $ANSI24, [bool] $ANSI8, [bool] $ANSI4, [hashtable] $Colors) {
        if ($null -eq $Value) {
            return ''
        }
        $layer = 38
        if ($Background) {
            $layer = 48
        }
        if ($ANSI24 -and $Value -is [array] -and $Value.Count -eq 3) {
            return "$([ColorCode]::Esc)[$layer;2;$($Value[0]);$($Value[1]);$($Value[2])m"
        }
        if ($ANSI8) {
            if ($Value -is [string]) {
                $entry = $Colors[$Value]
                if ($entry) {
                    return "$([ColorCode]::Esc)[$layer;5;$($entry[3])m"
                }
            } elseif ($Value -is [int]) {
                return "$([ColorCode]::Esc)[$layer;5;$($Value)m"
            }
            return ''
        }
        if ($ANSI4) {
            if ($Value -is [string]) {
                $entry = $Colors[$Value]
                if ($entry) {
                    $code = $entry[1]
                    if ($Background) {
                        $code = $entry[2]
                    }
                    return "$([ColorCode]::Esc)[$($code)m"
                }
            } elseif ($Value -is [int]) {
                return "$([ColorCode]::Esc)[$($Value)m"
            }
            return ''
        }
        # A console color name maps to itself in the color table
        $number = $null
        if ($Value -is [string]) {
            $number = [ColorCode]::ConsoleSgr[$Value]
        }
        if ($null -eq $number) {
            $number = [ColorCode]::ConsoleSgr[[ColorCode]::NativeName($Value, $Background, $Colors)]
        }
        if ($Background) {
            $number += 10
        }
        return "$([ColorCode]::Esc)[$($number)m"
    }

    # The console color for a color value. An unknown name or value is Gray for text and Black for
    # a background.
    static [string] NativeName([object] $Value, [bool] $Background, [hashtable] $Colors) {
        $fallback = 'Gray'
        if ($Background) {
            $fallback = 'Black'
        }
        if ($Value -is [string]) {
            $entry = $Colors[$Value]
            if ($entry) {
                return $entry[0]
            }
            return $fallback
        }
        if ($Value -is [int] -and $Value -ge 0 -and $Value -le 15) {
            return ([System.ConsoleColor]$Value).ToString()
        }
        return $fallback
    }

    # The styles -Style gives one segment: a name, or an array of names, at its index
    static [string] SegmentStyle([object] $Styles, [int] $Index) {
        if (-not $Styles) {
            return ''
        }
        $own = $null
        if ($Styles -is [array]) {
            if ($Index -lt $Styles.Count) {
                $own = $Styles[$Index]
            }
        } elseif ($Index -eq 0) {
            $own = $Styles
        }
        if (-not $own) {
            return ''
        }
        if ($own -is [array]) {
            $builder = [System.Text.StringBuilder]::new()
            foreach ($name in $own) {
                if ($null -ne $name) {
                    [void]$builder.Append([ColorCode]::StyleSgr[$name])
                }
            }
            return $builder.ToString()
        }
        if ($own -is [string]) {
            return [ColorCode]::StyleSgr[$own]
        }
        return ''
    }

    # The escape codes of the styles a markup tag or a -Highlight style gives a run
    static [string] RunStyle([object] $Styles) {
        if ($null -eq $Styles) {
            return ''
        }
        $builder = [System.Text.StringBuilder]::new()
        foreach ($name in $Styles) {
            [void]$builder.Append([ColorCode]::StyleSgr[$name])
        }
        return $builder.ToString()
    }

    # A link's address with its control characters removed, or '' for none
    static [string] Link([object] $Value) {
        if ($null -eq $Value) {
            return ''
        }
        return [regex]::Replace([string]$Value, '[\x00-\x1F\x7F]', '')
    }

    # Whether a color parameter holds a string that is neither a name in the color table, nor a
    # six-digit hex code, nor 'None' or empty: a color form to read, or an unknown name to warn about
    static [bool] NeedsForm([object[]] $Values, [hashtable] $Colors) {
        if ($null -eq $Values) {
            return $false
        }
        foreach ($value in $Values) {
            if ($value -is [string] -and -not $Colors.ContainsKey($value) -and
                $value -notmatch '^(#|0x)[0-9A-Fa-f]{6}$' -and $value -ne 'None' -and
                -not [string]::IsNullOrWhiteSpace($value)) {
                return $true
            }
        }
        return $false
    }

    # Console color numbers 0-15 as their names, so they keep their meaning in another color mode
    static [object[]] ConsoleNumbers([object[]] $Values) {
        $converted = [System.Collections.Generic.List[object]]::new()
        if ($null -eq $Values) {
            return $converted.ToArray()
        }
        foreach ($value in $Values) {
            if ($value -is [int] -and $value -ge 0 -and $value -le 15) {
                $converted.Add(([System.ConsoleColor]$value).ToString())
            } else {
                $converted.Add($value)
            }
        }
        return $converted.ToArray()
    }

    # The RGB color of a hex code #RRGGBB or 0xRRGGBB, or $null for any other text
    static [object[]] HexToRgb([string] $Hex) {
        if ($Hex -notmatch '^(?:#|0x)([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$') {
            return $null
        }
        return @([Convert]::ToInt32($Matches[1], 16), [Convert]::ToInt32($Matches[2], 16), [Convert]::ToInt32($Matches[3], 16))
    }

    # A segment of one run of text, with no colors, styles or link of its own
    static [System.Collections.Generic.List[object]] Segment([string] $Text) {
        $segment = [System.Collections.Generic.List[object]]::new()
        $segment.Add(@{ Text = $Text; HasFg = $false; HasBg = $false; HasLink = $false; Styles = $null })
        return $segment
    }

    # The text of segments, their runs joined
    static [string] SegmentText([System.Collections.Generic.List[object]] $Segments) {
        $builder = [System.Text.StringBuilder]::new()
        foreach ($segment in $Segments) {
            foreach ($run in $segment) {
                [void]$builder.Append($run.Text)
            }
        }
        return $builder.ToString()
    }

    # The text of a line's items, their runs joined
    static [string] ItemText([System.Collections.Generic.List[object]] $Items) {
        $builder = [System.Text.StringBuilder]::new()
        foreach ($item in $Items) {
            foreach ($run in $item.Runs) {
                [void]$builder.Append($run.Text)
            }
        }
        return $builder.ToString()
    }
}

class ColorLine {
    # Whether escape codes for styles reach the terminal, and the color mode in use
    [bool] $ANSISupport
    [bool] $ANSI24
    [bool] $ANSI8
    [bool] $ANSI4
    # The color table
    [hashtable] $Colors
    # -Style, one entry per segment, and the escape codes of the styles every segment takes
    [object] $Styles
    [string] $LineStyles
    # Each segment's text and background color, underline color code, and link ('' for none)
    [object[]] $Foregrounds
    [object[]] $Backgrounds
    [string[]] $Underlines
    [object[]] $Links
    # Whether links are written
    [bool] $LinksOn
    # The text and background gradients, one color for each character written, or $null
    [object[]] $Gradient
    [object[]] $BackGroundGradient

    # The text of a line with its colors, styles and links as escape codes.
    #
    # Items are the line's pieces in order, each @{ Index; Runs }: the segment whose colors,
    # styles, underline color and link it takes, and its runs. A run's markup or -Highlight colors
    # and styles go over the segment's. A segment with no text color of its own takes the
    # gradient, character by character from the run's GradientIndex, and one with no background
    # color the background gradient. Each run with codes ends with a reset; a link opens before
    # the codes of the first run it covers and closes after the last.
    [string] Ansi([System.Collections.Generic.List[object]] $Items) {
        $esc = [ColorCode]::Esc
        $reset = [ColorCode]::Reset
        $builder = [System.Text.StringBuilder]::new()
        $openLink = ''
        foreach ($item in $Items) {
            $i = [int]$item.Index
            $segmentStyles = ''
            if ($this.ANSISupport) {
                $segmentStyles = $this.LineStyles
                if ($this.Styles) {
                    $segmentStyles = [ColorCode]::SegmentStyle($this.Styles, $i) + $this.LineStyles
                }
            }
            $segmentFg = $null
            if ($i -lt $this.Foregrounds.Count) {
                $segmentFg = $this.Foregrounds[$i]
            }
            $segmentBg = $null
            if ($i -lt $this.Backgrounds.Count) {
                $segmentBg = $this.Backgrounds[$i]
            }
            $segmentUnderline = ''
            if ($i -lt $this.Underlines.Count) {
                $segmentUnderline = $this.Underlines[$i]
            }
            $segmentLink = ''
            if ($i -lt $this.Links.Count) {
                $segmentLink = [string]$this.Links[$i]
            }
            foreach ($run in $item.Runs) {
                $runLink = $segmentLink
                if ($run.HasLink) {
                    $runLink = [ColorCode]::Link($run.Link)
                }
                if ($this.LinksOn -and $runLink -cne $openLink) {
                    if ($openLink.Length -gt 0) {
                        [void]$builder.Append("$esc]8;;$esc\")
                    }
                    if ($runLink.Length -gt 0) {
                        [void]$builder.Append("$esc]8;;$runLink$esc\")
                    }
                    $openLink = $runLink
                }
                $codes = $segmentStyles + $segmentUnderline
                if ($this.ANSISupport -and $null -ne $run.Styles -and $run.Styles.Count -gt 0) {
                    $codes += [ColorCode]::RunStyle($run.Styles)
                }
                $fg = $segmentFg
                if ($run.HasFg) {
                    $fg = $run.ModeFg
                }
                $bg = $segmentBg
                if ($run.HasBg) {
                    $bg = $run.ModeBg
                }
                $fgGradient = $null -ne $this.Gradient -and -not $run.HasFg -and $null -eq $segmentFg
                $bgGradient = $null -ne $this.BackGroundGradient -and -not $run.HasBg -and $null -eq $segmentBg
                if ($fgGradient -or $bgGradient) {
                    if (-not $fgGradient -and $null -ne $fg) {
                        $codes += [ColorCode]::ColorSequence($fg, $false, $this.ANSI24, $this.ANSI8, $this.ANSI4, $this.Colors)
                    }
                    if (-not $bgGradient -and $null -ne $bg) {
                        $codes += [ColorCode]::ColorSequence($bg, $true, $this.ANSI24, $this.ANSI8, $this.ANSI4, $this.Colors)
                    }
                    [void]$builder.Append($codes)
                    $at = [int]$run.GradientIndex
                    foreach ($character in $run.Characters) {
                        if ($fgGradient) {
                            $step = $this.Gradient[$at]
                            if ($this.ANSI24 -and $step -is [array]) {
                                [void]$builder.Append("$esc[38;2;$($step[0]);$($step[1]);$($step[2])m")
                            } elseif ($this.ANSI8 -and $step -is [int]) {
                                [void]$builder.Append("$esc[38;5;$($step)m")
                            }
                        }
                        if ($bgGradient) {
                            $step = $this.BackGroundGradient[$at]
                            if ($this.ANSI24 -and $step -is [array]) {
                                [void]$builder.Append("$esc[48;2;$($step[0]);$($step[1]);$($step[2])m")
                            } elseif ($this.ANSI8 -and $step -is [int]) {
                                [void]$builder.Append("$esc[48;5;$($step)m")
                            }
                        }
                        [void]$builder.Append($character)
                        $at++
                    }
                    [void]$builder.Append($reset)
                    continue
                }
                if ($null -ne $fg) {
                    $codes += [ColorCode]::ColorSequence($fg, $false, $this.ANSI24, $this.ANSI8, $this.ANSI4, $this.Colors)
                }
                if ($null -ne $bg) {
                    $codes += [ColorCode]::ColorSequence($bg, $true, $this.ANSI24, $this.ANSI8, $this.ANSI4, $this.Colors)
                }
                [void]$builder.Append($codes).Append($run.Text)
                if ($codes.Length -gt 0 -or ($null -ne $this.Gradient -and $null -ne $segmentFg)) {
                    [void]$builder.Append($reset)
                }
            }
        }
        if ($openLink.Length -gt 0) {
            [void]$builder.Append("$esc]8;;$esc\")
        }
        return $builder.ToString()
    }

    # The pieces of a line written with console colors, one Write-Host call each: text with the
    # console colors of its run or segment. White space with no background joins its neighbor,
    # and pieces of one color pair go out together.
    [System.Collections.Generic.List[object]] Pieces([string] $Prefix, [string] $TimeText, [System.Collections.Generic.List[object]] $Items) {
        $pieces = [System.Collections.Generic.List[object]]::new()
        if ($Prefix) {
            $pieces.Add(@{ Text = $Prefix; Fg = $null; Bg = $null })
        }
        if ($TimeText) {
            $pieces.Add(@{ Text = $TimeText; Fg = 'DarkGray'; Bg = $null })
        }
        foreach ($item in $Items) {
            $i = [int]$item.Index
            foreach ($run in $item.Runs) {
                $fgValue = $null
                if ($run.HasFg) {
                    $fgValue = $run.ModeFg
                } elseif ($i -lt $this.Foregrounds.Count) {
                    $fgValue = $this.Foregrounds[$i]
                }
                $bgValue = $null
                if ($run.HasBg) {
                    $bgValue = $run.ModeBg
                } elseif ($i -lt $this.Backgrounds.Count) {
                    $bgValue = $this.Backgrounds[$i]
                }
                $fg = $null
                $bg = $null
                if ($null -ne $fgValue) {
                    $fg = [ColorCode]::NativeName($fgValue, $false, $this.Colors)
                }
                if ($null -ne $bgValue) {
                    $bg = [ColorCode]::NativeName($bgValue, $true, $this.Colors)
                }
                $pieces.Add(@{ Text = [string]$run.Text; Fg = $fg; Bg = $bg })
            }
        }

        $merged = [System.Collections.Generic.List[object]]::new()
        foreach ($piece in $pieces) {
            if ($piece.Text.Length -eq 0) {
                continue
            }
            $previousPiece = $null
            if ($merged.Count -gt 0) {
                $previousPiece = $merged[$merged.Count - 1]
            }
            $blank = [string]::IsNullOrWhiteSpace($piece.Text) -and $null -eq $piece.Bg
            if ($null -ne $previousPiece -and $null -eq $previousPiece.Bg -and $blank) {
                $previousPiece.Text += $piece.Text
                continue
            }
            if ($null -ne $previousPiece -and $previousPiece.Fg -eq $piece.Fg -and $previousPiece.Bg -eq $piece.Bg) {
                $previousPiece.Text += $piece.Text
                continue
            }
            if ($null -ne $previousPiece -and $null -eq $piece.Bg -and $null -eq $previousPiece.Bg -and [string]::IsNullOrWhiteSpace($previousPiece.Text)) {
                $piece.Text = $previousPiece.Text + $piece.Text
                $merged[$merged.Count - 1] = $piece
                continue
            }
            $merged.Add($piece)
        }
        return $merged
    }
}
