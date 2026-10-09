function Register-ColorName {
    <#
    .SYNOPSIS
    Adds a color name to the color table, for every command of the module.

    .DESCRIPTION
    Register-ColorName names a color, so -Color, -BackGroundColor, -UnderlineColor, the
    gradients, markup tags and -Highlight styles take the name as they take the built-in names.
    The name keeps the color in every color mode: the 256-color and 16-color codes and the console
    color nearest it.

    A name holds letters, digits, '-' and '_', starting with a letter. It cannot be None, on, or a
    style name markup reads, such as bold. A name in use, built-in or registered, is replaced only
    with -Force; Unregister-ColorName brings a replaced built-in name back.

    The names last for the session. Export-ColorProfile saves them with the style profiles, and
    Import-ColorProfile registers them again.

    .PARAMETER Name
    The name for the color.

    .PARAMETER Color
    The color: a hex code ('#FF8000', '#F80'), 'rgb(255, 128, 0)', 'hsl(30, 100%, 50%)', an RGB
    array @(255, 128, 0), or a name already in the color table.

    .PARAMETER Force
    Replaces a name that is in use.

    .EXAMPLE
    Register-ColorName -Name Brand -Color '#FF6B35'
    Write-ColorEX -Text 'Acme' -Color Brand -Bold

    Names a brand color and writes with it.

    .EXAMPLE
    Register-ColorName Orange 'hsl(30, 100%, 50%)' -Force

    Replaces the built-in Orange for the session.

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
    Unregister-ColorName

    .LINK
    Show-ColorTable
    #>
    [CmdletBinding()]
    [Alias('Register-ColourName')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory, Position = 1)]
        [object] $Color,

        [switch] $Force
    )

    if ($Name -notmatch '^[A-Za-z][A-Za-z0-9_-]*$' -or $Name -eq 'None' -or $Name -eq 'on' -or
        $script:MarkupStyleNames.ContainsKey($Name.ToLowerInvariant())) {
        $PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
            [System.ArgumentException]::new("'$Name' cannot be a color name. A name holds letters, digits, '-' and '_', starts with a letter, and is not None, on or a style name."),
            'InvalidColorName', [System.Management.Automation.ErrorCategory]::InvalidArgument, $Name))
        return
    }

    $table = Get-ColorTableWithRGB
    if ($table.ContainsKey($Name) -and -not $Force) {
        $PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
            [System.ArgumentException]::new("The color name '$Name' is in use. Use -Force to replace it."),
            'ColorNameInUse', [System.Management.Automation.ErrorCategory]::ResourceExists, $Name))
        return
    }

    $rgb = Get-ColorRegisterRgb -Value $Color -Table $table
    if ($null -eq $rgb) {
        $shown = if ($Color -is [array]) { "@($($Color -join ', '))" } else { "$Color" }
        $PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
            [System.ArgumentException]::new("'$shown' is not a color. A color is a hex code, rgb(), hsl(), an RGB array of three numbers 0-255, or a name in the color table."),
            'InvalidColor', [System.Management.Automation.ErrorCategory]::InvalidArgument, $Color))
        return
    }

    $ansi4 = Convert-RGBToANSI4 -RGB $rgb
    $script:CustomColors[$Name] = @((ConvertANSI4ToNativeColor -Code $ansi4), $ansi4, ($ansi4 + 10), (Convert-RGBToANSI8 -RGB $rgb), $rgb)
    $script:CachedColorTable = $null
}

function Unregister-ColorName {
    <#
    .SYNOPSIS
    Removes color names Register-ColorName added.

    .DESCRIPTION
    A built-in name that Register-ColorName replaced takes its built-in color again. A name that
    was not registered gives an error.

    .PARAMETER Name
    The names to remove.

    .EXAMPLE
    Unregister-ColorName -Name Brand

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
    Register-ColorName
    #>
    [CmdletBinding()]
    [Alias('Unregister-ColourName')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [string[]] $Name
    )

    process {
        foreach ($item in $Name) {
            if (-not $script:CustomColors.Contains($item)) {
                $PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
                    [System.ArgumentException]::new("No color name '$item' was registered."),
                    'ColorNameNotRegistered', [System.Management.Automation.ErrorCategory]::ObjectNotFound, $item))
                continue
            }
            $script:CustomColors.Remove($item)
            $script:CachedColorTable = $null
        }
    }
}

function Show-ColorTable {
    <#
    .SYNOPSIS
    Writes the color names with a sample of each in every color mode.

    .DESCRIPTION
    Show-ColorTable writes one line for each name in the color table, registered names among
    them: the name, a sample of the color in TrueColor, in 256 colors, in 16 colors and as a
    console color, then its hex code, its 256-color number and its console color. The names go by
    family, each family's Dark, normal and Light variants together.

    A terminal without a mode shows the nearest color it has in that mode's column.

    .PARAMETER Name
    The names to show. Wildcards are allowed.

    Default: every name

    .PARAMETER Background
    Shows each sample as a background behind spaces rather than as blocks of text color.

    .EXAMPLE
    Show-ColorTable

    .EXAMPLE
    Show-ColorTable *Blue*, *Cyan* -Background

    Shows the blue and cyan families as backgrounds.

    .INPUTS
    None

    .OUTPUTS
    None
    Show-ColorTable writes to the host.

    .NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    .LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

    .LINK
    Get-ColorTableWithRGB

    .LINK
    Register-ColorName
    #>
    [CmdletBinding()]
    [Alias('Show-ColourTable')]
    param(
        [Parameter(Position = 0)]
        [SupportsWildcards()]
        [string[]] $Name = '*',

        [switch] $Background
    )

    $table = Get-ColorTableWithRGB
    $names = @(Get-ColorNameOrder -Names @($table.Keys | Where-Object {
        $key = $_
        @($Name | Where-Object { $key -like $_ }).Count -gt 0
    }))
    if ($names.Count -eq 0) {
        return
    }

    $width = 4
    foreach ($item in $names) {
        $width = [Math]::Max($width, $item.Length)
    }
    $sample = if ($Background) { '      ' } else { [string][char]0x2588 * 6 }

    Write-ColorEX -Text ('Name'.PadRight($width) + '  TrueColor  256     16      Console  Hex      ANSI8  Console color') -Bold
    foreach ($item in $names) {
        $entry = $table[$item]
        $rgb = $entry[4]
        $hex = '#{0:X2}{1:X2}{2:X2}' -f $rgb[0], $rgb[1], $rgb[2]
        Write-ColorEX -Text ($item.PadRight($width) + '  ') -NoNewLine
        if ($Background) {
            Write-ColorEX -Text $sample -BackGroundColor $hex -TrueColor -Silent -NoNewLine
            Write-ColorEX -Text '     ' -NoNewLine
            Write-ColorEX -Text $sample -BackGroundColor $entry[3] -ANSI8 -Silent -NoNewLine
            Write-ColorEX -Text '  ' -NoNewLine
            Write-ColorEX -Text $sample -BackGroundColor $item -ANSI4 -Silent -NoNewLine
            Write-ColorEX -Text '  ' -NoNewLine
            Write-ColorEX -Text $sample -BackGroundColor $entry[0] -NoNewLine
        } else {
            Write-ColorEX -Text $sample -Color $hex -TrueColor -Silent -NoNewLine
            Write-ColorEX -Text '     ' -NoNewLine
            Write-ColorEX -Text $sample -Color $entry[3] -ANSI8 -Silent -NoNewLine
            Write-ColorEX -Text '  ' -NoNewLine
            Write-ColorEX -Text $sample -Color $item -ANSI4 -Silent -NoNewLine
            Write-ColorEX -Text '  ' -NoNewLine
            Write-ColorEX -Text $sample -Color $entry[0] -NoNewLine
        }
        Write-ColorEX -Text ('   ' + $hex + '  ' + "$($entry[3])".PadLeft(5) + '  ' + $entry[0])
    }
}
