<#
.SYNOPSIS
    The color arithmetic of gradients and color forms: the spaces a gradient blends in, its
    easing curves and stop places, HSL and the 256 colors.

.DESCRIPTION
    Written so Windows PowerShell 5.1, PowerShell 7 and PWRSWriteColorEX give the same results to
    the last bit: the constants are the bit patterns of their doubles rather than decimal numbers
    a parser may round either way, and the arithmetic is +, -, *, / and square roots in a fixed
    order, which IEEE 754 rounds the same everywhere. Sine, cosine, arctangent and powers of two
    are series written here from those operations, since [Math]'s may differ in the last bit
    between .NET versions. A class rather than functions because a gradient computes a color for
    every character, and a function call costs more than that arithmetic.

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

    # pi, pi/2 and pi/4
    static [double] $Pi = [BitConverter]::Int64BitsToDouble(0x400921FB54442D18)
    static [double] $HalfPi = [BitConverter]::Int64BitsToDouble(0x3FF921FB54442D18)
    static [double] $QuarterPi = [BitConverter]::Int64BitsToDouble(0x3FE921FB54442D18)

    # 2/pi, and pi/2 split into a part whose low bits are zero and the rest, so that k x pi/2
    # comes off a number without losing the bits beyond a double's pi/2
    static [double] $TwoOverPi = [BitConverter]::Int64BitsToDouble(0x3FE45F306DC9C883)
    static [double] $HalfPiHigh = [BitConverter]::Int64BitsToDouble(0x3FF921FB54400000)
    static [double] $HalfPiLow = [BitConverter]::Int64BitsToDouble(0x3DD0B4611A626331)

    # The natural logarithm of 2
    static [double] $Ln2 = [BitConverter]::Int64BitsToDouble(0x3FE62E42FEFA39EF)

    # 1/n! for n from 0 to 18
    static [double[]] $InverseFactorials = @(
        [BitConverter]::Int64BitsToDouble(0x3FF0000000000000),
        [BitConverter]::Int64BitsToDouble(0x3FF0000000000000),
        [BitConverter]::Int64BitsToDouble(0x3FE0000000000000),
        [BitConverter]::Int64BitsToDouble(0x3FC5555555555555),
        [BitConverter]::Int64BitsToDouble(0x3FA5555555555555),
        [BitConverter]::Int64BitsToDouble(0x3F81111111111111),
        [BitConverter]::Int64BitsToDouble(0x3F56C16C16C16C17),
        [BitConverter]::Int64BitsToDouble(0x3F2A01A01A01A01A),
        [BitConverter]::Int64BitsToDouble(0x3EFA01A01A01A01A),
        [BitConverter]::Int64BitsToDouble(0x3EC71DE3A556C734),
        [BitConverter]::Int64BitsToDouble(0x3E927E4FB7789F5C),
        [BitConverter]::Int64BitsToDouble(0x3E5AE64567F544E4),
        [BitConverter]::Int64BitsToDouble(0x3E21EED8EFF8D898),
        [BitConverter]::Int64BitsToDouble(0x3DE6124613A86D09),
        [BitConverter]::Int64BitsToDouble(0x3DA93974A8C07C9D),
        [BitConverter]::Int64BitsToDouble(0x3D6AE7F3E733B81F),
        [BitConverter]::Int64BitsToDouble(0x3D2AE7F3E733B81F),
        [BitConverter]::Int64BitsToDouble(0x3CE952C77030AD4A),
        [BitConverter]::Int64BitsToDouble(0x3CA6827863B97D97)
    )

    # The arctangent series' coefficients (-1)^k / (2k + 1) for k from 0 to 13
    static [double[]] $AtanSeries = @(
        [BitConverter]::Int64BitsToDouble(0x3FF0000000000000),
        -[BitConverter]::Int64BitsToDouble(0x3FD5555555555555),
        [BitConverter]::Int64BitsToDouble(0x3FC999999999999A),
        -[BitConverter]::Int64BitsToDouble(0x3FC2492492492492),
        [BitConverter]::Int64BitsToDouble(0x3FBC71C71C71C71C),
        -[BitConverter]::Int64BitsToDouble(0x3FB745D1745D1746),
        [BitConverter]::Int64BitsToDouble(0x3FB3B13B13B13B14),
        -[BitConverter]::Int64BitsToDouble(0x3FB1111111111111),
        [BitConverter]::Int64BitsToDouble(0x3FAE1E1E1E1E1E1E),
        -[BitConverter]::Int64BitsToDouble(0x3FAAF286BCA1AF28),
        [BitConverter]::Int64BitsToDouble(0x3FA8618618618618),
        -[BitConverter]::Int64BitsToDouble(0x3FA642C8590B2164),
        [BitConverter]::Int64BitsToDouble(0x3FA47AE147AE147B),
        -[BitConverter]::Int64BitsToDouble(0x3FA2F684BDA12F68)
    )

    # The sine of a number from -pi/4 to pi/4: its Taylor series to the 17th power, in Horner
    # form on the square. [Math]::Sin and the other library functions may differ in the last bit
    # between .NET versions and platforms; this uses only *, + and -.
    hidden static [double] SineNearZero([double] $R) {
        $z = $R * $R
        $factorials = [ColorMath]::InverseFactorials
        $sum = $factorials[17]
        for ($n = 15; $n -ge 3; $n -= 2) {
            if ($n % 4 -eq 3) {
                $sum = $sum * $z - $factorials[$n]
            } else {
                $sum = $sum * $z + $factorials[$n]
            }
        }
        return $R * ($sum * $z + 1.0)
    }

    # The cosine of a number from -pi/4 to pi/4: its Taylor series to the 18th power, in Horner
    # form on the square
    hidden static [double] CosineNearZero([double] $R) {
        $z = $R * $R
        $factorials = [ColorMath]::InverseFactorials
        $sum = -$factorials[18]
        for ($n = 16; $n -ge 2; $n -= 2) {
            if ($n % 4 -eq 2) {
                $sum = $sum * $z - $factorials[$n]
            } else {
                $sum = $sum * $z + $factorials[$n]
            }
        }
        return $sum * $z + 1.0
    }

    # A number as k x pi/2 + r, r from -pi/4 to pi/4: k's last two bits, which pick the quarter
    # turn, and r
    hidden static [double[]] QuarterTurns([double] $X) {
        $k = [Math]::Round($X * [ColorMath]::TwoOverPi, [MidpointRounding]::ToEven)
        $r = ($X - $k * [ColorMath]::HalfPiHigh) - $k * [ColorMath]::HalfPiLow
        $quarter = (([long]$k % 4) + 4) % 4
        return [double[]]@($quarter, $r)
    }

    # The sine of X in radians
    static [double] Sin([double] $X) {
        $turns = [ColorMath]::QuarterTurns($X)
        switch ([int]$turns[0]) {
            0 { return [ColorMath]::SineNearZero($turns[1]) }
            1 { return [ColorMath]::CosineNearZero($turns[1]) }
            2 { return -[ColorMath]::SineNearZero($turns[1]) }
        }
        return -[ColorMath]::CosineNearZero($turns[1])
    }

    # The cosine of X in radians
    static [double] Cos([double] $X) {
        $turns = [ColorMath]::QuarterTurns($X)
        switch ([int]$turns[0]) {
            0 { return [ColorMath]::CosineNearZero($turns[1]) }
            1 { return -[ColorMath]::SineNearZero($turns[1]) }
            2 { return -[ColorMath]::CosineNearZero($turns[1]) }
        }
        return [ColorMath]::SineNearZero($turns[1])
    }

    # The arctangent of a number from 0 to 1: taken from pi/4 above 1/2, then halved once with
    # atan u = 2 atan(u / (1 + sqrt(1 + u^2))), so the series runs on no more than 0.24.
    # [Math]::Sqrt is exact: IEEE 754 rounds a square root correctly everywhere.
    hidden static [double] ArctangentToOne([double] $Z) {
        $base = 0.0
        $u = $Z
        if ($Z -gt 0.5) {
            $base = [ColorMath]::QuarterPi
            $u = ($Z - 1.0) / ($Z + 1.0)
        }
        $half = $u / (1.0 + [Math]::Sqrt(1.0 + $u * $u))
        $w = $half * $half
        $series = [ColorMath]::AtanSeries
        $sum = $series[13]
        for ($k = 12; $k -ge 0; $k--) {
            $sum = $sum * $w + $series[$k]
        }
        return $base + 2.0 * ($half * $sum)
    }

    # The angle of the point (X, Y) in radians, from -pi to pi; 0 for the origin
    static [double] Atan2([double] $Y, [double] $X) {
        $ax = [Math]::Abs($X)
        $ay = [Math]::Abs($Y)
        if ($ax -eq 0.0 -and $ay -eq 0.0) {
            return 0.0
        }
        if ($ay -le $ax) {
            $angle = [ColorMath]::ArctangentToOne($ay / $ax)
        } else {
            $angle = [ColorMath]::HalfPi - [ColorMath]::ArctangentToOne($ax / $ay)
        }
        if ($X -lt 0.0) {
            $angle = [ColorMath]::Pi - $angle
        }
        if ($Y -lt 0.0) {
            return -$angle
        }
        return $angle
    }

    # 2 to the power X: 2^floor(X) by halving or doubling, times e^(f ln 2) for the fraction f by
    # its Taylor series to the 18th power
    static [double] Exp2([double] $X) {
        $whole = [Math]::Floor($X)
        $w = ($X - $whole) * [ColorMath]::Ln2
        $factorials = [ColorMath]::InverseFactorials
        $sum = $factorials[18]
        for ($k = 17; $k -ge 0; $k--) {
            $sum = $sum * $w + $factorials[$k]
        }
        $power = [long]$whole
        while ($power -gt 0) {
            $sum *= 2.0
            $power--
        }
        while ($power -lt 0) {
            $sum *= 0.5
            $power++
        }
        return $sum
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
        return [ColorMath]::HslToRgb($h, $s, $l)
    }

    # The sRGB channel values of a hue in degrees from 0 to 360 and a saturation and lightness from
    # 0 to 1, by FromHsl's formula
    static [int[]] HslToRgb([double] $h, [double] $s, [double] $l) {
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

    # The OKLab coordinates of the 256-color codes 16-255, at index code - 16: the 6x6x6 cube,
    # whose channel steps are 0, 95, 135, 175, 215 and 255, then the 24 grays, 8 to 238 by 10
    static [double[][]] $Ansi8Labs = [ColorMath]::Ansi8LabTable()

    # The indexes of Ansi8Labs in order of lightness, the lower index first of two as light, and
    # the lightness at each, for NearestAnsi8 to search outward from a color's own lightness
    static [int[]] $Ansi8Order = [ColorMath]::Ansi8LightnessOrder()
    static [double[]] $Ansi8Lightness = [ColorMath]::Ansi8LightnessTable()

    hidden static [double[][]] Ansi8LabTable() {
        $steps = [int[]]@(0, 95, 135, 175, 215, 255)
        $labs = [double[][]]::new(240)
        for ($i = 0; $i -lt 216; $i++) {
            $red = $steps[[int][Math]::Floor($i / 36)]
            $green = $steps[[int][Math]::Floor($i / 6) % 6]
            $blue = $steps[$i % 6]
            $labs[$i] = [ColorMath]::ToOkLab([int[]]@($red, $green, $blue))
        }
        for ($i = 0; $i -lt 24; $i++) {
            $gray = 8 + 10 * $i
            $labs[216 + $i] = [ColorMath]::ToOkLab([int[]]@($gray, $gray, $gray))
        }
        return $labs
    }

    hidden static [int[]] Ansi8LightnessOrder() {
        $labs = [ColorMath]::Ansi8Labs
        $order = [int[]]::new(240)
        for ($i = 0; $i -lt 240; $i++) {
            $place = $i
            while ($place -gt 0 -and $labs[$order[$place - 1]][0] -gt $labs[$i][0]) {
                $order[$place] = $order[$place - 1]
                $place--
            }
            $order[$place] = $i
        }
        return $order
    }

    hidden static [double[]] Ansi8LightnessTable() {
        $lightness = [double[]]::new(240)
        for ($i = 0; $i -lt 240; $i++) {
            $lightness[$i] = [ColorMath]::Ansi8Labs[[ColorMath]::Ansi8Order[$i]][0]
        }
        return $lightness
    }

    # The weight of the difference in lightness in NearestAnsi8's distance: 0.6, which keeps a
    # dark saturated color on a code of its own hue rather than the gray of its lightness.
    static [double] $LightnessWeight = [BitConverter]::Int64BitsToDouble(0x3FE3333333333333)

    # The 256-color code nearest an sRGB color by OKLab distance, of codes 16-255, the lower code
    # of two as near. Codes 0-15 are left out, since the terminal's scheme sets their colors. The
    # distance is (LightnessWeight x the difference in L) squared, plus the squared differences
    # in a and b, added in that order. The search runs outward from the color's lightness and
    # stops on each side at a code whose lightness term alone is more than the distance of the
    # nearest code found.
    static [int] NearestAnsi8([int] $Red, [int] $Green, [int] $Blue) {
        $lab = [ColorMath]::ToOkLab([int[]]@($Red, $Green, $Blue))
        $labs = [ColorMath]::Ansi8Labs
        $order = [ColorMath]::Ansi8Order
        $lightness = [ColorMath]::Ansi8Lightness
        $weight = [ColorMath]::LightnessWeight

        # The first code in lightness order at least as light as the color
        $low = 0
        $high = 240
        while ($low -lt $high) {
            $middle = ($low + $high) -shr 1
            if ($lightness[$middle] -lt $lab[0]) { $low = $middle + 1 } else { $high = $middle }
        }

        $bestCode = 256
        $bestDistance = [double]::MaxValue
        for ($i = $low; $i -lt 240; $i++) {
            $dl = ($lightness[$i] - $lab[0]) * $weight
            $dlSquared = $dl * $dl
            if ($dlSquared -gt $bestDistance) { break }
            $entry = $labs[$order[$i]]
            $da = $entry[1] - $lab[1]
            $db = $entry[2] - $lab[2]
            $distance = $dlSquared + $da * $da + $db * $db
            $code = $order[$i] + 16
            if ($distance -lt $bestDistance -or ($distance -eq $bestDistance -and $code -lt $bestCode)) {
                $bestDistance = $distance
                $bestCode = $code
            }
        }
        for ($i = $low - 1; $i -ge 0; $i--) {
            $dl = ($lightness[$i] - $lab[0]) * $weight
            $dlSquared = $dl * $dl
            if ($dlSquared -gt $bestDistance) { break }
            $entry = $labs[$order[$i]]
            $da = $entry[1] - $lab[1]
            $db = $entry[2] - $lab[2]
            $distance = $dlSquared + $da * $da + $db * $db
            $code = $order[$i] + 16
            if ($distance -lt $bestDistance -or ($distance -eq $bestDistance -and $code -lt $bestCode)) {
                $bestDistance = $distance
                $bestCode = $code
            }
        }
        return $bestCode
    }

    # The sRGB color of a 256-color code 16-255: the 6x6x6 cube, whose channel steps are 0, 95,
    # 135, 175, 215 and 255, then the 24 grays, 8 to 238 by 10
    static [int[]] Ansi8Rgb([int] $Code) {
        if ($Code -ge 232) {
            $gray = 8 + 10 * ($Code - 232)
            return [int[]]@($gray, $gray, $gray)
        }
        $steps = [int[]]@(0, 95, 135, 175, 215, 255)
        $index = $Code - 16
        return [int[]]@($steps[[int][Math]::Floor($index / 36)], $steps[[int][Math]::Floor($index / 6) % 6], $steps[$index % 6])
    }

    # The relative luminance weights of red, green and blue, the 0.05 the contrast ratio adds to a
    # luminance, and white's luminance plus that 0.05
    static [double] $LuminanceRed = [BitConverter]::Int64BitsToDouble(0x3FCB367A0F9096BC)
    static [double] $LuminanceGreen = [BitConverter]::Int64BitsToDouble(0x3FE6E2EB1C432CA5)
    static [double] $LuminanceBlue = [BitConverter]::Int64BitsToDouble(0x3FB27BB2FEC56D5D)
    static [double] $ContrastOffset = [BitConverter]::Int64BitsToDouble(0x3FA999999999999A)
    static [double] $WhiteContrast = [BitConverter]::Int64BitsToDouble(0x3FF0CCCCCCCCCCCD)

    # Whether black text on an sRGB color has a higher contrast ratio than white text: (Y + 0.05)
    # / 0.05 against 1.05 / (Y + 0.05), Y the color's relative luminance, compared as (Y + 0.05)
    # squared against 0.05 x 1.05
    static [bool] BlackTextReads([int] $Red, [int] $Green, [int] $Blue) {
        $table = [ColorMath]::SrgbToLinear
        $luminance = [ColorMath]::LuminanceRed * $table[$Red] + [ColorMath]::LuminanceGreen * $table[$Green] + [ColorMath]::LuminanceBlue * $table[$Blue]
        $shifted = $luminance + [ColorMath]::ContrastOffset
        return $shifted * $shifted -gt [ColorMath]::ContrastOffset * [ColorMath]::WhiteContrast
    }

    # The relative luminance of an sRGB color, channels 0-255: its linear red, green and blue
    # times their weights, added in that order
    static [double] RelativeLuminance([int] $Red, [int] $Green, [int] $Blue) {
        $table = [ColorMath]::SrgbToLinear
        return [ColorMath]::LuminanceRed * $table[$Red] + [ColorMath]::LuminanceGreen * $table[$Green] + [ColorMath]::LuminanceBlue * $table[$Blue]
    }

    # The contrast ratio of two sRGB colors as WCAG 2 defines it, from 1 to 21: (L1 + 0.05) /
    # (L2 + 0.05), L1 the higher relative luminance and L2 the lower
    static [double] ContrastRatio([int[]] $First, [int[]] $Second) {
        $one = [ColorMath]::RelativeLuminance($First[0], $First[1], $First[2]) + [ColorMath]::ContrastOffset
        $two = [ColorMath]::RelativeLuminance($Second[0], $Second[1], $Second[2]) + [ColorMath]::ContrastOffset
        if ($one -ge $two) {
            return $one / $two
        }
        return $two / $one
    }

    # One color for each of Steps characters, blended evenly between the waypoints, which are RGB
    # arrays: RGB arrays, or 256-color codes with Ansi8. With at least as many steps as waypoints,
    # waypoint w is the step nearest w * (Steps - 1) / (waypoints - 1), a half rounded up, so
    # every waypoint is drawn, and the steps between two waypoints fall between them at a ratio
    # from 0 to 1. With fewer steps than waypoints, the steps are spread evenly over the whole
    # gradient. With OkLab the blend is in OKLab, else each channel on its own, rounded half to
    # even. The OKLab conversion is written out in the loop because a method call costs more than
    # the arithmetic of a step.
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
        $linear = [double[]]::new(3)
        $out = [object[]]::new($Steps)
        $segmentCount = $Waypoints.Count - 1

        # Each waypoint's step, when every waypoint can have one
        $anchors = $null
        if ($segmentCount -gt 1 -and $Steps -ge $Waypoints.Count) {
            $anchors = [int[]]::new($Waypoints.Count)
            for ($w = 0; $w -lt $Waypoints.Count; $w++) {
                $anchors[$w] = [int][Math]::Floor((2.0 * $w * ($Steps - 1) + $segmentCount) / (2.0 * $segmentCount))
            }
        }
        $segmentIndex = 0

        for ($step = 0; $step -lt $Steps; $step++) {
            if ($Steps -eq 1) {
                $segmentIndex = 0
                $ratio = 0.0
            } elseif ($segmentCount -eq 1) {
                $segmentIndex = 0
                $ratio = [double]$step / ($Steps - 1)
            } elseif ($null -ne $anchors) {
                while ($step -gt $anchors[$segmentIndex + 1]) {
                    $segmentIndex++
                }
                $ratio = [double]($step - $anchors[$segmentIndex]) / ($anchors[$segmentIndex + 1] - $anchors[$segmentIndex])
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
                # table then decides, so the result does not depend on [Math]::Pow.
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

            # The nearest 256-color code by OKLab distance, as Convert-RGBToANSI8 returns it
            $out[$step] = [ColorMath]::NearestAnsi8($rgb[0], $rgb[1], $rgb[2])
        }
        return $out
    }

    # The sRGB channel value 0-255 whose linear value is nearest the one given, the lower of two
    # as near, by binary search of SrgbToLinear; below 0 is 0 and above 1 is 255
    static [int] FromLinear([double] $Value) {
        if ($Value -le 0.0) {
            return 0
        }
        if ($Value -ge 1.0) {
            return 255
        }
        $table = [ColorMath]::SrgbToLinear
        $low = 0
        $high = 255
        while ($high - $low -gt 1) {
            $middle = ($low + $high) -shr 1
            if ($table[$middle] -le $Value) { $low = $middle } else { $high = $middle }
        }
        if ($table[$high] - $Value -lt $Value - $table[$low]) {
            return $high
        }
        return $low
    }

    # The sRGB channel values 0-255 of OKLab coordinates, out-of-range channels clamped
    static [int[]] FromOkLab([double[]] $Lab) {
        $lRoot = $Lab[0] + [ColorMath]::LA * $Lab[1] + [ColorMath]::LB * $Lab[2]
        $mRoot = $Lab[0] + [ColorMath]::MA * $Lab[1] + [ColorMath]::MB * $Lab[2]
        $sRoot = $Lab[0] + [ColorMath]::SA * $Lab[1] + [ColorMath]::SB * $Lab[2]
        $l = $lRoot * $lRoot * $lRoot
        $m = $mRoot * $mRoot * $mRoot
        $s = $sRoot * $sRoot * $sRoot
        return [int[]]@(
            [ColorMath]::FromLinear([ColorMath]::R1 * $l + [ColorMath]::R2 * $m + [ColorMath]::R3 * $s),
            [ColorMath]::FromLinear([ColorMath]::G1 * $l + [ColorMath]::G2 * $m + [ColorMath]::G3 * $s),
            [ColorMath]::FromLinear([ColorMath]::B1 * $l + [ColorMath]::B2 * $m + [ColorMath]::B3 * $s)
        )
    }

    # The names -GradientSpace, -GradientHue, -GradientEasing, -GradientRepeat and
    # -GradientDirection take, in order; the methods below take each option as its index in its list
    static [string[]] $SpaceNames = @('OKLab', 'RGB', 'LinearRGB', 'OKLCH', 'HSL', 'HSV', 'Lab', 'LCh')
    static [string[]] $HueNames = @('Shorter', 'Longer', 'Increasing', 'Decreasing')
    static [string[]] $EasingNames = @(
        'Linear', 'InSine', 'OutSine', 'InOutSine', 'InQuad', 'OutQuad', 'InOutQuad', 'InCubic', 'OutCubic',
        'InOutCubic', 'InQuart', 'OutQuart', 'InOutQuart', 'InQuint', 'OutQuint', 'InOutQuint', 'InExpo',
        'OutExpo', 'InOutExpo', 'InCirc', 'OutCirc', 'InOutCirc', 'InBack', 'OutBack', 'InOutBack',
        'InElastic', 'OutElastic', 'InOutElastic', 'InBounce', 'OutBounce', 'InOutBounce'
    )
    static [string[]] $RepeatNames = @('None', 'Repeat', 'Mirror')
    static [string[]] $DirectionNames = @('Forward', 'Reverse', 'CenterOut', 'EdgesIn')

    # The index of a name in a list of option names, compared without regard to case; 0, each
    # list's default, for a name not in it
    static [int] OptionIndex([string[]] $Names, [string] $Name) {
        for ($i = 0; $i -lt $Names.Count; $i++) {
            if ($Names[$i] -eq $Name) {
                return $i
            }
        }
        return 0
    }

    # A gradient's options as GradientRgb takes them: the indexes of the space, hue path, easing,
    # repeat and direction, then the bands, 0 for a smooth blend
    static [int[]] GradientOptions([string] $Space, [string] $Hue, [string] $Easing, [string] $Repeat, [string] $Direction, [int] $Steps) {
        return [int[]]@(
            [ColorMath]::OptionIndex([ColorMath]::SpaceNames, $Space),
            [ColorMath]::OptionIndex([ColorMath]::HueNames, $Hue),
            [ColorMath]::OptionIndex([ColorMath]::EasingNames, $Easing),
            [ColorMath]::OptionIndex([ColorMath]::RepeatNames, $Repeat),
            [ColorMath]::OptionIndex([ColorMath]::DirectionNames, $Direction),
            $Steps
        )
    }

    # Degrees in a radian and radians in a degree
    static [double] $DegreesPerRadian = [BitConverter]::Int64BitsToDouble(0x404CA5DC1A63C1F8)
    static [double] $RadiansPerDegree = [BitConverter]::Int64BitsToDouble(0x3F91DF46A2529D39)

    # Below these chromas a color counts as gray, with no hue: 2^-20 in OKLab and 2^-10 in CIELAB,
    # above the rounding left in an sRGB gray and below the chroma of any color one step from one
    static [double] $OkLchHueless = 1.0 / 1048576.0
    static [double] $LchHueless = 1.0 / 1024.0

    # CSS Color 4's matrices, row by row: linear sRGB to CIE XYZ with D65 white and back, and the
    # Bradford adaptation from D65 to D50 and back
    static [double[]] $ToXyz = @(
        [BitConverter]::Int64BitsToDouble(0x3FDA649C610130B1), [BitConverter]::Int64BitsToDouble(0x3FD6E2A96CCDCB17), [BitConverter]::Int64BitsToDouble(0x3FC719FE95DEFF92),
        [BitConverter]::Int64BitsToDouble(0x3FCB37C144093A36), [BitConverter]::Int64BitsToDouble(0x3FE6E2A96CCDCB17), [BitConverter]::Int64BitsToDouble(0x3FB27B32117F32DB),
        [BitConverter]::Int64BitsToDouble(0x3F93CB7548C0E484), [BitConverter]::Int64BitsToDouble(0x3FBE838C9112641F), [BitConverter]::Int64BitsToDouble(0x3FEE6AC26776AE5E)
    )
    static [double[]] $FromXyz = @(
        [BitConverter]::Int64BitsToDouble(0x4009ED81A61E643A), -[BitConverter]::Int64BitsToDouble(0x3FF8991F1A515886), -[BitConverter]::Int64BitsToDouble(0x3FDFE93D1B3918E5),
        -[BitConverter]::Int64BitsToDouble(0x3FEF040B3AF5D706), [BitConverter]::Int64BitsToDouble(0x3FFE03F67FB55A13), [BitConverter]::Int64BitsToDouble(0x3FA546B459182D75),
        [BitConverter]::Int64BitsToDouble(0x3FAC7B8BB9F1E66D), -[BitConverter]::Int64BitsToDouble(0x3FCA1BEABFC8688F), [BitConverter]::Int64BitsToDouble(0x3FF0E95AF667A0D1)
    )
    static [double[]] $D65ToD50 = @(
        [BitConverter]::Int64BitsToDouble(0x3FF0C45207B7C1D9), [BitConverter]::Int64BitsToDouble(0x3F977F626B1E2A0E), -[BitConverter]::Int64BitsToDouble(0x3FA9B2CCFC72D22E),
        [BitConverter]::Int64BitsToDouble(0x3F9E56C096E0CD1E), [BitConverter]::Int64BitsToDouble(0x3FEFB1A389F7B189), -[BitConverter]::Int64BitsToDouble(0x3F917BCB426228F0),
        -[BitConverter]::Int64BitsToDouble(0x3F82EE03EA54107A), [BitConverter]::Int64BitsToDouble(0x3F8ED54198AFD11C), [BitConverter]::Int64BitsToDouble(0x3FE80F5AA72DFEC3)
    )
    static [double[]] $D50ToD65 = @(
        [BitConverter]::Int64BitsToDouble(0x3FEE933CFF2FA1D7), -[BitConverter]::Int64BitsToDouble(0x3F97A71F125F4EBC), [BitConverter]::Int64BitsToDouble(0x3FB031C1FCB7565E),
        -[BitConverter]::Int64BitsToDouble(0x3F9D0CF2F724D576), [BitConverter]::Int64BitsToDouble(0x3FF028F0EF3DEA4D), [BitConverter]::Int64BitsToDouble(0x3F958BE3371EB644),
        [BitConverter]::Int64BitsToDouble(0x3F8938171900D5F0), -[BitConverter]::Int64BitsToDouble(0x3F94FFF50C39F78C), [BitConverter]::Int64BitsToDouble(0x3FF5492DC80EC342)
    )

    # D50 white's X and Z, Y being 1: 0.3457 / 0.3585 and (1 - 0.3457 - 0.3585) / 0.3585, as CSS
    # writes them
    static [double] $WhiteX = [BitConverter]::Int64BitsToDouble(0x3FEEDB829B3E0DDB)
    static [double] $WhiteZ = [BitConverter]::Int64BitsToDouble(0x3FEA6741C471F7DC)

    # CIELAB's 216/24389 and 24389/27
    static [double] $LabEpsilon = [BitConverter]::Int64BitsToDouble(0x3F822354D28F7CD6)
    static [double] $LabKappa = [BitConverter]::Int64BitsToDouble(0x408C3A5ED097B426)

    # A matrix of nine numbers, row by row, times a column, each row's products added left to right
    hidden static [double[]] Multiply([double[]] $Matrix, [double[]] $Column) {
        return [double[]]@(
            ($Matrix[0] * $Column[0] + $Matrix[1] * $Column[1] + $Matrix[2] * $Column[2]),
            ($Matrix[3] * $Column[0] + $Matrix[4] * $Column[1] + $Matrix[5] * $Column[2]),
            ($Matrix[6] * $Column[0] + $Matrix[7] * $Column[1] + $Matrix[8] * $Column[2])
        )
    }

    # The CIELAB coordinates L, a and b of an sRGB color, with D50 white, as CSS lab() defines them
    static [double[]] ToLab([int[]] $Rgb) {
        $table = [ColorMath]::SrgbToLinear
        $xyz = [ColorMath]::Multiply([ColorMath]::ToXyz, [double[]]@($table[$Rgb[0]], $table[$Rgb[1]], $table[$Rgb[2]]))
        $d50 = [ColorMath]::Multiply([ColorMath]::D65ToD50, $xyz)
        $scaled = [double[]]@(($d50[0] / [ColorMath]::WhiteX), $d50[1], ($d50[2] / [ColorMath]::WhiteZ))
        $f = [double[]]::new(3)
        for ($k = 0; $k -lt 3; $k++) {
            if ($scaled[$k] -gt [ColorMath]::LabEpsilon) {
                $f[$k] = [ColorMath]::CubeRoot($scaled[$k])
            } else {
                $f[$k] = ([ColorMath]::LabKappa * $scaled[$k] + 16.0) / 116.0
            }
        }
        return [double[]]@((116.0 * $f[1] - 16.0), (500.0 * ($f[0] - $f[1])), (200.0 * ($f[1] - $f[2])))
    }

    # The sRGB channel values 0-255 of CIELAB coordinates with D50 white, out-of-range channels
    # clamped
    static [int[]] FromLab([double[]] $Lab) {
        $epsilon = [ColorMath]::LabEpsilon
        $kappa = [ColorMath]::LabKappa
        $fy = ($Lab[0] + 16.0) / 116.0
        $fx = $Lab[1] / 500.0 + $fy
        $fz = $fy - $Lab[2] / 200.0
        if ($fx * $fx * $fx -gt $epsilon) {
            $x = $fx * $fx * $fx
        } else {
            $x = (116.0 * $fx - 16.0) / $kappa
        }
        if ($Lab[0] -gt $kappa * $epsilon) {
            $y = $fy * $fy * $fy
        } else {
            $y = $Lab[0] / $kappa
        }
        if ($fz * $fz * $fz -gt $epsilon) {
            $z = $fz * $fz * $fz
        } else {
            $z = (116.0 * $fz - 16.0) / $kappa
        }
        $d65 = [ColorMath]::Multiply([ColorMath]::D50ToD65, [double[]]@(($x * [ColorMath]::WhiteX), $y, ($z * [ColorMath]::WhiteZ)))
        $linear = [ColorMath]::Multiply([ColorMath]::FromXyz, $d65)
        return [int[]]@([ColorMath]::FromLinear($linear[0]), [ColorMath]::FromLinear($linear[1]), [ColorMath]::FromLinear($linear[2]))
    }

    # Lightness, chroma, hue in degrees and 1 for no hue, from a lightness and two opponent axes;
    # a chroma below HuelessBelow has no hue
    hidden static [double[]] Polar([double[]] $Lab, [double] $HuelessBelow) {
        $chroma = [Math]::Sqrt($Lab[1] * $Lab[1] + $Lab[2] * $Lab[2])
        $hue = [ColorMath]::Atan2($Lab[2], $Lab[1]) * [ColorMath]::DegreesPerRadian
        if ($hue -lt 0.0) {
            $hue += 360.0
        }
        $hueless = 0.0
        if ($chroma -lt $HuelessBelow) {
            $hueless = 1.0
        }
        return [double[]]@($Lab[0], $chroma, $hue, $hueless)
    }

    # A lightness and two opponent axes from lightness, chroma and hue in degrees
    hidden static [double[]] FromPolar([double] $Lightness, [double] $Chroma, [double] $Hue) {
        $radians = $Hue * [ColorMath]::RadiansPerDegree
        return [double[]]@($Lightness, ($Chroma * [ColorMath]::Cos($radians)), ($Chroma * [ColorMath]::Sin($radians)))
    }

    # The hue in degrees of channels from 0 to 1 whose largest is Max, Range above the smallest
    hidden static [double] SextantHue([double] $R, [double] $G, [double] $B, [double] $Max, [double] $Range) {
        if ($Max -eq $R) {
            $wrap = 0.0
            if ($G -lt $B) {
                $wrap = 6.0
            }
            $sextant = ($G - $B) / $Range + $wrap
        } elseif ($Max -eq $G) {
            $sextant = ($B - $R) / $Range + 2.0
        } else {
            $sextant = ($R - $G) / $Range + 4.0
        }
        return $sextant * 60.0
    }

    # HSL saturation, lightness and hue of an sRGB color, then 1 for a gray, which has no hue
    hidden static [double[]] ToHsl([int[]] $Rgb) {
        $r = $Rgb[0] / 255.0
        $g = $Rgb[1] / 255.0
        $b = $Rgb[2] / 255.0
        $max = [Math]::Max([Math]::Max($r, $g), $b)
        $min = [Math]::Min([Math]::Min($r, $g), $b)
        $lightness = ($max + $min) / 2.0
        $range = $max - $min
        if ($range -eq 0.0) {
            return [double[]]@(0.0, $lightness, 0.0, 1.0)
        }
        $saturation = $range / (1.0 - [Math]::Abs(2.0 * $lightness - 1.0))
        return [double[]]@($saturation, $lightness, [ColorMath]::SextantHue($r, $g, $b, $max, $range), 0.0)
    }

    # HSV saturation, value and hue of an sRGB color, then 1 for a gray, which has no hue
    hidden static [double[]] ToHsv([int[]] $Rgb) {
        $r = $Rgb[0] / 255.0
        $g = $Rgb[1] / 255.0
        $b = $Rgb[2] / 255.0
        $max = [Math]::Max([Math]::Max($r, $g), $b)
        $min = [Math]::Min([Math]::Min($r, $g), $b)
        $range = $max - $min
        if ($range -eq 0.0) {
            return [double[]]@(0.0, $max, 0.0, 1.0)
        }
        return [double[]]@(($range / $max), $max, [ColorMath]::SextantHue($r, $g, $b, $max, $range), 0.0)
    }

    # The sRGB channel values of a hue in degrees from 0 to 360 and a saturation and value from 0
    # to 1: C = V * S, X = C * (1 - |(H / 60) mod 2 - 1|), m = V - C, each channel rounded half to
    # even after multiplying by 255
    static [int[]] HsvToRgb([double] $H, [double] $S, [double] $V) {
        $chroma = $V * $S
        $sector = $H / 60.0
        $x = $chroma * (1.0 - [Math]::Abs(($sector - 2.0 * [Math]::Floor($sector / 2.0)) - 1.0))
        $offset = $V - $chroma
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

    # A color's coordinates in a space, by its index in SpaceNames: three numbers, then 1 for a
    # color with no hue and 0 for one with. The round spaces keep their hue last, in degrees from 0
    # to 360: OKLCH and LCh hold lightness, chroma and hue; HSL saturation, lightness and hue; HSV
    # saturation, value and hue, the saturations and lightness and value from 0 to 1.
    static [double[]] ToCoordinates([int[]] $Rgb, [int] $Space) {
        switch ($Space) {
            1 { return [double[]]@($Rgb[0], $Rgb[1], $Rgb[2], 0.0) }
            2 {
                $table = [ColorMath]::SrgbToLinear
                return [double[]]@($table[$Rgb[0]], $table[$Rgb[1]], $table[$Rgb[2]], 0.0)
            }
            3 { return [ColorMath]::Polar([ColorMath]::ToOkLab($Rgb), [ColorMath]::OkLchHueless) }
            4 { return [ColorMath]::ToHsl($Rgb) }
            5 { return [ColorMath]::ToHsv($Rgb) }
            6 {
                $lab = [ColorMath]::ToLab($Rgb)
                return [double[]]@($lab[0], $lab[1], $lab[2], 0.0)
            }
            7 { return [ColorMath]::Polar([ColorMath]::ToLab($Rgb), [ColorMath]::LchHueless) }
        }
        $lab = [ColorMath]::ToOkLab($Rgb)
        return [double[]]@($lab[0], $lab[1], $lab[2], 0.0)
    }

    # The two hues a blend runs between, after CSS Color 4's fix-up for the path, by its index in
    # HueNames: a color with no hue takes the other's, and one hue moves a turn so the blend goes
    # the chosen way round
    hidden static [double[]] HueEnds([double[]] $A, [double[]] $B, [int] $Path) {
        $h1 = $A[2]
        $h2 = $B[2]
        if ($A[3] -ne 0.0 -and $B[3] -ne 0.0) {
            $h1 = 0.0
            $h2 = 0.0
        } elseif ($A[3] -ne 0.0) {
            $h1 = $B[2]
        } elseif ($B[3] -ne 0.0) {
            $h2 = $A[2]
        }
        $difference = $h2 - $h1
        switch ($Path) {
            0 {
                if ($difference -gt 180.0) {
                    $h1 += 360.0
                } elseif ($difference -lt -180.0) {
                    $h2 += 360.0
                }
            }
            1 {
                if ($difference -gt 0.0 -and $difference -lt 180.0) {
                    $h1 += 360.0
                } elseif ($difference -gt -180.0 -and $difference -le 0.0) {
                    $h2 += 360.0
                }
            }
            2 {
                if ($difference -lt 0.0) {
                    $h2 += 360.0
                }
            }
            3 {
                if ($difference -gt 0.0) {
                    $h1 += 360.0
                }
            }
        }
        return [double[]]@($h1, $h2)
    }

    # The color at Ratio along the blend from one color to another, given both colors and their
    # coordinates in the space, by its index in SpaceNames, with the hue path by its index in
    # HueNames: exactly the first at 0 and the second at 1
    static [int[]] BlendColors([int[]] $From, [int[]] $To, [double[]] $A, [double[]] $B, [double] $Ratio, [int] $Space, [int] $Path) {
        if ($Ratio -eq 0.0) {
            return [int[]]$From.Clone()
        }
        if ($Ratio -eq 1.0) {
            return [int[]]$To.Clone()
        }
        $mix0 = $A[0] + ($B[0] - $A[0]) * $Ratio
        $mix1 = $A[1] + ($B[1] - $A[1]) * $Ratio
        $mix2 = $A[2] + ($B[2] - $A[2]) * $Ratio
        switch ($Space) {
            0 { return [ColorMath]::FromOkLab([double[]]@($mix0, $mix1, $mix2)) }
            1 {
                return [int[]]@(
                    [int][Math]::Round($mix0, [MidpointRounding]::ToEven),
                    [int][Math]::Round($mix1, [MidpointRounding]::ToEven),
                    [int][Math]::Round($mix2, [MidpointRounding]::ToEven)
                )
            }
            2 { return [int[]]@([ColorMath]::FromLinear($mix0), [ColorMath]::FromLinear($mix1), [ColorMath]::FromLinear($mix2)) }
            6 { return [ColorMath]::FromLab([double[]]@($mix0, $mix1, $mix2)) }
        }
        $ends = [ColorMath]::HueEnds($A, $B, $Path)
        $turned = $ends[0] + ($ends[1] - $ends[0]) * $Ratio
        $hue = $turned - 360.0 * [Math]::Floor($turned / 360.0)
        switch ($Space) {
            3 { return [ColorMath]::FromOkLab([ColorMath]::FromPolar($mix0, $mix1, $hue)) }
            7 { return [ColorMath]::FromLab([ColorMath]::FromPolar($mix0, $mix1, $hue)) }
            4 { return [ColorMath]::HslToRgb($hue, $mix0, $mix1) }
        }
        return [ColorMath]::HsvToRgb($hue, $mix0, $mix1)
    }

    # Back's overshoot and the factor InOutBack scales it by: 1.70158 and 1.525
    static [double] $Back = [BitConverter]::Int64BitsToDouble(0x3FFB39ABF3387161)
    static [double] $BackInOutScale = [BitConverter]::Int64BitsToDouble(0x3FF8666666666666)

    # The value at X from 0 to 1 of an easing curve, by its index in EasingNames, as easings.net
    # writes the curves. Back and Elastic overshoot below 0 and above 1.
    static [double] Ease([int] $Easing, [double] $X) {
        $overshoot = [ColorMath]::Back
        switch ($Easing) {
            0 { return $X }
            1 { return 1.0 - [ColorMath]::Cos(($X * [ColorMath]::Pi) / 2.0) }
            2 { return [ColorMath]::Sin(($X * [ColorMath]::Pi) / 2.0) }
            3 { return -([ColorMath]::Cos([ColorMath]::Pi * $X) - 1.0) / 2.0 }
            4 { return $X * $X }
            5 {
                $rest = 1.0 - $X
                return 1.0 - $rest * $rest
            }
            6 {
                if ($X -lt 0.5) {
                    return 2.0 * $X * $X
                }
                $rest = -2.0 * $X + 2.0
                return 1.0 - $rest * $rest / 2.0
            }
            7 { return $X * $X * $X }
            8 {
                $rest = 1.0 - $X
                return 1.0 - $rest * $rest * $rest
            }
            9 {
                if ($X -lt 0.5) {
                    return 4.0 * $X * $X * $X
                }
                $rest = -2.0 * $X + 2.0
                return 1.0 - $rest * $rest * $rest / 2.0
            }
            10 { return $X * $X * $X * $X }
            11 {
                $rest = 1.0 - $X
                return 1.0 - $rest * $rest * $rest * $rest
            }
            12 {
                if ($X -lt 0.5) {
                    return 8.0 * $X * $X * $X * $X
                }
                $rest = -2.0 * $X + 2.0
                return 1.0 - $rest * $rest * $rest * $rest / 2.0
            }
            13 { return $X * $X * $X * $X * $X }
            14 {
                $rest = 1.0 - $X
                return 1.0 - $rest * $rest * $rest * $rest * $rest
            }
            15 {
                if ($X -lt 0.5) {
                    return 16.0 * $X * $X * $X * $X * $X
                }
                $rest = -2.0 * $X + 2.0
                return 1.0 - $rest * $rest * $rest * $rest * $rest / 2.0
            }
            16 {
                if ($X -eq 0.0) {
                    return 0.0
                }
                return [ColorMath]::Exp2(10.0 * $X - 10.0)
            }
            17 {
                if ($X -eq 1.0) {
                    return 1.0
                }
                return 1.0 - [ColorMath]::Exp2(-10.0 * $X)
            }
            18 {
                if ($X -eq 0.0) {
                    return 0.0
                }
                if ($X -eq 1.0) {
                    return 1.0
                }
                if ($X -lt 0.5) {
                    return [ColorMath]::Exp2(20.0 * $X - 10.0) / 2.0
                }
                return (2.0 - [ColorMath]::Exp2(-20.0 * $X + 10.0)) / 2.0
            }
            19 { return 1.0 - [Math]::Sqrt(1.0 - $X * $X) }
            20 {
                $rest = $X - 1.0
                return [Math]::Sqrt(1.0 - $rest * $rest)
            }
            21 {
                if ($X -lt 0.5) {
                    $twice = 2.0 * $X
                    return (1.0 - [Math]::Sqrt(1.0 - $twice * $twice)) / 2.0
                }
                $rest = -2.0 * $X + 2.0
                return ([Math]::Sqrt(1.0 - $rest * $rest) + 1.0) / 2.0
            }
            22 { return ($overshoot + 1.0) * $X * $X * $X - $overshoot * $X * $X }
            23 {
                $rest = $X - 1.0
                return 1.0 + ($overshoot + 1.0) * $rest * $rest * $rest + $overshoot * $rest * $rest
            }
            24 {
                $scaled = $overshoot * [ColorMath]::BackInOutScale
                if ($X -lt 0.5) {
                    $twice = 2.0 * $X
                    return ($twice * $twice * (($scaled + 1.0) * 2.0 * $X - $scaled)) / 2.0
                }
                $rest = 2.0 * $X - 2.0
                return ($rest * $rest * (($scaled + 1.0) * ($X * 2.0 - 2.0) + $scaled) + 2.0) / 2.0
            }
            25 {
                if ($X -eq 0.0) {
                    return 0.0
                }
                if ($X -eq 1.0) {
                    return 1.0
                }
                $period = (2.0 * [ColorMath]::Pi) / 3.0
                return -[ColorMath]::Exp2(10.0 * $X - 10.0) * [ColorMath]::Sin(($X * 10.0 - 10.75) * $period)
            }
            26 {
                if ($X -eq 0.0) {
                    return 0.0
                }
                if ($X -eq 1.0) {
                    return 1.0
                }
                $period = (2.0 * [ColorMath]::Pi) / 3.0
                return [ColorMath]::Exp2(-10.0 * $X) * [ColorMath]::Sin(($X * 10.0 - 0.75) * $period) + 1.0
            }
            27 {
                if ($X -eq 0.0) {
                    return 0.0
                }
                if ($X -eq 1.0) {
                    return 1.0
                }
                $period = (2.0 * [ColorMath]::Pi) / 4.5
                if ($X -lt 0.5) {
                    return -([ColorMath]::Exp2(20.0 * $X - 10.0) * [ColorMath]::Sin((20.0 * $X - 11.125) * $period)) / 2.0
                }
                return ([ColorMath]::Exp2(-20.0 * $X + 10.0) * [ColorMath]::Sin((20.0 * $X - 11.125) * $period)) / 2.0 + 1.0
            }
            28 { return 1.0 - [ColorMath]::OutBounce(1.0 - $X) }
            29 { return [ColorMath]::OutBounce($X) }
            30 {
                if ($X -lt 0.5) {
                    return (1.0 - [ColorMath]::OutBounce(1.0 - 2.0 * $X)) / 2.0
                }
                return (1.0 + [ColorMath]::OutBounce(2.0 * $X - 1.0)) / 2.0
            }
        }
        return $X
    }

    # easings.net's easeOutBounce: four parabolas, each lower bounce a quarter as high
    hidden static [double] OutBounce([double] $X) {
        if ($X -lt 1.0 / 2.75) {
            return 7.5625 * $X * $X
        }
        if ($X -lt 2.0 / 2.75) {
            $rest = $X - 1.5 / 2.75
            return 7.5625 * $rest * $rest + 0.75
        }
        if ($X -lt 2.5 / 2.75) {
            $rest = $X - 2.25 / 2.75
            return 7.5625 * $rest * $rest + 0.9375
        }
        $rest = $X - 2.625 / 2.75
        return 7.5625 * $rest * $rest + 0.984375
    }

    # A gradient color with its place after an '@', as a percent: 'Gold@40' is Gold at 0.4. The
    # place is the digits over 10 to the power of the decimals plus 2, in one division; above 100
    # is 1. Returns the color and the place, or $null for a text with no place.
    static [object[]] SplitPlace([string] $Text) {
        $at = $Text.LastIndexOf('@')
        if ($at -lt 0) {
            return $null
        }
        $place = $Text.Substring($at + 1).Trim()
        if ($place.EndsWith('%')) {
            $place = $place.Substring(0, $place.Length - 1).TrimEnd()
        }
        $whole = $place
        $fraction = ''
        $dot = $place.IndexOf('.')
        if ($dot -ge 0) {
            $whole = $place.Substring(0, $dot)
            $fraction = $place.Substring($dot + 1)
        }
        $digits = $whole + $fraction
        if ($digits.Length -eq 0 -or $digits.Length -gt 15) {
            return $null
        }
        $mantissa = [long]0
        foreach ($digit in $digits.ToCharArray()) {
            $code = [int]$digit
            if ($code -lt 48 -or $code -gt 57) {
                return $null
            }
            $mantissa = $mantissa * 10 + ($code - 48)
        }
        $scale = 100.0
        for ($k = 0; $k -lt $fraction.Length; $k++) {
            $scale *= 10.0
        }
        return [object[]]@($Text.Substring(0, $at).TrimEnd(), [Math]::Min(1.0, [double]$mantissa / $scale))
    }

    # Each stop's place from 0 to 1 as CSS places color stops, given each stop's place or $null:
    # the first at 0 and the last at 1 unless placed, a place before an earlier stop's moved up to
    # it, and the stops with none spread evenly between the placed ones around them
    static [double[]] ResolvePlaces([object[]] $Given) {
        $count = $Given.Count
        $last = $count - 1
        $known = [object[]]::new($count)
        for ($k = 0; $k -lt $count; $k++) {
            if ($null -ne $Given[$k]) {
                $known[$k] = [Math]::Min(1.0, [Math]::Max(0.0, [double]$Given[$k]))
            }
        }
        if ($null -eq $known[0]) {
            $known[0] = 0.0
        }
        if ($null -eq $known[$last]) {
            $known[$last] = 1.0
        }
        $highest = 0.0
        for ($k = 0; $k -lt $count; $k++) {
            if ($null -eq $known[$k]) {
                continue
            }
            if ($known[$k] -lt $highest) {
                $known[$k] = $highest
            } else {
                $highest = $known[$k]
            }
        }
        $places = [double[]]::new($count)
        $k = 0
        while ($k -le $last) {
            if ($null -ne $known[$k]) {
                $places[$k] = $known[$k]
                $k++
                continue
            }
            $before = $k - 1
            $after = $k
            while ($null -eq $known[$after]) {
                $after++
            }
            $from = $places[$before]
            $to = [double]$known[$after]
            $span = [double]($after - $before)
            for ($i = $k; $i -lt $after; $i++) {
                $places[$i] = $from + ($to - $from) * (($i - $before) / $span)
            }
            $k = $after
        }
        return $places
    }

    # The segment a place falls in among stops' places, and its ratio from the segment's first
    # stop to its last: the first stop's color at or before the first place, the last's at or
    # after the last, and the later stop's where two share a place
    static [double[]] Locate([double[]] $Places, [double] $Place) {
        $last = $Places.Count - 1
        if ($Place -le $Places[0]) {
            return [double[]]@(0.0, 0.0)
        }
        if ($Place -ge $Places[$last]) {
            return [double[]]@(($last - 1), 1.0)
        }
        $segment = 0
        while ($segment + 1 -lt $last -and $Places[$segment + 1] -le $Place) {
            $segment++
        }
        return [double[]]@($segment, (($Place - $Places[$segment]) / ($Places[$segment + 1] - $Places[$segment])))
    }

    # A place carried back into the span from the first stop's place to the last's by the repeat,
    # by its index in RepeatNames: unchanged inside the span or with no repeat
    static [double] RepeatPlace([double] $Place, [double] $First, [double] $Last, [int] $Repeat) {
        $span = $Last - $First
        if ($Repeat -eq 0 -or $span -le 0.0 -or ($Place -ge $First -and $Place -le $Last)) {
            return $Place
        }
        $turns = ($Place - $First) / $span
        if ($Repeat -eq 2) {
            $within = $turns - 2.0 * [Math]::Floor($turns / 2.0)
            if ($within -gt 1.0) {
                $within = 2.0 - $within
            }
        } else {
            $within = $turns - [Math]::Floor($turns)
        }
        return $First + $within * $span
    }

    # A place moved to the place of its band when the span from the first stop's place to the
    # last's is cut into Bands: band k of n at k / (n - 1) of the span, so the first band is the
    # first stop and the last band the last; a single band is the first stop, and 0 bands leave
    # the place as it is
    static [double] BandPlace([double] $Place, [double] $First, [double] $Last, [int] $Bands) {
        $span = $Last - $First
        if ($Bands -eq 0 -or $span -le 0.0) {
            return $Place
        }
        if ($Bands -eq 1) {
            return $First
        }
        $fraction = [Math]::Min(1.0, [Math]::Max(0.0, ($Place - $First) / $span))
        $band = [Math]::Min([int][Math]::Floor($fraction * $Bands), $Bands - 1)
        return $First + ($band / ($Bands - 1)) * $span
    }

    # The place along the gradient of a place from 0 to 1 across the text, by the direction's
    # index in DirectionNames
    static [double] DirectionPlace([double] $Across, [int] $Direction) {
        switch ($Direction) {
            1 { return 1.0 - $Across }
            2 { return [Math]::Abs(2.0 * $Across - 1.0) }
            3 { return 1.0 - [Math]::Abs(2.0 * $Across - 1.0) }
        }
        return $Across
    }

    # The place along the gradient a place across the text maps to, through the direction, the
    # easing curve, the repeat and the bands, in that order, with Options as GradientOptions
    # returns them
    static [double] Shape([double] $Across, [double[]] $Places, [int[]] $Options) {
        $first = $Places[0]
        $last = $Places[$Places.Count - 1]
        $eased = [ColorMath]::Ease($Options[2], [ColorMath]::DirectionPlace($Across, $Options[4]))
        return [ColorMath]::BandPlace([ColorMath]::RepeatPlace($eased, $first, $last, $Options[3]), $first, $last, $Options[5])
    }

    # A stop's place moved to the nearest place a character takes: the characters' places are
    # Offset + Interval x j over Denominator, from Lowest to Highest, and a half rounds up. Evenly
    # spaced stops, stop EvenIndex of Count, are placed in integers, exactly; EvenIndex is -1 for
    # stops that are not.
    static [int] Snapped([double] $Place, [int] $EvenIndex, [int] $Count, [int] $Denominator, [int] $Interval, [int] $Offset, [int] $Lowest, [int] $Highest) {
        if ($EvenIndex -ge 0) {
            # j = floor((index x denominator / spans - offset) / interval + 1/2) in integers; the
            # sum is never below 0, since an offset of 1 comes with an interval of 2
            $spans = $Count - 1
            $sum = 2 * $EvenIndex * $Denominator + $Interval * $spans - 2 * $Offset * $spans
            $divisor = 2 * $Interval * $spans
            $numerator = $Offset + $Interval * (($sum - $sum % $divisor) / $divisor)
        } else {
            $j = [Math]::Max(0.0, [Math]::Floor(($Place * $Denominator - $Offset) / $Interval + 0.5))
            $numerator = $Offset + $Interval * [int]$j
        }
        return [Math]::Min($Highest, [Math]::Max($Lowest, $numerator))
    }

    # The numerator over Denominator of character I's place along the gradient, by the
    # direction's index in DirectionNames
    hidden static [int] CharacterNumerator([int] $I, [int] $Denominator, [int] $Direction) {
        switch ($Direction) {
            1 { return $Denominator - $I }
            2 { return [Math]::Abs(2 * $I - $Denominator) }
            3 { return $Denominator - [Math]::Abs(2 * $I - $Denominator) }
        }
        return $I
    }

    # Each of Count stops' place, or $null, from a list of places that may be shorter or $null
    hidden static [object[]] StopPlaces([object[]] $Places, [int] $Count) {
        $given = [object[]]::new($Count)
        if ($null -ne $Places) {
            for ($k = 0; $k -lt [Math]::Min($Places.Count, $Count); $k++) {
                $given[$k] = $Places[$k]
            }
        }
        return $given
    }

    # The color at At, a segment and the ratio along it as Locate returns them
    hidden static [int[]] BlendAt([int[][]] $Rgbs, [double[][]] $Coordinates, [double[]] $At, [int] $Space, [int] $Hue) {
        $segment = [int]$At[0]
        return [ColorMath]::BlendColors($Rgbs[$segment], $Rgbs[$segment + 1], $Coordinates[$segment], $Coordinates[$segment + 1], $At[1], $Space, $Hue)
    }

    # The colors of a gradient across Count characters, as RGB arrays: Stops are RGB arrays, Places
    # each stop's place from 0 to 1 or $null, and Options as GradientOptions returns them. With
    # evenly spaced stops and no option but a space of OKLab or RGB, the colors are Blend's.
    static [object[]] GradientRgb([object[]] $Stops, [object[]] $Places, [int] $Count, [int[]] $Options) {
        if ($Count -le 0 -or $Stops.Count -eq 0) {
            return [object[]]@()
        }
        $rgbs = [int[][]]::new($Stops.Count)
        for ($k = 0; $k -lt $Stops.Count; $k++) {
            $rgbs[$k] = [int[]]$Stops[$k]
        }
        $out = [object[]]::new($Count)
        if ($Stops.Count -eq 1) {
            for ($i = 0; $i -lt $Count; $i++) {
                $out[$i] = [int[]]$rgbs[0].Clone()
            }
            return $out
        }
        $resolved = [ColorMath]::ResolvePlaces([ColorMath]::StopPlaces($Places, $Stops.Count))
        $spans = $Stops.Count - 1
        $even = $true
        for ($k = 0; $k -le $spans; $k++) {
            if ($resolved[$k] -ne $k / $spans) {
                $even = $false
            }
        }
        $space = $Options[0]
        $hue = $Options[1]
        if ($even -and $space -le 1 -and $Options[2] -eq 0 -and $Options[3] -eq 0 -and $Options[4] -eq 0 -and $Options[5] -eq 0) {
            return [ColorMath]::Blend($rgbs, $Count, $false, $space -eq 0)
        }

        $coordinates = [double[][]]::new($Stops.Count)
        for ($k = 0; $k -lt $Stops.Count; $k++) {
            $coordinates[$k] = [ColorMath]::ToCoordinates($rgbs[$k], $space)
        }
        if ($Count -eq 1) {
            $out[0] = [ColorMath]::BlendAt($rgbs, $coordinates, [ColorMath]::Locate($resolved, [ColorMath]::Shape(0.0, $resolved, $Options)), $space, $hue)
            return $out
        }

        # Each character's place is a numerator over Count - 1, after the direction. The places
        # the characters take are every numerator from 0 to Count - 1, or, from the middle out or
        # the ends in, every other one.
        $denominator = $Count - 1
        $direction = $Options[4]
        $interval = 1
        $offset = 0
        $lowest = 0
        $highest = $denominator
        if ($direction -eq 2) {
            $interval = 2
            $offset = $denominator % 2
            $lowest = $denominator % 2
        } elseif ($direction -eq 3) {
            $interval = 2
            $highest = $denominator - $denominator % 2
        }
        $width = $highest - $lowest
        if (($width - $width % $interval) / $interval + 1 -lt $Stops.Count) {
            for ($i = 0; $i -lt $Count; $i++) {
                $across = [ColorMath]::CharacterNumerator($i, $denominator, $direction) / $denominator
                $out[$i] = [ColorMath]::BlendAt($rgbs, $coordinates, [ColorMath]::Locate($resolved, [ColorMath]::Shape($across, $resolved, $Options)), $space, $hue)
            }
            return $out
        }

        # With a place for every stop, each stop moves to the nearest character's place
        $numerators = [int[]]::new($Stops.Count)
        for ($k = 0; $k -lt $Stops.Count; $k++) {
            $evenIndex = -1
            if ($even) {
                $evenIndex = $k
            }
            $numerators[$k] = [ColorMath]::Snapped($resolved[$k], $evenIndex, $Stops.Count, $denominator, $interval, $offset, $lowest, $highest)
        }
        $wholeSpan = $numerators[0] -eq 0 -and $numerators[$spans] -eq $denominator
        if ($Options[2] -eq 0 -and $Options[5] -eq 0 -and ($Options[3] -eq 0 -or $wholeSpan)) {
            $stopNumerators = [double[]]::new($Stops.Count)
            for ($k = 0; $k -lt $Stops.Count; $k++) {
                $stopNumerators[$k] = $numerators[$k]
            }
            for ($i = 0; $i -lt $Count; $i++) {
                $at = [ColorMath]::Locate($stopNumerators, [ColorMath]::CharacterNumerator($i, $denominator, $direction))
                $out[$i] = [ColorMath]::BlendAt($rgbs, $coordinates, $at, $space, $hue)
            }
            return $out
        }
        $snappedPlaces = [double[]]::new($Stops.Count)
        for ($k = 0; $k -lt $Stops.Count; $k++) {
            $snappedPlaces[$k] = $numerators[$k] / $denominator
        }
        for ($i = 0; $i -lt $Count; $i++) {
            $across = [ColorMath]::CharacterNumerator($i, $denominator, $direction) / $denominator
            $out[$i] = [ColorMath]::BlendAt($rgbs, $coordinates, [ColorMath]::Locate($snappedPlaces, [ColorMath]::Shape($across, $snappedPlaces, $Options)), $space, $hue)
        }
        return $out
    }

    # The color at a place from 0 to 1 along a gradient, for a single color that moves along it;
    # stops keep their exact places, since there are no characters to move them to. A place
    # outside 0 to 1 is the nearer end, and NaN is 0.
    static [int[]] GradientRgbAt([object[]] $Stops, [object[]] $Places, [double] $Place, [int[]] $Options) {
        if ($Stops.Count -eq 0) {
            return [int[]]@(128, 128, 128)
        }
        if ($Stops.Count -eq 1) {
            return [int[]]([int[]]$Stops[0]).Clone()
        }
        $along = 0.0
        if (-not [double]::IsNaN($Place)) {
            $along = [Math]::Min(1.0, [Math]::Max(0.0, $Place))
        }
        $resolved = [ColorMath]::ResolvePlaces([ColorMath]::StopPlaces($Places, $Stops.Count))
        $at = [ColorMath]::Locate($resolved, [ColorMath]::Shape($along, $resolved, $Options))
        $segment = [int]$at[0]
        $from = [int[]]$Stops[$segment]
        $to = [int[]]$Stops[$segment + 1]
        return [ColorMath]::BlendColors($from, $to, [ColorMath]::ToCoordinates($from, $Options[0]), [ColorMath]::ToCoordinates($to, $Options[0]), $at[1], $Options[0], $Options[1])
    }
}
