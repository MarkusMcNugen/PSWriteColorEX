function Get-ColorHelperParams {
    <#
    .SYNOPSIS
    Returns the Write-ColorEX parameters of a built-in profile, for the Write-Color* helpers.

    .DESCRIPTION
    Reads the profile from [PSColorStyle]::Profiles on each call, so a change to a profile
    applies to the next helper call. A profile that was removed falls back to the colors and
    styles it starts with.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'It returns the parameters of a profile, which the plural names.')]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Error', 'Warning', 'Info', 'Success', 'Critical', 'Debug')]
        [string]$Name
    )

    $style = [PSColorStyle]::Profiles[$Name]
    if (-not $style) {
        switch ($Name) {
            'Error' {
                $style = [PSColorStyle]::new('Error', 'Red', $null)
                $style.Bold = $true
            }
            'Warning' { $style = [PSColorStyle]::new('Warning', 'Yellow', $null) }
            'Info' { $style = [PSColorStyle]::new('Info', 'Cyan', $null) }
            'Success' { $style = [PSColorStyle]::new('Success', 'Green', $null) }
            'Critical' {
                $style = [PSColorStyle]::new('Critical', 'White', 'DarkRed')
                $style.Bold = $true
                $style.Blink = $true
            }
            'Debug' {
                $style = [PSColorStyle]::new('Debug', 'DarkGray', $null)
                $style.Italic = $true
            }
        }
    }
    # A PSColorStyle goes straight to the function its method calls; a subclass keeps its own method
    if ($style.GetType() -eq [PSColorStyle]) { return Get-ColorStyleParameter -Style $style }
    return $style.ToWriteColorParams()
}
