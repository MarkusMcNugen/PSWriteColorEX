# 📚 PSWriteColorEX Documentation

> **Complete documentation for the PSWriteColorEX PowerShell module**

This directory contains comprehensive documentation for all functions, classes, and features of the PSWriteColorEX module, organized by public and private components.

---

## 📂 Documentation Structure

Documentation is organized into **Public** and **Private** sections mirroring the module's architecture:

### 📁 Public - User-Facing Components
[**Public/**](Public/) - Functions and classes designed for direct user interaction

### 📁 Private - Internal Components
[**Private/**](Private/) - Internal functions used by the module (typically not called directly)

---

## 📖 Documentation Index

### 🔓 Public Functions & Classes

<details open>
<summary><b>Core Functions</b></summary>

| File | Description |
|------|-------------|
| **[Write-ColorEX.md](Public/Write-ColorEX.md)** | Main function for colored console output with complete parameter reference |

</details>

<details open>
<summary><b>Style Management Functions</b></summary>

| File | Type | Description |
|------|------|-------------|
| **[New-ColorStyle.md](Public/New-ColorStyle.md)** | Wrapper | Create custom style profiles _(wrapper around PSColorStyle class)_ |
| **[Set-ColorDefault.md](Public/Set-ColorDefault.md)** | Wrapper | Configure default style profile _(wrapper around PSColorStyle class)_ |
| **[Get-ColorProfiles.md](Public/Get-ColorProfiles.md)** | Wrapper | Retrieve style profiles _(wrapper around PSColorStyle class)_ |
| **[PSColorStyle-Class.md](Public/PSColorStyle-Class.md)** | Class | PSColorStyle class documentation for advanced style profile management |

</details>

<details open>
<summary><b>Helper Functions</b></summary>

| File | Profile Used | Description |
|------|--------------|-------------|
| **[Write-ColorError.md](Public/Write-ColorError.md)** | Error | Styled error message output (red, bold) |
| **[Write-ColorWarning.md](Public/Write-ColorWarning.md)** | Warning | Styled warning message output (yellow) |
| **[Write-ColorInfo.md](Public/Write-ColorInfo.md)** | Info | Styled informational message output (cyan) |
| **[Write-ColorSuccess.md](Public/Write-ColorSuccess.md)** | Success | Styled success message output (green) |
| **[Write-ColorCritical.md](Public/Write-ColorCritical.md)** | Critical | Styled critical alert output (white on dark red, bold, blink) |
| **[Write-ColorDebug.md](Public/Write-ColorDebug.md)** | Debug | Styled debug message output (dark gray, italic) |

</details>

<details open>
<summary><b>Utility Functions</b></summary>

| File | Description |
|------|-------------|
| **[Test-AnsiSupport.md](Public/Test-AnsiSupport.md)** | Terminal ANSI color support detection and capability testing |
| **[Color-Conversions.md](Public/Color-Conversions.md)** | Color format conversion utilities (Hex→RGB, RGB→ANSI8, RGB→ANSI4) |
| **[Measure-DisplayWidth.md](Public/Measure-DisplayWidth.md)** | Unicode-aware string width calculation for terminal display |

</details>

---

### 🔒 Private Functions

<details>
<summary><b>Internal Utility Functions</b></summary>

| File | Description |
|------|-------------|
| **[New-GradientColorArray.md](Private/New-GradientColorArray.md)** | Internal gradient color generation for smooth color transitions |

> [!NOTE]
> Private functions are typically called internally by the module and are not exposed as public exports. They handle low-level operations like gradient generation.

</details>

---

## 🎯 Quick Start Guide

### Basic Usage

```powershell
# Import the module
Import-Module PSWriteColorEX

# Simple colored output
Write-ColorEX -Text "Hello World" -Color Blue

# Multi-colored text
Write-ColorEX -Text "Status: ", "OK" -Color Gray, Green
```

### TrueColor Support

```powershell
# Hex colors
Write-ColorEX -Text "Orange" -Color "#FF8000" -TrueColor

# RGB arrays
Write-ColorEX -Text "Purple" -Color @(128,0,255) -TrueColor

# Gradients
Write-ColorEX -Text "RAINBOW" -Gradient @('Red','Orange','Yellow','Green','Blue')
```

### Style Profiles

```powershell
# Use built-in helper functions
Write-ColorError "Connection failed"
Write-ColorSuccess "Operation completed"

# Create custom profile (wrapper function)
$brand = New-ColorStyle -Name "Brand" -ForegroundColor "#FF6B35" -Bold
Write-ColorEX -Text "Company Message" -StyleProfile $brand

# Or use PSColorStyle class directly (advanced)
$style = [PSColorStyle]::new("Custom", "Cyan", $null)
$style.Bold = $true
$style.AddToProfiles()
```

---

## 🔍 Finding Information

### By Feature

- **Color Support**: See [Write-ColorEX.md](Public/Write-ColorEX.md#color-support-detection) and [Test-AnsiSupport.md](Public/Test-AnsiSupport.md)
- **Gradients**: See [Write-ColorEX.md](Public/Write-ColorEX.md#gradient-examples) and [New-GradientColorArray.md](Private/New-GradientColorArray.md)
- **Text Styling**: See [Write-ColorEX.md](Public/Write-ColorEX.md#style-parameters)
- **Style Profiles**: See [PSColorStyle-Class.md](Public/PSColorStyle-Class.md) and [New-ColorStyle.md](Public/New-ColorStyle.md)
- **Logging**: See [Write-ColorEX.md](Public/Write-ColorEX.md#logging-parameters)
- **Color Families**: See [Write-ColorEX.md](Public/Write-ColorEX.md#available-colors) and [Color-Conversions.md](Public/Color-Conversions.md#available-color-families)
- **Unicode Width Calculation**: See [Measure-DisplayWidth.md](Public/Measure-DisplayWidth.md)

### By Use Case

| Need to... | See Documentation | Type |
|------------|-------------------|------|
| Output colored text | [Write-ColorEX.md](Public/Write-ColorEX.md) | Public |
| Check terminal capabilities | [Test-AnsiSupport.md](Public/Test-AnsiSupport.md) | Public |
| Display error messages | [Write-ColorError.md](Public/Write-ColorError.md) | Public |
| Create custom styles | [New-ColorStyle.md](Public/New-ColorStyle.md) | Public (Wrapper) |
| Advanced style management | [PSColorStyle-Class.md](Public/PSColorStyle-Class.md) | Public (Class) |
| Convert color formats | [Color-Conversions.md](Public/Color-Conversions.md) | Public |
| Set default styling | [Set-ColorDefault.md](Public/Set-ColorDefault.md) | Public (Wrapper) |
| Get style profiles | [Get-ColorProfiles.md](Public/Get-ColorProfiles.md) | Public (Wrapper) |
| Measure Unicode text width | [Measure-DisplayWidth.md](Public/Measure-DisplayWidth.md) | Public |
| Generate gradients | [New-GradientColorArray.md](Private/New-GradientColorArray.md) | Private |

---

## 📊 Feature Matrix

| Feature | Documentation | Since Version |
|---------|---------------|---------------|
| **TrueColor (24-bit RGB)** | [Write-ColorEX.md](Public/Write-ColorEX.md#truecolor-examples) | v1.0.0 |
| **Gradient Support** | [New-GradientColorArray.md](Private/New-GradientColorArray.md) | v1.0.0 |
| **ANSI 256 Colors** | [Write-ColorEX.md](Public/Write-ColorEX.md#color-mode-switches) | v1.0.0 |
| **Style Profiles** | [PSColorStyle-Class.md](Public/PSColorStyle-Class.md) | v1.0.0 |
| **Hex Color Support** | [Color-Conversions.md](Public/Color-Conversions.md#convert-hextorgb) | v1.0.0 |
| **44 Color Families** | [Write-ColorEX.md](Public/Write-ColorEX.md#available-colors) | v1.0.0 |
| **Cross-platform** | [Test-AnsiSupport.md](Public/Test-AnsiSupport.md#platform-specific-notes) | v1.0.0 |
| **File Logging** | [Write-ColorEX.md](Public/Write-ColorEX.md#logging-parameters) | v1.0.0 |
| **Text Effects** | [Write-ColorEX.md](Public/Write-ColorEX.md#text-effects) | v1.0.0 |
| **Unicode Width Calculation** | [Measure-DisplayWidth.md](Public/Measure-DisplayWidth.md) | v1.0.0 |
| **AutoPad Feature** | [Write-ColorEX.md](Public/Write-ColorEX.md#autopad-parameters) | v1.0.0 |

---

## 🎨 Color Reference

> **Visual guide to all 44 color families with Dark/Normal/Light variants**
>
> Each color shows its **normal appearance** and **bold-lightened version**: the color as `Get-LighterRGBColor` and `Get-LighterANSI8Color` lighten it (for terminals without bold font support)

---

### Basic Color Families (PowerShell Native)

<details open>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FF0000?style=flat-square&labelColor=FF0000" alt="Red" style="vertical-align: middle;"> Red Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkRed** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B0000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C36666"/></svg> | `#8B0000` → `#C36666` | 52 → 95 | `@(139,0,0)` → `@(195,102,102)` |
| **Red** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF0000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6666"/></svg> | `#FF0000` → `#FF6666` | 1 → 9 | `@(255,0,0)` → `@(255,102,102)` |
| **LightRed** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF5555"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF7777"/></svg> | `#FF5555` → `#FF7777` | 9 → 203 | `@(255,85,85)` → `@(255,119,119)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-00FF00?style=flat-square&labelColor=00FF00" alt="Green" style="vertical-align: middle;"> Green Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkGreen** | <svg width="25" height="25"><rect width="25" height="25" fill="#006400"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#668C66"/></svg> | `#006400` → `#668C66` | 28 → 71 | `@(0,100,0)` → `@(102,140,102)` |
| **Green** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#00FF00` → `#66FF66` | 2 → 10 | `@(0,255,0)` → `@(102,255,102)` |
| **LightGreen** | <svg width="25" height="25"><rect width="25" height="25" fill="#55FF55"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#77FF77"/></svg> | `#55FF55` → `#77FF77` | 10 → 83 | `@(85,255,85)` → `@(119,255,119)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-0000FF?style=flat-square&labelColor=0000FF" alt="Blue" style="vertical-align: middle;"> Blue Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkBlue** | <svg width="25" height="25"><rect width="25" height="25" fill="#00008B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666C3"/></svg> | `#00008B` → `#6666C3` | 19 → 63 | `@(0,0,139)` → `@(102,102,195)` |
| **Blue** | <svg width="25" height="25"><rect width="25" height="25" fill="#0000FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666FF"/></svg> | `#0000FF` → `#6666FF` | 4 → 12 | `@(0,0,255)` → `@(102,102,255)` |
| **LightBlue** | <svg width="25" height="25"><rect width="25" height="25" fill="#5555FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#7777FF"/></svg> | `#5555FF` → `#7777FF` | 12 → 63 | `@(85,85,255)` → `@(119,119,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FFFF00?style=flat-square&labelColor=FFFF00" alt="Yellow" style="vertical-align: middle;"> Yellow Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkYellow** | <svg width="25" height="25"><rect width="25" height="25" fill="#CCCC00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#CCCC00` → `#FFFF66` | 136 → 215 | `@(204,204,0)` → `@(255,255,102)` |
| **Yellow** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFFF00` → `#FFFF66` | 220 → 227 | `@(255,255,0)` → `@(255,255,102)` |
| **LightYellow** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF55"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF77"/></svg> | `#FFFF55` → `#FFFF77` | 11 → 227 | `@(255,255,85)` → `@(255,255,119)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FF00FF?style=flat-square&labelColor=FF00FF" alt="Magenta" style="vertical-align: middle;"> Magenta Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkMagenta** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B008B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C366C3"/></svg> | `#8B008B` → `#C366C3` | 53 → 96 | `@(139,0,139)` → `@(195,102,195)` |
| **Magenta** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF00FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF66FF"/></svg> | `#FF00FF` → `#FF66FF` | 5 → 13 | `@(255,0,255)` → `@(255,102,255)` |
| **LightMagenta** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF55FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF77FF"/></svg> | `#FF55FF` → `#FF77FF` | 13 → 207 | `@(255,85,255)` → `@(255,119,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-00FFFF?style=flat-square&labelColor=00FFFF" alt="Cyan" style="vertical-align: middle;"> Cyan Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkCyan** | <svg width="25" height="25"><rect width="25" height="25" fill="#008B8B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66C3C3"/></svg> | `#008B8B` → `#66C3C3` | 30 → 73 | `@(0,139,139)` → `@(102,195,195)` |
| **Cyan** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00FFFF` → `#66FFFF` | 6 → 14 | `@(0,255,255)` → `@(102,255,255)` |
| **LightCyan** | <svg width="25" height="25"><rect width="25" height="25" fill="#55FFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#77FFFF"/></svg> | `#55FFFF` → `#77FFFF` | 14 → 87 | `@(85,255,255)` → `@(119,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-C0C0C0?style=flat-square&labelColor=C0C0C0" alt="Gray" style="vertical-align: middle;"> Neutral Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **Black** | <svg width="25" height="25"><rect width="25" height="25" fill="#000000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#000000` → `#666666` | 0 → 8 | `@(0,0,0)` → `@(102,102,102)` |
| **LightBlack** | <svg width="25" height="25"><rect width="25" height="25" fill="#767676"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#A5A5A5"/></svg> | `#767676` → `#A5A5A5` | 238 → 242 | `@(118,118,118)` → `@(165,165,165)` |
| **DarkGray** | <svg width="25" height="25"><rect width="25" height="25" fill="#808080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B3B3B3"/></svg> | `#808080` → `#B3B3B3` | 8 → 249 | `@(128,128,128)` → `@(179,179,179)` |
| **Gray** | <svg width="25" height="25"><rect width="25" height="25" fill="#C0C0C0"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#C0C0C0` → `#FFFFFF` | 7 → 15 | `@(192,192,192)` → `@(255,255,255)` |
| **LightGray** | <svg width="25" height="25"><rect width="25" height="25" fill="#EEEEEE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#EEEEEE` → `#FFFFFF` | 253 → 255 | `@(238,238,238)` → `@(255,255,255)` |
| **White** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF" stroke="#CCCCCC"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF" stroke="#CCCCCC"/></svg> | `#FFFFFF` → `#FFFFFF` | 15 → 231 | `@(255,255,255)` (max) |

</details>

---

### Extended Color Families

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FFA500?style=flat-square&labelColor=FFA500" alt="Orange" style="vertical-align: middle;"> Orange Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkOrange** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF8C00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFC466"/></svg> | `#FF8C00` → `#FFC466` | 166 → 209 | `@(255,140,0)` → `@(255,196,102)` |
| **Orange** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA500"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE766"/></svg> | `#FFA500` → `#FFE766` | 208 → 215 | `@(255,165,0)` → `@(255,231,102)` |
| **LightOrange** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFC300"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFC300` → `#FFFF66` | 215 → 228 | `@(255,195,0)` → `@(255,255,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-800080?style=flat-square&labelColor=800080" alt="Purple" style="vertical-align: middle;"> Purple Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPurple** | <svg width="25" height="25"><rect width="25" height="25" fill="#4B0082"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6966B6"/></svg> | `#4B0082` → `#6966B6` | 54 → 97 | `@(75,0,130)` → `@(105,102,182)` |
| **Purple** | <svg width="25" height="25"><rect width="25" height="25" fill="#800080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B366B3"/></svg> | `#800080` → `#B366B3` | 93 → 135 | `@(128,0,128)` → `@(179,102,179)` |
| **LightPurple** | <svg width="25" height="25"><rect width="25" height="25" fill="#9370DB"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#CE9DFF"/></svg> | `#9370DB` → `#CE9DFF` | 135 → 213 | `@(147,112,219)` → `@(206,157,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FFC0CB?style=flat-square&labelColor=FFC0CB" alt="Pink" style="vertical-align: middle;"> Pink Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPink** | <svg width="25" height="25"><rect width="25" height="25" fill="#C71585"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF66BA"/></svg> | `#C71585` → `#FF66BA` | 163 → 207 | `@(199,21,133)` → `@(255,102,186)` |
| **Pink** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFC0CB"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFC0CB` → `#FFFFFF` | 205 → 213 | `@(255,192,203)` → `@(255,255,255)` |
| **LightPink** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB6C1"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFB6C1` → `#FFFFFF` | 218 → 231 | `@(255,182,193)` → `@(255,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-964B00?style=flat-square&labelColor=964B00" alt="Brown" style="vertical-align: middle;"> Brown Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkBrown** | <svg width="25" height="25"><rect width="25" height="25" fill="#654321"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8D6666"/></svg> | `#654321` → `#8D6666` | 88 → 131 | `@(101,67,33)` → `@(141,102,102)` |
| **Brown** | <svg width="25" height="25"><rect width="25" height="25" fill="#964B00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#D26966"/></svg> | `#964B00` → `#D26966` | 130 → 209 | `@(150,75,0)` → `@(210,105,102)` |
| **LightBrown** | <svg width="25" height="25"><rect width="25" height="25" fill="#CD853F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFBA66"/></svg> | `#CD853F` → `#FFBA66` | 173 → 216 | `@(205,133,63)` → `@(255,186,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-009696?style=flat-square&labelColor=009696" alt="Teal" style="vertical-align: middle;"> Teal Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkTeal** | <svg width="25" height="25"><rect width="25" height="25" fill="#008080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66B3B3"/></svg> | `#008080` → `#66B3B3` | 23 → 66 | `@(0,128,128)` → `@(102,179,179)` |
| **Teal** | <svg width="25" height="25"><rect width="25" height="25" fill="#009696"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66D2D2"/></svg> | `#009696` → `#66D2D2` | 30 → 73 | `@(0,150,150)` → `@(102,210,210)` |
| **LightTeal** | <svg width="25" height="25"><rect width="25" height="25" fill="#40E0D0"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#40E0D0` → `#66FFFF` | 80 → 123 | `@(64,224,208)` → `@(102,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-EE82EE?style=flat-square&labelColor=EE82EE" alt="Violet" style="vertical-align: middle;"> Violet Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkViolet** | <svg width="25" height="25"><rect width="25" height="25" fill="#9400D3"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#CF66FF"/></svg> | `#9400D3` → `#CF66FF` | 128 → 207 | `@(148,0,211)` → `@(207,102,255)` |
| **Violet** | <svg width="25" height="25"><rect width="25" height="25" fill="#EE82EE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB6FF"/></svg> | `#EE82EE` → `#FFB6FF` | 134 → 213 | `@(238,130,238)` → `@(255,182,255)` |
| **LightViolet** | <svg width="25" height="25"><rect width="25" height="25" fill="#C8A2C8"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE3FF"/></svg> | `#C8A2C8` → `#FFE3FF` | 177 → 219 | `@(200,162,200)` → `@(255,227,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-00FF00?style=flat-square&labelColor=00FF00" alt="Lime" style="vertical-align: middle;"> Lime Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkLime** | <svg width="25" height="25"><rect width="25" height="25" fill="#32CD32"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#32CD32` → `#66FF66` | 34 → 83 | `@(50,205,50)` → `@(102,255,102)` |
| **Lime** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#00FF00` → `#66FF66` | 118 → 155 | `@(0,255,0)` → `@(102,255,102)` |
| **LightLime** | <svg width="25" height="25"><rect width="25" height="25" fill="#32FF32"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#32FF32` → `#66FF66` | 119 → 156 | `@(50,255,50)` → `@(102,255,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-708090?style=flat-square&labelColor=708090" alt="Slate" style="vertical-align: middle;"> Slate Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSlate** | <svg width="25" height="25"><rect width="25" height="25" fill="#2F4F4F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666F6F"/></svg> | `#2F4F4F` → `#666F6F` | 238 → 242 | `@(47,79,79)` → `@(102,111,111)` |
| **Slate** | <svg width="25" height="25"><rect width="25" height="25" fill="#708090"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#9DB3CA"/></svg> | `#708090` → `#9DB3CA` | 102 → 250 | `@(112,128,144)` → `@(157,179,202)` |
| **LightSlate** | <svg width="25" height="25"><rect width="25" height="25" fill="#778899"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#A7BED6"/></svg> | `#778899` → `#A7BED6` | 103 → 147 | `@(119,136,153)` → `@(167,190,214)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FFD700?style=flat-square&labelColor=FFD700" alt="Gold" style="vertical-align: middle;"> Gold Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkGold** | <svg width="25" height="25"><rect width="25" height="25" fill="#B8860B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFBC66"/></svg> | `#B8860B` → `#FFBC66` | 136 → 215 | `@(184,134,11)` → `@(255,188,102)` |
| **Gold** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFD700"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFD700` → `#FFFF66` | 178 → 227 | `@(255,215,0)` → `@(255,255,102)` |
| **LightGold** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFDF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFDF00` → `#FFFF66` | 185 → 228 | `@(255,223,0)` → `@(255,255,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-87CEEB?style=flat-square&labelColor=87CEEB" alt="Sky" style="vertical-align: middle;"> Sky Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSky** | <svg width="25" height="25"><rect width="25" height="25" fill="#00BFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00BFFF` → `#66FFFF` | 24 → 67 | `@(0,191,255)` → `@(102,255,255)` |
| **Sky** | <svg width="25" height="25"><rect width="25" height="25" fill="#87CEEB"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#BDFFFF"/></svg> | `#87CEEB` → `#BDFFFF` | 111 → 159 | `@(135,206,235)` → `@(189,255,255)` |
| **LightSky** | <svg width="25" height="25"><rect width="25" height="25" fill="#87CEFA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#BDFFFF"/></svg> | `#87CEFA` → `#BDFFFF` | 152 → 231 | `@(135,206,250)` → `@(189,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FF7F50?style=flat-square&labelColor=FF7F50" alt="Coral" style="vertical-align: middle;"> Coral Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkCoral** | <svg width="25" height="25"><rect width="25" height="25" fill="#CD5B45"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF7F66"/></svg> | `#CD5B45` → `#FF7F66` | 167 → 210 | `@(205,91,69)` → `@(255,127,102)` |
| **Coral** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF7F50"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB270"/></svg> | `#FF7F50` → `#FFB270` | 209 → 216 | `@(255,127,80)` → `@(255,178,112)` |
| **LightCoral** | <svg width="25" height="25"><rect width="25" height="25" fill="#F08080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB3B3"/></svg> | `#F08080` → `#FFB3B3` | 210 → 217 | `@(240,128,128)` → `@(255,179,179)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-808000?style=flat-square&labelColor=808000" alt="Olive" style="vertical-align: middle;"> Olive Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkOlive** | <svg width="25" height="25"><rect width="25" height="25" fill="#556B2F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#779666"/></svg> | `#556B2F` → `#779666` | 58 → 101 | `@(85,107,47)` → `@(119,150,102)` |
| **Olive** | <svg width="25" height="25"><rect width="25" height="25" fill="#808000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B3B366"/></svg> | `#808000` → `#B3B366` | 100 → 143 | `@(128,128,0)` → `@(179,179,102)` |
| **LightOlive** | <svg width="25" height="25"><rect width="25" height="25" fill="#AAAA00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#EEEE66"/></svg> | `#AAAA00` → `#EEEE66` | 107 → 156 | `@(170,170,0)` → `@(238,238,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-E6E6FA?style=flat-square&labelColor=E6E6FA" alt="Lavender" style="vertical-align: middle;"> Lavender Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkLavender** | <svg width="25" height="25"><rect width="25" height="25" fill="#646496"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8C8CD2"/></svg> | `#646496` → `#8C8CD2` | 97 → 141 | `@(100,100,150)` → `@(140,140,210)` |
| **Lavender** | <svg width="25" height="25"><rect width="25" height="25" fill="#E6E6FA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#E6E6FA` → `#FFFFFF` | 183 → 231 | `@(230,230,250)` → `@(255,255,255)` |
| **LightLavender** | <svg width="25" height="25"><rect width="25" height="25" fill="#F0F0FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#F0F0FF` → `#FFFFFF` | 189 → 231 | `@(240,240,255)` → `@(255,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-98FB98?style=flat-square&labelColor=98FB98" alt="Mint" style="vertical-align: middle;"> Mint Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkMint** | <svg width="25" height="25"><rect width="25" height="25" fill="#3CB371"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FB9E"/></svg> | `#3CB371` → `#66FB9E` | 29 → 72 | `@(60,179,113)` → `@(102,251,158)` |
| **Mint** | <svg width="25" height="25"><rect width="25" height="25" fill="#98FB98"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#D5FFD5"/></svg> | `#98FB98` → `#D5FFD5` | 121 → 159 | `@(152,251,152)` → `@(213,255,213)` |
| **LightMint** | <svg width="25" height="25"><rect width="25" height="25" fill="#BDFCC9"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#BDFCC9` → `#FFFFFF` | 157 → 231 | `@(189,252,201)` → `@(255,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FA8072?style=flat-square&labelColor=FA8072" alt="Salmon" style="vertical-align: middle;"> Salmon Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSalmon** | <svg width="25" height="25"><rect width="25" height="25" fill="#E9967A"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFD2AB"/></svg> | `#E9967A` → `#FFD2AB` | 173 → 216 | `@(233,150,122)` → `@(255,210,171)` |
| **Salmon** | <svg width="25" height="25"><rect width="25" height="25" fill="#FA8072"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB3A0"/></svg> | `#FA8072` → `#FFB3A0` | 174 → 217 | `@(250,128,114)` → `@(255,179,160)` |
| **LightSalmon** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA07A"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE0AB"/></svg> | `#FFA07A` → `#FFE0AB` | 175 → 219 | `@(255,160,122)` → `@(255,224,171)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-4B0082?style=flat-square&labelColor=4B0082" alt="Indigo" style="vertical-align: middle;"> Indigo Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkIndigo** | <svg width="25" height="25"><rect width="25" height="25" fill="#191970"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66669D"/></svg> | `#191970` → `#66669D` | 17 → 60 | `@(25,25,112)` → `@(102,102,157)` |
| **Indigo** | <svg width="25" height="25"><rect width="25" height="25" fill="#4B0082"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6966B6"/></svg> | `#4B0082` → `#6966B6` | 54 → 97 | `@(75,0,130)` → `@(105,102,182)` |
| **LightIndigo** | <svg width="25" height="25"><rect width="25" height="25" fill="#666699"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8F8FD6"/></svg> | `#666699` → `#8F8FD6` | 61 → 105 | `@(102,102,153)` → `@(143,143,214)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-40E0D0?style=flat-square&labelColor=40E0D0" alt="Turquoise" style="vertical-align: middle;"> Turquoise Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkTurquoise** | <svg width="25" height="25"><rect width="25" height="25" fill="#00CED1"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00CED1` → `#66FFFF` | 31 → 75 | `@(0,206,209)` → `@(102,255,255)` |
| **Turquoise** | <svg width="25" height="25"><rect width="25" height="25" fill="#40E0D0"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#40E0D0` → `#66FFFF` | 43 → 87 | `@(64,224,208)` → `@(102,255,255)` |
| **LightTurquoise** | <svg width="25" height="25"><rect width="25" height="25" fill="#AFEEEE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F5FFFF"/></svg> | `#AFEEEE` → `#F5FFFF` | 86 → 123 | `@(175,238,238)` → `@(245,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-E0115F?style=flat-square&labelColor=E0115F" alt="Ruby" style="vertical-align: middle;"> Ruby Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkRuby** | <svg width="25" height="25"><rect width="25" height="25" fill="#9B111E"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#D96666"/></svg> | `#9B111E` → `#D96666` | 52 → 95 | `@(155,17,30)` → `@(217,102,102)` |
| **Ruby** | <svg width="25" height="25"><rect width="25" height="25" fill="#E0115F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6685"/></svg> | `#E0115F` → `#FF6685` | 124 → 203 | `@(224,17,95)` → `@(255,102,133)` |
| **LightRuby** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6699"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF8FD6"/></svg> | `#FF6699` → `#FF8FD6` | 161 → 204 | `@(255,102,153)` → `@(255,143,214)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-00A86B?style=flat-square&labelColor=00A86B" alt="Jade" style="vertical-align: middle;"> Jade Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkJade** | <svg width="25" height="25"><rect width="25" height="25" fill="#006432"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#668C66"/></svg> | `#006432` → `#668C66` | 22 → 65 | `@(0,100,50)` → `@(102,140,102)` |
| **Jade** | <svg width="25" height="25"><rect width="25" height="25" fill="#00A86B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66EB96"/></svg> | `#00A86B` → `#66EB96` | 35 → 84 | `@(0,168,107)` → `@(102,235,150)` |
| **LightJade** | <svg width="25" height="25"><rect width="25" height="25" fill="#40D88F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFC8"/></svg> | `#40D88F` → `#66FFC8` | 79 → 123 | `@(64,216,143)` → `@(102,255,200)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FFBF00?style=flat-square&labelColor=FFBF00" alt="Amber" style="vertical-align: middle;"> Amber Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkAmber** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE066"/></svg> | `#FFA000` → `#FFE066` | 130 → 209 | `@(255,160,0)` → `@(255,224,102)` |
| **Amber** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFBF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFBF00` → `#FFFF66` | 214 → 227 | `@(255,191,0)` → `@(255,255,102)` |
| **LightAmber** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFCC00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFCC00` → `#FFFF66` | 221 → 228 | `@(255,204,0)` → `@(255,255,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-71797E?style=flat-square&labelColor=71797E" alt="Steel" style="vertical-align: middle;"> Steel Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSteel** | <svg width="25" height="25"><rect width="25" height="25" fill="#464646"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#464646` → `#666666` | 60 → 103 | `@(70,70,70)` → `@(102,102,102)` |
| **Steel** | <svg width="25" height="25"><rect width="25" height="25" fill="#71797E"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#9EA9B0"/></svg> | `#71797E` → `#9EA9B0` | 66 → 109 | `@(113,121,126)` → `@(158,169,176)` |
| **LightSteel** | <svg width="25" height="25"><rect width="25" height="25" fill="#B0C4DE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F6FFFF"/></svg> | `#B0C4DE` → `#F6FFFF` | 146 → 231 | `@(176,196,222)` → `@(246,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-DC143C?style=flat-square&labelColor=DC143C" alt="Crimson" style="vertical-align: middle;"> Crimson Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkCrimson** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B0000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C36666"/></svg> | `#8B0000` → `#C36666` | 88 → 131 | `@(139,0,0)` → `@(195,102,102)` |
| **Crimson** | <svg width="25" height="25"><rect width="25" height="25" fill="#DC143C"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6666"/></svg> | `#DC143C` → `#FF6666` | 160 → 203 | `@(220,20,60)` → `@(255,102,102)` |
| **LightCrimson** | <svg width="25" height="25"><rect width="25" height="25" fill="#F83058"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF667B"/></svg> | `#F83058` → `#FF667B` | 161 → 204 | `@(248,48,88)` → `@(255,102,123)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-50C878?style=flat-square&labelColor=50C878" alt="Emerald" style="vertical-align: middle;"> Emerald Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkEmerald** | <svg width="25" height="25"><rect width="25" height="25" fill="#006400"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#668C66"/></svg> | `#006400` → `#668C66` | 22 → 65 | `@(0,100,0)` → `@(102,140,102)` |
| **Emerald** | <svg width="25" height="25"><rect width="25" height="25" fill="#50C878"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#70FFA8"/></svg> | `#50C878` → `#70FFA8` | 36 → 85 | `@(80,200,120)` → `@(112,255,168)` |
| **LightEmerald** | <svg width="25" height="25"><rect width="25" height="25" fill="#80FFAA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B3FFEE"/></svg> | `#80FFAA` → `#B3FFEE` | 85 → 123 | `@(128,255,170)` → `@(179,255,238)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-0F52BA?style=flat-square&labelColor=0F52BA" alt="Sapphire" style="vertical-align: middle;"> Sapphire Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSapphire** | <svg width="25" height="25"><rect width="25" height="25" fill="#082567"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666690"/></svg> | `#082567` → `#666690` | 18 → 61 | `@(8,37,103)` → `@(102,102,144)` |
| **Sapphire** | <svg width="25" height="25"><rect width="25" height="25" fill="#0F52BA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6673FF"/></svg> | `#0F52BA` → `#6673FF` | 25 → 69 | `@(15,82,186)` → `@(102,115,255)` |
| **LightSapphire** | <svg width="25" height="25"><rect width="25" height="25" fill="#6495ED"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8CD1FF"/></svg> | `#6495ED` → `#8CD1FF` | 69 → 111 | `@(100,149,237)` → `@(140,209,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-722F37?style=flat-square&labelColor=722F37" alt="Wine" style="vertical-align: middle;"> Wine Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkWine** | <svg width="25" height="25"><rect width="25" height="25" fill="#480019"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#480019` → `#666666` | 52 → 95 | `@(72,0,25)` → `@(102,102,102)` |
| **Wine** | <svg width="25" height="25"><rect width="25" height="25" fill="#722F37"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#A06666"/></svg> | `#722F37` → `#A06666` | 88 → 131 | `@(114,47,55)` → `@(160,102,102)` |
| **LightWine** | <svg width="25" height="25"><rect width="25" height="25" fill="#B36173"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FB88A1"/></svg> | `#B36173` → `#FB88A1` | 125 → 204 | `@(179,97,115)` → `@(251,136,161)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FFDAB9?style=flat-square&labelColor=FFDAB9" alt="Peach" style="vertical-align: middle;"> Peach Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPeach** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA460"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE686"/></svg> | `#FFA460` → `#FFE686` | 172 → 215 | `@(255,164,96)` → `@(255,230,134)` |
| **Peach** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFDAB9"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFDAB9` → `#FFFFFF` | 216 → 229 | `@(255,218,185)` → `@(255,255,255)` |
| **LightPeach** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFEFD5"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFEFD5` → `#FFFFFF` | 223 → 231 | `@(255,239,213)` → `@(255,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-000080?style=flat-square&labelColor=000080" alt="Navy" style="vertical-align: middle;"> Navy Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkNavy** | <svg width="25" height="25"><rect width="25" height="25" fill="#000050"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666670"/></svg> | `#000050` → `#666670` | 17 → 60 | `@(0,0,80)` → `@(102,102,112)` |
| **Navy** | <svg width="25" height="25"><rect width="25" height="25" fill="#000080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666B3"/></svg> | `#000080` → `#6666B3` | 18 → 61 | `@(0,0,128)` → `@(102,102,179)` |
| **LightNavy** | <svg width="25" height="25"><rect width="25" height="25" fill="#0000CD"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666FF"/></svg> | `#0000CD` → `#6666FF` | 24 → 67 | `@(0,0,205)` → `@(102,102,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-228B22?style=flat-square&labelColor=228B22" alt="Forest" style="vertical-align: middle;"> Forest Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkForest** | <svg width="25" height="25"><rect width="25" height="25" fill="#224B22"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666966"/></svg> | `#224B22` → `#666966` | 22 → 65 | `@(34,75,34)` → `@(102,105,102)` |
| **Forest** | <svg width="25" height="25"><rect width="25" height="25" fill="#228B22"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66C366"/></svg> | `#228B22` → `#66C366` | 28 → 71 | `@(34,139,34)` → `@(102,195,102)` |
| **LightForest** | <svg width="25" height="25"><rect width="25" height="25" fill="#32CD32"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#32CD32` → `#66FF66` | 34 → 83 | `@(50,205,50)` → `@(102,255,102)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-FF007F?style=flat-square&labelColor=FF007F" alt="Rose" style="vertical-align: middle;"> Rose Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkRose** | <svg width="25" height="25"><rect width="25" height="25" fill="#800040"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B36666"/></svg> | `#800040` → `#B36666` | 125 → 204 | `@(128,0,64)` → `@(179,102,102)` |
| **Rose** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF007F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF66B2"/></svg> | `#FF007F` → `#FF66B2` | 168 → 211 | `@(255,0,127)` → `@(255,102,178)` |
| **LightRose** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB6C1"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFB6C1` → `#FFFFFF` | 211 → 219 | `@(255,182,193)` → `@(255,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-DDA0DD?style=flat-square&labelColor=DDA0DD" alt="Plum" style="vertical-align: middle;"> Plum Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPlum** | <svg width="25" height="25"><rect width="25" height="25" fill="#663399"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8F66D6"/></svg> | `#663399` → `#8F66D6` | 89 → 132 | `@(102,51,153)` → `@(143,102,214)` |
| **Plum** | <svg width="25" height="25"><rect width="25" height="25" fill="#DDA0DD"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE0FF"/></svg> | `#DDA0DD` → `#FFE0FF` | 133 → 213 | `@(221,160,221)` → `@(255,224,255)` |
| **LightPlum** | <svg width="25" height="25"><rect width="25" height="25" fill="#EEAEEE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFF4FF"/></svg> | `#EEAEEE` → `#FFF4FF` | 176 → 219 | `@(238,174,238)` → `@(255,244,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-D2B48C?style=flat-square&labelColor=D2B48C" alt="Tan" style="vertical-align: middle;"> Tan Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkTan** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B5A2B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C37E66"/></svg> | `#8B5A2B` → `#C37E66` | 94 → 137 | `@(139,90,43)` → `@(195,126,102)` |
| **Tan** | <svg width="25" height="25"><rect width="25" height="25" fill="#D2B48C"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFCC4"/></svg> | `#D2B48C` → `#FFFCC4` | 180 → 229 | `@(210,180,140)` → `@(255,252,196)` |
| **LightTan** | <svg width="25" height="25"><rect width="25" height="25" fill="#F5DEB3"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFB"/></svg> | `#F5DEB3` → `#FFFFFB` | 187 → 231 | `@(245,222,179)` → `@(255,255,251)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-800000?style=flat-square&labelColor=800000" alt="Maroon" style="vertical-align: middle;"> Maroon Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkMaroon** | <svg width="25" height="25"><rect width="25" height="25" fill="#450000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#450000` → `#666666` | 52 → 95 | `@(69,0,0)` → `@(102,102,102)` |
| **Maroon** | <svg width="25" height="25"><rect width="25" height="25" fill="#800000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B36666"/></svg> | `#800000` → `#B36666` | 88 → 131 | `@(128,0,0)` → `@(179,102,102)` |
| **LightMaroon** | <svg width="25" height="25"><rect width="25" height="25" fill="#B03060"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F66686"/></svg> | `#B03060` → `#F66686` | 124 → 203 | `@(176,48,96)` → `@(246,102,134)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-00FFFF?style=flat-square&labelColor=00FFFF" alt="Aqua" style="vertical-align: middle;"> Aqua Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkAqua** | <svg width="25" height="25"><rect width="25" height="25" fill="#008080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66B3B3"/></svg> | `#008080` → `#66B3B3` | 30 → 73 | `@(0,128,128)` → `@(102,179,179)` |
| **Aqua** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00FFFF` → `#66FFFF` | 6 → 14 | `@(0,255,255)` → `@(102,255,255)` |
| **LightAqua** | <svg width="25" height="25"><rect width="25" height="25" fill="#7FFFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B2FFFF"/></svg> | `#7FFFFF` → `#B2FFFF` | 14 → 87 | `@(127,255,255)` → `@(178,255,255)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-7FFF00?style=flat-square&labelColor=7FFF00" alt="Chartreuse" style="vertical-align: middle;"> Chartreuse Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkChartreuse** | <svg width="25" height="25"><rect width="25" height="25" fill="#458B00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66C366"/></svg> | `#458B00` → `#66C366` | 64 → 107 | `@(69,139,0)` → `@(102,195,102)` |
| **Chartreuse** | <svg width="25" height="25"><rect width="25" height="25" fill="#7FFF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B2FF66"/></svg> | `#7FFF00` → `#B2FF66` | 118 → 155 | `@(127,255,0)` → `@(178,255,102)` |
| **LightChartreuse** | <svg width="25" height="25"><rect width="25" height="25" fill="#BFFF7F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFB2"/></svg> | `#BFFF7F` → `#FFFFB2` | 154 → 227 | `@(191,255,127)` → `@(255,255,178)` |

</details>

<details>
<summary><b><img src="https://img.shields.io/badge/%20-%20-B22222?style=flat-square&labelColor=B22222" alt="Brick" style="vertical-align: middle;"> Brick Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkBrick** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B1A1A"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C36666"/></svg> | `#8B1A1A` → `#C36666` | 88 → 131 | `@(139,26,26)` → `@(195,102,102)` |
| **Brick** | <svg width="25" height="25"><rect width="25" height="25" fill="#B22222"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F96666"/></svg> | `#B22222` → `#F96666` | 124 → 203 | `@(178,34,34)` → `@(249,102,102)` |
| **LightBrick** | <svg width="25" height="25"><rect width="25" height="25" fill="#CD5C5C"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF8181"/></svg> | `#CD5C5C` → `#FF8181` | 167 → 210 | `@(205,92,92)` → `@(255,129,129)` |

</details>

> [!NOTE]
> **Bold-Lightened Colors**: In terminals without bold font support (such as Windows PowerShell 5.1), `-Bold` first takes the next lighter name in the family (DarkRed → Red → LightRed). A color with no lighter name (the `Light*` names and White) is lightened in ANSI8 and TrueColor modes as the Bold (Lightened) column shows: a 1.4x lightening factor with minimum brightness of 102 per channel.
>
> **Super-Lightening**: In ANSI8/TrueColor modes, even `Light*` colors can be lightened beyond their family using algorithmic lightening!

---

## 💻 Platform Support

| Platform | Max Colors | Documentation |
|----------|------------|---------------|
| **Windows Terminal** | TrueColor | [Test-AnsiSupport.md](Public/Test-AnsiSupport.md#windows) |
| **PowerShell 7+** | TrueColor | [Test-AnsiSupport.md](Public/Test-AnsiSupport.md#windows) |
| **Linux Terminals** | TrueColor | [Test-AnsiSupport.md](Public/Test-AnsiSupport.md#linuxmacos) |
| **macOS iTerm2** | TrueColor | [Test-AnsiSupport.md](Public/Test-AnsiSupport.md#macos) |
| **VS Code Terminal** | TrueColor | All platforms |
| **PowerShell ISE** | 16 Native | [Write-ColorEX.md](Public/Write-ColorEX.md#platform-compatibility) |

---

## 🏗️ Architecture Guide

### Understanding Public vs Private

**Public Components** are designed for direct use:
- User-facing functions with full documentation
- Helper functions for common tasks
- Wrapper functions providing simplified interfaces
- Classes for advanced customization

**Private Components** are internal utilities:
- Called automatically by public functions
- Not exported by the module, so not called directly
- Handle low-level operations like gradient generation
- Provide foundational functionality

### Wrapper Functions

The module provides **wrapper functions** that simplify interaction with the underlying PSColorStyle class:

| Wrapper Function | Wraps | Purpose |
|------------------|-------|---------|
| `New-ColorStyle` | PSColorStyle class | Simplified style creation |
| `Set-ColorDefault` | PSColorStyle::Default | Simplified default management |
| `Get-ColorProfiles` | PSColorStyle::Profiles | Simplified profile retrieval |

**When to use wrappers vs class:**
- ✅ **Use wrappers** for typical scenarios and cleaner PowerShell-idiomatic code
- ✅ **Use class directly** for advanced scenarios requiring fine-grained control

### Exported vs Internal Functions

The module clearly distinguishes between **exported (public)** and **internal (private)** functions:

**Exported Functions** (available after `Import-Module`):
- All public functions in [Public/](Public/) folder
- Includes utility functions like `Test-AnsiSupport`, `Measure-DisplayWidth`, and color conversion functions
- Helper functions for common messaging patterns
- Style management wrapper functions

**Internal Functions** (not exported):
- Functions in [Private/](Private/) folder
- Used internally by the module but not exposed to users
- Example: `New-GradientColorArray` (called by Write-ColorEX when `-Gradient` is used)

---

## 📝 Documentation Standards

All documentation in this folder follows these standards:

- **GitHub Flavored Markdown** with modern features
- **Alert blocks** for important information (NOTE, TIP, IMPORTANT, WARNING, CAUTION)
- **Code examples** for all major features
- **Tables** for parameter references
- **Cross-references** between related documents
- **Emoji indicators** for visual navigation
- **Mermaid diagrams** for complex workflows

---

## 🔗 Additional Resources

- **[Module README](../README.md)** - Module overview and installation
- **[Examples](../Examples/)** - Sample scripts and use cases
- **[Tests](../Tests/)** - Pester test files
- **[PowerShell Gallery](https://www.powershellgallery.com/packages/PSWriteColorEX)** - Official module page
- **[GitHub Repository](https://github.com/MarkusMcNugen/PSWriteColorEX)** - Source code and issues

---

## 📄 License

This documentation is part of PSWriteColorEX, released under the MIT License.

---

<div align="center">

**PSWriteColorEX Documentation** | Version 1.1.0 | [GitHub](https://github.com/MarkusMcNugen/PSWriteColorEX)

</div>
