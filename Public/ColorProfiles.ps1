function Export-ColorProfile {
    <#
    .SYNOPSIS
    Saves style profiles and registered color names to a file.

    .DESCRIPTION
    Export-ColorProfile writes the style profiles in [PSColorStyle]::Profiles, or those named,
    and every color name Register-ColorName added, to a JSON file that Import-ColorProfile reads
    back. The file also names the default style when it is one of the profiles saved.

    A profile holds the properties that differ from a new PSColorStyle's, and its colors as
    given. The file is UTF-8 without a byte order mark, with LF line ends, and the same in Windows
    PowerShell 5.1 and PowerShell 7. A file at the path is replaced.

    .PARAMETER Path
    The file to write.

    .PARAMETER Name
    The profiles to save. Wildcards are allowed.

    Default: every profile

    .EXAMPLE
    Export-ColorProfile -Path ~/colors.json

    .EXAMPLE
    Export-ColorProfile -Path ./build-colors.json -Name Build*

    Saves the profiles whose names start with Build.

    .INPUTS
    None

    .OUTPUTS
    None

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Import-ColorProfile
    #>
    [CmdletBinding()]
    [Alias('Export-ColourProfile')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Path,

        [SupportsWildcards()]
        [string[]] $Name = '*'
    )

    # The profiles named, in the order of their names in upper case, ordinal, the same everywhere
    $profileNames = [string[]]@([PSColorStyle]::Profiles.Keys | Where-Object {
        $key = $_
        @($Name | Where-Object { $key -like $_ }).Count -gt 0
    })
    $keys = [string[]]@(foreach ($profileName in $profileNames) { $profileName.ToUpperInvariant() })
    [Array]::Sort($keys, $profileNames, [System.StringComparer]::Ordinal)
    $blank = [PSColorStyle]::new()

    $document = [ordered]@{}
    $colors = [ordered]@{}
    foreach ($colorName in $script:CustomColors.Keys) {
        $rgb = $script:CustomColors[$colorName][4]
        $colors[$colorName] = '#{0:X2}{1:X2}{2:X2}' -f $rgb[0], $rgb[1], $rgb[2]
    }
    $document['Colors'] = $colors

    $default = $null
    $profiles = [System.Collections.Generic.List[object]]::new()
    foreach ($profileName in $profileNames) {
        $style = [PSColorStyle]::Profiles[$profileName]
        if ([object]::ReferenceEquals($style, [PSColorStyle]::Default)) {
            $default = $style.Name
        }
        $entry = [ordered]@{ Name = $style.Name }
        foreach ($property in $script:ColorProfileProperties) {
            $value = $style.$property
            if ($property -eq 'ForegroundColor' -or $property -eq 'BackgroundColor') {
                $entry[$property] = $value
                continue
            }
            $isDefault = if ($value -is [array]) { $value.Count -eq 0 } else { $value -eq $blank.$property }
            if ($null -ne $value -and -not $isDefault) {
                $entry[$property] = if ($value -is [char]) { [string]$value } else { $value }
            }
        }
        $profiles.Add($entry)
    }
    if ($null -ne $default) {
        $document['Default'] = $default
    }
    $document['Profiles'] = $profiles

    $file = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    $text = (ConvertTo-ColorJson -Value $document) + "`n"
    [System.IO.File]::WriteAllText($file, $text, [System.Text.UTF8Encoding]::new($false))
}

function Import-ColorProfile {
    <#
    .SYNOPSIS
    Reads style profiles and color names from a file Export-ColorProfile wrote.

    .DESCRIPTION
    Import-ColorProfile registers the file's color names, replacing names in use, then adds its
    profiles to [PSColorStyle]::Profiles, replacing profiles of the same name, and makes the
    style the file names the default style.

    .PARAMETER Path
    The file to read.

    .PARAMETER PassThru
    Writes the profiles read to the pipeline.

    .EXAMPLE
    Import-ColorProfile -Path ~/colors.json
    Write-ColorEX -Text 'Deploying' -StyleProfile ([PSColorStyle]::Profiles['Build'])

    .EXAMPLE
    # In a PowerShell profile script, so the styles are there in every session
    Import-ColorProfile -Path (Join-Path (Split-Path $PROFILE) 'colors.json')

    .INPUTS
    None

    .OUTPUTS
    None, or PSColorStyle with -PassThru

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Export-ColorProfile
    #>
    [CmdletBinding()]
    [Alias('Import-ColourProfile')]
    [OutputType([PSColorStyle])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Path,

        [switch] $PassThru
    )

    $file = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    try {
        $document = [System.IO.File]::ReadAllText($file) | ConvertFrom-Json -ErrorAction Stop
    } catch {
        $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
            [System.IO.InvalidDataException]::new("Cannot read the profiles in '$Path'. $($_.Exception.Message)"),
            'InvalidProfileFile', [System.Management.Automation.ErrorCategory]::InvalidData, $Path))
    }

    if ($document.Colors) {
        foreach ($property in $document.Colors.PSObject.Properties) {
            Register-ColorName -Name $property.Name -Color (ConvertFrom-ColorJsonValue -Value $property.Value) -Force
        }
    }

    foreach ($entry in @($document.Profiles)) {
        if ($null -eq $entry -or [string]::IsNullOrEmpty($entry.Name)) {
            continue
        }
        $style = [PSColorStyle]::new([string]$entry.Name, $null, $null)
        foreach ($property in $script:ColorProfileProperties) {
            $member = $entry.PSObject.Properties[$property]
            if ($null -ne $member) {
                $style.$property = ConvertFrom-ColorJsonValue -Value $member.Value
            }
        }
        $style.AddToProfiles()
        if ($document.Default -and $document.Default -eq $style.Name) {
            $style.SetAsDefault()
        }
        if ($PassThru) {
            $style
        }
    }
}

function Remove-ColorProfile {
    <#
    .SYNOPSIS
    Removes style profiles from [PSColorStyle]::Profiles.

    .DESCRIPTION
    A removed built-in profile, such as Error, leaves its helper, Write-ColorError, with the
    colors and styles it starts with. A name with no profile gives an error.

    .PARAMETER Name
    The profiles to remove.

    .EXAMPLE
    Remove-ColorProfile -Name Build

    .INPUTS
    System.String[]
    Names piped in are removed.

    .OUTPUTS
    None

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Get-ColorProfiles
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('Remove-ColourProfile')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [string[]] $Name
    )

    process {
        foreach ($item in $Name) {
            if (-not [PSColorStyle]::Profiles.ContainsKey($item)) {
                $PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
                    [System.ArgumentException]::new("No profile named '$item'."),
                    'ProfileNotFound', [System.Management.Automation.ErrorCategory]::ObjectNotFound, $item))
                continue
            }
            if ($PSCmdlet.ShouldProcess($item, 'Remove the style profile')) {
                [PSColorStyle]::Profiles.Remove($item)
            }
        }
    }
}
