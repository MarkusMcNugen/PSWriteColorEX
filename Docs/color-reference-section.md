## 🎨 Color Reference

> **Complete visual guide to all 44 color families with Dark/Normal/Light variants**
>
> Each color shows its **normal appearance** and **bold-lightened version**: the color as `Get-LighterRGBColor` and `Get-LighterANSI8Color` lighten it (for terminals without bold font support)

---

### Basic Color Families (PowerShell Native)

<details open>
<summary>![Red](https://img.shields.io/badge/-Red-FF0000?style=flat-square) <b>Red Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkRed** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B0000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C36666"/></svg> | `#8B0000` → `#C36666` | 52 → 95 | `@(139,0,0)` → `@(195,102,102)` |
| **Red** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF0000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6666"/></svg> | `#FF0000` → `#FF6666` | 1 → 9 | `@(255,0,0)` → `@(255,102,102)` |
| **LightRed** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF5555"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF7777"/></svg> | `#FF5555` → `#FF7777` | 9 → 203 | `@(255,85,85)` → `@(255,119,119)` |

</details>

<details>
<summary>![Green](https://img.shields.io/badge/-Green-00FF00?style=flat-square) <b>Green Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkGreen** | <svg width="25" height="25"><rect width="25" height="25" fill="#006400"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#668C66"/></svg> | `#006400` → `#668C66` | 28 → 71 | `@(0,100,0)` → `@(102,140,102)` |
| **Green** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#00FF00` → `#66FF66` | 2 → 10 | `@(0,255,0)` → `@(102,255,102)` |
| **LightGreen** | <svg width="25" height="25"><rect width="25" height="25" fill="#55FF55"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#77FF77"/></svg> | `#55FF55` → `#77FF77` | 10 → 83 | `@(85,255,85)` → `@(119,255,119)` |

</details>

<details>
<summary>![Blue](https://img.shields.io/badge/-Blue-0000FF?style=flat-square) <b>Blue Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkBlue** | <svg width="25" height="25"><rect width="25" height="25" fill="#00008B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666C3"/></svg> | `#00008B` → `#6666C3` | 19 → 63 | `@(0,0,139)` → `@(102,102,195)` |
| **Blue** | <svg width="25" height="25"><rect width="25" height="25" fill="#0000FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666FF"/></svg> | `#0000FF` → `#6666FF` | 4 → 12 | `@(0,0,255)` → `@(102,102,255)` |
| **LightBlue** | <svg width="25" height="25"><rect width="25" height="25" fill="#5555FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#7777FF"/></svg> | `#5555FF` → `#7777FF` | 12 → 63 | `@(85,85,255)` → `@(119,119,255)` |

</details>

<details>
<summary>![Yellow](https://img.shields.io/badge/-Yellow-FFFF00?style=flat-square&logoColor=black) <b>Yellow Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkYellow** | <svg width="25" height="25"><rect width="25" height="25" fill="#CCCC00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#CCCC00` → `#FFFF66` | 136 → 215 | `@(204,204,0)` → `@(255,255,102)` |
| **Yellow** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFFF00` → `#FFFF66` | 220 → 227 | `@(255,255,0)` → `@(255,255,102)` |
| **LightYellow** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF55"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF77"/></svg> | `#FFFF55` → `#FFFF77` | 11 → 227 | `@(255,255,85)` → `@(255,255,119)` |

</details>

<details>
<summary>![Magenta](https://img.shields.io/badge/-Magenta-FF00FF?style=flat-square) <b>Magenta Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkMagenta** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B008B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C366C3"/></svg> | `#8B008B` → `#C366C3` | 53 → 96 | `@(139,0,139)` → `@(195,102,195)` |
| **Magenta** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF00FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF66FF"/></svg> | `#FF00FF` → `#FF66FF` | 5 → 13 | `@(255,0,255)` → `@(255,102,255)` |
| **LightMagenta** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF55FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF77FF"/></svg> | `#FF55FF` → `#FF77FF` | 13 → 207 | `@(255,85,255)` → `@(255,119,255)` |

</details>

<details>
<summary>![Cyan](https://img.shields.io/badge/-Cyan-00FFFF?style=flat-square&logoColor=black) <b>Cyan Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkCyan** | <svg width="25" height="25"><rect width="25" height="25" fill="#008B8B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66C3C3"/></svg> | `#008B8B` → `#66C3C3` | 30 → 73 | `@(0,139,139)` → `@(102,195,195)` |
| **Cyan** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00FFFF` → `#66FFFF` | 6 → 14 | `@(0,255,255)` → `@(102,255,255)` |
| **LightCyan** | <svg width="25" height="25"><rect width="25" height="25" fill="#55FFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#77FFFF"/></svg> | `#55FFFF` → `#77FFFF` | 14 → 87 | `@(85,255,255)` → `@(119,255,255)` |

</details>

<details>
<summary>![Gray](https://img.shields.io/badge/-Gray-C0C0C0?style=flat-square&logoColor=black) <b>Neutral Family (Black/Gray/White)</b></summary>

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

### Extended Color Families (35 Families)

<details>
<summary>![Amber](https://img.shields.io/badge/-Amber-FFBF00?style=flat-square&logoColor=black) <b>Amber Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkAmber** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE066"/></svg> | `#FFA000` → `#FFE066` | 130 → 209 | `@(255,160,0)` → `@(255,224,102)` |
| **Amber** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFBF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFBF00` → `#FFFF66` | 214 → 227 | `@(255,191,0)` → `@(255,255,102)` |
| **LightAmber** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFCC00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFCC00` → `#FFFF66` | 221 → 228 | `@(255,204,0)` → `@(255,255,102)` |

</details>

<details>
<summary>![Aqua](https://img.shields.io/badge/-Aqua-00FFFF?style=flat-square&logoColor=black) <b>Aqua Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkAqua** | <svg width="25" height="25"><rect width="25" height="25" fill="#008080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66B3B3"/></svg> | `#008080` → `#66B3B3` | 30 → 73 | `@(0,128,128)` → `@(102,179,179)` |
| **Aqua** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00FFFF` → `#66FFFF` | 6 → 14 | `@(0,255,255)` → `@(102,255,255)` |
| **LightAqua** | <svg width="25" height="25"><rect width="25" height="25" fill="#7FFFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B2FFFF"/></svg> | `#7FFFFF` → `#B2FFFF` | 14 → 87 | `@(127,255,255)` → `@(178,255,255)` |

</details>

<details>
<summary>![Brick](https://img.shields.io/badge/-Brick-B22222?style=flat-square) <b>Brick Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkBrick** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B1A1A"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C36666"/></svg> | `#8B1A1A` → `#C36666` | 88 → 131 | `@(139,26,26)` → `@(195,102,102)` |
| **Brick** | <svg width="25" height="25"><rect width="25" height="25" fill="#B22222"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F96666"/></svg> | `#B22222` → `#F96666` | 124 → 203 | `@(178,34,34)` → `@(249,102,102)` |
| **LightBrick** | <svg width="25" height="25"><rect width="25" height="25" fill="#CD5C5C"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF8181"/></svg> | `#CD5C5C` → `#FF8181` | 167 → 210 | `@(205,92,92)` → `@(255,129,129)` |

</details>

<details>
<summary>![Brown](https://img.shields.io/badge/-Brown-964B00?style=flat-square) <b>Brown Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkBrown** | <svg width="25" height="25"><rect width="25" height="25" fill="#654321"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8D6666"/></svg> | `#654321` → `#8D6666` | 88 → 131 | `@(101,67,33)` → `@(141,102,102)` |
| **Brown** | <svg width="25" height="25"><rect width="25" height="25" fill="#964B00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#D26966"/></svg> | `#964B00` → `#D26966` | 130 → 209 | `@(150,75,0)` → `@(210,105,102)` |
| **LightBrown** | <svg width="25" height="25"><rect width="25" height="25" fill="#CD853F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFBA66"/></svg> | `#CD853F` → `#FFBA66` | 173 → 216 | `@(205,133,63)` → `@(255,186,102)` |

</details>

<details>
<summary>![Chartreuse](https://img.shields.io/badge/-Chartreuse-7FFF00?style=flat-square&logoColor=black) <b>Chartreuse Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkChartreuse** | <svg width="25" height="25"><rect width="25" height="25" fill="#458B00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66C366"/></svg> | `#458B00` → `#66C366` | 64 → 107 | `@(69,139,0)` → `@(102,195,102)` |
| **Chartreuse** | <svg width="25" height="25"><rect width="25" height="25" fill="#7FFF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B2FF66"/></svg> | `#7FFF00` → `#B2FF66` | 118 → 155 | `@(127,255,0)` → `@(178,255,102)` |
| **LightChartreuse** | <svg width="25" height="25"><rect width="25" height="25" fill="#BFFF7F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFB2"/></svg> | `#BFFF7F` → `#FFFFB2` | 154 → 227 | `@(191,255,127)` → `@(255,255,178)` |

</details>

<details>
<summary>![Coral](https://img.shields.io/badge/-Coral-FF7F50?style=flat-square&logoColor=black) <b>Coral Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkCoral** | <svg width="25" height="25"><rect width="25" height="25" fill="#CD5B45"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF7F66"/></svg> | `#CD5B45` → `#FF7F66` | 167 → 210 | `@(205,91,69)` → `@(255,127,102)` |
| **Coral** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF7F50"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB270"/></svg> | `#FF7F50` → `#FFB270` | 209 → 216 | `@(255,127,80)` → `@(255,178,112)` |
| **LightCoral** | <svg width="25" height="25"><rect width="25" height="25" fill="#F08080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB3B3"/></svg> | `#F08080` → `#FFB3B3` | 210 → 217 | `@(240,128,128)` → `@(255,179,179)` |

</details>

<details>
<summary>![Crimson](https://img.shields.io/badge/-Crimson-DC143C?style=flat-square) <b>Crimson Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkCrimson** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B0000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C36666"/></svg> | `#8B0000` → `#C36666` | 88 → 131 | `@(139,0,0)` → `@(195,102,102)` |
| **Crimson** | <svg width="25" height="25"><rect width="25" height="25" fill="#DC143C"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6666"/></svg> | `#DC143C` → `#FF6666` | 160 → 203 | `@(220,20,60)` → `@(255,102,102)` |
| **LightCrimson** | <svg width="25" height="25"><rect width="25" height="25" fill="#F83058"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF667B"/></svg> | `#F83058` → `#FF667B` | 161 → 204 | `@(248,48,88)` → `@(255,102,123)` |

</details>

<details>
<summary>![Emerald](https://img.shields.io/badge/-Emerald-50C878?style=flat-square&logoColor=black) <b>Emerald Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkEmerald** | <svg width="25" height="25"><rect width="25" height="25" fill="#006400"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#668C66"/></svg> | `#006400` → `#668C66` | 22 → 65 | `@(0,100,0)` → `@(102,140,102)` |
| **Emerald** | <svg width="25" height="25"><rect width="25" height="25" fill="#50C878"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#70FFA8"/></svg> | `#50C878` → `#70FFA8` | 36 → 85 | `@(80,200,120)` → `@(112,255,168)` |
| **LightEmerald** | <svg width="25" height="25"><rect width="25" height="25" fill="#80FFAA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B3FFEE"/></svg> | `#80FFAA` → `#B3FFEE` | 85 → 123 | `@(128,255,170)` → `@(179,255,238)` |

</details>

<details>
<summary>![Forest](https://img.shields.io/badge/-Forest-228B22?style=flat-square) <b>Forest Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkForest** | <svg width="25" height="25"><rect width="25" height="25" fill="#224B22"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666966"/></svg> | `#224B22` → `#666966` | 22 → 65 | `@(34,75,34)` → `@(102,105,102)` |
| **Forest** | <svg width="25" height="25"><rect width="25" height="25" fill="#228B22"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66C366"/></svg> | `#228B22` → `#66C366` | 28 → 71 | `@(34,139,34)` → `@(102,195,102)` |
| **LightForest** | <svg width="25" height="25"><rect width="25" height="25" fill="#32CD32"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#32CD32` → `#66FF66` | 34 → 83 | `@(50,205,50)` → `@(102,255,102)` |

</details>

<details>
<summary>![Gold](https://img.shields.io/badge/-Gold-FFD700?style=flat-square&logoColor=black) <b>Gold Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkGold** | <svg width="25" height="25"><rect width="25" height="25" fill="#B8860B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFBC66"/></svg> | `#B8860B` → `#FFBC66` | 136 → 215 | `@(184,134,11)` → `@(255,188,102)` |
| **Gold** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFD700"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFD700` → `#FFFF66` | 178 → 227 | `@(255,215,0)` → `@(255,255,102)` |
| **LightGold** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFDF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFDF00` → `#FFFF66` | 185 → 228 | `@(255,223,0)` → `@(255,255,102)` |

</details>

<details>
<summary>![Indigo](https://img.shields.io/badge/-Indigo-4B0082?style=flat-square) <b>Indigo Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkIndigo** | <svg width="25" height="25"><rect width="25" height="25" fill="#191970"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66669D"/></svg> | `#191970` → `#66669D` | 17 → 60 | `@(25,25,112)` → `@(102,102,157)` |
| **Indigo** | <svg width="25" height="25"><rect width="25" height="25" fill="#4B0082"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6966B6"/></svg> | `#4B0082` → `#6966B6` | 54 → 97 | `@(75,0,130)` → `@(105,102,182)` |
| **LightIndigo** | <svg width="25" height="25"><rect width="25" height="25" fill="#666699"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8F8FD6"/></svg> | `#666699` → `#8F8FD6` | 61 → 105 | `@(102,102,153)` → `@(143,143,214)` |

</details>

<details>
<summary>![Jade](https://img.shields.io/badge/-Jade-00A86B?style=flat-square) <b>Jade Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkJade** | <svg width="25" height="25"><rect width="25" height="25" fill="#006432"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#668C66"/></svg> | `#006432` → `#668C66` | 22 → 65 | `@(0,100,50)` → `@(102,140,102)` |
| **Jade** | <svg width="25" height="25"><rect width="25" height="25" fill="#00A86B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66EB96"/></svg> | `#00A86B` → `#66EB96` | 35 → 84 | `@(0,168,107)` → `@(102,235,150)` |
| **LightJade** | <svg width="25" height="25"><rect width="25" height="25" fill="#40D88F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFC8"/></svg> | `#40D88F` → `#66FFC8` | 79 → 123 | `@(64,216,143)` → `@(102,255,200)` |

</details>

<details>
<summary>![Lavender](https://img.shields.io/badge/-Lavender-E6E6FA?style=flat-square&logoColor=black) <b>Lavender Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkLavender** | <svg width="25" height="25"><rect width="25" height="25" fill="#646496"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8C8CD2"/></svg> | `#646496` → `#8C8CD2` | 97 → 141 | `@(100,100,150)` → `@(140,140,210)` |
| **Lavender** | <svg width="25" height="25"><rect width="25" height="25" fill="#E6E6FA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#E6E6FA` → `#FFFFFF` | 183 → 231 | `@(230,230,250)` → `@(255,255,255)` |
| **LightLavender** | <svg width="25" height="25"><rect width="25" height="25" fill="#F0F0FF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#F0F0FF` → `#FFFFFF` | 189 → 231 | `@(240,240,255)` → `@(255,255,255)` |

</details>

<details>
<summary>![Lime](https://img.shields.io/badge/-Lime-00FF00?style=flat-square&logoColor=black) <b>Lime Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkLime** | <svg width="25" height="25"><rect width="25" height="25" fill="#32CD32"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#32CD32` → `#66FF66` | 34 → 83 | `@(50,205,50)` → `@(102,255,102)` |
| **Lime** | <svg width="25" height="25"><rect width="25" height="25" fill="#00FF00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#00FF00` → `#66FF66` | 118 → 155 | `@(0,255,0)` → `@(102,255,102)` |
| **LightLime** | <svg width="25" height="25"><rect width="25" height="25" fill="#32FF32"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FF66"/></svg> | `#32FF32` → `#66FF66` | 119 → 156 | `@(50,255,50)` → `@(102,255,102)` |

</details>

<details>
<summary>![Maroon](https://img.shields.io/badge/-Maroon-800000?style=flat-square) <b>Maroon Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkMaroon** | <svg width="25" height="25"><rect width="25" height="25" fill="#450000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#450000` → `#666666` | 52 → 95 | `@(69,0,0)` → `@(102,102,102)` |
| **Maroon** | <svg width="25" height="25"><rect width="25" height="25" fill="#800000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B36666"/></svg> | `#800000` → `#B36666` | 88 → 131 | `@(128,0,0)` → `@(179,102,102)` |
| **LightMaroon** | <svg width="25" height="25"><rect width="25" height="25" fill="#B03060"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F66686"/></svg> | `#B03060` → `#F66686` | 124 → 203 | `@(176,48,96)` → `@(246,102,134)` |

</details>

<details>
<summary>![Mint](https://img.shields.io/badge/-Mint-98FB98?style=flat-square&logoColor=black) <b>Mint Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkMint** | <svg width="25" height="25"><rect width="25" height="25" fill="#3CB371"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FB9E"/></svg> | `#3CB371` → `#66FB9E` | 29 → 72 | `@(60,179,113)` → `@(102,251,158)` |
| **Mint** | <svg width="25" height="25"><rect width="25" height="25" fill="#98FB98"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#D5FFD5"/></svg> | `#98FB98` → `#D5FFD5` | 121 → 159 | `@(152,251,152)` → `@(213,255,213)` |
| **LightMint** | <svg width="25" height="25"><rect width="25" height="25" fill="#BDFCC9"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#BDFCC9` → `#FFFFFF` | 157 → 231 | `@(189,252,201)` → `@(255,255,255)` |

</details>

<details>
<summary>![Navy](https://img.shields.io/badge/-Navy-000080?style=flat-square) <b>Navy Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkNavy** | <svg width="25" height="25"><rect width="25" height="25" fill="#000050"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666670"/></svg> | `#000050` → `#666670` | 17 → 60 | `@(0,0,80)` → `@(102,102,112)` |
| **Navy** | <svg width="25" height="25"><rect width="25" height="25" fill="#000080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666B3"/></svg> | `#000080` → `#6666B3` | 18 → 61 | `@(0,0,128)` → `@(102,102,179)` |
| **LightNavy** | <svg width="25" height="25"><rect width="25" height="25" fill="#0000CD"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6666FF"/></svg> | `#0000CD` → `#6666FF` | 24 → 67 | `@(0,0,205)` → `@(102,102,255)` |

</details>

<details>
<summary>![Olive](https://img.shields.io/badge/-Olive-808000?style=flat-square&logoColor=black) <b>Olive Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkOlive** | <svg width="25" height="25"><rect width="25" height="25" fill="#556B2F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#779666"/></svg> | `#556B2F` → `#779666` | 58 → 101 | `@(85,107,47)` → `@(119,150,102)` |
| **Olive** | <svg width="25" height="25"><rect width="25" height="25" fill="#808000"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B3B366"/></svg> | `#808000` → `#B3B366` | 100 → 143 | `@(128,128,0)` → `@(179,179,102)` |
| **LightOlive** | <svg width="25" height="25"><rect width="25" height="25" fill="#AAAA00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#EEEE66"/></svg> | `#AAAA00` → `#EEEE66` | 107 → 156 | `@(170,170,0)` → `@(238,238,102)` |

</details>

<details>
<summary>![Orange](https://img.shields.io/badge/-Orange-FFA500?style=flat-square&logoColor=black) <b>Orange Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkOrange** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF8C00"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFC466"/></svg> | `#FF8C00` → `#FFC466` | 166 → 209 | `@(255,140,0)` → `@(255,196,102)` |
| **Orange** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA500"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE766"/></svg> | `#FFA500` → `#FFE766` | 208 → 215 | `@(255,165,0)` → `@(255,231,102)` |
| **LightOrange** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFC300"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFF66"/></svg> | `#FFC300` → `#FFFF66` | 215 → 228 | `@(255,195,0)` → `@(255,255,102)` |

</details>

<details>
<summary>![Peach](https://img.shields.io/badge/-Peach-FFDAB9?style=flat-square&logoColor=black) <b>Peach Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPeach** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA460"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE686"/></svg> | `#FFA460` → `#FFE686` | 172 → 215 | `@(255,164,96)` → `@(255,230,134)` |
| **Peach** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFDAB9"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFDAB9` → `#FFFFFF` | 216 → 229 | `@(255,218,185)` → `@(255,255,255)` |
| **LightPeach** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFEFD5"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFEFD5` → `#FFFFFF` | 223 → 231 | `@(255,239,213)` → `@(255,255,255)` |

</details>

<details>
<summary>![Pink](https://img.shields.io/badge/-Pink-FFC0CB?style=flat-square&logoColor=black) <b>Pink Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPink** | <svg width="25" height="25"><rect width="25" height="25" fill="#C71585"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF66BA"/></svg> | `#C71585` → `#FF66BA` | 163 → 207 | `@(199,21,133)` → `@(255,102,186)` |
| **Pink** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFC0CB"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFC0CB` → `#FFFFFF` | 205 → 213 | `@(255,192,203)` → `@(255,255,255)` |
| **LightPink** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB6C1"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFB6C1` → `#FFFFFF` | 218 → 231 | `@(255,182,193)` → `@(255,255,255)` |

</details>

<details>
<summary>![Plum](https://img.shields.io/badge/-Plum-DDA0DD?style=flat-square&logoColor=black) <b>Plum Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPlum** | <svg width="25" height="25"><rect width="25" height="25" fill="#663399"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8F66D6"/></svg> | `#663399` → `#8F66D6` | 89 → 132 | `@(102,51,153)` → `@(143,102,214)` |
| **Plum** | <svg width="25" height="25"><rect width="25" height="25" fill="#DDA0DD"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE0FF"/></svg> | `#DDA0DD` → `#FFE0FF` | 133 → 213 | `@(221,160,221)` → `@(255,224,255)` |
| **LightPlum** | <svg width="25" height="25"><rect width="25" height="25" fill="#EEAEEE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFF4FF"/></svg> | `#EEAEEE` → `#FFF4FF` | 176 → 219 | `@(238,174,238)` → `@(255,244,255)` |

</details>

<details>
<summary>![Purple](https://img.shields.io/badge/-Purple-800080?style=flat-square) <b>Purple Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkPurple** | <svg width="25" height="25"><rect width="25" height="25" fill="#4B0082"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6966B6"/></svg> | `#4B0082` → `#6966B6` | 54 → 97 | `@(75,0,130)` → `@(105,102,182)` |
| **Purple** | <svg width="25" height="25"><rect width="25" height="25" fill="#800080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B366B3"/></svg> | `#800080` → `#B366B3` | 93 → 135 | `@(128,0,128)` → `@(179,102,179)` |
| **LightPurple** | <svg width="25" height="25"><rect width="25" height="25" fill="#9370DB"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#CE9DFF"/></svg> | `#9370DB` → `#CE9DFF` | 135 → 213 | `@(147,112,219)` → `@(206,157,255)` |

</details>

<details>
<summary>![Rose](https://img.shields.io/badge/-Rose-FF007F?style=flat-square) <b>Rose Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkRose** | <svg width="25" height="25"><rect width="25" height="25" fill="#800040"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#B36666"/></svg> | `#800040` → `#B36666` | 125 → 204 | `@(128,0,64)` → `@(179,102,102)` |
| **Rose** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF007F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF66B2"/></svg> | `#FF007F` → `#FF66B2` | 168 → 211 | `@(255,0,127)` → `@(255,102,178)` |
| **LightRose** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB6C1"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFF"/></svg> | `#FFB6C1` → `#FFFFFF` | 211 → 219 | `@(255,182,193)` → `@(255,255,255)` |

</details>

<details>
<summary>![Ruby](https://img.shields.io/badge/-Ruby-E0115F?style=flat-square) <b>Ruby Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkRuby** | <svg width="25" height="25"><rect width="25" height="25" fill="#9B111E"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#D96666"/></svg> | `#9B111E` → `#D96666` | 52 → 95 | `@(155,17,30)` → `@(217,102,102)` |
| **Ruby** | <svg width="25" height="25"><rect width="25" height="25" fill="#E0115F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6685"/></svg> | `#E0115F` → `#FF6685` | 124 → 203 | `@(224,17,95)` → `@(255,102,133)` |
| **LightRuby** | <svg width="25" height="25"><rect width="25" height="25" fill="#FF6699"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FF8FD6"/></svg> | `#FF6699` → `#FF8FD6` | 161 → 204 | `@(255,102,153)` → `@(255,143,214)` |

</details>

<details>
<summary>![Salmon](https://img.shields.io/badge/-Salmon-FA8072?style=flat-square&logoColor=black) <b>Salmon Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSalmon** | <svg width="25" height="25"><rect width="25" height="25" fill="#E9967A"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFD2AB"/></svg> | `#E9967A` → `#FFD2AB` | 173 → 216 | `@(233,150,122)` → `@(255,210,171)` |
| **Salmon** | <svg width="25" height="25"><rect width="25" height="25" fill="#FA8072"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB3A0"/></svg> | `#FA8072` → `#FFB3A0` | 174 → 217 | `@(250,128,114)` → `@(255,179,160)` |
| **LightSalmon** | <svg width="25" height="25"><rect width="25" height="25" fill="#FFA07A"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE0AB"/></svg> | `#FFA07A` → `#FFE0AB` | 175 → 219 | `@(255,160,122)` → `@(255,224,171)` |

</details>

<details>
<summary>![Sapphire](https://img.shields.io/badge/-Sapphire-0F52BA?style=flat-square) <b>Sapphire Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSapphire** | <svg width="25" height="25"><rect width="25" height="25" fill="#082567"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666690"/></svg> | `#082567` → `#666690` | 18 → 61 | `@(8,37,103)` → `@(102,102,144)` |
| **Sapphire** | <svg width="25" height="25"><rect width="25" height="25" fill="#0F52BA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#6673FF"/></svg> | `#0F52BA` → `#6673FF` | 25 → 69 | `@(15,82,186)` → `@(102,115,255)` |
| **LightSapphire** | <svg width="25" height="25"><rect width="25" height="25" fill="#6495ED"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#8CD1FF"/></svg> | `#6495ED` → `#8CD1FF` | 69 → 111 | `@(100,149,237)` → `@(140,209,255)` |

</details>

<details>
<summary>![Sky](https://img.shields.io/badge/-Sky-87CEEB?style=flat-square&logoColor=black) <b>Sky Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSky** | <svg width="25" height="25"><rect width="25" height="25" fill="#00BFFF"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00BFFF` → `#66FFFF` | 24 → 67 | `@(0,191,255)` → `@(102,255,255)` |
| **Sky** | <svg width="25" height="25"><rect width="25" height="25" fill="#87CEEB"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#BDFFFF"/></svg> | `#87CEEB` → `#BDFFFF` | 111 → 159 | `@(135,206,235)` → `@(189,255,255)` |
| **LightSky** | <svg width="25" height="25"><rect width="25" height="25" fill="#87CEFA"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#BDFFFF"/></svg> | `#87CEFA` → `#BDFFFF` | 152 → 231 | `@(135,206,250)` → `@(189,255,255)` |

</details>

<details>
<summary>![Slate](https://img.shields.io/badge/-Slate-708090?style=flat-square) <b>Slate Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSlate** | <svg width="25" height="25"><rect width="25" height="25" fill="#2F4F4F"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666F6F"/></svg> | `#2F4F4F` → `#666F6F` | 238 → 242 | `@(47,79,79)` → `@(102,111,111)` |
| **Slate** | <svg width="25" height="25"><rect width="25" height="25" fill="#708090"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#9DB3CA"/></svg> | `#708090` → `#9DB3CA` | 102 → 250 | `@(112,128,144)` → `@(157,179,202)` |
| **LightSlate** | <svg width="25" height="25"><rect width="25" height="25" fill="#778899"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#A7BED6"/></svg> | `#778899` → `#A7BED6` | 103 → 147 | `@(119,136,153)` → `@(167,190,214)` |

</details>

<details>
<summary>![Steel](https://img.shields.io/badge/-Steel-71797E?style=flat-square) <b>Steel Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkSteel** | <svg width="25" height="25"><rect width="25" height="25" fill="#464646"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#464646` → `#666666` | 60 → 103 | `@(70,70,70)` → `@(102,102,102)` |
| **Steel** | <svg width="25" height="25"><rect width="25" height="25" fill="#71797E"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#9EA9B0"/></svg> | `#71797E` → `#9EA9B0` | 66 → 109 | `@(113,121,126)` → `@(158,169,176)` |
| **LightSteel** | <svg width="25" height="25"><rect width="25" height="25" fill="#B0C4DE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F6FFFF"/></svg> | `#B0C4DE` → `#F6FFFF` | 146 → 231 | `@(176,196,222)` → `@(246,255,255)` |

</details>

<details>
<summary>![Tan](https://img.shields.io/badge/-Tan-D2B48C?style=flat-square&logoColor=black) <b>Tan Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkTan** | <svg width="25" height="25"><rect width="25" height="25" fill="#8B5A2B"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#C37E66"/></svg> | `#8B5A2B` → `#C37E66` | 94 → 137 | `@(139,90,43)` → `@(195,126,102)` |
| **Tan** | <svg width="25" height="25"><rect width="25" height="25" fill="#D2B48C"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFCC4"/></svg> | `#D2B48C` → `#FFFCC4` | 180 → 229 | `@(210,180,140)` → `@(255,252,196)` |
| **LightTan** | <svg width="25" height="25"><rect width="25" height="25" fill="#F5DEB3"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFFFFB"/></svg> | `#F5DEB3` → `#FFFFFB` | 187 → 231 | `@(245,222,179)` → `@(255,255,251)` |

</details>

<details>
<summary>![Teal](https://img.shields.io/badge/-Teal-009696?style=flat-square) <b>Teal Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkTeal** | <svg width="25" height="25"><rect width="25" height="25" fill="#008080"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66B3B3"/></svg> | `#008080` → `#66B3B3` | 23 → 66 | `@(0,128,128)` → `@(102,179,179)` |
| **Teal** | <svg width="25" height="25"><rect width="25" height="25" fill="#009696"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66D2D2"/></svg> | `#009696` → `#66D2D2` | 30 → 73 | `@(0,150,150)` → `@(102,210,210)` |
| **LightTeal** | <svg width="25" height="25"><rect width="25" height="25" fill="#40E0D0"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#40E0D0` → `#66FFFF` | 80 → 123 | `@(64,224,208)` → `@(102,255,255)` |

</details>

<details>
<summary>![Turquoise](https://img.shields.io/badge/-Turquoise-40E0D0?style=flat-square&logoColor=black) <b>Turquoise Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkTurquoise** | <svg width="25" height="25"><rect width="25" height="25" fill="#00CED1"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#00CED1` → `#66FFFF` | 31 → 75 | `@(0,206,209)` → `@(102,255,255)` |
| **Turquoise** | <svg width="25" height="25"><rect width="25" height="25" fill="#40E0D0"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#66FFFF"/></svg> | `#40E0D0` → `#66FFFF` | 43 → 87 | `@(64,224,208)` → `@(102,255,255)` |
| **LightTurquoise** | <svg width="25" height="25"><rect width="25" height="25" fill="#AFEEEE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#F5FFFF"/></svg> | `#AFEEEE` → `#F5FFFF` | 86 → 123 | `@(175,238,238)` → `@(245,255,255)` |

</details>

<details>
<summary>![Violet](https://img.shields.io/badge/-Violet-EE82EE?style=flat-square) <b>Violet Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkViolet** | <svg width="25" height="25"><rect width="25" height="25" fill="#9400D3"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#CF66FF"/></svg> | `#9400D3` → `#CF66FF` | 128 → 207 | `@(148,0,211)` → `@(207,102,255)` |
| **Violet** | <svg width="25" height="25"><rect width="25" height="25" fill="#EE82EE"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFB6FF"/></svg> | `#EE82EE` → `#FFB6FF` | 134 → 213 | `@(238,130,238)` → `@(255,182,255)` |
| **LightViolet** | <svg width="25" height="25"><rect width="25" height="25" fill="#C8A2C8"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FFE3FF"/></svg> | `#C8A2C8` → `#FFE3FF` | 177 → 219 | `@(200,162,200)` → `@(255,227,255)` |

</details>

<details>
<summary>![Wine](https://img.shields.io/badge/-Wine-722F37?style=flat-square) <b>Wine Family</b></summary>

| Variant | Normal | Bold (Lightened) | Hex | ANSI8 | RGB |
|---------|--------|------------------|-----|-------|-----|
| **DarkWine** | <svg width="25" height="25"><rect width="25" height="25" fill="#480019"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#666666"/></svg> | `#480019` → `#666666` | 52 → 95 | `@(72,0,25)` → `@(102,102,102)` |
| **Wine** | <svg width="25" height="25"><rect width="25" height="25" fill="#722F37"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#A06666"/></svg> | `#722F37` → `#A06666` | 88 → 131 | `@(114,47,55)` → `@(160,102,102)` |
| **LightWine** | <svg width="25" height="25"><rect width="25" height="25" fill="#B36173"/></svg> | <svg width="25" height="25"><rect width="25" height="25" fill="#FB88A1"/></svg> | `#B36173` → `#FB88A1` | 125 → 204 | `@(179,97,115)` → `@(251,136,161)` |

</details>

---

> [!NOTE]
> **Bold-Lightened Colors**: In terminals without bold font support (such as Windows PowerShell 5.1), `-Bold` first takes the next lighter name in the family (DarkRed → Red → LightRed). A color with no lighter name (the `Light*` names and White) is lightened in ANSI8 and TrueColor modes as the Bold (Lightened) column shows: a 1.4x lightening factor with minimum brightness of 102 per channel.
>
> **Super-Lightening**: In ANSI8/TrueColor modes, even `Light*` colors can be lightened beyond their family using algorithmic lightening!
>
> **Color Count**: 44 families and 129 color names: Black has 2 names (Black, LightBlack), White has 1, and each other family has 3.
