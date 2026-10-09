---
title: Share style profiles
weight: 60
---

To use the same styles on another machine, or across a team, save them to a file with
`Export-ColorProfile` and read the file with `Import-ColorProfile`.

## Save styles to a file

`-Name` picks the profiles to save; without it, every profile is saved. Registered color names
are always saved:

```powershell
PS> $null = New-ColorStyle -Name Heading -ForegroundColor Cyan -Bold -Underline -AddToProfiles
PS> $null = New-ColorStyle -Name Muted -ForegroundColor DarkGray -Italic -AddToProfiles
PS> Export-ColorProfile -Path 'team-styles.json' -Name Heading, Muted
PS> Get-Content 'team-styles.json'
{
  "Colors": {},
  "Profiles": [
    {
      "Name": "Heading",
      "ForegroundColor": "Cyan",
      "BackgroundColor": null,
      "Bold": true,
      "Underline": true
    },
    {
      "Name": "Muted",
      "ForegroundColor": "DarkGray",
      "BackgroundColor": null,
      "Italic": true
    }
  ]
}
```

The file is plain JSON. Each profile lists only the settings that differ from a new style's.

## Read styles from a file

`Import-ColorProfile` adds the file's profiles, replacing profiles of the same name, and registers
its color names:

```powershell
PS> $null = New-ColorStyle -Name Heading -ForegroundColor Cyan -Bold -Underline -AddToProfiles
PS> Export-ColorProfile -Path 'team-styles.json' -Name Heading
PS> Remove-ColorProfile -Name Heading
PS> Import-ColorProfile -Path 'team-styles.json'
PS> Write-ColorEX -Text 'Back from the file' -StyleProfile (Get-ColorProfiles -Name Heading)
Back from the file
```

`-PassThru` also writes the profiles it read to the pipeline.

## Share between the two modules

PSWriteColorEX and PWRSWriteColorEX write the same bytes to the file, so either module reads a
file the other wrote. The file is UTF-8 with LF line ends, the same in Windows PowerShell 5.1 and
PowerShell 7, so it can go in a shared folder or a git repository as it is.

## The whole script

```powershell
# On the machine that has the styles
Export-ColorProfile -Path '\\server\share\team-styles.json'

# On each other machine, for example in $PROFILE
Import-ColorProfile -Path '\\server\share\team-styles.json'
```
