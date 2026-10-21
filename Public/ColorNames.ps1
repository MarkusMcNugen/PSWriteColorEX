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
    Writes the color names with a sample of each in every color mode, or a view of the text
    styles, the 256 colors or the style profiles.

    .DESCRIPTION
    Show-ColorTable writes one line for each name in the color table, registered names among
    them: the name, a sample of the color in TrueColor, in 256 colors, in 16 colors and as a
    console color, then its hex code, its 256-color number and its console color. The names go by
    family, each family's Dark, normal and Light variants together.

    A terminal without a mode shows the nearest color it has in that mode's column.

    -Styles, -Palette and -Profiles write a view instead of the names:

    - -Styles: each text style, with a sample in it, the Write-ColorEX parameter that gives it and
      the markup tags that give it.
    - -Palette: the 256-color chart, each number written on its own color in black or white,
      whichever has the higher contrast: the terminal's 16 colors, the 6x6x6 color cube as six
      blocks of 6x6, and the 24 grays. On the 16 colors, which the terminal's scheme sets, the
      numbers 0-6 and 8 are white and the others black.
    - -Profiles: each style profile, with a sample in its colors and styles, then its settings in
      words, the default style marked. Layout settings such as AutoPad are listed, not applied. A
      color Write-ColorEX does not take, such as 5.5, gives Write-ColorEX's error in place of the
      sample.

    .PARAMETER Name
    The names to show, or with -Profiles the profiles. Wildcards are allowed.

    Default: every name

    .PARAMETER Background
    Shows each sample as a background behind spaces rather than as blocks of text color.

    .PARAMETER Styles
    Writes the text styles instead of the color names.

    .PARAMETER Palette
    Writes the 256-color chart instead of the color names.

    .PARAMETER Profiles
    Writes the style profiles instead of the color names.

    .EXAMPLE
    Show-ColorTable

    .EXAMPLE
    Show-ColorTable *Blue*, *Cyan* -Background

    Shows the blue and cyan families as backgrounds.

    .EXAMPLE
    Show-ColorTable -Styles

    .EXAMPLE
    Show-ColorTable -Palette

    .EXAMPLE
    Import-ColorProfile -Theme Nord
    Show-ColorTable -Profiles

    Shows the profiles as the Nord theme set them.

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
    [CmdletBinding(DefaultParameterSetName = 'Names')]
    [Alias('Show-ColourTable')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Names')]
        [Parameter(Position = 0, ParameterSetName = 'Profiles')]
        [SupportsWildcards()]
        [string[]] $Name = '*',

        [Parameter(ParameterSetName = 'Names')]
        [switch] $Background,

        [Parameter(Mandatory, ParameterSetName = 'Styles')]
        [switch] $Styles,

        [Parameter(Mandatory, ParameterSetName = 'Palette')]
        [switch] $Palette,

        [Parameter(Mandatory, ParameterSetName = 'Profiles')]
        [switch] $Profiles
    )

    if ($Styles) {
        # Each style, the Write-ColorEX parameters that give it, and the parameter as written
        $rows = @(
            , @('Bold', @{ Bold = $true }, '-Bold')
            , @('Faint', @{ Faint = $true }, '-Faint')
            , @('Italic', @{ Italic = $true }, '-Italic')
            , @('Underline', @{ Underline = $true }, '-Underline')
            , @('DoubleUnderline', @{ DoubleUnderline = $true }, '-DoubleUnderline')
            , @('Curly', @{ UnderlineStyle = 'Curly' }, '-UnderlineStyle Curly')
            , @('Dotted', @{ UnderlineStyle = 'Dotted' }, '-UnderlineStyle Dotted')
            , @('Dashed', @{ UnderlineStyle = 'Dashed' }, '-UnderlineStyle Dashed')
            , @('Blink', @{ Blink = $true }, '-Blink')
            , @('Reverse', @{ Reverse = $true }, '-Reverse')
            , @('CrossedOut', @{ CrossedOut = $true }, '-CrossedOut')
            , @('Overline', @{ Overline = $true }, '-Overline')
        )
        $markupColumn = 17 + 13 + 24
        Write-ColorEX -Text ('Style'.PadRight(17) + 'Sample'.PadRight(13) + 'Parameter'.PadRight(24) + 'Markup') -Bold
        foreach ($row in $rows) {
            $styleName = $row[0]
            $sample = $row[1]
            # The markup tags for the style: its own name, then the others in ordinal order
            $own = $styleName.ToLowerInvariant()
            $others = [string[]]@($script:MarkupStyleNames.Keys | Where-Object { $script:MarkupStyleNames[$_] -eq $styleName -and $_ -ne $own })
            [Array]::Sort($others, [System.StringComparer]::Ordinal)
            # The tags wrap onto lines of their own under the markup column to stay within 80 columns
            $tagLines = [System.Collections.Generic.List[string]]::new()
            $tagLine = ''
            foreach ($tag in @($own) + $others) {
                $word = "[$tag]"
                if ($tagLine.Length -gt 0 -and $markupColumn + $tagLine.Length + 1 + $word.Length -gt 80) {
                    $tagLines.Add($tagLine)
                    $tagLine = $word
                } elseif ($tagLine.Length -gt 0) {
                    $tagLine += " $word"
                } else {
                    $tagLine = $word
                }
            }
            $tagLines.Add($tagLine)
            Write-ColorEX -Text $styleName.PadRight(17) -NoNewLine
            Write-ColorEX -Text 'Sample text' @sample -NoNewLine
            Write-ColorEX -Text ('  ' + $row[2].PadRight(24) + $tagLines[0])
            for ($i = 1; $i -lt $tagLines.Count; $i++) {
                Write-ColorEX -Text ((' ' * $markupColumn) + $tagLines[$i])
            }
        }
        return
    }

    if ($Palette) {
        # The rows of the chart, each a list of codes and gaps, a part's last row followed by a
        # blank line: the 16 colors, the cube's two bands of three 6x6 blocks, the 24 grays
        $rows = [System.Collections.Generic.List[object]]::new()
        $rows.Add(@{ Cells = @(0..7); Blank = $false })
        $rows.Add(@{ Cells = @(8..15); Blank = $true })
        foreach ($band in 0, 1) {
            for ($r = 0; $r -lt 6; $r++) {
                $cells = [System.Collections.Generic.List[object]]::new()
                for ($block = 0; $block -lt 3; $block++) {
                    if ($block -gt 0) {
                        $cells.Add('  ')
                    }
                    $start = 16 + ($band * 3 + $block) * 36 + $r * 6
                    for ($c = 0; $c -lt 6; $c++) {
                        $cells.Add($start + $c)
                    }
                }
                $rows.Add(@{ Cells = $cells.ToArray(); Blank = ($r -eq 5) })
            }
        }
        $rows.Add(@{ Cells = @(232..243); Blank = $false })
        $rows.Add(@{ Cells = @(244..255); Blank = $false })
        foreach ($row in $rows) {
            $cellTexts = [System.Collections.Generic.List[string]]::new()
            $cellColors = [System.Collections.Generic.List[object]]::new()
            $cellBackgrounds = [System.Collections.Generic.List[object]]::new()
            foreach ($cell in $row.Cells) {
                if ($cell -is [string]) {
                    $cellTexts.Add($cell)
                    $cellColors.Add($null)
                    $cellBackgrounds.Add($null)
                    continue
                }
                $cellTexts.Add(('{0,3} ' -f $cell))
                $cellColors.Add((Get-PaletteTextColor -Code $cell))
                $cellBackgrounds.Add([int]$cell)
            }
            $lines = 0
            if ($row.Blank) {
                $lines = 1
            }
            Write-ColorEX -Text $cellTexts.ToArray() -Color $cellColors.ToArray() -BackGroundColor $cellBackgrounds.ToArray() -ANSI8 -Silent -LinesAfter $lines
        }
        return
    }

    if ($Profiles) {
        # The profiles named, in the order of their names in upper case, ordinal
        $profileNames = [string[]]@([PSColorStyle]::Profiles.Keys | Where-Object {
            $key = $_
            @($Name | Where-Object { $key -like $_ }).Count -gt 0
        })
        if ($profileNames.Count -eq 0) {
            return
        }
        $keys = [string[]]@(foreach ($profileName in $profileNames) { $profileName.ToUpperInvariant() })
        [Array]::Sort($keys, $profileNames, [System.StringComparer]::Ordinal)
        $width = 7
        foreach ($profileName in $profileNames) {
            $width = [Math]::Max($width, $profileName.Length)
        }
        Write-ColorEX -Text ('Profile'.PadRight($width) + '  ' + 'Sample'.PadRight(13) + 'Settings') -Bold
        foreach ($profileName in $profileNames) {
            $style = [PSColorStyle]::Profiles[$profileName]
            # The sample takes the profile's colors and styles, not its layout
            $sample = $style.ToWriteColorParams()
            foreach ($key in 'StartTab', 'StartSpaces', 'LinesBefore', 'LinesAfter', 'ShowTime', 'NoNewLine', 'HorizontalCenter', 'AutoPad', 'PadLeft', 'PadChar', 'PadCenter', 'Truncate', 'Wrap') {
                $sample.Remove($key)
            }
            Write-ColorEX -Text ($profileName.PadRight($width) + '  ') -NoNewLine
            # A color Write-ColorEX does not take gives its error in place of the sample, written
            # as one that does not stop the view, and the other profiles follow
            try {
                Write-ColorEX -Text 'Sample text' @sample -Silent -NoNewLine
            } catch {
                $PSCmdlet.WriteError($_)
            }
            Write-ColorEX -Text ('  ' + (Get-ColorStyleSummary -Style $style))
        }
        return
    }

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
