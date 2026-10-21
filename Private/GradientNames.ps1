# The named gradients -Gradient and -BackGroundGradient take as a single value, each with its colors
# in order. Rainbow to Grayscale and Progress are this module's; Atlas to Summer are gradient-string's
# presets (https://github.com/bokub/gradient-string, MIT, Copyright (c) 2017 Boris K), whose own
# rainbow and pastel blend in HSV, which this module's do not, so Rainbow and Pastel are this
# module's. Progress is the color table's Red, LightRuby, Orange, Yellow and Green.
$script:GradientNames = [ordered]@{
    Rainbow   = @('#FF0000', '#FFFF00', '#00FF00', '#00FFFF', '#0000FF', '#FF00FF')
    Sunset    = @('#4A1C6F', '#C2185B', '#FF6F3C', '#FFC857')
    Ocean     = @('#003366', '#0077B6', '#00B4D8', '#90E0EF')
    Forest    = @('#0B3D20', '#1E6B3A', '#4C9A2A', '#A3C94F')
    Fire      = @('#8B0000', '#FF4500', '#FF8C00', '#FFD700')
    Ice       = @('#FFFFFF', '#CAF0F8', '#72C6EF', '#3A86FF')
    Neon      = @('#FF00CC', '#3333FF', '#00FFCC')
    Pastel    = @('#FFB3BA', '#FFDFBA', '#FFFFBA', '#BAFFC9', '#BAE1FF', '#D7BAFF')
    Grayscale = @('#000000', '#FFFFFF')
    Atlas     = @('#FEAC5E', '#C779D0', '#4BC0C8')
    Cristal   = @('#BDFFF3', '#4AC29A')
    Teen      = @('#77A1D3', '#79CBCA', '#E684AE')
    Mind      = @('#473B7B', '#3584A7', '#30D2BE')
    Morning   = @('#FF5F6D', '#FFC371')
    Vice      = @('#5EE7DF', '#B490CA')
    Passion   = @('#F43B47', '#453A94')
    Fruit     = @('#FF4E50', '#F9D423')
    Instagram = @('#833AB4', '#FD1D1D', '#FCB045')
    Retro     = @('#3F51B1', '#5A55AE', '#7B5FAC', '#8F6AAE', '#A86AA4', '#CC6B8E', '#F18271', '#F3A469', '#F7C978')
    Summer    = @('#FDBB2D', '#22C1C3')
    Progress  = @('#FF0000', '#FF6699', '#FFA500', '#FFFF00', '#00FF00')
}

function Resolve-GradientName {
    <#
    .SYNOPSIS
    The colors of a named gradient when the list holds that one name, compared without regard to
    case; any other list as it is. Never called with $null.
    #>
    param([object[]]$Values)
    if ($Values.Count -eq 1 -and $Values[0] -is [string] -and $script:GradientNames.Contains([string]$Values[0])) {
        return , ([object[]]$script:GradientNames[[string]$Values[0]])
    }
    return , $Values
}

function Split-GradientPlace {
    <#
    .SYNOPSIS
    Takes the place given with '@' off each of a gradient's colors: returns Colors, the colors
    without their places, and Places, each color's place from 0 to 1 or $null for one with none.
    Only text carries a place.
    #>
    param([object[]]$Values)
    $colors = [object[]]::new($Values.Count)
    $places = [object[]]::new($Values.Count)
    for ($k = 0; $k -lt $Values.Count; $k++) {
        $colors[$k] = $Values[$k]
        if ($Values[$k] -is [string]) {
            $split = [ColorMath]::SplitPlace($Values[$k])
            if ($null -ne $split) {
                $colors[$k] = $split[0]
                $places[$k] = $split[1]
            }
        }
    }
    @{ Colors = $colors; Places = $places }
}
