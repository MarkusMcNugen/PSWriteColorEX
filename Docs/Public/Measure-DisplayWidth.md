# Measure-DisplayWidth

> 📏 **Measure Unicode-aware terminal display width**

---

## 📑 Table of Contents

[Synopsis](#synopsis) • [Syntax](#syntax) • [Description](#description) • [Parameters](#parameters) • [Return Values](#return-values) • [Examples](#-examples) • [Character Width Rules](#-character-width-rules) • [Use Cases](#-use-cases) • [Related](#-related-commands)

---

## Synopsis

Calculates the terminal display width (in cells) of a string, correctly handling Unicode characters including emoji, CJK, and box-drawing.

## Syntax

```powershell
Measure-DisplayWidth
    [-Text] <String>
    [-AmbiguousAsWide]
    [<CommonParameters>]
```

## Description

`Measure-DisplayWidth` calculates how many terminal cells a string will occupy when displayed in a console. This is critical for proper alignment when using Unicode characters, as PowerShell's `.Length` property counts UTF-16 code units, not visual display width.

### The Problem

PowerShell's `.Length` doesn't understand Unicode character widths:
```powershell
"Hello".Length      # Returns 5 ✓ Correct
"世界".Length        # Returns 2 ✗ WRONG! Displays as 4 cells
"✅❌".Length       # Returns 2 ✗ WRONG! Displays as 4 cells
"Server ✅".Length  # Returns 8 ✗ WRONG! Displays as 9 cells (✅ = 2 cells)
```

### The Solution

`Measure-DisplayWidth` returns the actual terminal display width:
```powershell
Measure-DisplayWidth "Hello"      # Returns 5 ✓
Measure-DisplayWidth "世界"        # Returns 4 ✓
Measure-DisplayWidth "✅❌"       # Returns 4 ✓
Measure-DisplayWidth "Server ✅"  # Returns 9 ✓
```

### ✨ Key Features

- **📏 Accurate Width Calculation** - Correctly measures terminal cell width
- **🌏 Unicode Support** - Handles wide characters (CJK, emoji) that occupy 2 cells
- **🔤 Combining Marks** - Recognizes zero-width characters (combining diacritics)
- **📦 Box-Drawing** - Configurable treatment of East Asian Ambiguous Width characters
- **⚡ Single Pass** - One pass through the string, no external dependencies
- **🌍 Cross-Platform** - Works on Windows, Linux, macOS with PowerShell 5.1+
- **🔄 Pipeline Support** - Accepts pipeline input

---

## Parameters

<details open>
<summary><b>🎛️ Command Parameters</b></summary>

### `-Text`
> **Type:** `String`
> **Position:** 0
> **Mandatory:** Yes
> **Pipeline:** Yes (ByValue)

The text string to measure. Accepts empty strings.

```powershell
Measure-DisplayWidth "Test"
Measure-DisplayWidth "Hello 世界"
"Server ●" | Measure-DisplayWidth
```

### `-AmbiguousAsWide`
> **Type:** `Switch`
> **Default:** `$false` (treat as narrow)

Treat East Asian Ambiguous Width characters as 2 cells instead of 1 cell.

**Ambiguous characters** include:
- Box-drawing: `╔═╗║╚╝╠╣╦╩╬─│┌┐└┘├┤┬┴┼`
- Symbols: `®×○●◆◇★☆`
- Some punctuation

**Default behavior (narrow):** Matches 90% of terminal configurations
**Use `-AmbiguousAsWide`:** For East Asian locales or terminals configured for wide ambiguous characters

```powershell
# Default: Box-drawing treated as narrow (1 cell each)
Measure-DisplayWidth "╔═══╗"                # Returns 5

# East Asian mode: Box-drawing treated as wide (2 cells each)
Measure-DisplayWidth "╔═══╗" -AmbiguousAsWide  # Returns 10
```

</details>

---

## Return Values

Returns `[int]` - The number of terminal cells the string will occupy.

| Character Type | Width (cells) | Examples |
|----------------|---------------|----------|
| **ASCII/Latin** | 1 | `a-z A-Z 0-9 !@#$%` |
| **Wide (CJK)** | 2 | `世界 日本語 中文 한글` |
| **Wide (Emoji)** | 2 | `😀👍🎨🌟` |
| **Wide (Symbols)** | 2 | `✅` (check mark button U+2705) |
| **Zero-width** | 0 | Combining marks (accents) |
| **Ambiguous** | 1 (default) or 2 (with `-AmbiguousAsWide`) | `╔═╗║●★` |

---

## 📚 Examples

<details>
<summary><b>Example 1: ASCII Text</b></summary>

```powershell
Measure-DisplayWidth "Hello"
# Returns: 5
# 5 ASCII characters × 1 cell each = 5 cells
```

</details>

<details>
<summary><b>Example 2: CJK Characters (Chinese, Japanese, Korean)</b></summary>

```powershell
Measure-DisplayWidth "世界"
# Returns: 4
# 2 CJK characters × 2 cells each = 4 cells

Measure-DisplayWidth "Hello 世界"
# Returns: 10
# 5 ASCII + 1 space + (2 CJK × 2) = 10 cells
```

</details>

<details>
<summary><b>Example 3: Emoji</b></summary>

```powershell
Measure-DisplayWidth "😀👍"
# Returns: 4
# 2 emoji × 2 cells each = 4 cells

Measure-DisplayWidth "Status: ✓"
# Returns: 9
# "Status: " (8) + "✓" (1) = 9 cells
```

</details>

<details>
<summary><b>Example 4: Mixed ASCII and Unicode</b></summary>

```powershell
Measure-DisplayWidth "Server ✅"
# Returns: 9
# "Server " (7 ASCII) + "✅" (2 cells) = 9 cells

# This is why .PadRight() breaks alignment:
"Server ✅".PadRight(21)  # Adds 13 spaces (21 - 8 .Length)
                          # But displays as 22 cells! ❌ MISALIGNED

# Use AutoPad instead:
Write-ColorEX "Server ✅" -AutoPad 21  # ✅ Perfectly aligned
```

</details>

<details>
<summary><b>Example 5: Box-Drawing Characters</b></summary>

```powershell
# Default: Narrow treatment (1 cell per character)
Measure-DisplayWidth "╔═══╗"
# Returns: 5
# Compatible with 90% of terminals

# East Asian mode: Wide treatment (2 cells per character)
Measure-DisplayWidth "╔═══╗" -AmbiguousAsWide
# Returns: 10
# For terminals configured for wide ambiguous chars
```

</details>

<details>
<summary><b>Example 6: Pipeline Usage</b></summary>

```powershell
# Measure multiple strings
@("Hello", "世界", "😀") | Measure-DisplayWidth
# Returns: 5, 4, 2

# Calculate padding needed for alignment
$text = "Server ✅"
$targetWidth = 21
$currentWidth = Measure-DisplayWidth $text
$paddingNeeded = $targetWidth - $currentWidth
Write-Host "Need $paddingNeeded spaces for perfect alignment"
# Output: "Need 12 spaces for perfect alignment"
```

</details>

<details>
<summary><b>Example 7: Combining Marks (Zero-Width)</b></summary>

```powershell
# é can be represented two ways:
$composed = "é"     # Single precomposed character (U+00E9)
$decomposed = "e$([char]0x0301)"   # 'e' (U+0065) + combining acute (U+0301)

Measure-DisplayWidth $composed
# Returns: 1 (single character)

Measure-DisplayWidth $decomposed
# Returns: 1 (base char 1 + combining mark 0 = 1 cell)
```

</details>

<details>
<summary><b>Example 8: Real-World Table Alignment</b></summary>

```powershell
# Build a perfectly aligned table with Unicode
$services = @(
    @{Name="Web Server"; Status="✅"}    # ✅ = 2 cells
    @{Name="Database";   Status="✅"}
    @{Name="Cache";      Status="❌"}    # ❌ = 2 cells
)

foreach ($svc in $services) {
    $name = $svc.Name + " " + $svc.Status
    $width = Measure-DisplayWidth $name
    $padding = " " * (25 - $width)
    Write-Host "$name$padding[OK]"
}

# Output (perfectly aligned):
# Web Server ✅            [OK]
# Database ✅              [OK]
# Cache ❌                 [OK]
```

</details>

---

## 🔄 Width Calculation Flow

<details open>
<summary><b>Unicode Width Detection Logic</b></summary>

```mermaid
graph TD
    Start([Measure-DisplayWidth Called]) --> InitWidth[Initialize Total Width = 0]
    InitWidth --> ForEach{For Each Code Point<br/>in String}

    ForEach -->|Has More| GetCodePoint[Get Unicode Code Point]
    ForEach -->|Done| ReturnTotal[Return Total Width]

    GetCodePoint --> CheckSeq{Emoji Sequence?<br/>FE0F/FE0E/Skin Tone/ZWJ}

    CheckSeq -->|Yes| AddSeq[Apply Sequence Rule<br/>0, +1 or -1 Cell]
    CheckSeq -->|No| CheckZero{Zero-Width or<br/>Control Character?}

    CheckZero -->|Yes| AddZero[Add 0 Cells]
    CheckZero -->|No| CheckWide{Wide Character?<br/>CJK/Emoji/Fullwidth}

    CheckWide -->|Yes| AddTwo[Add 2 Cells]
    CheckWide -->|No| CheckAmbiguous{Ambiguous Width?<br/>Box-Drawing/Symbols}

    CheckAmbiguous -->|Yes| CheckMode{-AmbiguousAsWide<br/>Parameter?}
    CheckAmbiguous -->|No| AddOne[Add 1 Cell<br/>Standard Character]

    CheckMode -->|True| AddTwoAmb[Add 2 Cells<br/>East Asian Mode]
    CheckMode -->|False| AddOneAmb[Add 1 Cell<br/>Default Mode]

    AddSeq --> ForEach
    AddZero --> ForEach
    AddTwo --> ForEach
    AddOne --> ForEach
    AddOneAmb --> ForEach
    AddTwoAmb --> ForEach

    style Start fill:#e3f2fd,stroke:#1565c0,stroke-width:3px,color:#000
    style ReturnTotal fill:#c8e6c9,stroke:#388e3c,stroke-width:3px,color:#000
    style AddSeq fill:#fff9c4,stroke:#f9a825,stroke-width:2px,color:#000
    style AddZero fill:#fff9c4,stroke:#f9a825,stroke-width:2px,color:#000
    style AddOne fill:#e1bee7,stroke:#8e24aa,stroke-width:2px,color:#000
    style AddTwo fill:#b3e5fc,stroke:#0277bd,stroke-width:2px,color:#000
    style AddOneAmb fill:#e1bee7,stroke:#8e24aa,stroke-width:2px,color:#000
    style AddTwoAmb fill:#b3e5fc,stroke:#0277bd,stroke-width:2px,color:#000
```

</details>

<details>
<summary><b>Character Category Examples</b></summary>

```mermaid
graph LR
    subgraph "Zero-Width (0 cells)"
        Z1[Combining Marks<br/>U+0300-U+036F]
        Z2[Zero-Width Space<br/>U+200B]
        Z3[Variation Selectors<br/>U+FE00-U+FE0F]
    end

    subgraph "Wide Characters (2 cells)"
        W1[CJK Ideographs<br/>世界 日本語]
        W2[Emoji<br/>😀 👍 🎉]
        W3[Fullwidth Forms<br/>ＡＢＣＤ １２３]
    end

    subgraph "Ambiguous (1 or 2 cells)"
        A1[Box-Drawing<br/>╔═══╗ ║ ─]
        A2[Symbols<br/>● ○ ★ ☆]
        A3[Some Punctuation<br/>± × ÷]
    end

    subgraph "Narrow (1 cell)"
        N1[ASCII<br/>A-Z 0-9]
        N2[Latin Extended<br/>é ñ ç]
        N3[Most Symbols<br/>@ # $ %]
    end

    style Z1 fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    style Z2 fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    style Z3 fill:#fff9c4,stroke:#f9a825,stroke-width:2px

    style W1 fill:#b3e5fc,stroke:#0277bd,stroke-width:2px
    style W2 fill:#b3e5fc,stroke:#0277bd,stroke-width:2px
    style W3 fill:#b3e5fc,stroke:#0277bd,stroke-width:2px

    style A1 fill:#e1bee7,stroke:#8e24aa,stroke-width:2px
    style A2 fill:#e1bee7,stroke:#8e24aa,stroke-width:2px
    style A3 fill:#e1bee7,stroke:#8e24aa,stroke-width:2px

    style N1 fill:#c8e6c9,stroke:#388e3c,stroke-width:2px
    style N2 fill:#c8e6c9,stroke:#388e3c,stroke-width:2px
    style N3 fill:#c8e6c9,stroke:#388e3c,stroke-width:2px
```

</details>

---

## 📐 Character Width Rules

### Wide Characters (2 cells)

**CJK Unified Ideographs:**
- Chinese: `中文`, `汉字`
- Japanese: `日本語`, `漢字`
- Korean: `한글`, `조선말`
- Ranges: U+4E00-9FFF, U+3400-4DBF, U+20000-2FFFD

**Emoji:**
- Smileys: `😀😃😄😁😆`
- Symbols: `❤️🔥✨🎉👍`
- Flags: `🇺🇸🇬🇧🇯🇵`
- Ranges: most of U+1F300-1F64F, U+1F680-1F6FF and U+1F900-1FAFF (and others)

**Emoji Sequences:**
- A character with an emoji form, followed by U+FE0F: 2 cells (`⚠️`, `❤️`)
- A wide emoji with a text form, followed by U+FE0E: 1 cell, or 2 with `-AmbiguousAsWide`
- A skin tone after an emoji adds nothing: `👍🏽` is 2 cells
- Emoji joined by U+200D add nothing: `👨‍👩‍👧` is 2 cells

**Other Wide Characters:**
- Filled symbols: `⚫` (U+26AB), `⬛` (U+2B1B)
- Fullwidth Latin: `Ａ` (U+FF21) vs `A` (U+0041)
- Hangul Syllables: U+AC00-D7A3

### Narrow Characters (1 cell)

**ASCII (U+0020-007E):**
- Letters: `a-z A-Z`
- Digits: `0-9`
- Punctuation: `!@#$%^&*()`
- Symbols: `+-=<>[]{}|\/`

**Latin Extended:**
- Accented characters: `àáâãäå èéêë`
- Ranges: U+00C0-024F (except `×` and `÷`, which are ambiguous)

**Common Symbols:**
- Checkmark: `✓` (U+2713)
- Copyright: `©` (U+00A9)
- Pound: `£` (U+00A3)

### Zero-Width Characters (0 cells)

**Combining Diacritical Marks:**
- Acute: ´ (U+0301)
- Grave: ` (U+0300)
- Tilde: ~ (U+0303)
- Range: U+0300-036F

**Zero-Width Joiners:**
- ZWSP: U+200B
- ZWNJ: U+200C
- ZWJ: U+200D

### Ambiguous Width (Configurable)

**Default: 1 cell | With `-AmbiguousAsWide`: 2 cells**

**Box-Drawing (U+2500-254B, U+2550-2574):**
- `╔═╗║╚╝╠╣╦╩╬`
- `─│┌┐└┘├┤┬┴┼`
- `━┃┏┓┗┛┣┫┳┻╋`

**Symbols:**
- `●○◆◇★☆`
- `®™§¶†‡`
- `±×÷≠≤≥`

> [!TIP]
> **When to use `-AmbiguousAsWide`:**
> - Terminal configured for East Asian languages
> - Target audience primarily uses CJK locales
> - Terminal emulator set to "wide ambiguous" mode
>
> **Default (narrow) is recommended for:**
> - Western locales and mixed audiences
> - Maximum cross-platform compatibility
> - Windows Terminal, VS Code, most modern terminals

---

## 🎯 Use Cases

### 1. Text Padding and Alignment

```powershell
# Problem: .PadRight() breaks with Unicode
"Server ✅".PadRight(20)  # Misaligned! ❌

# Solution: Use Measure-DisplayWidth + manual padding
$text = "Server ✅"
$width = Measure-DisplayWidth $text
$padding = " " * (20 - $width)
"$text$padding"  # ✅ Perfect alignment!

# Better: Use AutoPad (does this automatically)
Write-ColorEX "Server ✅" -AutoPad 20  # ✅ Best solution!
```

### 2. Table Column Alignment

```powershell
function Format-TableRow {
    param([string]$Text, [int]$ColumnWidth)

    $displayWidth = Measure-DisplayWidth $Text
    $padding = " " * ($ColumnWidth - $displayWidth)
    return "$Text$padding"
}

Format-TableRow "Server ●" 20  # Returns "Server ●            "
```

### 3. Progress Bars

```powershell
function Show-Progress {
    param([int]$Percent, [int]$BarWidth = 50)

    $filled = [math]::Floor($BarWidth * $Percent / 100)
    $bar = "█" * $filled + "░" * ($BarWidth - $filled)

    # Verify bar width is correct
    $actualWidth = Measure-DisplayWidth $bar
    Write-Host "[$bar] $Percent%"
}

Show-Progress 75  # [█████████████████████████████████████░░░░░░░░░░░░░] 75%
```

### 4. Center Text

```powershell
function Center-Text {
    param([string]$Text, [int]$ConsoleWidth = $Host.UI.RawUI.WindowSize.Width)

    $textWidth = Measure-DisplayWidth $Text
    $leftPadding = [math]::Max(0, [math]::Floor(($ConsoleWidth - $textWidth) / 2))

    (" " * $leftPadding) + $Text
}

Center-Text "═══ Hello 世界 ═══"  # Perfectly centered!
```

### 5. Truncate Text

```powershell
function Truncate-Text {
    param([string]$Text, [int]$MaxWidth)

    $currentWidth = 0
    $result = ""

    foreach ($char in [char[]]$Text) {
        $charWidth = Measure-DisplayWidth $char
        if ($currentWidth + $charWidth -le $MaxWidth) {
            $result += $char
            $currentWidth += $charWidth
        } else {
            break
        }
    }

    return $result
}

Truncate-Text "Hello 世界 World" 10  # Returns "Hello 世界"
```

---

## 🔗 Related Commands

- **[Write-ColorEX](Write-ColorEX.md)** - Uses Measure-DisplayWidth for AutoPad feature
- **[Test-AnsiSupport](Test-AnsiSupport.md)** - Detect terminal capabilities
- **[PSColorStyle Class](PSColorStyle-Class.md)** - Style profiles with AutoPad support

---

## 💡 Performance Notes

- **Single pass algorithm** - O(n) time complexity where n = string length
- **No external dependencies** - Reads widths from a table that ships with the module
- **Used by AutoPad** - Write-ColorEX `-AutoPad` and `-HorizontalCenter` measure the text with it, without `-AmbiguousAsWide`

---

## 🐛 Known Limitations

1. **Terminal Font Matters:** This function calculates the *standard* Unicode width. Some terminals may render characters differently based on font configuration.

2. **Emoji Sequences:** Emoji joined by U+200D (👨‍👩‍👧) and emoji with a skin tone (👍🏽) count as 2 cells, as terminals that support the sequence draw them. A terminal that draws the parts side by side shows them wider.

3. **Terminal Configuration:** Ambiguous width behavior depends on terminal locale settings. Default (narrow) works for 90% of cases.

4. **Right-to-Left (RTL):** Width calculation is correct, but terminal RTL rendering may affect visual alignment.

---

## 📖 Technical Background

This function takes the width of each code point from the table of the Rust crate unicode-width 0.2.2, the same table PWRSWriteColorEX uses. The table is built from the **East Asian Width** property of Unicode Standard Annex #11 (UAX#11) and other parts of the Unicode standard. UAX#11 categorizes characters into:

- **F** (Fullwidth) - 2 cells
- **W** (Wide) - 2 cells
- **A** (Ambiguous) - 1 or 2 cells (configurable via `-AmbiguousAsWide`); letters in this class, such as `é`, are 1 cell
- **N** (Neutral) - 1 cell
- **H** (Halfwidth) - 1 cell
- **Na** (Narrow) - 1 cell

Zero-width characters (combining marks, ZWJ, ZWNJ) and control characters are 0 cells. The string is walked by code point, so Windows PowerShell 5.1 and PowerShell 7 give the same answer.

**References:**
- [UAX #11: East Asian Width](https://www.unicode.org/reports/tr11/)
- [unicode-width 0.2.2](https://docs.rs/unicode-width/0.2.2/unicode_width/)
