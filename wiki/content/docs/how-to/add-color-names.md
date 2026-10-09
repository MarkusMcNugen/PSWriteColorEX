---
title: Add color names
weight: 50
---

To use your own colors by name, such as a company's brand colors, register them with
`Register-ColorName`. Every command then takes the name, as it takes the built-in names.

## Register a name

A name holds letters, digits, `-` and `_`, and starts with a letter. The color can be any form
except a bare number:

```powershell
PS> Register-ColorName -Name Brand -Color '#FF6B35'
PS> Register-ColorName -Name BrandDark -Color 'hsl(17, 100%, 35%)'
PS> Write-ColorEX -Text 'Acme ', 'Cloud' -Color BrandDark, Brand -TrueColor
Acme Cloud
PS> Write-ColorEX -Markup '[bold brand]Acme[/] Cloud'
Acme Cloud
```

The name works in `-Color`, `-BackGroundColor`, `-UnderlineColor`, gradients, markup tags,
`-Highlight` styles and style profiles, and tab completion offers it.

## Replace or remove a name

A name already in use is replaced only with `-Force`. `Unregister-ColorName` removes a name, and
gives a built-in name you replaced its own color back:

```powershell
PS> Register-ColorName -Name Red -Color '#FF3B30'
Register-ColorName: The color name 'Red' is in use. Use -Force to replace it.
PS> Register-ColorName -Name Red -Color '#FF3B30' -Force
PS> Unregister-ColorName -Name Red
```

## Keep names for every session

Registered names last until the session ends. `Export-ColorProfile` saves them in a file along
with your style profiles, and `Import-ColorProfile` brings them back. Import the file in your
PowerShell profile:

```powershell
Register-ColorName -Name Brand -Color '#FF6B35'
Export-ColorProfile -Path "$HOME\colors.json"

# In $PROFILE:
Import-ColorProfile -Path "$HOME\colors.json"
```

[Share style profiles](share-style-profiles.md) covers the file.
