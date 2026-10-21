---
title: Show-ColorTable
weight: 40
---

Writes the color names with a sample of each in every color mode, or a view of the text styles,
the 256 colors or the style profiles.

{{< syntax "Show-ColorTable" >}}

## Description

`Show-ColorTable` writes one line for each name in the color table, registered names among them:
the name, a sample of the color in TrueColor, in 256 colors, in 16 colors and as a console color,
then its hex code, its 256-color number and its console color. The names go by family, each
family's Dark, normal and Light variants together. A terminal without a mode shows the nearest
color it has in that mode's column. [Colors and names](colors-and-names.md) shows the same table
on this site.

`-Styles`, `-Palette` and `-Profiles` write a view in place of the names: the text styles, the
256-color chart, or the style profiles.

## Examples

```powershell
PS> Show-ColorTable -Name *Teal, *Coral
Name        TrueColor  256     16      Console  Hex      ANSI8  Console color
DarkCoral   ██████     ██████  ██████  ██████   #CD5B45    167  DarkRed
Coral       ██████     ██████  ██████  ██████   #FF7F50    209  Red
LightCoral  ██████     ██████  ██████  ██████   #F08080    210  Red
DarkTeal    ██████     ██████  ██████  ██████   #008080     30  DarkCyan
Teal        ██████     ██████  ██████  ██████   #009696     30  DarkCyan
LightTeal   ██████     ██████  ██████  ██████   #40E0D0     44  Cyan
```

`-Background` draws each sample as a background behind spaces:

```powershell
PS> Show-ColorTable -Name Amber, Sky -Background
Name   TrueColor  256     16      Console  Hex      ANSI8  Console color
Amber                                      #FFBF00    214  Yellow
Sky                                        #87CEEB    117  Blue
```

`-Styles` writes each text style with a sample in it, the `Write-ColorEX` parameter that gives it,
and the [markup](markup-syntax.md) tags that give it:

```powershell
PS> Show-ColorTable -Styles
Style            Sample       Parameter               Markup
Bold             Sample text  -Bold                   [bold]
Faint            Sample text  -Faint                  [faint] [dim]
Italic           Sample text  -Italic                 [italic]
Underline        Sample text  -Underline              [underline]
DoubleUnderline  Sample text  -DoubleUnderline        [doubleunderline]
Curly            Sample text  -UnderlineStyle Curly   [curly]
Dotted           Sample text  -UnderlineStyle Dotted  [dotted]
Dashed           Sample text  -UnderlineStyle Dashed  [dashed]
Blink            Sample text  -Blink                  [blink]
Reverse          Sample text  -Reverse                [reverse] [invert]
CrossedOut       Sample text  -CrossedOut             [crossedout] [strike]
                                                      [strikethrough]
Overline         Sample text  -Overline               [overline]
```

`-Palette` writes the 256-color chart: the terminal's 16 colors, the 6x6x6 color cube as six
blocks of 6x6, and the 24 grays. Each number is written on its own color, in black or white,
whichever has the higher contrast there; on the 16 colors, which the terminal's scheme sets, the
numbers 0 to 6 and 8 are white and the others black.

```powershell
PS> Show-ColorTable -Palette
  0   1   2   3   4   5   6   7
  8   9  10  11  12  13  14  15

 16  17  18  19  20  21    52  53  54  55  56  57    88  89  90  91  92  93
 22  23  24  25  26  27    58  59  60  61  62  63    94  95  96  97  98  99
 28  29  30  31  32  33    64  65  66  67  68  69   100 101 102 103 104 105
 34  35  36  37  38  39    70  71  72  73  74  75   106 107 108 109 110 111
 40  41  42  43  44  45    76  77  78  79  80  81   112 113 114 115 116 117
 46  47  48  49  50  51    82  83  84  85  86  87   118 119 120 121 122 123

124 125 126 127 128 129   160 161 162 163 164 165   196 197 198 199 200 201
130 131 132 133 134 135   166 167 168 169 170 171   202 203 204 205 206 207
136 137 138 139 140 141   172 173 174 175 176 177   208 209 210 211 212 213
142 143 144 145 146 147   178 179 180 181 182 183   214 215 216 217 218 219
148 149 150 151 152 153   184 185 186 187 188 189   220 221 222 223 224 225
154 155 156 157 158 159   190 191 192 193 194 195   226 227 228 229 230 231

232 233 234 235 236 237 238 239 240 241 242 243
244 245 246 247 248 249 250 251 252 253 254 255
```

`-Profiles` writes each [style profile](style-profiles.md) with a sample in its colors and
styles, then its settings in words, the default style marked. Layout settings such as `AutoPad`
are listed but not applied to the sample, and a color Write-ColorEX does not take, such as `5.5`,
gives Write-ColorEX's error in place of the sample. `-Name` picks profiles, with wildcards:

```powershell
PS> Import-ColorProfile -Theme Nord
PS> Show-ColorTable -Profiles
Profile   Sample       Settings
Critical  Sample text  #2E3440 on #BF616A, Bold, Blink
Debug     Sample text  #81A1C1, Italic
Default   Sample text  #D8DEE9 (the default style)
Error     Sample text  #BF616A, Bold
Info      Sample text  #88C0D0
Success   Sample text  #A3BE8C
Warning   Sample text  #EBCB8B
PS> Show-ColorTable -Profiles -Name Error, Warning
Profile  Sample       Settings
Error    Sample text  #BF616A, Bold
Warning  Sample text  #EBCB8B
```

## Parameters

{{% parameters "Show-ColorTable" %}}
