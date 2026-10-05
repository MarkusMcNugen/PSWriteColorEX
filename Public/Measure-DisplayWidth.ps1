function Measure-DisplayWidth {
    <#
    .SYNOPSIS
        Measures the display width of a string in terminal cells.

    .DESCRIPTION
        Answers how many terminal cells a string occupies, which String.Length does not: Length
        counts UTF-16 code units. The width of each character comes from the table of the Rust
        crate unicode-width 0.2.2, which PWRSWriteColorEX uses, so both modules measure alike:
        - Wide characters (CJK, most emoji) take 2 cells
        - Combining marks, zero-width spaces and joiners take 0 cells
        - Control characters take 0 cells
        - East Asian Ambiguous characters (box drawing, arrows, some symbols) take 1 cell, or 2 with -AmbiguousAsWide
        - Everything else takes 1 cell

        Emoji sequences count as the cells a terminal draws for them:
        - A character followed by U+FE0F (emoji presentation) takes 2 cells, as in ⚠️ and ❤️
        - A wide emoji followed by U+FE0E (text presentation) takes 1 cell, except with -AmbiguousAsWide
        - A skin tone modifier after an emoji that takes one adds nothing, as in 👍🏽
        - An emoji joined to the one before it by U+200D adds nothing, as in 👨‍👩‍👧
        - A pair of regional indicators (a flag) takes 2 cells

        The string is walked by code point, so Windows PowerShell 5.1 and PowerShell 7 give the
        same answer.

    .PARAMETER Text
        The text string to measure.

    .PARAMETER AmbiguousAsWide
        Treats East Asian Ambiguous characters as 2 cells instead of 1, and keeps a wide emoji
        followed by U+FE0E at 2 cells, as East Asian terminals draw them.

        Ambiguous characters include box drawing (╔═╗║), arrows (→), some symbols (●★®×○) and
        punctuation. Use this for terminals set to draw them wide.

    .EXAMPLE
        Measure-DisplayWidth "Hello"
        Returns: 5

    .EXAMPLE
        Measure-DisplayWidth "Hello 世界"
        Returns: 10 (6 for "Hello " and 2 for each CJK character)

    .EXAMPLE
        Measure-DisplayWidth "✓ Done"
        Returns: 6 (✓ takes 1 cell)

    .EXAMPLE
        Measure-DisplayWidth "😀👍"
        Returns: 4

    .EXAMPLE
        Measure-DisplayWidth "╔═══╗"
        Returns: 5

    .EXAMPLE
        Measure-DisplayWidth "╔═══╗" -AmbiguousAsWide
        Returns: 10

    .NOTES
        Author: MarkusMcNugen
        License: MIT
        Requires: PowerShell 5.1 or later

    .LINK
        https://github.com/MarkusMcNugen/PSWriteColorEX
    #>
    [CmdletBinding()]
    [Alias('MDW', 'Get-DisplayWidth')]
    [OutputType([int])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter()]
        [switch]$AmbiguousAsWide
    )

    process {
        if ([string]::IsNullOrEmpty($Text)) {
            return 0
        }

        $index = $script:DisplayWidthIndex
        $starts = $index.Starts
        $ends = $index.Ends
        $classes = $index.Classes
        $last = $starts.Length - 1
        $wideAmbiguous = $AmbiguousAsWide.IsPresent

        $total = 0
        # The code point before this one and the cells it added, for the sequence rules.
        $previous = -1
        $previousWidth = 0
        # Whether the character before a U+200D was an emoji, so the next emoji joins it.
        $joining = $false

        $i = 0
        $length = $Text.Length
        while ($i -lt $length) {
            $cp = [int]$Text[$i]
            $i++

            # Printable ASCII is one cell and ends any sequence.
            if ($cp -ge 0x20 -and $cp -le 0x7E) {
                $total++
                $previous = $cp
                $previousWidth = 1
                $joining = $false
                continue
            }

            if ($cp -ge 0xD800 -and $cp -le 0xDBFF -and $i -lt $length) {
                $low = [int]$Text[$i]
                if ($low -ge 0xDC00 -and $low -le 0xDFFF) {
                    $cp = 0x10000 + (($cp - 0xD800) -shl 10) + ($low - 0xDC00)
                    $i++
                }
            }

            if ($cp -eq 0xFE0F) {
                # Emoji presentation widens a one-cell base that has an emoji form.
                if ($previousWidth -eq 1 -and (Test-DisplayWidthSet $script:DisplayWidthTable.Vs16Base $previous)) {
                    $total++
                    $previousWidth = 2
                }
                continue
            }

            if ($cp -eq 0xFE0E) {
                # Text presentation narrows a two-cell emoji, outside East Asian text.
                if (-not $wideAmbiguous -and $previousWidth -eq 2 -and (Test-DisplayWidthSet $script:DisplayWidthTable.Vs15Base $previous)) {
                    $total--
                    $previousWidth = 1
                }
                continue
            }

            if ($cp -eq 0x200D) {
                $joining = $previousWidth -eq 2 -and (Test-DisplayWidthSet $script:DisplayWidthTable.Pictographic $previous)
                continue
            }

            if ($cp -ge 0x1F3FB -and $cp -le 0x1F3FF -and $previousWidth -eq 2 -and (Test-DisplayWidthSet $script:DisplayWidthTable.ModifierBase $previous)) {
                # A skin tone belongs to the emoji before it.
                $joining = $false
                continue
            }

            if ($joining -and (Test-DisplayWidthSet $script:DisplayWidthTable.Pictographic $cp)) {
                # An emoji joined to the one before it is drawn in that emoji's cells.
                $joining = $false
                $previous = $cp
                $previousWidth = 2
                continue
            }
            $joining = $false

            $class = 0
            $lo = 0
            $hi = $last
            while ($lo -le $hi) {
                $mid = ($lo + $hi) -shr 1
                if ($cp -lt $starts[$mid]) {
                    $hi = $mid - 1
                } elseif ($cp -gt $ends[$mid]) {
                    $lo = $mid + 1
                } else {
                    $class = $classes[$mid]
                    break
                }
            }

            $width = switch ($class) {
                1 { 0 }
                2 { 2 }
                3 { 3 }
                4 { if ($wideAmbiguous) { 2 } else { 1 } }
                5 { 0 }
                default { 1 }
            }
            $total += $width
            $previous = $cp
            $previousWidth = $width
        }

        return $total
    }
}

function Test-DisplayWidthSet {
    # Whether a code point falls in a list of start and end pairs sorted by start.
    param([int[]]$Pairs, [int]$CodePoint)

    $lo = 0
    $hi = ($Pairs.Length -shr 1) - 1
    while ($lo -le $hi) {
        $mid = ($lo + $hi) -shr 1
        if ($CodePoint -lt $Pairs[2 * $mid]) {
            $hi = $mid - 1
        } elseif ($CodePoint -gt $Pairs[2 * $mid + 1]) {
            $lo = $mid + 1
        } else {
            return $true
        }
    }
    return $false
}

function Initialize-DisplayWidthIndex {
    # One list of ranges sorted by start, each with its class: 1 zero, 2 wide, 3 three cells,
    # 4 ambiguous, 5 control. The classes do not overlap, so one search finds a code point's.
    $table = $script:DisplayWidthTable
    $sources = @(
        @{ Pairs = $table.Zero; Class = 1 }
        @{ Pairs = $table.Wide; Class = 2 }
        @{ Pairs = $table.Three; Class = 3 }
        @{ Pairs = $table.Ambiguous; Class = 4 }
        @{ Pairs = $table.Control; Class = 5 }
    )
    $count = 0
    foreach ($source in $sources) { $count += $source.Pairs.Length -shr 1 }

    $starts = [int[]]::new($count)
    $ends = [int[]]::new($count)
    $classes = [byte[]]::new($count)
    $n = 0
    foreach ($source in $sources) {
        $pairs = $source.Pairs
        for ($p = 0; $p -lt $pairs.Length; $p += 2) {
            $starts[$n] = $pairs[$p]
            $ends[$n] = $pairs[$p + 1]
            $classes[$n] = $source.Class
            $n++
        }
    }

    $order = [int[]]::new($count)
    for ($k = 0; $k -lt $count; $k++) { $order[$k] = $k }
    $keys = [int[]]$starts.Clone()
    [System.Array]::Sort($keys, $order)

    $sortedEnds = [int[]]::new($count)
    $sortedClasses = [byte[]]::new($count)
    for ($k = 0; $k -lt $count; $k++) {
        $sortedEnds[$k] = $ends[$order[$k]]
        $sortedClasses[$k] = $classes[$order[$k]]
    }

    $script:DisplayWidthIndex = @{
        Starts = $keys
        Ends = $sortedEnds
        Classes = $sortedClasses
    }
}

Initialize-DisplayWidthIndex
