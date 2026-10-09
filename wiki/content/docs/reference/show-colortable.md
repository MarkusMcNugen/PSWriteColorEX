---
title: Show-ColorTable
weight: 40
---

Writes the color names with a sample of each in every color mode.

{{< syntax "Show-ColorTable" >}}

## Description

`Show-ColorTable` writes one line for each name in the color table, registered names among them:
the name, a sample of the color in TrueColor, in 256 colors, in 16 colors and as a console color,
then its hex code, its 256-color number and its console color. The names go by family, each
family's Dark, normal and Light variants together. A terminal without a mode shows the nearest
color it has in that mode's column. [Colors and names](colors-and-names.md) shows the same table
on this site.

## Examples

```powershell
PS> Show-ColorTable -Name *Teal, *Coral
Name        TrueColor  256     16      Console  Hex      ANSI8  Console color
DarkCoral   ██████     ██████  ██████  ██████   #CD5B45    167  DarkRed
Coral       ██████     ██████  ██████  ██████   #FF7F50    209  Red
LightCoral  ██████     ██████  ██████  ██████   #F08080    210  Red
DarkTeal    ██████     ██████  ██████  ██████   #008080     23  DarkCyan
Teal        ██████     ██████  ██████  ██████   #009696     30  DarkCyan
LightTeal   ██████     ██████  ██████  ██████   #40E0D0     80  Cyan
```

`-Background` draws each sample as a background behind spaces:

```powershell
PS> Show-ColorTable -Name Amber, Sky -Background
Name   TrueColor  256     16      Console  Hex      ANSI8  Console color
Amber                                      #FFBF00    214  Yellow
Sky                                        #87CEEB    111  Blue
```

## Parameters

{{% parameters "Show-ColorTable" %}}
