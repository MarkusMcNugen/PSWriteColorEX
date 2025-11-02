function Measure-DisplayWidth {
    <#
    .SYNOPSIS
        Measures the display width of a string in terminal cells.

    .DESCRIPTION
        Calculates how many terminal cells a string will occupy when displayed. This accounts for:
        - Wide characters (CJK, emoji) that take 2 cells
        - Zero-width characters (combining marks) that take 0 cells
        - East Asian Ambiguous Width characters (configurable)
        - Regular ASCII and Latin characters that take 1 cell

        This is critical for proper alignment when using Unicode characters in terminal output,
        as String.Length counts UTF-16 code units, not display width.

    .PARAMETER Text
        The text string to measure.

    .PARAMETER AmbiguousAsWide
        Treat East Asian Ambiguous Width characters as 2 cells instead of 1.
        Default is narrow (1 cell) for maximum cross-platform compatibility.

        Ambiguous characters include box-drawing (╔═╗║), some symbols (®×○), and punctuation.
        Enable this if targeting East Asian locales or terminals configured for wide ambiguous chars.

    .EXAMPLE
        Measure-DisplayWidth "Hello"
        Returns: 5 (5 ASCII characters = 5 cells)

    .EXAMPLE
        Measure-DisplayWidth "Hello 世界"
        Returns: 10 (5 ASCII + 1 space + 2 CJK characters × 2 cells each)

    .EXAMPLE
        Measure-DisplayWidth "😀👍"
        Returns: 4 (2 emoji × 2 cells each)

    .EXAMPLE
        Measure-DisplayWidth "╔═══╗" -AmbiguousAsWide
        Returns: 10 (5 box-drawing characters × 2 cells with -AmbiguousAsWide)

    .EXAMPLE
        Measure-DisplayWidth "╔═══╗"
        Returns: 5 (5 box-drawing characters × 1 cell, default narrow treatment)

    .NOTES
        Author: MarkusMcNugen
        License: MIT
        Requires: PowerShell 5.1 or later

        This function is cross-platform compatible (Windows, Linux, macOS) and uses
        built-in .NET classes with no external dependencies required.

        Box-drawing characters are treated as narrow (1 cell) by default for maximum
        compatibility, as this matches behavior on 90% of terminals. Use -AmbiguousAsWide
        if you need wide treatment for East Asian environments.

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

    begin {
        # Helper function to determine character width
        function Get-CharacterWidth {
            param(
                [int]$CodePoint,
                [bool]$TreatAmbiguousAsWide
            )

            # Zero-width characters
            if (($CodePoint -ge 0x0300 -and $CodePoint -le 0x036F) -or   # Combining Diacritical Marks
                ($CodePoint -ge 0x0483 -and $CodePoint -le 0x0489) -or   # Combining Cyrillic
                ($CodePoint -ge 0x0591 -and $CodePoint -le 0x05BD) -or   # Hebrew combining
                ($CodePoint -ge 0x0600 -and $CodePoint -le 0x0605) -or   # Arabic combining
                ($CodePoint -ge 0x064B -and $CodePoint -le 0x065F) -or   # Arabic combining
                ($CodePoint -ge 0x0670 -and $CodePoint -le 0x0670) -or   # Arabic combining
                ($CodePoint -ge 0x06D6 -and $CodePoint -le 0x06DD) -or   # Arabic combining
                ($CodePoint -ge 0x1AB0 -and $CodePoint -le 0x1AFF) -or   # Combining marks
                ($CodePoint -ge 0x1DC0 -and $CodePoint -le 0x1DFF) -or   # Combining marks
                ($CodePoint -ge 0x20D0 -and $CodePoint -le 0x20FF) -or   # Combining marks for symbols
                ($CodePoint -ge 0xFE00 -and $CodePoint -le 0xFE0F) -or   # Variation selectors
                ($CodePoint -ge 0xFE20 -and $CodePoint -le 0xFE2F) -or   # Combining half marks
                ($CodePoint -ge 0x180B -and $CodePoint -le 0x180D) -or   # Mongolian variation selectors
                ($CodePoint -ge 0x200B -and $CodePoint -le 0x200F) -or   # Zero-width spaces/joiners
                $CodePoint -eq 0x00AD -or                                 # Soft hyphen
                $CodePoint -eq 0x034F -or                                 # Combining grapheme joiner
                $CodePoint -eq 0x061C -or                                 # Arabic letter mark
                $CodePoint -eq 0x115F -or $CodePoint -eq 0x1160 -or      # Hangul fillers
                $CodePoint -eq 0x17B4 -or $CodePoint -eq 0x17B5 -or      # Khmer vowels
                ($CodePoint -ge 0xE0100 -and $CodePoint -le 0xE01EF)) {  # Variation selectors supplement
                return 0
            }

            # Wide characters (2 cells)
            # Emoji ranges
            if (($CodePoint -ge 0x1F300 -and $CodePoint -le 0x1F5FF) -or # Misc Symbols and Pictographs
                ($CodePoint -ge 0x1F600 -and $CodePoint -le 0x1F64F) -or # Emoticons
                ($CodePoint -ge 0x1F680 -and $CodePoint -le 0x1F6FF) -or # Transport and Map Symbols
                ($CodePoint -ge 0x1F700 -and $CodePoint -le 0x1F77F) -or # Alchemical Symbols
                ($CodePoint -ge 0x1F780 -and $CodePoint -le 0x1F7FF) -or # Geometric Shapes Extended
                ($CodePoint -ge 0x1F800 -and $CodePoint -le 0x1F8FF) -or # Supplemental Arrows-C
                ($CodePoint -ge 0x1F900 -and $CodePoint -le 0x1F9FF) -or # Supplemental Symbols and Pictographs
                ($CodePoint -ge 0x1FA00 -and $CodePoint -le 0x1FA6F) -or # Chess Symbols
                ($CodePoint -ge 0x1FA70 -and $CodePoint -le 0x1FAFF) -or # Symbols and Pictographs Extended-A
                ($CodePoint -ge 0x2600 -and $CodePoint -le 0x26FF) -or   # Miscellaneous Symbols
                ($CodePoint -ge 0x2700 -and $CodePoint -le 0x27BF)) {    # Dingbats
                return 2
            }

            # CJK and other wide ranges
            if (($CodePoint -ge 0x1100 -and $CodePoint -le 0x115F) -or   # Hangul Jamo
                ($CodePoint -ge 0x2329 -and $CodePoint -le 0x232A) -or   # Angle brackets
                ($CodePoint -ge 0x2E80 -and $CodePoint -le 0x2E99) -or   # CJK Radicals Supplement
                ($CodePoint -ge 0x2E9B -and $CodePoint -le 0x2EF3) -or   # CJK Radicals Supplement
                ($CodePoint -ge 0x2F00 -and $CodePoint -le 0x2FD5) -or   # Kangxi Radicals
                ($CodePoint -ge 0x2FF0 -and $CodePoint -le 0x2FFB) -or   # Ideographic Description Characters
                ($CodePoint -ge 0x3000 -and $CodePoint -le 0x303E) -or   # CJK Symbols and Punctuation
                ($CodePoint -ge 0x3041 -and $CodePoint -le 0x3096) -or   # Hiragana
                ($CodePoint -ge 0x3099 -and $CodePoint -le 0x30FF) -or   # Katakana
                ($CodePoint -ge 0x3105 -and $CodePoint -le 0x312F) -or   # Bopomofo
                ($CodePoint -ge 0x3131 -and $CodePoint -le 0x318E) -or   # Hangul Compatibility Jamo
                ($CodePoint -ge 0x3190 -and $CodePoint -le 0x31E3) -or   # CJK Misc
                ($CodePoint -ge 0x31F0 -and $CodePoint -le 0x321E) -or   # Katakana Phonetic Extensions
                ($CodePoint -ge 0x3220 -and $CodePoint -le 0x3247) -or   # Enclosed CJK
                ($CodePoint -ge 0x3250 -and $CodePoint -le 0x4DBF) -or   # CJK Extension A
                ($CodePoint -ge 0x4E00 -and $CodePoint -le 0xA48C) -or   # CJK Unified Ideographs
                ($CodePoint -ge 0xA490 -and $CodePoint -le 0xA4C6) -or   # Yi Radicals
                ($CodePoint -ge 0xA960 -and $CodePoint -le 0xA97C) -or   # Hangul Jamo Extended-A
                ($CodePoint -ge 0xAC00 -and $CodePoint -le 0xD7A3) -or   # Hangul Syllables
                ($CodePoint -ge 0xD7B0 -and $CodePoint -le 0xD7C6) -or   # Hangul Jamo Extended-B
                ($CodePoint -ge 0xD7CB -and $CodePoint -le 0xD7FB) -or   # Hangul Jamo Extended-B
                ($CodePoint -ge 0xF900 -and $CodePoint -le 0xFAFF) -or   # CJK Compatibility Ideographs
                ($CodePoint -ge 0xFE10 -and $CodePoint -le 0xFE19) -or   # Vertical Forms
                ($CodePoint -ge 0xFE30 -and $CodePoint -le 0xFE6F) -or   # CJK Compatibility Forms
                ($CodePoint -ge 0xFF00 -and $CodePoint -le 0xFF60) -or   # Fullwidth Forms
                ($CodePoint -ge 0xFFE0 -and $CodePoint -le 0xFFE6) -or   # Fullwidth symbols
                ($CodePoint -ge 0x1B000 -and $CodePoint -le 0x1B2FF) -or # Kana Supplement/Extended
                ($CodePoint -ge 0x1F200 -and $CodePoint -le 0x1F251) -or # Enclosed Ideographic Supplement
                ($CodePoint -ge 0x20000 -and $CodePoint -le 0x2FFFD) -or # CJK Extensions
                ($CodePoint -ge 0x30000 -and $CodePoint -le 0x3FFFD)) {  # CJK Extensions
                return 2
            }

            # Ambiguous Width characters - configurable behavior
            # Box-drawing characters (U+2500 to U+257F)
            if ($CodePoint -ge 0x2500 -and $CodePoint -le 0x257F) {
                if ($TreatAmbiguousAsWide) {
                    return 2
                } else {
                    return 1
                }
            }

            # Other common ambiguous characters
            $ambiguousChars = @(
                0x00A1, 0x00A4, 0x00A7, 0x00A8, 0x00AA, 0x00AD, 0x00AE, 0x00B0, 0x00B1,
                0x00B2, 0x00B3, 0x00B4, 0x00B6, 0x00B7, 0x00B8, 0x00B9, 0x00BA, 0x00BC,
                0x00BD, 0x00BE, 0x00BF, 0x00C6, 0x00D0, 0x00D7, 0x00D8, 0x00DE, 0x00DF,
                0x00E6, 0x00F0, 0x00F7, 0x00F8, 0x00FE, 0x0101, 0x0111, 0x0113, 0x011B,
                0x0126, 0x0127, 0x012B, 0x0131, 0x0132, 0x0133, 0x0138, 0x013F, 0x0140,
                0x0141, 0x0142, 0x0144, 0x0148, 0x0149, 0x014A, 0x014B, 0x014D, 0x0152,
                0x0153, 0x0166, 0x0167, 0x016B, 0x01CE, 0x01D0, 0x01D2, 0x01D4, 0x01D6,
                0x01D8, 0x01DA, 0x01DC, 0x0251, 0x0261, 0x02C4, 0x02C7, 0x02C9, 0x02CA,
                0x02CB, 0x02CD, 0x02D0, 0x02D8, 0x02D9, 0x02DA, 0x02DB, 0x02DD, 0x02DF,
                0x0391, 0x03A9, 0x03B1, 0x03C9, 0x0401, 0x0451, 0x2010, 0x2013, 0x2014,
                0x2015, 0x2016, 0x2018, 0x2019, 0x201C, 0x201D, 0x2020, 0x2021, 0x2022,
                0x2024, 0x2025, 0x2026, 0x2027, 0x2030, 0x2032, 0x2033, 0x2035, 0x203B,
                0x203E, 0x2074, 0x207F, 0x2081, 0x2084, 0x20AC, 0x2103, 0x2105, 0x2109,
                0x2113, 0x2116, 0x2121, 0x2122, 0x2126, 0x212B, 0x2153, 0x2154, 0x215B,
                0x215C, 0x215D, 0x215E, 0x2160, 0x216B, 0x2170, 0x2179, 0x2189, 0x2190,
                0x2194, 0x2195, 0x2199, 0x21B8, 0x21B9, 0x21D2, 0x21D4, 0x21E7, 0x2200,
                0x2202, 0x2203, 0x2207, 0x2208, 0x220B, 0x220F, 0x2211, 0x2215, 0x221A,
                0x221D, 0x221F, 0x2220, 0x2223, 0x2225, 0x2227, 0x2228, 0x2229, 0x222A,
                0x222B, 0x222C, 0x222E, 0x2234, 0x2235, 0x2236, 0x2237, 0x223C, 0x223D,
                0x2248, 0x224C, 0x2252, 0x2260, 0x2261, 0x2264, 0x2265, 0x2266, 0x2267,
                0x226A, 0x226B, 0x226E, 0x226F, 0x2282, 0x2283, 0x2286, 0x2287, 0x2295,
                0x2299, 0x22A5, 0x22BF, 0x2312, 0x2460, 0x24EA, 0x254B, 0x2550, 0x2573,
                0x2580, 0x258F, 0x2592, 0x2595, 0x25A0, 0x25A1, 0x25A3, 0x25A9, 0x25B2,
                0x25B3, 0x25B6, 0x25B7, 0x25BC, 0x25BD, 0x25C0, 0x25C1, 0x25C6, 0x25C7,
                0x25C8, 0x25CB, 0x25CE, 0x25CF, 0x25D0, 0x25D1, 0x25E2, 0x25E5, 0x25EF,
                0x2605, 0x2606, 0x2609, 0x260E, 0x260F, 0x261C, 0x261E, 0x2640, 0x2642,
                0x2660, 0x2661, 0x2663, 0x2665, 0x2667, 0x266A, 0x266D, 0x266F, 0x269E,
                0x269F, 0x26BF, 0x26C6, 0x26C7, 0x26CE, 0x26CF, 0x26E2, 0x26EF, 0x26F1,
                0x26F4, 0x26F5, 0x26F7, 0x26FA, 0x26FD, 0x2705, 0x270A, 0x270B, 0x2728,
                0x274C, 0x274E, 0x2753, 0x2754, 0x2755, 0x2757, 0x2795, 0x2796, 0x2797,
                0x27B0, 0x27BF, 0x2B1B, 0x2B1C, 0x2B50, 0x2B55, 0x2B56, 0x2B59
            )

            if ($ambiguousChars -contains $CodePoint) {
                if ($TreatAmbiguousAsWide) {
                    return 2
                } else {
                    return 1
                }
            }

            # Additional ambiguous ranges
            if (($CodePoint -ge 0x2580 -and $CodePoint -le 0x258F) -or  # Block Elements (some)
                ($CodePoint -ge 0x2592 -and $CodePoint -le 0x2595)) {   # Block Elements (some)
                if ($TreatAmbiguousAsWide) {
                    return 2
                } else {
                    return 1
                }
            }

            # Control characters (non-printable)
            if ($CodePoint -lt 0x20 -or ($CodePoint -ge 0x7F -and $CodePoint -lt 0xA0)) {
                return 0
            }

            # Default: narrow (1 cell) - includes ASCII, Latin, etc.
            return 1
        }
    }

    process {
        # Handle empty strings
        if ([string]::IsNullOrEmpty($Text)) {
            return 0
        }

        $totalWidth = 0

        # Use StringInfo to properly handle grapheme clusters (emoji with modifiers, etc.)
        $textElementEnumerator = [System.Globalization.StringInfo]::GetTextElementEnumerator($Text)

        while ($textElementEnumerator.MoveNext()) {
            $textElement = $textElementEnumerator.GetTextElement()

            # Get the codepoint of the first character in the text element
            if ($textElement.Length -eq 1) {
                $codepoint = [int][char]$textElement[0]
            }
            elseif ($textElement.Length -ge 2) {
                # Handle surrogate pairs (emoji, supplementary characters)
                try {
                    $codepoint = [char]::ConvertToUtf32($textElement, 0)
                }
                catch {
                    # If conversion fails, treat as narrow
                    $codepoint = [int][char]$textElement[0]
                }
            }
            else {
                continue
            }

            $charWidth = Get-CharacterWidth -CodePoint $codepoint -TreatAmbiguousAsWide:$AmbiguousAsWide.IsPresent
            $totalWidth += $charWidth
        }

        return $totalWidth
    }
}

