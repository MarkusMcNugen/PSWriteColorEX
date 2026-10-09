# The helpers Write-ColorEX calls on each line, defined once for the module rather than on
# each call. PowerShell scopes are dynamic within a module, so they read the switches and
# values of the Write-ColorEX call they run under, such as $Debugging, $Silent, $Colors,
# $styles and the color mode switches.

# The escape code tables, kept in the ColorCode class (Classes/ColorCode.ps1)
$script:Esc = [ColorCode]::Esc
$script:SgrReset = [ColorCode]::Reset
$script:StyleSgr = [ColorCode]::StyleSgr
$script:UnderlineStyleSgr = [ColorCode]::UnderlineStyleSgr
$script:ConsoleColorAnsiIndex = [ColorCode]::ConsoleAnsiIndex

function Write-DebugLog {
    param([string]$Message)
    if ($Debugging) {
        Write-Verbose "[DEBUG] $Message" -Verbose
    }
}

# A warning that -Silent suppresses
function Write-ColorWarningMsg {
    param([string]$Message)
    if (-not $Silent) {
        Write-Warning $Message
    }
}

# The console color an ANSI4 foreground or background code stands for
function ConvertANSI4ToNativeColor {
    param([int]$Code)

    if (($Code -ge 40 -and $Code -le 47) -or ($Code -ge 100 -and $Code -le 107)) {
        $Code -= 10
    }
    switch ($Code) {
        30 { return 'Black' }
        31 { return 'DarkRed' }
        32 { return 'DarkGreen' }
        33 { return 'DarkYellow' }
        34 { return 'DarkBlue' }
        35 { return 'DarkMagenta' }
        36 { return 'DarkCyan' }
        37 { return 'Gray' }
        90 { return 'DarkGray' }
        91 { return 'Red' }
        92 { return 'Green' }
        93 { return 'Yellow' }
        94 { return 'Blue' }
        95 { return 'Magenta' }
        96 { return 'Cyan' }
        97 { return 'White' }
        default { return 'Gray' }
    }
}

# The ANSI4 foreground code nearest an ANSI8 color code
function ConvertANSI8ToANSI4 {
    param([int]$Code)

    if ($Code -lt 8) { return 30 + $Code }
    if ($Code -lt 16) { return 82 + $Code }
    if ($Code -lt 232) {
        # The 6x6x6 color cube
        $levels = 0, 95, 135, 175, 215, 255
        $index = $Code - 16
        $rgb = @($levels[[int][Math]::Floor($index / 36)], $levels[[int][Math]::Floor($index / 6) % 6], $levels[$index % 6])
    } else {
        # The 24 grays
        $value = 8 + ($Code - 232) * 10
        $rgb = @($value, $value, $value)
    }
    return Convert-RGBToANSI4 -RGB $rgb
}

# ---------------------------------------------------------------------------------------------
# Color forms, markup, highlighting and splitting
# ---------------------------------------------------------------------------------------------

# The style names a markup tag or a -Highlight style takes, and the style each stands for
$script:MarkupStyleNames = @{
    'bold' = 'Bold'; 'faint' = 'Faint'; 'dim' = 'Faint'; 'italic' = 'Italic'
    'underline' = 'Underline'; 'blink' = 'Blink'; 'crossedout' = 'CrossedOut'
    'strike' = 'CrossedOut'; 'strikethrough' = 'CrossedOut'; 'doubleunderline' = 'DoubleUnderline'
    'overline' = 'Overline'; 'reverse' = 'Reverse'; 'invert' = 'Reverse'
    'curly' = 'Curly'; 'dotted' = 'Dotted'; 'dashed' = 'Dashed'
}

function ConvertTo-ColorForm {
    <#
    .SYNOPSIS
    A color as Write-ColorEX reads it further on: '#RGB', '0xRGB', 'rgb(r, g, b)' and
    'hsl(h, s%, l%)' become '#RRGGBB'; any other value is answered as it is.
    #>
    param([object]$Value)
    if ($Value -isnot [string]) {
        return ,$Value
    }
    if ($Value -match '^(?:#|0x)([0-9A-Fa-f])([0-9A-Fa-f])([0-9A-Fa-f])$') {
        return ('#{0}{0}{1}{1}{2}{2}' -f $Matches[1], $Matches[2], $Matches[3]).ToUpperInvariant()
    }
    if ($Value -match '^\s*rgb\(\s*(-?\d+)\s*[,\s]\s*(-?\d+)\s*[,\s]\s*(-?\d+)\s*\)\s*$') {
        $channels = @([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
        $clamped = @(foreach ($channel in $channels) { [Math]::Max(0, [Math]::Min(255, $channel)) })
        if ($clamped[0] -ne $channels[0] -or $clamped[1] -ne $channels[1] -or $clamped[2] -ne $channels[2]) {
            Write-ColorWarningMsg "RGB values out of range (0-255). Original: @($($channels -join ',')). Clamped to: @($($clamped -join ','))"
        }
        return '#{0:X2}{1:X2}{2:X2}' -f $clamped[0], $clamped[1], $clamped[2]
    }
    if ($Value -match '^\s*hsl\(\s*(-?\d+(?:\.\d+)?)\s*(?:deg)?\s*[,\s]\s*(\d+(?:\.\d+)?)%?\s*[,\s]\s*(\d+(?:\.\d+)?)%?\s*\)\s*$') {
        $culture = [System.Globalization.CultureInfo]::InvariantCulture
        $rgb = [ColorMath]::FromHsl([double]::Parse($Matches[1], $culture), [double]::Parse($Matches[2], $culture), [double]::Parse($Matches[3], $culture))
        return '#{0:X2}{1:X2}{2:X2}' -f $rgb[0], $rgb[1], $rgb[2]
    }
    return $Value
}

function ConvertTo-ColorFormList {
    <#
    .SYNOPSIS
    The entries of a color parameter with their color forms read by ConvertTo-ColorForm, and a
    warning, once per call and name, for each name the color table lacks.
    #>
    param([object[]]$Values)
    if ($null -eq $Values) {
        return ,$null
    }
    $converted = [System.Collections.Generic.List[object]]::new()
    foreach ($value in $Values) {
        if ($value -is [string] -and -not $script:CachedColorTable.ContainsKey($value)) {
            $value = ConvertTo-ColorForm -Value $value
            Test-ColorName -Name $value
        }
        $converted.Add($value)
    }
    return ,$converted.ToArray()
}

function Test-ColorName {
    <#
    .SYNOPSIS
    Warns once per call, unless -Silent, about a color name the color table lacks. Hex codes and
    'None' and an empty string, which mean no color, are not names.
    #>
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name) -or $Name -match '^#|^0x' -or $Name -eq 'None' -or $script:CachedColorTable.ContainsKey($Name)) {
        return
    }
    if ($unknownColorNames.Add($Name)) {
        Write-ColorWarningMsg "Unknown color '$Name'."
    }
}

function ConvertFrom-ColorStyleSpec {
    <#
    .SYNOPSIS
    Reads a markup tag or a -Highlight style: style names, a text color, 'on' and a background
    color, and link=URL, separated by spaces outside parentheses. Answers $null when a word is none
    of these.
    #>
    param([string]$Spec)
    $words = [System.Collections.Generic.List[string]]::new()
    $current = [System.Text.StringBuilder]::new()
    $depth = 0
    foreach ($character in $Spec.ToCharArray()) {
        if ($character -eq '(') { $depth++ }
        elseif ($character -eq ')' -and $depth -gt 0) { $depth-- }
        if ([char]::IsWhiteSpace($character) -and $depth -eq 0) {
            if ($current.Length -gt 0) { $words.Add($current.ToString()); [void]$current.Clear() }
            continue
        }
        [void]$current.Append($character)
    }
    if ($current.Length -gt 0) { $words.Add($current.ToString()) }
    if ($words.Count -eq 0) {
        return $null
    }

    $result = @{ Styles = [System.Collections.Generic.List[string]]::new(); HasFg = $false; HasBg = $false; HasLink = $false; Fg = $null; Bg = $null; Link = $null }
    $background = $false
    foreach ($word in $words) {
        if ($background) {
            $form = ConvertTo-ColorForm -Value $word
            if (-not (Test-ColorSpecColor -Value $form)) { return $null }
            $result.Bg = $form
            $result.HasBg = $true
            $background = $false
            continue
        }
        if ($word -eq 'on') {
            if ($result.HasBg) { return $null }
            $background = $true
            continue
        }
        if ($word -match '^(?i)link=(.+)$') {
            $result.Link = $Matches[1]
            $result.HasLink = $true
            continue
        }
        $styleName = $script:MarkupStyleNames[$word.ToLowerInvariant()]
        if ($styleName) {
            $result.Styles.Add($styleName)
            continue
        }
        $form = ConvertTo-ColorForm -Value $word
        if ($result.HasFg -or -not (Test-ColorSpecColor -Value $form)) {
            return $null
        }
        $result.Fg = $form
        $result.HasFg = $true
    }
    if ($background) {
        return $null
    }
    return $result
}

function Test-ColorSpecColor {
    <#
    .SYNOPSIS
    Whether a word of a markup tag or a -Highlight style is a color: a name in the color table, or
    a hex code.
    #>
    param([object]$Value)
    return ($Value -is [string] -and ($Value -match '^(#|0x)[0-9A-Fa-f]{6}$' -or $script:CachedColorTable.ContainsKey($Value)))
}

function New-ColorRun {
    <#
    .SYNOPSIS
    A run of text with the colors, styles and link markup or -Highlight give it.
    #>
    param([string]$Text, [hashtable]$Style)
    if ($null -eq $Style) {
        return @{ Text = $Text; HasFg = $false; HasBg = $false; HasLink = $false; Styles = $null }
    }
    return @{ Text = $Text; HasFg = $Style.HasFg; Fg = $Style.Fg; HasBg = $Style.HasBg; Bg = $Style.Bg; HasLink = $Style.HasLink; Link = $Style.Link; Styles = $Style.Styles }
}

function Merge-ColorStyleSpec {
    <#
    .SYNOPSIS
    A style that takes what the inner one sets and the rest from the outer one; the styles of both.
    #>
    param([hashtable]$Outer, [hashtable]$Inner)
    if ($null -eq $Outer) {
        return $Inner
    }
    $styles = [System.Collections.Generic.List[string]]::new()
    if ($Outer.Styles) { $styles.AddRange([string[]]$Outer.Styles) }
    if ($Inner.Styles) { $styles.AddRange([string[]]$Inner.Styles) }
    return @{
        HasFg = $Inner.HasFg -or $Outer.HasFg; Fg = if ($Inner.HasFg) { $Inner.Fg } else { $Outer.Fg }
        HasBg = $Inner.HasBg -or $Outer.HasBg; Bg = if ($Inner.HasBg) { $Inner.Bg } else { $Outer.Bg }
        HasLink = $Inner.HasLink -or $Outer.HasLink; Link = if ($Inner.HasLink) { $Inner.Link } else { $Outer.Link }
        Styles = $styles
    }
}

function ConvertFrom-ColorMarkup {
    <#
    .SYNOPSIS
    The runs of a string written with markup: [style]text[/], where [/...] closes the tag opened
    last, and [[ and ]] write [ and ]. A tag that is not a style, and a closing tag with no tag
    open, are written as text, with a warning unless -Silent.
    #>
    param([string]$Text)
    $runs = [System.Collections.Generic.List[object]]::new()
    $stack = [System.Collections.Generic.List[hashtable]]::new()
    $buffer = [System.Text.StringBuilder]::new()
    $current = $null
    $flush = {
        if ($buffer.Length -gt 0) {
            $runs.Add((New-ColorRun -Text $buffer.ToString() -Style $current))
            [void]$buffer.Clear()
        }
    }
    $i = 0
    $length = $Text.Length
    while ($i -lt $length) {
        $character = $Text[$i]
        if ($character -eq '[') {
            if ($i + 1 -lt $length -and $Text[$i + 1] -eq '[') {
                [void]$buffer.Append('[')
                $i += 2
                continue
            }
            $close = $Text.IndexOf(']', $i + 1)
            if ($close -lt 0) {
                [void]$buffer.Append($Text.Substring($i))
                break
            }
            $tag = $Text.Substring($i + 1, $close - $i - 1)
            if ($tag.StartsWith('/')) {
                if ($stack.Count -gt 0) {
                    . $flush
                    $stack.RemoveAt($stack.Count - 1)
                    $current = if ($stack.Count -gt 0) { $stack[$stack.Count - 1] } else { $null }
                } else {
                    Write-ColorWarningMsg "Markup tag [$tag] closes no tag; it is written as text."
                    [void]$buffer.Append("[$tag]")
                }
            } else {
                $spec = ConvertFrom-ColorStyleSpec -Spec $tag
                if ($null -eq $spec) {
                    Write-ColorWarningMsg "Markup tag [$tag] is not a style; it is written as text."
                    [void]$buffer.Append("[$tag]")
                } else {
                    . $flush
                    $current = Merge-ColorStyleSpec -Outer $current -Inner $spec
                    $stack.Add($current)
                }
            }
            $i = $close + 1
            continue
        }
        if ($character -eq ']' -and $i + 1 -lt $length -and $Text[$i + 1] -eq ']') {
            [void]$buffer.Append(']')
            $i += 2
            continue
        }
        [void]$buffer.Append($character)
        $i++
    }
    . $flush
    return ,$runs
}

function Get-ColorSegmentText {
    <#
    .SYNOPSIS
    The text of a segment: its runs joined.
    #>
    param([System.Collections.Generic.List[object]]$Segment)
    if ($Segment.Count -eq 1) {
        return [string]$Segment[0].Text
    }
    $builder = [System.Text.StringBuilder]::new()
    foreach ($run in $Segment) {
        [void]$builder.Append($run.Text)
    }
    return $builder.ToString()
}

function Split-ColorRunList {
    <#
    .SYNOPSIS
    A segment's runs cut at the text positions given, as one list of runs per part.
    #>
    param([System.Collections.Generic.List[object]]$Segment, [int[]]$Cuts)
    $parts = [System.Collections.Generic.List[object]]::new()
    $part = [System.Collections.Generic.List[object]]::new()
    $offset = 0
    $cutIndex = 0
    foreach ($run in $Segment) {
        $text = [string]$run.Text
        $start = 0
        while ($cutIndex -lt $Cuts.Count -and $Cuts[$cutIndex] -le $offset + $text.Length) {
            $at = $Cuts[$cutIndex] - $offset
            if ($at -gt $start) {
                $piece = $run.Clone()
                $piece.Text = $text.Substring($start, $at - $start)
                $part.Add($piece)
            }
            if ($part.Count -gt 0) {
                $parts.Add($part)
                $part = [System.Collections.Generic.List[object]]::new()
            }
            $start = [Math]::Max($start, $at)
            $cutIndex++
        }
        if ($start -lt $text.Length) {
            $piece = $run.Clone()
            $piece.Text = $text.Substring($start)
            $part.Add($piece)
        }
        $offset += $text.Length
    }
    if ($part.Count -gt 0) {
        $parts.Add($part)
    }
    return ,$parts
}

function Find-ColorSeparator {
    <#
    .SYNOPSIS
    The places separators occur in a text, as start and end pairs, left to right without overlap;
    where several separators start at one place, the longest.
    #>
    param([string]$Text, [string[]]$Separators)
    $found = [System.Collections.Generic.List[int[]]]::new()
    $i = 0
    while ($i -lt $Text.Length) {
        $longest = 0
        foreach ($separator in $Separators) {
            if ($separator.Length -gt $longest -and $i + $separator.Length -le $Text.Length -and
                [string]::CompareOrdinal($Text, $i, $separator, 0, $separator.Length) -eq 0) {
                $longest = $separator.Length
            }
        }
        if ($longest -gt 0) {
            $found.Add([int[]]@($i, ($i + $longest)))
            $i += $longest
        } else {
            $i++
        }
    }
    return ,$found
}

function Split-ColorSegment {
    <#
    .SYNOPSIS
    The segments cut by -Split, -SplitAround or -SplitEvenly.

    .DESCRIPTION
    -Split cuts after each separator, which stays with the part before it. -SplitAround cuts
    before and after each separator, which becomes a part of its own. -SplitEvenly cuts each
    segment into Parts parts of display characters as equal as they can be, the first ones a
    character longer.
    #>
    param(
        [System.Collections.Generic.List[object]]$Segments,
        [string[]]$Separators,
        [switch]$Around,
        [int]$Parts = 0
    )
    $result = [System.Collections.Generic.List[object]]::new()
    $useful = @($Separators | Where-Object { -not [string]::IsNullOrEmpty($_) })
    foreach ($segment in $Segments) {
        $text = Get-ColorSegmentText -Segment $segment
        $cuts = [System.Collections.Generic.List[int]]::new()
        if ($Parts -gt 0) {
            $characters = @(Split-DisplayCharacter -Text $text)
            $count = $characters.Count
            $partCount = [Math]::Min($Parts, $count)
            if ($partCount -gt 1) {
                $size = [Math]::Floor($count / $partCount)
                $longer = $count % $partCount
                $position = 0
                $characterIndex = 0
                for ($p = 0; $p -lt $partCount - 1; $p++) {
                    $take = $size + $(if ($p -lt $longer) { 1 } else { 0 })
                    for ($c = 0; $c -lt $take; $c++) {
                        $position += $characters[$characterIndex].Length
                        $characterIndex++
                    }
                    $cuts.Add($position)
                }
            }
        } elseif ($useful.Count -gt 0) {
            foreach ($match in (Find-ColorSeparator -Text $text -Separators $useful)) {
                if ($Around -and $match[0] -gt 0) { $cuts.Add($match[0]) }
                if ($match[1] -lt $text.Length) { $cuts.Add($match[1]) }
            }
        }
        if ($cuts.Count -eq 0) {
            $result.Add($segment)
            continue
        }
        foreach ($part in (Split-ColorRunList -Segment $segment -Cuts ([int[]]$cuts.ToArray()))) {
            $result.Add($part)
        }
    }
    return ,$result
}

function Add-ColorHighlight {
    <#
    .SYNOPSIS
    The segments with -Highlight's styles over the text its patterns match.

    .DESCRIPTION
    Entries are the patterns ConvertFrom-ColorHighlight compiled, each with its style. A pattern
    matches across the text of the whole line. Where matches of several patterns overlap, the
    pattern given first wins; an empty match colors nothing.
    #>
    param([System.Collections.Generic.List[object]]$Segments, [object[]]$Entries)
    $texts = @(foreach ($segment in $Segments) { Get-ColorSegmentText -Segment $segment })
    $line = -join $texts
    if ($line.Length -eq 0) {
        return ,$Segments
    }
    $owner = [int[]]::new($line.Length)
    for ($i = 0; $i -lt $owner.Length; $i++) { $owner[$i] = -1 }
    $styles = [System.Collections.Generic.List[hashtable]]::new()
    $entry = 0
    foreach ($highlightEntry in $Entries) {
        $styles.Add($highlightEntry.Style)
        foreach ($match in $highlightEntry.Regex.Matches($line)) {
            for ($i = $match.Index; $i -lt $match.Index + $match.Length; $i++) {
                if ($owner[$i] -lt 0) { $owner[$i] = $entry }
            }
        }
        $entry++
    }

    $result = [System.Collections.Generic.List[object]]::new()
    $offset = 0
    foreach ($segment in $Segments) {
        $newSegment = [System.Collections.Generic.List[object]]::new()
        foreach ($run in $segment) {
            $text = [string]$run.Text
            $start = 0
            while ($start -lt $text.Length) {
                $who = $owner[$offset + $start]
                $end = $start + 1
                while ($end -lt $text.Length -and $owner[$offset + $end] -eq $who) { $end++ }
                if ($who -ge 0) {
                    $piece = New-ColorRun -Text $text.Substring($start, $end - $start) -Style (Merge-ColorStyleSpec -Outer $run -Inner $styles[$who])
                } else {
                    $piece = $run.Clone()
                    $piece.Text = $text.Substring($start, $end - $start)
                }
                $newSegment.Add($piece)
                $start = $end
            }
            $offset += $text.Length
        }
        if ($newSegment.Count -eq 0) {
            $newSegment.Add((New-ColorRun -Text ''))
        }
        $result.Add($newSegment)
    }
    return ,$result
}

function Limit-ColorSegmentWidth {
    <#
    .SYNOPSIS
    The segments cut to a display width with an ellipsis, when they are wider: as many display
    characters as fit in Width - 1 cells, then an ellipsis in the colors of the first character
    that did not fit.
    #>
    param([System.Collections.Generic.List[object]]$Segments, [int]$Width)
    $all = -join @(foreach ($segment in $Segments) { Get-ColorSegmentText -Segment $segment })
    if ((Measure-DisplayWidth -Text $all) -le $Width) {
        return ,$Segments
    }
    $result = [System.Collections.Generic.List[object]]::new()
    $room = $Width - 1
    $used = 0
    $done = $false
    foreach ($segment in $Segments) {
        if ($done) { break }
        $newSegment = [System.Collections.Generic.List[object]]::new()
        foreach ($run in $segment) {
            if ($done) { break }
            $kept = [System.Text.StringBuilder]::new()
            foreach ($character in (Split-DisplayCharacter -Text ([string]$run.Text))) {
                $cells = Measure-DisplayWidth -Text $character
                if ($used + $cells -gt $room) {
                    $done = $true
                    break
                }
                $used += $cells
                [void]$kept.Append($character)
            }
            $piece = $run.Clone()
            $piece.Text = $kept.ToString()
            if ($done) {
                $piece.Text += [string][char]0x2026
            }
            if ($piece.Text.Length -gt 0) {
                $newSegment.Add($piece)
            }
        }
        if ($newSegment.Count -gt 0) {
            $result.Add($newSegment)
        }
    }
    if (-not $done) {
        return ,$Segments
    }
    if ($result.Count -eq 0) {
        $only = [System.Collections.Generic.List[object]]::new()
        $only.Add((New-ColorRun -Text ([string][char]0x2026)))
        $result.Add($only)
    }
    return ,$result
}

function ConvertFrom-ColorHighlight {
    <#
    .SYNOPSIS
    -Highlight's patterns compiled, each with its style read as a markup tag is.

    .DESCRIPTION
    Patterns are .NET regular expressions matched without regard to case. A pattern that does not
    compile stops the command; a style that is not one is skipped with a warning unless -Silent.
    #>
    param([System.Collections.IDictionary]$Highlight)
    $options = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($pattern in $Highlight.Keys) {
        try {
            $regex = [System.Text.RegularExpressions.Regex]::new([string]$pattern, $options)
        } catch {
            $reason = $_.Exception
            while ($reason.InnerException) { $reason = $reason.InnerException }
            $message = "Cannot validate argument on parameter 'Highlight'. $($reason.Message)"
            $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
                [System.ArgumentException]::new($message), 'ParameterArgumentValidationError',
                [System.Management.Automation.ErrorCategory]::InvalidData, $pattern))
        }
        $spec = ConvertFrom-ColorStyleSpec -Spec ([string]$Highlight[$pattern])
        if ($null -eq $spec) {
            Write-ColorWarningMsg "Highlight style '$($Highlight[$pattern])' for '$pattern' is not a style; the pattern is skipped."
            continue
        }
        $entries.Add(@{ Regex = $regex; Style = $spec })
    }
    return ,$entries.ToArray()
}

# ---------------------------------------------------------------------------------------------
# Colors for the mode in use
# ---------------------------------------------------------------------------------------------

function ConvertTo-ForegroundModeColor {
    <#
    .SYNOPSIS
    A text color as the mode in use writes it, with the warnings about its form and range.

    .DESCRIPTION
    Checks the color against the mode asked for, lightens it for -Bold where the terminal shows
    bold as brighter colors, and converts it for the mode in use after any fallback. Index is the
    segment the color is for, and Original the color as given, both for the debug messages.
    #>
    param([object]$Value, [int]$Index, [object]$Original)
    $currentColor = $Value

    if ($null -eq $currentColor) {
        # $null leaves the segment to a gradient, or to the terminal's color
        return ,($null)
    }

    # A name the color table lacks takes no color; the warning came when the colors were read
    if ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x' -and -not $Colors.ContainsKey($currentColor)) {
        return ,($null)
    }

    # A hex code, which rgb() and hsl() colors have become, is a TrueColor color in any mode asked
    # for, read before -Bold can lighten it into an RGB array
    $hexColor = $currentColor -is [string] -and $currentColor -match '^#|^0x'

    if ($Debugging) { Write-DebugLog "Processing color at index $($Index): $currentColor (type: $($currentColor.GetType().Name))" }

    # Checked against the mode asked for, before any fallback
    if ($OriginalTrueColor) {
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $r = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[0]))
            $g = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[1]))
            $b = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[2]))

            if ($r -ne $currentColor[0] -or $g -ne $currentColor[1] -or $b -ne $currentColor[2]) {
                Write-ColorWarningMsg "RGB values out of range (0-255). Original: @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])). Clamped to: @($r,$g,$b)"
                $currentColor = @($r, $g, $b)
            }
        } elseif ($currentColor -is [int] -and -not $impliedTrueColor) {
            Write-ColorWarningMsg "TrueColor mode expects RGB array @(R,G,B) or hex color, but received integer code $currentColor. Use -ANSI8 or -ANSI4 for integer codes."
            if ($Debugging) { Write-DebugLog "Type mismatch: integer $currentColor provided for TrueColor" }
        }
    } elseif ($OriginalANSI8) {
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            Write-ColorWarningMsg "ANSI8 mode expects integer code (0-255) or color name, but received RGB array. Use -TrueColor for RGB arrays."
            if ($Debugging) { Write-DebugLog "Type mismatch: RGB array provided for ANSI8" }
        } elseif ($currentColor -is [int]) {
            if ($currentColor -lt 0 -or $currentColor -gt 255) {
                Write-ColorWarningMsg "ANSI8 color code $currentColor is out of range (0-255). Using Gray (7)."
                $currentColor = 7
            }
        }
    }

    # Where the terminal shows bold as brighter colors, the color is made lighter instead
    if ($Bold -and -not $script:SupportsBoldFonts) {
        if ($Debugging) { Write-DebugLog "Bold enabled but terminal doesn't support bold fonts - auto-lightening color" }

        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $currentColor = Get-LighterRGBColor -RGB $currentColor
            if ($Debugging) { Write-DebugLog "RGB color lightened to: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])" }
        } elseif ($currentColor -is [int]) {
            # ANSI4 codes are left to the terminal, which brightens them for bold
            if ($ANSI8 -and $currentColor -ge 0 -and $currentColor -le 255) {
                $originalCode = $currentColor
                $currentColor = Get-LighterANSI8Color -ANSI8Code $currentColor
                if ($Debugging) { Write-DebugLog "ANSI8 code $originalCode algorithmically lightened to $currentColor" }
            }
        } elseif ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x') {
            $lightenedName = Get-LighterColorName -ColorName $currentColor
            if ($lightenedName -ne $currentColor) {
                $currentColor = $lightenedName
                if ($Debugging) { Write-DebugLog "Color name lightened from $($Original) to $currentColor" }
            } else {
                # No lighter name: ANSI8 and TrueColor lighten the color's value instead
                if ($ANSI8 -and $Colors.ContainsKey($currentColor)) {
                    $ansi8Code = $Colors[$currentColor][3]
                    $lightenedCode = Get-LighterANSI8Color -ANSI8Code $ansi8Code
                    $currentColor = $lightenedCode
                    if ($Debugging) { Write-DebugLog "Color name $($Original) algorithmically lightened in ANSI8 from code $ansi8Code to $lightenedCode" }
                } elseif ($ANSI24 -and $Colors.ContainsKey($currentColor)) {
                    $rgb = $Colors[$currentColor][4]
                    $lightenedRGB = Get-LighterRGBColor -RGB $rgb
                    $currentColor = $lightenedRGB
                    if ($Debugging) { Write-DebugLog "Color name $($Original) algorithmically lightened in ANSI24 from RGB to R=$($lightenedRGB[0]) G=$($lightenedRGB[1]) B=$($lightenedRGB[2])" }
                }
            }
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $rgb = Convert-HexToRGB -Hex $currentColor
            $currentColor = Get-LighterRGBColor -RGB $rgb
            if ($Debugging) { Write-DebugLog "Hex color $($Original) converted to RGB and lightened" }
        }
    }

    # Converted for the mode in use after any fallback
    if ($ANSI24) {
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            if ($Debugging) { Write-DebugLog "RGB array color: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])" }
            return ,($currentColor)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $rgb = Convert-HexToRGB -Hex $currentColor
            if ($Debugging) { Write-DebugLog "Hex color $currentColor converted to RGB: R=$($rgb[0]) G=$($rgb[1]) B=$($rgb[2])" }
            return ,($rgb)
        } elseif ($currentColor -is [string]) {
            $colorEntry = $Colors[$currentColor]
            if ($colorEntry) {
                if ($Debugging) { Write-DebugLog "Named color $currentColor mapped to RGB" }
                return ,($colorEntry[4])
            } else {
                return ,($currentColor)
            }
        } else {
            return ,($currentColor)
        }
    } elseif ($ANSI8 -and ($OriginalTrueColor -or $hexColor)) {
        # A TrueColor color in ANSI8, asked for or fallen back to
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $ansi8Code = Convert-RGBToANSI8 -RGB $currentColor
            if ($Debugging) { Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI8: $ansi8Code" }
            return ,($ansi8Code)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $ansi8Code = Convert-RGBToANSI8 -RGB (Convert-HexToRGB -Hex $currentColor)
            if ($Debugging) { Write-DebugLog "Hex $currentColor converted to ANSI8: $ansi8Code" }
            return ,($ansi8Code)
        } else {
            return ,($currentColor)
        }
    } elseif ($ANSI4 -and ($OriginalTrueColor -or $hexColor)) {
        # A TrueColor color in ANSI4, asked for or fallen back to
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $ansi4Code = Convert-RGBToANSI4 -RGB $currentColor
            if ($Debugging) { Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI4: $ansi4Code" }
            return ,($ansi4Code)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $ansi4Code = Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor)
            if ($Debugging) { Write-DebugLog "Hex $currentColor converted to ANSI4: $ansi4Code" }
            return ,($ansi4Code)
        } else {
            return ,($currentColor)
        }
    } elseif (-not $ANSISupport -and ($OriginalTrueColor -or $hexColor)) {
        # A TrueColor color fell back to console colors, through the nearest ANSI4 code
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $nativeColor = ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB $currentColor)
            if ($Debugging) { Write-DebugLog "RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to Native: $nativeColor" }
            return ,($nativeColor)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $nativeColor = ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor))
            if ($Debugging) { Write-DebugLog "Hex $currentColor converted to Native: $nativeColor" }
            return ,($nativeColor)
        } else {
            return ,($currentColor)
        }
    } elseif ($currentColor -is [int] -and $ANSI4 -and $OriginalANSI8) {
        # ANSI8 fell back to ANSI4
        $ansi4Code = ConvertANSI8ToANSI4 -Code $currentColor
        if ($Debugging) { Write-DebugLog "ANSI8 code $currentColor converted to ANSI4: $ansi4Code" }
        return ,($ansi4Code)
    } elseif ($currentColor -is [int] -and -not $ANSISupport -and ($OriginalANSI8 -or $OriginalANSI4)) {
        # ANSI8 or ANSI4 fell back to console colors
        $ansi4Code = if ($OriginalANSI8) { ConvertANSI8ToANSI4 -Code $currentColor } else { $currentColor }
        $nativeColor = ConvertANSI4ToNativeColor -Code $ansi4Code
        if ($Debugging) { Write-DebugLog "Color code $currentColor converted to Native: $nativeColor" }
        return ,($nativeColor)
    } else {
        return ,($currentColor)
    }
    return ,($currentColor)
}

function ConvertTo-BackgroundModeColor {
    <#
    .SYNOPSIS
    A background color as the mode in use writes it, as ConvertTo-ForegroundModeColor does for
    text, with the background's codes and messages.
    #>
    param([object]$Value, [int]$Index, [object]$Original)
    $currentColor = $Value

    if ($null -eq $currentColor -or $currentColor -eq "None") {
        return ,($null)
    }

    # A name the color table lacks takes no color; the warning came when the colors were read
    if ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x' -and -not $Colors.ContainsKey($currentColor)) {
        return ,($null)
    }

    # A hex code, which rgb() and hsl() colors have become, is a TrueColor color in any mode asked
    # for, read before -Bold can lighten it into an RGB array
    $hexColor = $currentColor -is [string] -and $currentColor -match '^#|^0x'

    # Checked against the mode asked for, before any fallback
    if ($OriginalTrueColor) {
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $r = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[0]))
            $g = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[1]))
            $b = [Math]::Max(0, [Math]::Min(255, [int]$currentColor[2]))

            if ($r -ne $currentColor[0] -or $g -ne $currentColor[1] -or $b -ne $currentColor[2]) {
                Write-ColorWarningMsg "Background RGB values out of range (0-255). Original: @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])). Clamped to: @($r,$g,$b)"
                $currentColor = @($r, $g, $b)
            }
        } elseif ($currentColor -is [int] -and -not $impliedTrueColor) {
            Write-ColorWarningMsg "TrueColor mode expects RGB array @(R,G,B) or hex color for background, but received integer code $currentColor. Use -ANSI8 or -ANSI4 for integer codes."
            if ($Debugging) { Write-DebugLog "Type mismatch: integer $currentColor provided for TrueColor background" }
        }
    } elseif ($OriginalANSI8) {
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            Write-ColorWarningMsg "ANSI8 mode expects integer code (0-255) or color name for background, but received RGB array. Use -TrueColor for RGB arrays."
            if ($Debugging) { Write-DebugLog "Type mismatch: RGB array provided for ANSI8 background" }
        } elseif ($currentColor -is [int]) {
            if ($currentColor -lt 0 -or $currentColor -gt 255) {
                Write-ColorWarningMsg "Background ANSI8 color code $currentColor is out of range (0-255). Using Gray (7)."
                $currentColor = 7
            }
        }
    }

    # Where the terminal shows bold as brighter colors, the color is made lighter instead
    if ($Bold -and -not $script:SupportsBoldFonts) {
        if ($Debugging) { Write-DebugLog "Bold enabled but terminal doesn't support bold fonts - auto-lightening background color" }

        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $currentColor = Get-LighterRGBColor -RGB $currentColor
            if ($Debugging) { Write-DebugLog "Background RGB color lightened to: R=$($currentColor[0]) G=$($currentColor[1]) B=$($currentColor[2])" }
        } elseif ($currentColor -is [int]) {
            # ANSI4 codes are left to the terminal, which brightens them for bold
            if ($ANSI8 -and $currentColor -ge 0 -and $currentColor -le 255) {
                $originalCode = $currentColor
                $currentColor = Get-LighterANSI8Color -ANSI8Code $currentColor
                if ($Debugging) { Write-DebugLog "Background ANSI8 code $originalCode algorithmically lightened to $currentColor" }
            }
        } elseif ($currentColor -is [string] -and $currentColor -notmatch '^#|^0x') {
            $lightenedName = Get-LighterColorName -ColorName $currentColor
            if ($lightenedName -ne $currentColor) {
                $currentColor = $lightenedName
                if ($Debugging) { Write-DebugLog "Background color name lightened from $($Original) to $currentColor" }
            } else {
                # No lighter name: ANSI8 and TrueColor lighten the color's value instead
                if ($ANSI8 -and $Colors.ContainsKey($currentColor)) {
                    $ansi8Code = $Colors[$currentColor][3]
                    $lightenedCode = Get-LighterANSI8Color -ANSI8Code $ansi8Code
                    $currentColor = $lightenedCode
                    if ($Debugging) { Write-DebugLog "Background color name $($Original) algorithmically lightened in ANSI8 from code $ansi8Code to $lightenedCode" }
                } elseif ($ANSI24 -and $Colors.ContainsKey($currentColor)) {
                    $rgb = $Colors[$currentColor][4]
                    $lightenedRGB = Get-LighterRGBColor -RGB $rgb
                    $currentColor = $lightenedRGB
                    if ($Debugging) { Write-DebugLog "Background color name $($Original) algorithmically lightened in ANSI24 from RGB to R=$($lightenedRGB[0]) G=$($lightenedRGB[1]) B=$($lightenedRGB[2])" }
                }
            }
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $rgb = Convert-HexToRGB -Hex $currentColor
            $currentColor = Get-LighterRGBColor -RGB $rgb
            if ($Debugging) { Write-DebugLog "Background hex color $($Original) converted to RGB and lightened" }
        }
    }

    # Converted for the mode in use after any fallback
    if ($ANSI24) {
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            return ,($currentColor)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            return ,((Convert-HexToRGB -Hex $currentColor))
        } elseif ($currentColor -is [string]) {
            $colorEntry = $Colors[$currentColor]
            if ($colorEntry) {
                return ,($colorEntry[4])
            } else {
                return ,($currentColor)
            }
        } else {
            return ,($currentColor)
        }
    } elseif ($ANSI8 -and ($OriginalTrueColor -or $hexColor)) {
        # A TrueColor color in ANSI8, asked for or fallen back to
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $ansi8Code = Convert-RGBToANSI8 -RGB $currentColor
            if ($Debugging) { Write-DebugLog "Background RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI8: $ansi8Code" }
            return ,($ansi8Code)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $ansi8Code = Convert-RGBToANSI8 -RGB (Convert-HexToRGB -Hex $currentColor)
            if ($Debugging) { Write-DebugLog "Background hex $currentColor converted to ANSI8: $ansi8Code" }
            return ,($ansi8Code)
        } else {
            return ,($currentColor)
        }
    } elseif ($ANSI4 -and ($OriginalTrueColor -or $hexColor)) {
        # A TrueColor color in ANSI4, asked for or fallen back to; a background code is the
        # foreground code plus 10
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            $ansi4Code = (Convert-RGBToANSI4 -RGB $currentColor) + 10
            if ($Debugging) { Write-DebugLog "Background RGB @($($currentColor[0]),$($currentColor[1]),$($currentColor[2])) converted to ANSI4: $ansi4Code" }
            return ,($ansi4Code)
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            $ansi4Code = (Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor)) + 10
            if ($Debugging) { Write-DebugLog "Background hex $currentColor converted to ANSI4: $ansi4Code" }
            return ,($ansi4Code)
        } else {
            return ,($currentColor)
        }
    } elseif (-not $ANSISupport -and ($OriginalTrueColor -or $hexColor)) {
        # A TrueColor color fell back to console colors, through the nearest ANSI4 code
        if ($currentColor -is [array] -and $currentColor.Count -eq 3) {
            return ,((ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB $currentColor)))
        } elseif ($currentColor -is [string] -and $currentColor -match '^#|^0x') {
            return ,((ConvertANSI4ToNativeColor -Code (Convert-RGBToANSI4 -RGB (Convert-HexToRGB -Hex $currentColor))))
        } else {
            return ,($currentColor)
        }
    } elseif ($currentColor -is [int] -and $ANSI4 -and $OriginalANSI8) {
        # ANSI8 fell back to ANSI4; a background code is the foreground code plus 10
        $ansi4Code = (ConvertANSI8ToANSI4 -Code $currentColor) + 10
        if ($Debugging) { Write-DebugLog "Background ANSI8 code $currentColor converted to ANSI4: $ansi4Code" }
        return ,($ansi4Code)
    } elseif ($currentColor -is [int] -and -not $ANSISupport -and ($OriginalANSI8 -or $OriginalANSI4)) {
        # ANSI8 or ANSI4 fell back to console colors
        $ansi4Code = if ($OriginalANSI8) { ConvertANSI8ToANSI4 -Code $currentColor } else { $currentColor }
        return ,((ConvertANSI4ToNativeColor -Code $ansi4Code))
    } else {
        return ,($currentColor)
    }
    return ,($currentColor)
}

# ---------------------------------------------------------------------------------------------
# Underline colors, and wrapping
# ---------------------------------------------------------------------------------------------

function Get-UnderlineColorSequence {
    <#
    .SYNOPSIS
    The escape code that sets an underline color in the mode in use, or '' for none: 58;2;R;G;B in
    TrueColor, 58;5;N otherwise, with N the 256-color number, or 0-15 in 16 colors.
    #>
    param([object]$Value)
    if ($null -eq $Value -or ($Value -is [string] -and $Value -eq 'None')) {
        return ''
    }
    $rgb = $null
    $number = $null
    if ($Value -is [array] -and $Value.Count -eq 3) {
        $rgb = @(foreach ($channel in $Value) { [Math]::Max(0, [Math]::Min(255, [int]$channel)) })
    } elseif ($Value -is [string] -and $Value -match '^#|^0x') {
        $rgb = Convert-HexToRGB -Hex $Value
    } elseif ($Value -is [string]) {
        $entry = $Colors[$Value]
        if (-not $entry) {
            return ''
        }
        if ($ANSI24) { $rgb = $entry[4] }
        elseif ($ANSI8) { $number = $entry[3] }
        elseif ($ANSI4) { $number = if ($entry[1] -ge 90) { $entry[1] - 82 } else { $entry[1] - 30 } }
        else { $number = $script:ConsoleColorAnsiIndex[$entry[0]] }
    } elseif ($Value -is [int]) {
        $number = [Math]::Max(0, [Math]::Min(255, $Value))
    } else {
        return ''
    }
    if ($null -ne $rgb) {
        if ($ANSI24) {
            return "$script:Esc[58;2;$($rgb[0]);$($rgb[1]);$($rgb[2])m"
        }
        if ($ANSI8) {
            $number = Convert-RGBToANSI8 -RGB $rgb
        } else {
            $code = Convert-RGBToANSI4 -RGB $rgb
            $number = if ($code -ge 90) { $code - 82 } else { $code - 30 }
        }
    }
    return "$script:Esc[58;5;${number}m"
}

function Split-ColorLine {
    <#
    .SYNOPSIS
    The segments wrapped into lines no wider than Width cells, each line a list of items
    @{ Index; Runs }.

    .DESCRIPTION
    A line breaks at the last space that fits, which is dropped; a word wider than the line breaks
    at a display character. A line end in the text starts a new line. A run cut across lines keeps
    its colors, styles and link on each.
    #>
    param([System.Collections.Generic.List[object]]$Segments, [int]$Width)
    $characters = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $Segments.Count; $i++) {
        foreach ($run in $Segments[$i]) {
            foreach ($character in (Split-DisplayCharacter -Text ([string]$run.Text))) {
                $characters.Add(@{ Index = $i; Run = $run; Text = $character; Cells = (Measure-DisplayWidth -Text $character) })
            }
        }
    }

    $lines = [System.Collections.Generic.List[object]]::new()
    $line = [System.Collections.Generic.List[object]]::new()
    $used = 0
    $lastSpace = -1
    foreach ($character in $characters) {
        if ($character.Text -eq "`r") {
            continue
        }
        if ($character.Text -eq "`n") {
            $lines.Add($line)
            $line = [System.Collections.Generic.List[object]]::new()
            $used = 0
            $lastSpace = -1
            continue
        }
        if ($used + $character.Cells -gt $Width -and $line.Count -gt 0) {
            if ($character.Text -eq ' ') {
                $lines.Add($line)
                $line = [System.Collections.Generic.List[object]]::new()
                $used = 0
                $lastSpace = -1
                continue
            }
            if ($lastSpace -ge 0) {
                $rest = [System.Collections.Generic.List[object]]::new()
                for ($k = $lastSpace + 1; $k -lt $line.Count; $k++) { $rest.Add($line[$k]) }
                $line.RemoveRange($lastSpace, $line.Count - $lastSpace)
                $lines.Add($line)
                $line = $rest
                $used = 0
                foreach ($kept in $line) { $used += $kept.Cells }
                $lastSpace = -1
            } else {
                $lines.Add($line)
                $line = [System.Collections.Generic.List[object]]::new()
                $used = 0
            }
        }
        if ($character.Text -eq ' ') {
            $lastSpace = $line.Count
        }
        $line.Add($character)
        $used += $character.Cells
    }
    $lines.Add($line)

    $result = [System.Collections.Generic.List[object]]::new()
    foreach ($characterLine in $lines) {
        $items = [System.Collections.Generic.List[object]]::new()
        $item = $null
        $piece = $null
        foreach ($character in $characterLine) {
            if ($null -eq $item -or $item.Index -ne $character.Index) {
                $item = @{ Index = $character.Index; Runs = [System.Collections.Generic.List[object]]::new() }
                $items.Add($item)
                $piece = $null
            }
            if ($null -eq $piece -or -not [object]::ReferenceEquals($piece.Source, $character.Run)) {
                $piece = $character.Run.Clone()
                $piece.Source = $character.Run
                $piece.Text = ''
                $piece.Characters = [System.Collections.Generic.List[string]]::new()
                $item.Runs.Add($piece)
            }
            $piece.Text += $character.Text
            $piece.Characters.Add($character.Text)
        }
        $result.Add($items)
    }
    return ,$result
}

function Add-ColorLinePadding {
    <#
    .SYNOPSIS
    Wrapped lines each padded to a display width, by -AutoPad's rules.

    .DESCRIPTION
    The padding is a segment of its own, as without -Wrap: before the text with Side 'Left', on
    both sides with 'Center' (the right side one character more when the count is odd), and after
    it with 'Right'. A padding segment before the text moves the text's segments one on, when any
    line has padding there. Answers @{ Lines; SegmentCount }, the count with the padding segments.
    #>
    param(
        [System.Collections.Generic.List[object]]$Lines,
        [int]$SegmentCount,
        [int]$Width,
        [string]$PadChar,
        [int]$PadCharWidth,
        [string]$Side
    )
    $counts = [System.Collections.Generic.List[int[]]]::new()
    $anyLeft = $false
    $anyRight = $false
    foreach ($items in $Lines) {
        $lineWidth = Measure-DisplayWidth -Text ([ColorCode]::ItemText($items))
        $count = 0
        if ($lineWidth -lt $Width) {
            $count = [int][Math]::Floor(($Width - $lineWidth) / $PadCharWidth)
        }
        $left = 0
        $right = 0
        if ($Side -eq 'Left') {
            $left = $count
        } elseif ($Side -eq 'Center') {
            $left = [int][Math]::Floor($count / 2)
            $right = $count - $left
        } else {
            $right = $count
        }
        if ($left -gt 0) { $anyLeft = $true }
        if ($right -gt 0) { $anyRight = $true }
        $counts.Add([int[]]@($left, $right))
    }

    $offset = if ($anyLeft) { 1 } else { 0 }
    $rightIndex = $SegmentCount + $offset
    $result = [System.Collections.Generic.List[object]]::new()
    for ($l = 0; $l -lt $Lines.Count; $l++) {
        $items = [System.Collections.Generic.List[object]]::new()
        if ($counts[$l][0] -gt 0) {
            $items.Add(@{ Index = 0; Runs = [ColorCode]::Segment($PadChar * $counts[$l][0]) })
        }
        foreach ($item in $Lines[$l]) {
            $items.Add(@{ Index = $item.Index + $offset; Runs = $item.Runs })
        }
        if ($counts[$l][1] -gt 0) {
            $items.Add(@{ Index = $rightIndex; Runs = [ColorCode]::Segment($PadChar * $counts[$l][1]) })
        }
        $result.Add($items)
    }
    $total = $SegmentCount + $offset
    if ($anyRight) { $total++ }
    return @{ Lines = $result; SegmentCount = $total }
}
