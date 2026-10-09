<#
.SYNOPSIS
    The color arithmetic of gradients and color forms: OKLab, HSL and the 256 colors.

.DESCRIPTION
    Written so Windows PowerShell 5.1, PowerShell 7 and PWRSWriteColorEX give the same results to
    the last bit: the constants are the bit patterns of their doubles rather than decimal numbers
    a parser may round either way, and the arithmetic is +, -, * and / in a fixed order, which
    IEEE 754 rounds the same everywhere. A class rather than functions because a gradient
    computes a color for every character, and a function call costs more than that arithmetic.

.NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later
#>

class ColorMath {
    # The linear value of each sRGB channel value 0-255: ((c / 255 + 0.055) / 1.055) ^ 2.4, or
    # c / 255 / 12.92 at the dark end. It rises, so a linear value finds its nearest channel
    # value by comparing with its neighbors.
    static [double[]] $SrgbToLinear = [ColorMath]::LinearTable()

    # Bjorn Ottosson's OKLab matrices: linear sRGB to LMS, the cube roots of LMS to OKLab, OKLab
    # to the cube roots of LMS, and LMS to linear sRGB
    static [double] $L1 = [BitConverter]::Int64BitsToDouble(0x3FDA61D629F2E197)
    static [double] $L2 = [BitConverter]::Int64BitsToDouble(0x3FE129A2D9E60E32)
    static [double] $L3 = [BitConverter]::Int64BitsToDouble(0x3FAA572112081026)
    static [double] $M1 = [BitConverter]::Int64BitsToDouble(0x3FCB1FA76156A7C5)
    static [double] $M2 = [BitConverter]::Int64BitsToDouble(0x3FE5C84A69936914)
    static [double] $M3 = [BitConverter]::Int64BitsToDouble(0x3FBB7E5DF0497455)
    static [double] $S1 = [BitConverter]::Int64BitsToDouble(0x3FB69AFD7A044C17)
    static [double] $S2 = [BitConverter]::Int64BitsToDouble(0x3FD207AE728A2F45)
    static [double] $S3 = [BitConverter]::Int64BitsToDouble(0x3FE428C9177A5EDB)
    static [double] $LL = [BitConverter]::Int64BitsToDouble(0x3FCAF02A3FE8A4FA)
    static [double] $LM = [BitConverter]::Int64BitsToDouble(0x3FE9655120032AAD)
    static [double] $LS = -[BitConverter]::Int64BitsToDouble(0x3F70ADD9BD572B38)
    static [double] $AL = [BitConverter]::Int64BitsToDouble(0x3FFFA5E1BFFFDE12)
    static [double] $AM = -[BitConverter]::Int64BitsToDouble(0x40036DC1BFFE5D3E)
    static [double] $AS = [BitConverter]::Int64BitsToDouble(0x3FDCD686FFF371A5)
    static [double] $BL = [BitConverter]::Int64BitsToDouble(0x3F9A869680B729E0)
    static [double] $BM = [BitConverter]::Int64BitsToDouble(0x3FE90C776001F502)
    static [double] $BS = -[BitConverter]::Int64BitsToDouble(0x3FE9E0AC0001353D)
    static [double] $LA = [BitConverter]::Int64BitsToDouble(0x3FD95D9920068C8A)
    static [double] $LB = [BitConverter]::Int64BitsToDouble(0x3FCB9F751FFA8CC8)
    static [double] $MA = -[BitConverter]::Int64BitsToDouble(0x3FBB06117FEEC881)
    static [double] $MB = -[BitConverter]::Int64BitsToDouble(0x3FB058BF3FE39E34)
    static [double] $SA = -[BitConverter]::Int64BitsToDouble(0x3FB6E86F5FDF38B5)
    static [double] $SB = -[BitConverter]::Int64BitsToDouble(0x3FF4A9ECBFFEAA8D)
    static [double] $R1 = [BitConverter]::Int64BitsToDouble(0x40104E955DC3D73A)
    static [double] $R2 = -[BitConverter]::Int64BitsToDouble(0x400A76317EA9DE73)
    static [double] $R3 = [BitConverter]::Int64BitsToDouble(0x3FCD906C3222FFEF)
    static [double] $G1 = -[BitConverter]::Int64BitsToDouble(0x3FF44B85A62C2AFF)
    static [double] $G2 = [BitConverter]::Int64BitsToDouble(0x4004E0C87D01BF65)
    static [double] $G3 = -[BitConverter]::Int64BitsToDouble(0x3FD5D82D4F5D4F2A)
    static [double] $B1 = -[BitConverter]::Int64BitsToDouble(0x3F712FEA56E00671)
    static [double] $B2 = -[BitConverter]::Int64BitsToDouble(0x3FE68267C131178D)
    static [double] $B3 = [BitConverter]::Int64BitsToDouble(0x3FFB5263CAEF6BCD)

    hidden static [double[]] LinearTable() {
        $bits = [long[]]@(
            0x0000000000000000, 0x3F33E45677C176F7, 0x3F43E45677C176F7, 0x3F4DD681B3A23272,
            0x3F53E45677C176F7, 0x3F58DD6C15B1D4B4, 0x3F5DD681B3A23272, 0x3F6167CBA8C94818,
            0x3F63E45677C176F7, 0x3F6660E146B9A5D5, 0x3F68DD6C15B1D4B4, 0x3F6B6A31B5259C99,
            0x3F6E1E31D70C99DD, 0x3F707C38BF8583A9, 0x3F71FCC2BEED6421, 0x3F7390FFAF95E279,
            0x3F753936CC7BC928, 0x3F76F5ADDB50C915, 0x3F78C6A94031B561, 0x3F7AAC6C0FB97351,
            0x3F7CA7381F9F602B, 0x3F7EB74E160978D0, 0x3F806E76BBDA92B8, 0x3F818C2A5A8A8044,
            0x3F82B4E09B3F0AE3, 0x3F83E8B7B3BDE965, 0x3F8527CD60AF8B85, 0x3F86723EEA8D3709,
            0x3F87C8292A3DB6B3, 0x3F8929A88D67B521, 0x3F8A96D91A8016BD, 0x3F8C0FD67499FAB6,
            0x3F8D94BBDEFD740E, 0x3F8F25A44089883F, 0x3F9061551372C694, 0x3F9135F3E4C2CCE2,
            0x3F9210BB8642B172, 0x3F92F1B8C1AE46BD, 0x3F93D8F839B79C0B, 0x3F94C6866B3E9FA4,
            0x3F95BA6FAE794313, 0x3F96B4C0380D2DEE, 0x3F97B5841A1BF3AC, 0x3F98BCC74542ADDB,
            0x3F99CA95898DC8B5, 0x3F9ADEFA9761C020, 0x3F9BFA0200597BD9, 0x3F9D1BB7381AEC1F,
            0x3F9E442595227BCA, 0x3F9F73585185E1B5, 0x3FA054AD45D76878, 0x3FA0F31BA386FF26,
            0x3FA194FCB663747B, 0x3FA23A55E62A662A, 0x3FA2E32C8E148D11, 0x3FA38F85FD21EACF,
            0x3FA43F67766310FF, 0x3FA4F2D6313FA8D0, 0x3FA5A9D759BA5ED0, 0x3FA6647010B254EE,
            0x3FA722A56C2239EE, 0x3FA7E47C775D2427, 0x3FA8A9FA33494B07, 0x3FA973239698B9CC,
            0x3FAA3FFD8E001389, 0x3FAB108CFC6B7FBC, 0x3FABE4D6BB31D522, 0x3FACBCDF9A4616F2,
            0x3FAD98AC60675833, 0x3FAE7841CB4F16DF, 0x3FAF5BA48FDE2048, 0x3FB0216CAD240765,
            0x3FB096F2671EB815, 0x3FB10E65C38A5192, 0x3FB187C90BF8BCE2, 0x3FB2031E85F5D6DA,
            0x3FB28068731A1952, 0x3FB2FFA9111CB94B, 0x3FB380E299E53F92, 0x3FB40417439CA10F,
            0x3FB4894940BDDBFB, 0x3FB5107AC0261E59, 0x3FB599ADED247AAC, 0x3FB624E4EF892ED4,
            0x3FB6B221EBB4817E, 0x3FB7416702A539D1, 0x3FB7D2B65206B527, 0x3FB86611F43E9E6A,
            0x3FB8FB7C007A4A70, 0x3FB992F68ABBBC89, 0x3FBA2C83A3E6566D, 0x3FBAC82559CB3644,
            0x3FBB65DDB7354604, 0x3FBC05AEC3F4FE5E, 0x3FBCA79A84EBE030, 0x3FBD4BA2FC17A6A5,
            0x3FBDF1CA289D34B8, 0x3FBE9A1206D34003, 0x3FBF447C904CBB4E, 0x3FBFF10BBBE302C2,
            0x3FC04FE0BEDFE5F1, 0x3FC0A84FE3B36D8F, 0x3FC101D443DFC06F, 0x3FC15C6ED58EEFDF,
            0x3FC1B8208DA5FEF0, 0x3FC214EA5FC9514A, 0x3FC272CD3E610123, 0x3FC2D1CA1A9D1CFB,
            0x3FC331E1E479CDF5, 0x3FC393158AC3674E, 0x3FC3F565FB1A5FD5, 0x3FC458D421F735DF,
            0x3FC4BD60EAAE3E73, 0x3FC5230D3F736034, 0x3FC589DA095DBAA1, 0x3FC5F1C8306B3A3C,
            0x3FC65AD89B841A2B, 0x3FC6C50C307E53BF, 0x3FC73063D420FC80, 0x3FC79CE06A279303,
            0x3FC80A82D5453B5D, 0x3FC8794BF727EB3F, 0x3FC8E93CB07B8679, 0x3FC95A55E0ECEC0B,
            0x3FC9CC98672CF47E, 0x3FCA400520F3619C, 0x3FCAB49CEB01C003, 0x3FCB2A60A1263B0A,
            0x3FCBA1511E3E632D, 0x3FCC196F3C39E76F, 0x3FCC92BBD41D41FE, 0x3FCD0D37BE045851,
            0x3FCD88E3D1250F68, 0x3FCE05C0E3D1D3E0, 0x3FCE83CFCB7C16F0, 0x3FCF03115CB6BFD3,
            0x3FCF83866B38924D, 0x3FD00297E4EF4553, 0x3FD044072557177A, 0x3FD086115F6BEB3A,
            0x3FD0C8B6FB5C735E, 0x3FD10BF860EF039A, 0x3FD14FD5F782A5A6, 0x3FD1945026102997,
            0x3FD1D967532B31B1, 0x3FD21F1BE50339E7, 0x3FD2656E41649AE3, 0x3FD2AC5ECDB988F8,
            0x3FD2F3EDEF0B0ED8, 0x3FD33C1C0A020438, 0x3FD384E982E800B1, 0x3FD3CE56BDA84A81,
            0x3FD418641DD0C1BC, 0x3FD463120692C7AF, 0x3FD4AE60DAC4229D, 0x3FD4FA50FCDFDE15,
            0x3FD546E2CF0727A9, 0x3FD59416B3022858, 0x3FD5E1ED0A40DAAB, 0x3FD6306635DBDD7B,
            0x3FD67F82969543A2, 0x3FD6CF428CD96079, 0x3FD71FA678BF915D, 0x3FD770AEBA0B042A,
            0x3FD7C25BB02B7AC5, 0x3FD814ADBA3E0BD9, 0x3FD867A5370DE0B1, 0x3FD8BB428514F067,
            0x3FD90F86027CB84E, 0x3FD964700D1EF1B1, 0x3FD9BA0102864521, 0x3FDA10393FEEFAFD,
            0x3FDA67192247A9BE, 0x3FDABEA10631E195, 0x3FDB16D14802D5CA, 0x3FDB6FAA43C403BB,
            0x3FDBC92C5533D785, 0x3FDC2357D7C64E5D, 0x3FDC7E2D26A596DE, 0x3FDCD9AC9CB2AEF2,
            0x3FDD35D69485FFC5, 0x3FDD92AB686FF782, 0x3FDDF02B7279A10D, 0x3FDE4E570C6539C5,
            0x3FDEAD2E8FAEC526, 0x3FDF0CB2558C9EA4, 0x3FDF6CE2B6F00983, 0x3FDFCDC00C85BEC2,
            0x3FE017A5575B3CB2, 0x3FE048C17AD3C04B, 0x3FE07A349C9D9837, 0x3FE0ABFEE888C050,
            0x3FE0DE208A4444C8, 0x3FE11099AD5E83EB, 0x3FE1436A7D456EEF, 0x3FE176932546CA12,
            0x3FE1AA13D0906BDA, 0x3FE1DDECAA307B85, 0x3FE2121DDD15AECE, 0x3FE246A7940F86D1,
            0x3FE27B89F9CE8C4B, 0x3FE2B0C538E48B07, 0x3FE2E6597BC4CCA0, 0x3FE31C46ECC4528D,
            0x3FE3528DB61A0F73, 0x3FE3892E01DF1FCC, 0x3FE3C027FA0F01EB, 0x3FE3F77BC887CD3B,
            0x3FE42F29970A68F8, 0x3FE467318F3AC22D, 0x3FE49F93DAA00113, 0x3FE4D850A2A4BDE1,
            0x3FE51168109734E5, 0x3FE54ADA4DA97A1B, 0x3FE584A782F1AC23, 0x3FE5BECFD96A2698,
            0x3FE5F95379F1B3ED, 0x3FE634328D4BBE97, 0x3FE66F6D3C2081CF, 0x3FE6AB03AEFD39AA,
            0x3FE6E6F60E5452B1, 0x3FE72344827D98F6, 0x3FE75FEF33B6669B, 0x3FE79CF64A21D1E2,
            0x3FE7DA59EDC8DAB0, 0x3FE8181A469A9787, 0x3FE856377C6C6224, 0x3FE894B1B6FA0377,
            0x3FE8D3891DE5DF49, 0x3FE912BDD8B91F45, 0x3FE952500EE3DDA5, 0x3FE9923FE7BD4F67,
            0x3FE9D28D8A83EDFC, 0x3FEA13391E5DA09F, 0x3FEA5442CA57E52E, 0x3FEA95AAB567F88F,
            0x3FEAD771066AFEC2, 0x3FEB1995E4262A69, 0x3FEB5C197546E3F8, 0x3FEB9EFBE062F086,
            0x3FEBE23D4BF8981B, 0x3FEC25DDDE6ECBBB, 0x3FEC69DDBE154AF1, 0x3FECAE3D1124C90B,
            0x3FECF2FBFDBF11F1, 0x3FED381AA9EF2E82, 0x3FED7D993BA988D4, 0x3FEDC377D8CC0FD5,
            0x3FEE09B6A71E5AA6, 0x3FEE5055CC51CBB4, 0x3FEE97556E01B351, 0x3FEEDEB5B1B37216,
            0x3FEF2676BCD69ADE, 0x3FEF6E98B4C51466, 0x3FEFB71BBEC33AB2, 0x3FF0000000000000
        )
        $table = [double[]]::new(256)
        for ($i = 0; $i -lt 256; $i++) {
            $table[$i] = [BitConverter]::Int64BitsToDouble($bits[$i])
        }
        return $table
    }

    # The cube root of a number from 0 to 1, by 40 Newton steps from 1. [Math]::Pow and Math.Cbrt
    # may differ in the last bit between .NET versions and libraries; Newton's steps use only *,
    # + and /, which do not. From 1 the steps fall to the root, and 40 of them reach it from any
    # LMS value a color gives.
    static [double] CubeRoot([double] $Value) {
        if ($Value -le 0.0) {
            return 0.0
        }
        $root = 1.0
        for ($step = 0; $step -lt 40; $step++) {
            $root = (2.0 * $root + $Value / ($root * $root)) / 3.0
        }
        return $root
    }

    # The OKLab coordinates L, a and b of an sRGB color given as three channel values 0-255
    static [double[]] ToOkLab([int[]] $Rgb) {
        $table = [ColorMath]::SrgbToLinear
        $red = $table[$Rgb[0]]
        $green = $table[$Rgb[1]]
        $blue = $table[$Rgb[2]]
        $l = [ColorMath]::CubeRoot([ColorMath]::L1 * $red + [ColorMath]::L2 * $green + [ColorMath]::L3 * $blue)
        $m = [ColorMath]::CubeRoot([ColorMath]::M1 * $red + [ColorMath]::M2 * $green + [ColorMath]::M3 * $blue)
        $s = [ColorMath]::CubeRoot([ColorMath]::S1 * $red + [ColorMath]::S2 * $green + [ColorMath]::S3 * $blue)
        return [double[]]@(
            ([ColorMath]::LL * $l + [ColorMath]::LM * $m + [ColorMath]::LS * $s),
            ([ColorMath]::AL * $l + [ColorMath]::AM * $m + [ColorMath]::AS * $s),
            ([ColorMath]::BL * $l + [ColorMath]::BM * $m + [ColorMath]::BS * $s)
        )
    }

    # The sRGB channel values of a hue in degrees and a saturation and lightness from 0 to 100:
    # C = (1 - |2L - 1|) * S, X = C * (1 - |(H / 60) mod 2 - 1|), m = L - C / 2, each channel
    # rounded half to even after multiplying by 255
    static [int[]] FromHsl([double] $Hue, [double] $Saturation, [double] $Lightness) {
        $h = $Hue - 360.0 * [Math]::Floor($Hue / 360.0)
        $s = [Math]::Min(100.0, [Math]::Max(0.0, $Saturation)) / 100.0
        $l = [Math]::Min(100.0, [Math]::Max(0.0, $Lightness)) / 100.0
        $chroma = (1.0 - [Math]::Abs(2.0 * $l - 1.0)) * $s
        $sector = $h / 60.0
        $x = $chroma * (1.0 - [Math]::Abs(($sector - 2.0 * [Math]::Floor($sector / 2.0)) - 1.0))
        $offset = $l - $chroma / 2.0
        $parts = switch ([int][Math]::Floor($sector)) {
            0 { $chroma, $x, 0.0 }
            1 { $x, $chroma, 0.0 }
            2 { 0.0, $chroma, $x }
            3 { 0.0, $x, $chroma }
            4 { $x, 0.0, $chroma }
            default { $chroma, 0.0, $x }
        }
        return [int[]]@(
            [int][Math]::Round(($parts[0] + $offset) * 255.0, [MidpointRounding]::ToEven),
            [int][Math]::Round(($parts[1] + $offset) * 255.0, [MidpointRounding]::ToEven),
            [int][Math]::Round(($parts[2] + $offset) * 255.0, [MidpointRounding]::ToEven)
        )
    }

    # Each channel value's step in the 6x6x6 color cube, 0 to 5
    static [int[]] $CubeSteps = [ColorMath]::CubeStepTable()

    hidden static [int[]] CubeStepTable() {
        $steps = [int[]]::new(256)
        for ($i = 0; $i -lt 256; $i++) {
            if ($i -lt 48) { $steps[$i] = 0 }
            elseif ($i -lt 115) { $steps[$i] = 1 }
            elseif ($i -lt 155) { $steps[$i] = 2 }
            elseif ($i -lt 195) { $steps[$i] = 3 }
            elseif ($i -lt 235) { $steps[$i] = 4 }
            else { $steps[$i] = 5 }
        }
        return $steps
    }

    # One color for each of Steps characters, blended evenly between the waypoints, which are RGB
    # arrays: RGB arrays, or 256-color codes with Ansi8. Each step falls between the two
    # waypoints around it, at a ratio from 0 to 1 between them; the first and last step of each
    # stretch are the waypoints themselves. With OkLab the blend is in OKLab, else each channel on
    # its own, rounded half to even. The conversions are written out in the loop because a
    # method call costs more than the arithmetic of a step.
    static [object[]] Blend([object[]] $Waypoints, [int] $Steps, [bool] $Ansi8, [bool] $OkLab) {
        $points = [int[][]]::new($Waypoints.Count)
        $labs = [double[][]]::new($Waypoints.Count)
        for ($w = 0; $w -lt $Waypoints.Count; $w++) {
            $points[$w] = [int[]]$Waypoints[$w]
            if ($OkLab) {
                $labs[$w] = [ColorMath]::ToOkLab($points[$w])
            }
        }
        $table = [ColorMath]::SrgbToLinear
        $cube = [ColorMath]::CubeSteps
        $linear = [double[]]::new(3)
        $out = [object[]]::new($Steps)
        $segmentCount = $Waypoints.Count - 1
        for ($step = 0; $step -lt $Steps; $step++) {
            if ($Steps -eq 1) {
                $segmentIndex = 0
                $ratio = 0.0
            } elseif ($segmentCount -eq 1) {
                $segmentIndex = 0
                $ratio = [double]$step / ($Steps - 1)
            } else {
                $position = [double]$step / ($Steps - 1) * $segmentCount
                $segmentIndex = [Math]::Min([int][Math]::Floor($position), $segmentCount - 1)
                $ratio = $position - $segmentIndex
            }
            $start = $points[$segmentIndex]
            $end = $points[$segmentIndex + 1]
            $rgb = [int[]]::new(3)
            if ($ratio -eq 0.0) {
                $rgb[0] = $start[0]
                $rgb[1] = $start[1]
                $rgb[2] = $start[2]
            } elseif ($ratio -eq 1.0) {
                $rgb[0] = $end[0]
                $rgb[1] = $end[1]
                $rgb[2] = $end[2]
            } elseif ($OkLab) {
                # The OKLab coordinates between the two waypoints, to LMS and on to linear sRGB
                $startLab = $labs[$segmentIndex]
                $endLab = $labs[$segmentIndex + 1]
                $lightness = $startLab[0] + ($endLab[0] - $startLab[0]) * $ratio
                $greenRed = $startLab[1] + ($endLab[1] - $startLab[1]) * $ratio
                $blueYellow = $startLab[2] + ($endLab[2] - $startLab[2]) * $ratio
                $lRoot = $lightness + [ColorMath]::LA * $greenRed + [ColorMath]::LB * $blueYellow
                $mRoot = $lightness + [ColorMath]::MA * $greenRed + [ColorMath]::MB * $blueYellow
                $sRoot = $lightness + [ColorMath]::SA * $greenRed + [ColorMath]::SB * $blueYellow
                $l = $lRoot * $lRoot * $lRoot
                $m = $mRoot * $mRoot * $mRoot
                $s = $sRoot * $sRoot * $sRoot
                $linear[0] = [ColorMath]::R1 * $l + [ColorMath]::R2 * $m + [ColorMath]::R3 * $s
                $linear[1] = [ColorMath]::G1 * $l + [ColorMath]::G2 * $m + [ColorMath]::G3 * $s
                $linear[2] = [ColorMath]::B1 * $l + [ColorMath]::B2 * $m + [ColorMath]::B3 * $s

                # Each linear value to the channel value whose linear value is nearest, the lower
                # of two as near; below 0 is 0 and above 1 is 255. The sRGB curve gives a first
                # guess, which may be off where [Math]::Pow differs between platforms; the
                # table then decides, so the answer does not depend on [Math]::Pow.
                for ($channel = 0; $channel -lt 3; $channel++) {
                    $value = $linear[$channel]
                    if ($value -le 0.0) {
                        $rgb[$channel] = 0
                    } elseif ($value -ge 1.0) {
                        $rgb[$channel] = 255
                    } else {
                        $low = [int][Math]::Floor((1.055 * [Math]::Pow($value, 1.0 / 2.4) - 0.055) * 255.0)
                        if ($low -lt 0) { $low = 0 } elseif ($low -gt 254) { $low = 254 }
                        while ($low -lt 254 -and $table[$low + 1] -le $value) { $low++ }
                        while ($low -gt 0 -and $table[$low] -gt $value) { $low-- }
                        if ($table[$low + 1] - $value -lt $value - $table[$low]) {
                            $rgb[$channel] = $low + 1
                        } else {
                            $rgb[$channel] = $low
                        }
                    }
                }
            } else {
                $rgb[0] = [int][Math]::Round($start[0] + ($end[0] - $start[0]) * $ratio, [MidpointRounding]::ToEven)
                $rgb[1] = [int][Math]::Round($start[1] + ($end[1] - $start[1]) * $ratio, [MidpointRounding]::ToEven)
                $rgb[2] = [int][Math]::Round($start[2] + ($end[2] - $start[2]) * $ratio, [MidpointRounding]::ToEven)
            }

            if (-not $Ansi8) {
                $out[$step] = $rgb
                continue
            }

            # The nearest 256-color code, as Convert-RGBToANSI8 answers it: one of the 24 grays
            # for a color whose channels are within 10 of each other, black (16) and white (231)
            # at the ends, else the 6x6x6 cube
            $redGreen = $rgb[0] - $rgb[1]
            $greenBlue = $rgb[1] - $rgb[2]
            if ($redGreen -gt -10 -and $redGreen -lt 10 -and $greenBlue -gt -10 -and $greenBlue -lt 10) {
                $gray = [Math]::Round(($rgb[0] + $rgb[1] + $rgb[2]) / 3.0)
                if ($gray -lt 8) {
                    $out[$step] = 16
                } elseif ($gray -gt 248) {
                    $out[$step] = 231
                } else {
                    $out[$step] = 232 + [int][Math]::Min(23, [Math]::Round(($gray - 8) / 10.0))
                }
            } else {
                $out[$step] = 16 + 36 * $cube[$rgb[0]] + 6 * $cube[$rgb[1]] + $cube[$rgb[2]]
            }
        }
        return $out
    }
}
