#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeDiscovery {
    # PowerShell 7.2 and later remove escape codes from transcripts, and Write-ColorEX writes a
    # line of several colors as one call there when the host shows escape codes
    $composesLines = $PSVersionTable.PSVersion -ge [version]'7.2' -and $Host.UI.SupportsVirtualTerminal
    $isDesktop = $PSVersionTable.PSEdition -eq 'Desktop'

    $encodingCases = @(
        @{ Encoding = 'utf8'; Bytes = 'C3 A9' }
        @{ Encoding = 'utf8NoBOM'; Bytes = 'C3 A9' }
        @{ Encoding = 'default'; Bytes = 'C3 A9' }
        @{ Encoding = 'utf8BOM'; Bytes = 'EF BB BF C3 A9' }
        @{ Encoding = 'unicode'; Bytes = 'FF FE E9 00' }
        @{ Encoding = 'bigendianunicode'; Bytes = 'FE FF 00 E9' }
        @{ Encoding = 'utf32'; Bytes = 'FF FE 00 00 E9 00 00 00' }
        @{ Encoding = 'ascii'; Bytes = '3F' }
    )
}

BeforeAll {
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
    $esc = [char]27

    # Sets the color support Write-ColorEX found at import, and whether bold is a bold font
    function Set-TestColorSupport {
        param($Support, [bool]$BoldFonts = $true)
        & (Get-Module PSWriteColorEX) { param($s, $b) $script:CachedANSISupport = $s; $script:SupportsBoldFonts = $b } $Support $BoldFonts
    }

    function Get-TestColorSupport {
        & (Get-Module PSWriteColorEX) { @($script:CachedANSISupport, $script:SupportsBoldFonts) }
    }

    # Removes escape codes, to compare the text alone
    function Remove-EscapeCode {
        param([string]$Text)
        $Text -replace "$([char]27)\[[0-9;]*m", ''
    }

    # The lines a transcript recorded between its header and its footer
    function Get-TranscriptBody {
        param([string]$Path)
        $lines = @(Get-Content -LiteralPath $Path)
        $stars = @(for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^\*{22}$') { $i } })
        if ($stars[2] - $stars[1] -le 1) { return @() }
        return @($lines[($stars[1] + 1)..($stars[2] - 1)])
    }

    # NO_COLOR, FORCE_COLOR and TERM=dumb change the output, so the tests clear them
    function Save-ColorEnvironment {
        $saved = @{}
        foreach ($name in 'NO_COLOR', 'FORCE_COLOR', 'TERM') {
            $saved[$name] = [System.Environment]::GetEnvironmentVariable($name)
        }
        [System.Environment]::SetEnvironmentVariable('NO_COLOR', $null)
        [System.Environment]::SetEnvironmentVariable('FORCE_COLOR', $null)
        if ($saved['TERM'] -eq 'dumb') {
            [System.Environment]::SetEnvironmentVariable('TERM', $null)
        }
        return $saved
    }

    function Restore-ColorEnvironment {
        param([hashtable]$Saved)
        foreach ($name in $Saved.Keys) {
            [System.Environment]::SetEnvironmentVariable($name, $Saved[$name])
        }
    }
}

Describe 'Write-ColorEX host output' -Tag 'Unit', 'Output' {

    BeforeAll {
        $script:hostCalls = [System.Collections.Generic.List[object]]::new()
        Mock -ModuleName PSWriteColorEX Write-Host {
            $script:hostCalls.Add([pscustomobject]@{
                Object = [string]$Object
                NoNewline = [bool]$NoNewline
                ForegroundColor = if ($PesterBoundParameters.ContainsKey('ForegroundColor')) { [string]$ForegroundColor } else { '' }
                BackgroundColor = if ($PesterBoundParameters.ContainsKey('BackgroundColor')) { [string]$BackgroundColor } else { '' }
            })
        }
        $script:savedSupport = Get-TestColorSupport
    }

    AfterAll {
        Set-TestColorSupport -Support $script:savedSupport[0] -BoldFonts $script:savedSupport[1]
    }

    BeforeEach {
        $script:hostCalls.Clear()
        $script:savedEnvironment = Save-ColorEnvironment
    }

    AfterEach {
        Restore-ColorEnvironment -Saved $script:savedEnvironment
        Set-TestColorSupport -Support $script:savedSupport[0] -BoldFonts $script:savedSupport[1]
    }

    Context 'A line of console colors written as one call' {
        BeforeAll {
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $true }
        }

        It 'Writes all segments in one call that ends the line' {
            Write-ColorEX -Text ' - Consumer', '- Count: ', '55' -Color White, Gray, Cyan

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be "$esc[97m - Consumer$esc[0m$esc[37m- Count: $esc[0m$esc[96m55$esc[0m"
            $script:hostCalls[0].NoNewline | Should -Be $false
        }

        It 'Writes text without -Color in the terminal colors' {
            Write-ColorEX -Text 'plain'

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be 'plain'
        }

        It 'Writes one call for each blank line from -LinesBefore and -LinesAfter' {
            Write-ColorEX -Text 'x' -LinesBefore 3 -LinesAfter 2

            $script:hostCalls.Count | Should -Be 6
            $script:hostCalls.Object | Should -Be @('', '', '', 'x', '', '')
            $script:hostCalls.NoNewline | Should -Not -Contain $true
        }

        It 'Leaves the line open with -NoNewLine' {
            Write-ColorEX -Text 'open' -Color Green -NoNewLine

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].NoNewline | Should -Be $true
        }

        It 'Writes the indent and the time in the same call as the text' {
            Write-ColorEX -Text 'indented' -StartSpaces 4 -ShowTime -DateTimeFormat 'HH'

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Match "^    $esc\[90m\[\d\d\] $esc\[0mindented$"
        }

        It 'Writes -Color 0 as black' {
            Write-ColorEX -Text 'x' -Color 0

            $script:hostCalls[0].Object | Should -Be "$esc[30mx$esc[0m"
        }

        It 'Leaves a segment with -BackGroundColor None on the terminal background' {
            { Write-ColorEX -Text 'a', 'b' -BackGroundColor 'None', 'Red' -ErrorAction Stop } | Should -Not -Throw

            $script:hostCalls[0].Object | Should -Be "a$esc[101mb$esc[0m"
        }
    }

    Context 'A line of console colors written as one call per color' {
        BeforeAll {
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $false }
        }

        It 'Ends the line on the last call' {
            Write-ColorEX -Text ' - Consumer', '- Count: ', '55' -Color White, Gray, Cyan

            $script:hostCalls.Count | Should -Be 3
            $script:hostCalls.Object | Should -Be @(' - Consumer', '- Count: ', '55')
            $script:hostCalls.ForegroundColor | Should -Be @('White', 'Gray', 'Cyan')
            $script:hostCalls.NoNewline | Should -Be @($true, $true, $false)
        }

        It 'Joins white space with no background to the text before it' {
            Write-ColorEX -Text 'a', '  ', 'b' -Color Red, Green, Blue

            $script:hostCalls.Object | Should -Be @('a  ', 'b')
            $script:hostCalls.ForegroundColor | Should -Be @('Red', 'Blue')
        }

        It 'Writes one call for text of one color' {
            Write-ColorEX -Text 'single' -Color Green

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].NoNewline | Should -Be $false
        }

        It 'Writes an empty line for empty text' {
            Write-ColorEX -Text ''

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be ''
            $script:hostCalls[0].NoNewline | Should -Be $false
        }
    }

    Context 'ANSI color modes' {
        BeforeAll {
            Mock -ModuleName PSWriteColorEX Test-ColorHostAnsi { $true }
        }

        It 'Writes an ANSI8 number as the nearest of 16 colors on a 16-color terminal' {
            Set-TestColorSupport -Support 'ANSI4'

            Write-ColorEX -Text 'x' -Color 9 -ANSI8 -Silent
            Write-ColorEX -Text 'x' -Color 208 -ANSI8 -Silent
            Write-ColorEX -Text 'x' -BackGroundColor 208 -ANSI8 -Silent

            $script:hostCalls.Object | Should -Be @("$esc[91mx$esc[0m", "$esc[93mx$esc[0m", "$esc[103mx$esc[0m")
        }

        It 'Writes an ANSI8 number as is on a 256-color terminal' {
            Set-TestColorSupport -Support 'ANSI8'

            Write-ColorEX -Text 'x' -Color 208 -ANSI8

            $script:hostCalls[0].Object | Should -Be "$esc[38;5;208mx$esc[0m"
        }

        It 'Writes a gradient for -Gradient alone' {
            Set-TestColorSupport -Support 'TrueColor'

            Write-ColorEX -Text 'ab' -Gradient Red, Blue

            $script:hostCalls[0].Object | Should -Match ([regex]::Escape("$esc[38;2;"))
            Remove-EscapeCode $script:hostCalls[0].Object | Should -Be 'ab'
        }

        It 'Keeps an emoji whole in a gradient' {
            Set-TestColorSupport -Support 'TrueColor'
            $emoji = [char]::ConvertFromUtf32(0x1F600)

            Write-ColorEX -Text "a$($emoji)b" -Gradient Red, Blue

            $line = $script:hostCalls[0].Object
            ([regex]::Matches($line, [regex]::Escape("$esc[38;2;"))).Count | Should -Be 3
            $line | Should -Match ([regex]::Escape("m$($emoji)$esc"))
            Remove-EscapeCode $line | Should -Be "a$($emoji)b"
        }

        It 'Gives an emoji sequence one gradient step' {
            Set-TestColorSupport -Support 'TrueColor'
            $family = -join (@(0x1F468, 0x200D, 0x1F469, 0x200D, 0x1F467) | ForEach-Object { [char]::ConvertFromUtf32($_) })

            Write-ColorEX -Text "$($family)x" -Gradient Red, Blue

            $line = $script:hostCalls[0].Object
            ([regex]::Matches($line, [regex]::Escape("$esc[38;2;"))).Count | Should -Be 2
            $line | Should -Match ([regex]::Escape("m$($family)$esc"))
        }

        It 'Turns a gradient off with a warning on a 16-color terminal' {
            Set-TestColorSupport -Support 'ANSI4'

            Write-ColorEX -Text 'ab' -Gradient Red, Blue -WarningVariable warnings -WarningAction SilentlyContinue

            $warnings | Should -Match 'Gradient requires'
            $script:hostCalls[0].Object | Should -Be 'ab'
        }

        It 'Writes a hex color without -TrueColor in the best mode the terminal has' {
            Set-TestColorSupport -Support 'TrueColor'
            Write-ColorEX -Text 'x' -Color '#FF6B35' -WarningVariable warnings1 -WarningAction SilentlyContinue
            Set-TestColorSupport -Support 'ANSI8'
            Write-ColorEX -Text 'x' -Color '#FF6B35' -WarningVariable warnings2 -WarningAction SilentlyContinue
            Set-TestColorSupport -Support 'ANSI4'
            Write-ColorEX -Text 'x' -Color '#FF6B35' -WarningVariable warnings3 -WarningAction SilentlyContinue

            $script:hostCalls.Object | Should -Be @("$esc[38;2;255;107;53mx$esc[0m", "$esc[38;5;203mx$esc[0m", "$esc[93mx$esc[0m")
            @($warnings1) + @($warnings2) + @($warnings3) | Should -BeNullOrEmpty
        }

        It 'Writes the hex color of a style made with New-ColorStyle' {
            Set-TestColorSupport -Support 'TrueColor'
            $style = New-ColorStyle -Name 'HexStyle' -ForegroundColor '#FF6B35'

            Write-ColorEX -Text 'x' -StyleProfile $style

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;107;53mx$esc[0m"
        }

        It 'Keeps a console color number next to a hex color' {
            Set-TestColorSupport -Support 'TrueColor'

            Write-ColorEX -Text 'a', 'b' -Color 12, '#00FF00'

            $script:hostCalls[0].Object | Should -Be "$esc[38;2;255;0;0ma$esc[0m$esc[38;2;0;255;0mb$esc[0m"
        }

        It 'Styles the first segment with one style given alone' {
            Set-TestColorSupport -Support 'ANSI4'

            Write-ColorEX -Text 'x', 'y' -Style 'Bold'

            $script:hostCalls[0].Object | Should -Be "$esc[1mx$esc[0my"
        }

        It 'Styles each segment with its entry in -Style' {
            Set-TestColorSupport -Support 'ANSI4'

            Write-ColorEX -Text 'x', 'y' -Style @(@('Bold', 'Underline'), 'Italic')

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[4mx$esc[0m$esc[3my$esc[0m"
        }

        It 'Writes a color code for each character of an ANSI8 gradient through grays' {
            Set-TestColorSupport -Support 'ANSI8'

            Write-ColorEX -Text 'abc' -Gradient '#202020', '#E0E0E0' -ANSI8

            $script:hostCalls[0].Object | Should -Be "$esc[38;5;234ma$esc[38;5;244mb$esc[38;5;254mc$esc[0m"
        }

        It 'Writes a lighter gray for -Bold where the terminal shows bold as brighter colors' {
            Set-TestColorSupport -Support 'ANSI8' -BoldFonts $false

            Write-ColorEX -Text 'x' -Color 240 -ANSI8 -Bold

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[38;5;244mx$esc[0m"
        }

        It 'Writes bold as a code where the terminal draws bold fonts' {
            Set-TestColorSupport -Support 'ANSI4' -BoldFonts $true

            Write-ColorEX -Text 'x' -Color White -Bold

            $script:hostCalls[0].Object | Should -Be "$esc[1m$esc[97mx$esc[0m"
        }
    }

    Context 'Console colors where the terminal has no ANSI support' {
        BeforeEach {
            Set-TestColorSupport -Support 'None'
        }

        It 'Writes an ANSI4 number as its console color' {
            Write-ColorEX -Text 'x' -Color 91 -ANSI4 -Silent

            $script:hostCalls[0].ForegroundColor | Should -Be 'Red'
        }

        It 'Writes an ANSI4 background number as its console color' {
            Write-ColorEX -Text 'x' -BackGroundColor 41 -ANSI4 -Silent

            $script:hostCalls[0].BackgroundColor | Should -Be 'DarkRed'
        }

        It 'Writes an ANSI8 number as the nearest console color' {
            Write-ColorEX -Text 'x' -Color 1 -ANSI8 -Silent
            Write-ColorEX -Text 'x' -Color 196 -ANSI8 -Silent

            $script:hostCalls.ForegroundColor | Should -Be @('DarkRed', 'Red')
        }

        It 'Writes a hex color as the nearest console color' {
            Write-ColorEX -Text 'x' -Color '#FF6B35'

            $script:hostCalls[0].ForegroundColor | Should -Be 'Yellow'
        }

        It 'Writes styles as plain text' {
            Write-ColorEX -Text 'x' -Color Green -Bold -Underline

            $script:hostCalls[0].Object | Should -Be 'x'
            $script:hostCalls[0].ForegroundColor | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Colors turned off' {
        It 'Writes plain text in one call with NO_COLOR set' {
            $env:NO_COLOR = '1'

            Write-ColorEX -Text 'a', 'b' -Color Red, Green -BackGroundColor Blue -Bold

            $script:hostCalls.Count | Should -Be 1
            $script:hostCalls[0].Object | Should -Be 'ab'
            $script:hostCalls[0].ForegroundColor | Should -Be ''
        }

        It 'Writes plain text with TERM=dumb' {
            $env:TERM = 'dumb'

            Write-ColorEX -Text 'a', 'b' -Color Red, Green

            $script:hostCalls[0].Object | Should -Be 'ab'
        }

        It 'Writes plain text with FORCE_COLOR=0' {
            $env:FORCE_COLOR = '0'

            Write-ColorEX -Text 'a', 'b' -Color Red, Green -Italic

            $script:hostCalls[0].Object | Should -Be 'ab'
        }

        It 'Writes colors when FORCE_COLOR sets a mode, even with NO_COLOR set' {
            $env:NO_COLOR = '1'
            $env:FORCE_COLOR = '1'

            Write-ColorEX -Text 'x' -Color Green -Bold

            $script:hostCalls[0].Object | Should -Match ([regex]::Escape("$esc["))
        }
    }

    Context 'Console width' {
        BeforeAll {
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $true }
        }

        It 'Writes an empty line for -BlankLine when the width is unknown' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 0 }

            { Write-ColorEX -BlankLine -BackGroundColor DarkBlue -ErrorAction Stop } | Should -Not -Throw

            $script:hostCalls.Count | Should -Be 1
            Remove-EscapeCode $script:hostCalls[0].Object | Should -Be ''
        }

        It 'Writes a line of spaces as wide as the console for -BlankLine' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 10 }

            Write-ColorEX -BlankLine -BackGroundColor DarkBlue

            Remove-EscapeCode $script:hostCalls[0].Object | Should -Be (' ' * 10)
        }

        It 'Centers the text in the console' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 20 }

            Write-ColorEX -Text 'abcd' -HorizontalCenter

            $script:hostCalls[0].Object | Should -Be ((' ' * 8) + 'abcd')
        }

        It 'Writes the text without centering when the width is unknown' {
            Mock -ModuleName PSWriteColorEX Get-ColorHostWidth { 0 }

            Write-ColorEX -Text 'abcd' -HorizontalCenter

            $script:hostCalls[0].Object | Should -Be 'abcd'
        }
    }

    Context 'Piped strings' {
        BeforeAll {
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $true }
        }

        It 'Writes each piped string as its own line' {
            'p1', 'p2' | Write-ColorEX -Color Green

            $script:hostCalls.Object | Should -Be @("$esc[92mp1$esc[0m", "$esc[92mp2$esc[0m")
        }

        It 'Pads each piped string on its own' {
            'x', 'yy' | Write-ColorEX -AutoPad 5 -PadChar '.'

            $script:hostCalls.Object | Should -Be @('x....', 'yy...')
        }

        It 'Writes each string piped to a helper' {
            'e1', 'e2' | Write-ColorError

            ($script:hostCalls | ForEach-Object { Remove-EscapeCode $_.Object }) | Should -Be @('e1', 'e2')
        }
    }

    Context 'Built-in profiles' {
        BeforeAll {
            Mock -ModuleName PSWriteColorEX Test-ColorLineComposition { $true }
        }

        It 'Uses a change to a profile in the next helper call' {
            $infoProfile = [PSColorStyle]::GetProfile('Info')
            $saved = $infoProfile.ForegroundColor
            try {
                $infoProfile.ForegroundColor = 'Magenta'

                Write-ColorInfo 'x'

                $script:hostCalls[0].Object | Should -Be "$esc[95mx$esc[0m"
            } finally {
                $infoProfile.ForegroundColor = $saved
            }
        }
    }
}

Describe 'Write-ColorEX log file' -Tag 'Unit', 'Logging' {

    BeforeAll {
        $script:accent = [string][char]0xE9
    }

    It 'Puts a file name alone in the folder of the calling script' {
        $folder = Join-Path $TestDrive 'caller'
        $null = New-Item -ItemType Directory -Path $folder -Force
        $script = Join-Path $folder 'caller.ps1'
        Set-Content -LiteralPath $script -Value "Write-ColorEX -Text 'from a script' -LogFile 'caller' -NoConsoleOutput"

        & $script

        Join-Path $folder 'caller.log' | Should -Exist
    }

    It 'Puts a file name alone given to a helper in the folder of the calling script' {
        $folder = Join-Path $TestDrive 'helper'
        $null = New-Item -ItemType Directory -Path $folder -Force
        $script = Join-Path $folder 'helper.ps1'
        Set-Content -LiteralPath $script -Value "Write-ColorInfo -Text 'from a script' -LogFile 'helper' -NoConsoleOutput"

        & $script

        Join-Path $folder 'helper.log' | Should -Exist
    }

    It 'Puts a file name alone in the current location when no script calls' {
        $folder = Join-Path $TestDrive 'prompt'
        $null = New-Item -ItemType Directory -Path $folder -Force
        Push-Location -LiteralPath $folder
        try {
            & ([scriptblock]::Create("Write-ColorEX -Text 'from the prompt' -LogFile 'prompt' -NoConsoleOutput"))
        } finally {
            Pop-Location
        }

        Join-Path $folder 'prompt.log' | Should -Exist
    }

    It 'Puts a file name alone in the -LogPath folder' {
        $folder = Join-Path $TestDrive 'logpath'

        Write-ColorEX -Text 'x' -LogFile 'named.log' -LogPath $folder -NoConsoleOutput

        Join-Path $folder 'named.log' | Should -Exist
    }

    It 'Uses a path with a folder as given and creates the folder' {
        $path = Join-Path (Join-Path $TestDrive 'new folder') 'given.log'

        Write-ColorEX -Text 'x' -LogFile $path -NoConsoleOutput

        $path | Should -Exist
    }

    It 'Writes <Encoding> as <Bytes>' -TestCases $encodingCases {
        $path = Join-Path $TestDrive "encoding-$Encoding.log"

        Write-ColorEX -Text $script:accent -LogFile $path -Encoding $Encoding -NoNewLine -NoConsoleOutput

        $actual = ([System.IO.File]::ReadAllBytes($path) | ForEach-Object { $_.ToString('X2') }) -join ' '
        $actual | Should -Be $Bytes
    }

    It 'Writes a byte order mark only to a new file' {
        $path = Join-Path $TestDrive 'bom-once.log'

        Write-ColorEX -Text $script:accent -LogFile $path -Encoding utf8BOM -NoNewLine -NoConsoleOutput
        Write-ColorEX -Text $script:accent -LogFile $path -Encoding utf8BOM -NoNewLine -NoConsoleOutput

        $actual = ([System.IO.File]::ReadAllBytes($path) | ForEach-Object { $_.ToString('X2') }) -join ' '
        $actual | Should -Be 'EF BB BF C3 A9 C3 A9'
    }

    It 'Ends each entry with the line end of the system' {
        $path = Join-Path $TestDrive 'newline.log'

        Write-ColorEX -Text 'a' -LogFile $path -NoConsoleOutput
        Write-ColorEX -Text 'b' -LogFile $path -NoConsoleOutput

        [System.IO.File]::ReadAllText($path) | Should -Be ('a' + [System.Environment]::NewLine + 'b' + [System.Environment]::NewLine)
    }

    It 'Writes the time and level before the text' {
        $path = Join-Path $TestDrive 'level.log'

        Write-ColorEX -Text 'entry' -LogFile $path -LogTime -LogLevel 'WARN' -DateTimeFormat 'yyyy' -NoConsoleOutput

        [System.IO.File]::ReadAllText($path) | Should -Match '^\[\d{4}\]\[WARN\] entry'
    }

    It 'Writes the segments joined' {
        $path = Join-Path $TestDrive 'segments.log'

        Write-ColorEX -Text 'a', 'b', 'c' -Color Red, Green, Blue -LogFile $path -NoNewLine -NoConsoleOutput

        [System.IO.File]::ReadAllText($path) | Should -Be 'abc'
    }

    It 'Warns when the file stays locked' {
        $path = Join-Path $TestDrive 'locked.log'
        $stream = [System.IO.File]::Open($path, 'OpenOrCreate', 'ReadWrite', 'None')
        try {
            Write-ColorEX -Text 'x' -LogFile $path -LogRetry 2 -NoConsoleOutput -WarningVariable warnings -WarningAction SilentlyContinue
        } finally {
            $stream.Dispose()
        }

        $warnings | Should -Match "Couldn't write to log file"
    }
}

Describe 'Write-ColorEX transcript' -Tag 'Integration', 'Transcript' {

    BeforeEach {
        $script:savedEnvironment = Save-ColorEnvironment
    }

    AfterEach {
        Restore-ColorEnvironment -Saved $script:savedEnvironment
    }

    It 'Records a line of one color as one line, with no blank line after it' {
        $path = Join-Path $TestDrive 'one-color.txt'
        $null = Start-Transcript -Path $path
        try {
            Write-ColorEX -Text 'first' -Color Green
            Write-ColorEX -Text 'second'
            Write-ColorEX -Text 'third' -LinesBefore 2
        } finally {
            $null = Stop-Transcript
        }

        $body = Get-TranscriptBody -Path $path | ForEach-Object { Remove-EscapeCode $_ }
        $body | Should -Be @('first', 'second', '', '', 'third')
    }

    It 'Records a line of several colors as one line' -Skip:(-not $composesLines) {
        $path = Join-Path $TestDrive 'several-colors.txt'
        $null = Start-Transcript -Path $path
        try {
            Write-ColorEX -Text ' - Consumer', '- Count: ', '55' -Color White, Gray, Cyan
            Write-ColorEX -Text '   - Sum: ', '1000' -Color Gray, Green
            Write-ColorEX -Text 'indented' -StartSpaces 4 -Color Yellow
        } finally {
            $null = Stop-Transcript
        }

        Get-TranscriptBody -Path $path | Should -Be @(' - Consumer- Count: 55', '   - Sum: 1000', '    indented')
    }

    It 'Keeps escape codes out of a Windows PowerShell 5.1 transcript' -Skip:(-not $isDesktop) {
        $path = Join-Path $TestDrive 'desktop.txt'
        $null = Start-Transcript -Path $path
        try {
            Write-ColorEX -Text 'a', 'b' -Color Red, Green
        } finally {
            $null = Stop-Transcript
        }

        (Get-TranscriptBody -Path $path) -join '' | Should -Not -Match ([regex]::Escape([string][char]27))
    }
}

Describe 'PSWriteColorEX import' -Tag 'Unit', 'Module' {

    It 'Imports without warnings' {
        Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force -WarningVariable importWarnings -WarningAction SilentlyContinue

        $importWarnings | Should -BeNullOrEmpty
    }

    It 'Makes [PSColorStyle] available after Import-Module' {
        'PSColorStyle' -as [type] | Should -Not -BeNullOrEmpty
        [PSColorStyle]::GetProfile('Error').Name | Should -Be 'Error'
    }

    It 'Passes a [PSColorStyle] made outside the module to -StyleProfile' {
        $style = [PSColorStyle]::new('Outside', 'Green', $null)

        { Write-ColorEX -Text 'x' -StyleProfile $style -NoConsoleOutput -ErrorAction Stop } | Should -Not -Throw
    }
}
