#Requires -Version 7.2
<#
.SYNOPSIS
Runs the wiki's examples through PSWriteColorEX and writes the data the pages are built from.

.DESCRIPTION
Every ```powershell block in content/ that holds a session, a line opening with "PS> ", is run:
its commands in order, in a runspace of its own with the module imported and an empty temporary
folder as its location. A command goes on through the lines after it that open with ">> ". What
each command writes to the host, with its colors, styles and links, its warnings and errors, and
the objects it outputs, formatted as the console formats them, become styled spans in
data/examples.json, keyed by the MD5 of the block's text as Hugo reads it. The codeblock partial
renders a session from them as a terminal, and stops the build for a session with no entry.

The lines written under each command in the page must equal what the command wrote, line for
line, without trailing white space; the last command's trailing blank lines are not compared,
since Hugo drops the end of a block. Each difference is listed and the script exits 1, after
writing the data.

Flags after the fence's language, comma-separated, as in ```powershell,ansi8:
  truecolor ansi8 ansi4 none  the color mode the block runs in: FORCE_COLOR=3, 2 or 1, or
                              NO_COLOR=1. truecolor when none is given.
  detect                      no color variable set, in a terminal whose detected support is
                              TrueColor, for sessions that set the color variables themselves.
  clock                       digits may differ from the written ones, as a time does; the page
                              shows the written digits.
  norun                       the commands are not run, and the written lines are shown in the
                              terminal's own colors, for output that depends on the machine.

data/commands.json holds each command's syntax, aliases, and parameters with their help, and
data/colors.json the color table, for the reference pages.

The 16 colors and the console colors are drawn in Windows Terminal's Campbell scheme, and
command lines are colored as PSReadLine 2.4 colors them by default.

.EXAMPLE
pwsh ./generate.ps1
#>
[CmdletBinding()]
param(
    [string]$ContentPath = (Join-Path $PSScriptRoot 'content'),
    [string]$DataPath = (Join-Path $PSScriptRoot 'data'),
    [string]$ModulePath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'PSWriteColorEX.psd1')
)

$ErrorActionPreference = 'Stop'

# The report quotes what the module wrote, wide characters and ellipses among it, so it goes out in
# UTF-8 whatever the console's code page
try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
} catch {
    Write-Verbose 'No console encoding to set'
}

# Windows Terminal's Campbell scheme: the 16 ANSI colors, then the default text and background
$script:Palette = @(
    '#0C0C0C', '#C50F1F', '#13A10E', '#C19C00', '#0037DA', '#881798', '#3A96DD', '#CCCCCC',
    '#767676', '#E74856', '#16C60C', '#F9F1A5', '#3B78FF', '#B4009E', '#61D6D6', '#F2F2F2'
)
$script:DefaultForeground = '#CCCCCC'
$script:DefaultBackground = '#0C0C0C'

# The ANSI color number of each console color
$script:ConsoleIndex = @{
    Black = 0; DarkRed = 1; DarkGreen = 2; DarkYellow = 3; DarkBlue = 4; DarkMagenta = 5; DarkCyan = 6; Gray = 7
    DarkGray = 8; Red = 9; Green = 10; Yellow = 11; Blue = 12; Magenta = 13; Cyan = 14; White = 15
}

# PSReadLine 2.4's default token colors, as ANSI color numbers
$script:TokenColor = @{
    Command = 11; Parameter = 8; String = 6; Variable = 10; Number = 15; Operator = 8
    Keyword = 10; Type = 7; Member = 7; Comment = 2; Default = 7; Prompt = 7
}

$script:Esc = [char]27

# The variables a color mode is set by, cleared before each block and restored at the end
$script:ColorVariables = @(
    'NO_COLOR', 'FORCE_COLOR', 'CLICOLOR', 'CLICOLOR_FORCE', 'TERM', 'COLORTERM', 'TERM_PROGRAM',
    'WT_SESSION', 'ConEmuANSI', 'VTE_VERSION', 'TMUX', 'KITTY_WINDOW_ID', 'ALACRITTY_LOG',
    'WEZTERM_EXECUTABLE', 'GHOSTTY_RESOURCES_DIR', 'TERMINAL_EMULATOR'
)

function ConvertTo-Hex([int]$R, [int]$G, [int]$B) {
    '#{0:X2}{1:X2}{2:X2}' -f $R, $G, $B
}

function Get-Color256([int]$Number) {
    if ($Number -lt 16) {
        return $script:Palette[$Number]
    }
    if ($Number -lt 232) {
        $n = $Number - 16
        $levels = 0, 95, 135, 175, 215, 255
        return ConvertTo-Hex $levels[[int][math]::Floor($n / 36)] $levels[[int][math]::Floor(($n % 36) / 6)] $levels[$n % 6]
    }
    $v = 8 + 10 * ($Number - 232)
    return ConvertTo-Hex $v $v $v
}

# The color halfway between two #RRGGBB colors, which is how a faint color is drawn
function Get-MixedColor([string]$A, [string]$B) {
    $x = [Convert]::FromHexString($A.Substring(1))
    $y = [Convert]::FromHexString($B.Substring(1))
    ConvertTo-Hex (($x[0] + $y[0]) -shr 1) (($x[1] + $y[1]) -shr 1) (($x[2] + $y[2]) -shr 1)
}

# The graphic rendition a terminal holds between escape codes, and the link OSC 8 opened
class TerminalState {
    [string]$Foreground
    [string]$Background
    [bool]$Bold
    [bool]$Faint
    [bool]$Italic
    [string]$Underline = ''
    [string]$UnderlineColor
    [bool]$Blink
    [bool]$Reverse
    [bool]$Hidden
    [bool]$CrossedOut
    [bool]$Overline
    [string]$Link

    [void] Reset() {
        $this.Foreground = $null
        $this.Background = $null
        $this.Bold = $false
        $this.Faint = $false
        $this.Italic = $false
        $this.Underline = ''
        $this.UnderlineColor = $null
        $this.Blink = $false
        $this.Reverse = $false
        $this.Hidden = $false
        $this.CrossedOut = $false
        $this.Overline = $false
    }
}

# The lines a command writes, each a list of spans: t the text, s its CSS, c its class, h its link
class OutputLines {
    [System.Collections.Generic.List[object]]$Lines = [System.Collections.Generic.List[object]]::new()
    [System.Collections.Generic.List[object]]$Current

    [void] Add([string]$Text, [string]$Style, [string]$Class, [string]$Link) {
        if ($null -eq $this.Current) {
            $this.Current = [System.Collections.Generic.List[object]]::new()
        }
        if ($this.Current.Count -gt 0) {
            $last = $this.Current[$this.Current.Count - 1]
            if ($last.s -ceq $Style -and $last.c -ceq $Class -and $last.h -ceq $Link) {
                $last.t += $Text
                return
            }
        }
        $this.Current.Add([ordered]@{ t = $Text; s = $Style; c = $Class; h = $Link })
    }

    [void] EndLine() {
        if ($null -eq $this.Current) {
            $this.Current = [System.Collections.Generic.List[object]]::new()
        }
        $this.Lines.Add($this.Current)
        $this.Current = $null
    }

    [void] Finish() {
        if ($null -ne $this.Current) {
            $this.EndLine()
        }
    }
}

function Get-SpanStyle([TerminalState]$State) {
    $fg = $State.Foreground
    $bg = $State.Background
    if ($State.Reverse) {
        $newForeground = if ($bg) { $bg } else { $script:DefaultBackground }
        $newBackground = if ($fg) { $fg } else { $script:DefaultForeground }
        $fg = $newForeground
        $bg = $newBackground
    }
    $shownBackground = if ($bg) { $bg } else { $script:DefaultBackground }
    if ($State.Faint) {
        $fg = Get-MixedColor $(if ($fg) { $fg } else { $script:DefaultForeground }) $shownBackground
    }
    if ($State.Hidden) {
        $fg = $shownBackground
    }
    $parts = [System.Collections.Generic.List[string]]::new()
    if ($fg) { $parts.Add("color:$fg") }
    if ($bg) { $parts.Add("background-color:$bg") }
    if ($State.Bold) { $parts.Add('font-weight:bold') }
    if ($State.Italic) { $parts.Add('font-style:italic') }
    $decorations = @()
    if ($State.Underline) { $decorations += 'underline' }
    if ($State.Overline) { $decorations += 'overline' }
    if ($State.CrossedOut) { $decorations += 'line-through' }
    if ($decorations) {
        $parts.Add("text-decoration-line:$($decorations -join ' ')")
        $lineStyle = switch ($State.Underline) {
            'double' { 'double' }
            'curly' { 'wavy' }
            'dotted' { 'dotted' }
            'dashed' { 'dashed' }
            default { 'solid' }
        }
        $parts.Add("text-decoration-style:$lineStyle")
        if ($State.Underline -and $State.UnderlineColor) {
            $parts.Add("text-decoration-color:$($State.UnderlineColor)")
        }
    }
    return $parts -join ';'
}

function Add-Span([OutputLines]$Out, [TerminalState]$State, [string]$Text) {
    if ($Text.Length -eq 0) {
        return
    }
    $class = if ($State.Blink) { 'wcx-blink' } else { '' }
    $Out.Add($Text, (Get-SpanStyle $State), $class, $State.Link)
}

# The color an extended color code names: 5;N from the 256 colors, 2;R;G;B in TrueColor. Answers
# the color and how many codes after the 38, 48 or 58 it took.
function Get-ExtendedColor([string[]]$Codes, [int]$At) {
    if ($At + 1 -lt $Codes.Count -and $Codes[$At + 1] -eq '5' -and $At + 2 -lt $Codes.Count) {
        return @((Get-Color256 ([int]$Codes[$At + 2])), 2)
    }
    if ($At + 1 -lt $Codes.Count -and $Codes[$At + 1] -eq '2' -and $At + 4 -lt $Codes.Count) {
        return @((ConvertTo-Hex ([int]$Codes[$At + 2]) ([int]$Codes[$At + 3]) ([int]$Codes[$At + 4])), 4)
    }
    return @($null, $Codes.Count)
}

function Set-GraphicRendition([TerminalState]$State, [string]$Parameters) {
    if ($Parameters -eq '') {
        $State.Reset()
        return
    }
    $codes = $Parameters.Split(';')
    for ($k = 0; $k -lt $codes.Count; $k++) {
        $code = $codes[$k]
        if ($code.Contains(':')) {
            # Colon sub-parameters: 4:N is an underline style, 38:, 48: and 58: an extended color
            $sub = @($code.Split(':') | Where-Object { $_ -ne '' })
            switch ($sub[0]) {
                '4' {
                    $State.Underline = switch ($sub[1]) {
                        '0' { '' } '2' { 'double' } '3' { 'curly' } '4' { 'dotted' } '5' { 'dashed' } default { 'single' }
                    }
                }
                { $_ -in '38', '48', '58' } {
                    $color = (Get-ExtendedColor $sub 0)[0]
                    if ($sub[0] -eq '38') { $State.Foreground = $color }
                    elseif ($sub[0] -eq '48') { $State.Background = $color }
                    else { $State.UnderlineColor = $color }
                }
            }
            continue
        }
        $value = if ($code -eq '') { 0 } else { [int]$code }
        if ($value -eq 0) { $State.Reset() }
        elseif ($value -eq 1) { $State.Bold = $true }
        elseif ($value -eq 2) { $State.Faint = $true }
        elseif ($value -eq 3) { $State.Italic = $true }
        elseif ($value -eq 4) { $State.Underline = 'single' }
        elseif ($value -eq 5 -or $value -eq 6) { $State.Blink = $true }
        elseif ($value -eq 7) { $State.Reverse = $true }
        elseif ($value -eq 8) { $State.Hidden = $true }
        elseif ($value -eq 9) { $State.CrossedOut = $true }
        elseif ($value -eq 21) { $State.Underline = 'double' }
        elseif ($value -eq 22) { $State.Bold = $false; $State.Faint = $false }
        elseif ($value -eq 23) { $State.Italic = $false }
        elseif ($value -eq 24) { $State.Underline = '' }
        elseif ($value -eq 25) { $State.Blink = $false }
        elseif ($value -eq 27) { $State.Reverse = $false }
        elseif ($value -eq 28) { $State.Hidden = $false }
        elseif ($value -eq 29) { $State.CrossedOut = $false }
        elseif ($value -ge 30 -and $value -le 37) { $State.Foreground = $script:Palette[$value - 30] }
        elseif ($value -eq 39) { $State.Foreground = $null }
        elseif ($value -ge 40 -and $value -le 47) { $State.Background = $script:Palette[$value - 40] }
        elseif ($value -eq 49) { $State.Background = $null }
        elseif ($value -eq 53) { $State.Overline = $true }
        elseif ($value -eq 55) { $State.Overline = $false }
        elseif ($value -eq 59) { $State.UnderlineColor = $null }
        elseif ($value -ge 90 -and $value -le 97) { $State.Foreground = $script:Palette[$value - 90 + 8] }
        elseif ($value -ge 100 -and $value -le 107) { $State.Background = $script:Palette[$value - 100 + 8] }
        elseif ($value -in 38, 48, 58) {
            $color, $taken = Get-ExtendedColor $codes $k
            if ($value -eq 38) { $State.Foreground = $color }
            elseif ($value -eq 48) { $State.Background = $color }
            else { $State.UnderlineColor = $color }
            $k += $taken
        }
    }
}

# Adds text holding escape codes to the lines: CSI ... m sets the rendition, OSC 8 opens and closes
# a link, and every other escape sequence is dropped, as a terminal draws nothing for it
function Add-AnsiText([OutputLines]$Out, [TerminalState]$State, [string]$Text) {
    $buffer = [System.Text.StringBuilder]::new()
    $i = 0
    $n = $Text.Length
    while ($i -lt $n) {
        $c = $Text[$i]
        if ($c -eq $script:Esc -and $i + 1 -lt $n) {
            $next = $Text[$i + 1]
            if ($next -eq '[') {
                $j = $i + 2
                while ($j -lt $n -and ([int]$Text[$j] -lt 0x40 -or [int]$Text[$j] -gt 0x7E)) { $j++ }
                if ($j -ge $n) { break }
                if ($Text[$j] -eq 'm') {
                    Add-Span $Out $State $buffer.ToString()
                    [void]$buffer.Clear()
                    Set-GraphicRendition $State $Text.Substring($i + 2, $j - $i - 2)
                }
                $i = $j + 1
                continue
            }
            if ($next -eq ']') {
                $j = $i + 2
                $end = -1
                $terminator = 0
                while ($j -lt $n) {
                    if ($Text[$j] -eq [char]7) { $end = $j; $terminator = 1; break }
                    if ($Text[$j] -eq $script:Esc -and $j + 1 -lt $n -and $Text[$j + 1] -eq '\') { $end = $j; $terminator = 2; break }
                    $j++
                }
                if ($end -lt 0) { break }
                $body = $Text.Substring($i + 2, $end - $i - 2)
                if ($body.StartsWith('8;')) {
                    Add-Span $Out $State $buffer.ToString()
                    [void]$buffer.Clear()
                    $separator = $body.IndexOf(';', 2)
                    $uri = if ($separator -ge 0) { $body.Substring($separator + 1) } else { '' }
                    $State.Link = if ($uri) { $uri } else { $null }
                }
                $i = $end + $terminator
                continue
            }
            $i += 2
            continue
        }
        if ($c -eq "`n") {
            Add-Span $Out $State $buffer.ToString()
            [void]$buffer.Clear()
            $Out.EndLine()
            $i++
            continue
        }
        if ($c -ne "`r") {
            [void]$buffer.Append($c)
        }
        $i++
    }
    Add-Span $Out $State $buffer.ToString()
}

# A line in a rendition of its own, as the console writes warnings and errors
function Add-StyledLine([OutputLines]$Out, [string]$Rendition, [string]$Text) {
    $Out.Finish()
    Add-AnsiText $Out ([TerminalState]::new()) "$script:Esc[${Rendition}m$Text$script:Esc[0m"
    $Out.EndLine()
}

function Add-HostWrite([OutputLines]$Out, [TerminalState]$State, $Message) {
    $savedForeground = $State.Foreground
    $savedBackground = $State.Background
    if ($null -ne $Message.ForegroundColor) {
        $State.Foreground = $script:Palette[$script:ConsoleIndex["$($Message.ForegroundColor)"]]
    }
    if ($null -ne $Message.BackgroundColor) {
        $State.Background = $script:Palette[$script:ConsoleIndex["$($Message.BackgroundColor)"]]
    }
    Add-AnsiText $Out $State ([string]$Message.Message)
    if ($null -ne $Message.ForegroundColor) { $State.Foreground = $savedForeground }
    if ($null -ne $Message.BackgroundColor) { $State.Background = $savedBackground }
    if (-not $Message.NoNewLine) {
        $Out.EndLine()
    }
}

function Get-TokenColor($Token) {
    $flags = $Token.TokenFlags
    $kind = "$($Token.Kind)"
    if ($flags -band [System.Management.Automation.Language.TokenFlags]::CommandName) {
        return $script:TokenColor.Command
    }
    switch ($kind) {
        'Comment' { return $script:TokenColor.Comment }
        'Parameter' { return $script:TokenColor.Parameter }
        { $_ -in 'Variable', 'SplattedVariable' } { return $script:TokenColor.Variable }
        { $_ -in 'StringExpandable', 'StringLiteral', 'HereStringExpandable', 'HereStringLiteral' } { return $script:TokenColor.String }
        'Number' { return $script:TokenColor.Number }
    }
    if ($flags -band [System.Management.Automation.Language.TokenFlags]::Keyword) {
        return $script:TokenColor.Keyword
    }
    $operators = [System.Management.Automation.Language.TokenFlags]::BinaryOperator -bor
        [System.Management.Automation.Language.TokenFlags]::UnaryOperator -bor
        [System.Management.Automation.Language.TokenFlags]::AssignmentOperator
    if ($kind -ne 'Generic' -and ($flags -band $operators)) {
        return $script:TokenColor.Operator
    }
    if ($flags -band [System.Management.Automation.Language.TokenFlags]::TypeName) {
        return $script:TokenColor.Type
    }
    if ($flags -band [System.Management.Automation.Language.TokenFlags]::MemberName) {
        return $script:TokenColor.Member
    }
    return $script:TokenColor.Default
}

function Set-TokenColors([int[]]$Colors, $Token) {
    $color = Get-TokenColor $Token
    for ($p = $Token.Extent.StartOffset; $p -lt $Token.Extent.EndOffset -and $p -lt $Colors.Count; $p++) {
        $Colors[$p] = $color
    }
    if ($Token -is [System.Management.Automation.Language.StringExpandableToken] -and $Token.NestedTokens) {
        foreach ($nested in $Token.NestedTokens) {
            Set-TokenColors $Colors $nested
        }
    }
}

# A command as it shows at the prompt: "PS> " and its first line, ">> " and each line after, its
# tokens colored as PSReadLine colors them
function Get-CommandLines([string]$Text) {
    $tokens = $null
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$errors)
    $colors = [int[]]::new($Text.Length)
    for ($p = 0; $p -lt $colors.Count; $p++) { $colors[$p] = $script:TokenColor.Default }
    foreach ($token in $tokens) {
        Set-TokenColors $colors $token
    }
    $out = [OutputLines]::new()
    $state = [TerminalState]::new()
    $state.Foreground = $script:Palette[$script:TokenColor.Prompt]
    Add-Span $out $state 'PS> '
    $run = [System.Text.StringBuilder]::new()
    $runColor = -1
    for ($p = 0; $p -lt $Text.Length; $p++) {
        $c = $Text[$p]
        if ($c -eq "`n" -or $colors[$p] -ne $runColor) {
            if ($run.Length) {
                $state.Foreground = $script:Palette[$runColor]
                Add-Span $out $state $run.ToString()
                [void]$run.Clear()
            }
        }
        if ($c -eq "`n") {
            $out.EndLine()
            $state.Foreground = $script:Palette[$script:TokenColor.Prompt]
            Add-Span $out $state '>> '
            $runColor = -1
            continue
        }
        $runColor = $colors[$p]
        [void]$run.Append($c)
    }
    if ($run.Length) {
        $state.Foreground = $script:Palette[$runColor]
        Add-Span $out $state $run.ToString()
    }
    $out.Finish()
    return , $out.Lines
}

# The fenced code blocks of a Markdown page, each with its info string and its lines as Goldmark
# reads them: a fence indented up to three spaces takes that many spaces off each line in it
function Get-CodeBlocks([string]$Path) {
    $text = [System.IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n")
    $lines = $text.Split("`n")
    $blocks = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $open = [regex]::Match($lines[$i], '^( {0,3})(`{3,}|~{3,})[ \t]*([^\s`]*)')
        if (-not $open.Success) {
            continue
        }
        $indent = $open.Groups[1].Length
        $fence = $open.Groups[2].Value
        $info = $open.Groups[3].Value
        $close = '^ {0,3}' + [regex]::Escape([string]$fence[0]) + '{' + $fence.Length + ',}[ \t]*$'
        $body = [System.Collections.Generic.List[string]]::new()
        $j = $i + 1
        while ($j -lt $lines.Count -and $lines[$j] -notmatch $close) {
            $line = $lines[$j]
            $strip = 0
            while ($strip -lt $indent -and $strip -lt $line.Length -and $line[$strip] -eq ' ') { $strip++ }
            $body.Add($line.Substring($strip))
            $j++
        }
        $blocks.Add([pscustomobject]@{ Line = $i + 1; Info = $info; Lines = $body })
        $i = $j
    }
    return , $blocks
}

# The MD5 of the fence's info string, a line end and the block's text, so the same commands
# fenced in two color modes are two entries
function Get-BlockKey([string]$Info, [string[]]$Lines) {
    $content = $Info + "`n" + ($Lines -join "`n").TrimEnd("`n")
    $hash = [System.Security.Cryptography.MD5]::HashData([System.Text.Encoding]::UTF8.GetBytes($content))
    return [Convert]::ToHexString($hash).ToLowerInvariant()
}

# A session's commands, each with the lines written under it
function Get-SessionCommands($Block) {
    $commands = [System.Collections.Generic.List[object]]::new()
    $current = $null
    foreach ($line in $Block.Lines) {
        if ($line.StartsWith('PS> ')) {
            $current = [pscustomobject]@{ Text = $line.Substring(4); Written = [System.Collections.Generic.List[string]]::new(); Output = $null }
            $commands.Add($current)
        } elseif ($null -ne $current -and $line.StartsWith('>> ') -and $current.Written.Count -eq 0) {
            $current.Text += "`n" + $line.Substring(3)
        } elseif ($null -ne $current) {
            $current.Written.Add($line)
        } else {
            throw "line $($Block.Line): a session's first line must open with 'PS> '"
        }
    }
    return , $commands
}

function Set-ColorMode([string]$Mode) {
    foreach ($name in $script:ColorVariables) {
        [System.Environment]::SetEnvironmentVariable($name, $null)
    }
    [System.Environment]::SetEnvironmentVariable('TERM', 'xterm-256color')
    switch ($Mode) {
        'TrueColor' { [System.Environment]::SetEnvironmentVariable('FORCE_COLOR', '3') }
        'ANSI8' { [System.Environment]::SetEnvironmentVariable('FORCE_COLOR', '2') }
        'ANSI4' { [System.Environment]::SetEnvironmentVariable('FORCE_COLOR', '1') }
        'None' { [System.Environment]::SetEnvironmentVariable('NO_COLOR', '1') }
    }
}

function Invoke-InRunspace([System.Management.Automation.Runspaces.Runspace]$Runspace, [string]$Script, [object[]]$Arguments = @()) {
    $shell = [powershell]::Create()
    try {
        $shell.Runspace = $Runspace
        [void]$shell.AddScript($Script)
        foreach ($argument in $Arguments) {
            [void]$shell.AddArgument($argument)
        }
        $result = $shell.Invoke()
        if ($shell.Streams.Error.Count -gt 0 -and $Script -notlike '*__WikiCommand*') {
            throw "runspace: $($shell.Streams.Error[0])"
        }
        return , $result
    } finally {
        $shell.Dispose()
    }
}

# Runs one command in the session's scope with every stream merged into the output, in order; a
# terminating error comes back as its record
$script:RunCommand = @'
param($__WikiCommand)
try {
    . ([scriptblock]::Create($__WikiCommand)) *>&1
} catch {
    $_
}
'@

# Objects formatted as the console formats them, without the blank lines it writes around a table
function Format-Objects([System.Management.Automation.Runspaces.Runspace]$Runspace, $Objects) {
    $shell = [powershell]::Create()
    try {
        $shell.Runspace = $Runspace
        [void]$shell.AddCommand('Out-String').AddParameter('Width', 120)
        $text = ($shell.Invoke($Objects) -join '').Replace("`r", '')
    } finally {
        $shell.Dispose()
    }
    $lines = [System.Collections.Generic.List[string]]::new([string[]]$text.Split("`n"))
    while ($lines.Count -gt 0 -and $lines[0].Trim() -eq '') { $lines.RemoveAt(0) }
    while ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -eq '') { $lines.RemoveAt($lines.Count - 1) }
    return , $lines
}

function Invoke-SessionCommand([System.Management.Automation.Runspaces.Runspace]$Runspace, [string]$Text) {
    $out = [OutputLines]::new()
    $state = [TerminalState]::new()
    $items = Invoke-InRunspace $Runspace $script:RunCommand @($Text)
    $group = [System.Collections.Generic.List[object]]::new()
    $flush = {
        if ($group.Count -gt 0) {
            $out.Finish()
            foreach ($line in (Format-Objects $Runspace $group)) {
                Add-AnsiText $out $state $line
                $out.EndLine()
            }
            $group.Clear()
        }
    }
    foreach ($item in $items) {
        $value = if ($item -is [psobject]) { $item.psobject.BaseObject } else { $item }
        if ($value -is [System.Management.Automation.InformationRecord]) {
            & $flush
            if ($value.MessageData -is [System.Management.Automation.HostInformationMessage]) {
                Add-HostWrite $out $state $value.MessageData
            }
        } elseif ($value -is [System.Management.Automation.WarningRecord]) {
            & $flush
            Add-StyledLine $out '33;1' "WARNING: $($value.Message)"
        } elseif ($value -is [System.Management.Automation.ErrorRecord]) {
            & $flush
            $name = if ($value.InvocationInfo -and $value.InvocationInfo.MyCommand) { $value.InvocationInfo.MyCommand.Name } else { '' }
            $text = if ($name) { "${name}: $($value.Exception.Message)" } else { $value.Exception.Message }
            foreach ($line in $text.Replace("`r", '').Split("`n")) {
                Add-StyledLine $out '31;1' $line
            }
        } elseif ($value -is [System.Management.Automation.VerboseRecord] -or $value -is [System.Management.Automation.DebugRecord] -or $value -is [System.Management.Automation.ProgressRecord]) {
            continue
        } else {
            $group.Add($item)
        }
    }
    & $flush
    $out.Finish()
    return , $out.Lines
}

function Get-LineText($Spans) {
    -join @($Spans | ForEach-Object { $_.t })
}

# Spans whose digits are those of the written line, where both have a digit at that place
function Set-WrittenDigits($Spans, [string]$Written) {
    $at = 0
    foreach ($span in $Spans) {
        $chars = $span.t.ToCharArray()
        for ($k = 0; $k -lt $chars.Count; $k++) {
            $p = $at + $k
            if ($p -lt $Written.Length -and [char]::IsDigit($chars[$k]) -and [char]::IsDigit($Written[$p])) {
                $chars[$k] = $Written[$p]
            }
        }
        $at += $chars.Count
        $span.t = -join $chars
    }
}

function Compare-Output($Command, [bool]$Last, [bool]$Clock) {
    $got = [System.Collections.Generic.List[string]]::new()
    foreach ($spans in $Command.Output) { $got.Add((Get-LineText $spans).TrimEnd()) }
    $want = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $Command.Written) { $want.Add($line.TrimEnd()) }
    if ($Last) {
        while ($got.Count -gt 0 -and $got[$got.Count - 1] -eq '') { $got.RemoveAt($got.Count - 1) }
        while ($want.Count -gt 0 -and $want[$want.Count - 1] -eq '') { $want.RemoveAt($want.Count - 1) }
    }
    $same = $got.Count -eq $want.Count
    for ($k = 0; $same -and $k -lt $got.Count; $k++) {
        $a = $got[$k]
        $b = $want[$k]
        if ($Clock) {
            $a = $a -replace '\d', '0'
            $b = $b -replace '\d', '0'
        }
        if ($a -cne $b) { $same = $false }
    }
    if ($same -and $Clock) {
        for ($k = 0; $k -lt $want.Count; $k++) {
            Set-WrittenDigits $Command.Output[$k] $want[$k]
        }
    }
    if ($same) {
        return $null
    }
    return [pscustomobject]@{ Want = $want; Got = $got }
}

function ConvertTo-PlainLines($Written) {
    $lines = [System.Collections.Generic.List[object]]::new()
    foreach ($line in $Written) {
        $out = [OutputLines]::new()
        Add-Span $out ([TerminalState]::new()) $line
        $out.Finish()
        $lines.Add($out.Lines[0])
    }
    return , $lines
}

# A span as JSON holds only what it sets
function ConvertTo-SpanData($Spans) {
    @(foreach ($span in $Spans) {
        $data = [ordered]@{ t = $span.t }
        if ($span.s) { $data.s = $span.s }
        if ($span.c) { $data.c = $span.c }
        if ($span.h) { $data.h = $span.h }
        $data
    })
}

function Split-Paragraphs([string]$Text) {
    # Help text as paragraphs (p), lists whose items open with "- " (ul), and "Example:" lines
    # (ex). "Alias:" and "Aliases:" lines are left out, since the aliases are listed from the
    # command's own metadata.
    $blocks = [System.Collections.Generic.List[object]]::new()
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return , $blocks
    }
    $paragraph = [System.Collections.Generic.List[string]]::new()
    $list = $null
    $flush = {
        if ($paragraph.Count -gt 0) {
            $blocks.Add([ordered]@{ p = ($paragraph -join ' ') })
            $paragraph.Clear()
        }
    }
    foreach ($raw in $Text.Replace("`r", '').Split("`n")) {
        $line = $raw.Trim()
        if ($line -eq '') {
            & $flush
            $list = $null
            continue
        }
        if ($line -match '^Alias(es)?:') {
            & $flush
            $list = $null
            continue
        }
        if ($line -match '^Example:\s*(.+)$') {
            & $flush
            $list = $null
            $blocks.Add([ordered]@{ ex = $Matches[1] })
            continue
        }
        if ($line.StartsWith('- ')) {
            & $flush
            if ($null -eq $list) {
                $list = [System.Collections.Generic.List[string]]::new()
                $blocks.Add([ordered]@{ ul = $list })
            }
            $list.Add($line.Substring(2))
            continue
        }
        if ($null -ne $list -and $list.Count -gt 0 -and $raw -match '^\s{2,}') {
            $list[$list.Count - 1] += ' ' + $line
            continue
        }
        $list = $null
        $paragraph.Add($line)
    }
    & $flush
    return , $blocks
}

function Get-CommandData([System.Management.Automation.Runspaces.Runspace]$Runspace) {
    $script = @'
$common = [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters
foreach ($command in Get-Command -Module PSWriteColorEX -CommandType Function | Sort-Object Name) {
    $help = Get-Help $command.Name -Full
    $parameters = foreach ($parameter in $command.Parameters.Values) {
        if ($common -contains $parameter.Name) { continue }
        $attributes = @($parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] })
        $helpParameter = @($help.parameters.parameter | Where-Object { $_.name -eq $parameter.Name })[0]
        $positions = @($attributes | Where-Object { $_.Position -ge 0 } | ForEach-Object Position | Select-Object -Unique)
        [pscustomobject]@{
            Name = $parameter.Name
            Type = $parameter.ParameterType.Name
            Position = if ($positions) { $positions[0] } else { $null }
            Mandatory = [bool]($attributes | Where-Object Mandatory)
            Pipeline = [bool]($attributes | Where-Object { $_.ValueFromPipeline -or $_.ValueFromPipelineByPropertyName })
            Aliases = @($parameter.Aliases)
            Values = @($parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } | ForEach-Object ValidValues)
            Sets = @($attributes | ForEach-Object ParameterSetName | Where-Object { $_ -ne '__AllParameterSets' } | Select-Object -Unique)
            Default = if ($helpParameter -and $helpParameter.defaultValue -and $helpParameter.defaultValue -ne 'None') { [string]$helpParameter.defaultValue } else { $null }
            Description = if ($helpParameter -and $helpParameter.description) { ($helpParameter.description | ForEach-Object Text) -join "`n`n" } else { '' }
        }
    }
    [pscustomobject]@{
        Name = $command.Name
        Synopsis = [string]$help.Synopsis
        Description = if ($help.description) { ($help.description | ForEach-Object Text) -join "`n`n" } else { '' }
        Syntax = @((Get-Command $command.Name -Syntax).Trim().Replace("`r", '').Split("`n") | Where-Object { $_.Trim() -ne '' } | ForEach-Object Trim)
        Aliases = @(Get-Alias -Definition $command.Name -ErrorAction SilentlyContinue | ForEach-Object Name | Sort-Object)
        Parameters = @($parameters)
    }
}
'@
    $commands = [ordered]@{}
    foreach ($command in (Invoke-InRunspace $Runspace $script)) {
        $parameters = @(foreach ($parameter in $command.Parameters) {
            [ordered]@{
                name = $parameter.Name
                type = $parameter.Type
                position = if ($null -ne $parameter.Position) { [string]$parameter.Position } else { $null }
                mandatory = $parameter.Mandatory
                pipeline = $parameter.Pipeline
                aliases = @($parameter.Aliases)
                values = @($parameter.Values)
                sets = @($parameter.Sets)
                default = $parameter.Default
                description = Split-Paragraphs $parameter.Description
            }
        })
        $commands[$command.Name] = [ordered]@{
            name = $command.Name
            synopsis = $command.Synopsis.Trim()
            description = Split-Paragraphs $command.Description
            syntax = @($command.Syntax)
            aliases = @($command.Aliases)
            parameters = $parameters
        }
    }
    return $commands
}

function Get-ColorData([System.Management.Automation.Runspaces.Runspace]$Runspace) {
    $table = (Invoke-InRunspace $Runspace 'Get-ColorTableWithRGB')[0].psobject.BaseObject
    $variantOrder = @{ Dark = 0; '' = 1; Light = 2 }
    $entries = foreach ($name in $table.Keys) {
        $value = $table[$name]
        $match = [regex]::Match($name, '^(Dark|Light)(.+)$')
        $family = if ($match.Success) { $match.Groups[2].Value } else { $name }
        $variant = if ($match.Success) { $match.Groups[1].Value } else { '' }
        $rgb = @($value[4])
        $ansi4 = [int]$value[1]
        $ansi4Index = if ($ansi4 -ge 90) { $ansi4 - 90 + 8 } else { $ansi4 - 30 }
        [pscustomobject]@{
            Family = $family
            Order = $variantOrder[$variant]
            Data = [ordered]@{
                name = $name
                hex = ConvertTo-Hex $rgb[0] $rgb[1] $rgb[2]
                rgb = $rgb
                ansi8 = [int]$value[3]
                ansi8hex = Get-Color256 ([int]$value[3])
                ansi4 = $ansi4
                ansi4hex = $script:Palette[$ansi4Index]
                console = [string]$value[0]
                consolehex = $script:Palette[$script:ConsoleIndex[[string]$value[0]]]
            }
        }
    }
    return @($entries | Sort-Object Family, Order | ForEach-Object Data)
}

function Write-Data([string]$Name, $Value) {
    $path = Join-Path $DataPath $Name
    $temporary = "$path.$([guid]::NewGuid().ToString('N')).tmp"
    $json = ConvertTo-Json -InputObject $Value -Depth 16 -Compress
    [System.IO.File]::WriteAllText($temporary, $json, [System.Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temporary -Destination $path -Force
}

# A runspace with the module imported, set as in a terminal with virtual terminal support in the
# block's color mode, as Windows Terminal is: a runspace has no console, and the module would
# otherwise write a line of console colors as separate calls rather than as escape codes
function New-SessionRunspace([string]$Folder, [string]$Mode) {
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $setup = @'
param($Folder, $Module, $Mode)
Set-Location -LiteralPath $Folder
Import-Module $Module -Force
$support = if ($Mode -eq 'Detected') { 'TrueColor' } else { $Mode }
& (Get-Module PSWriteColorEX) { param($m) $script:HostVirtualTerminal = $true; $script:CachedANSISupport = $m; $script:SupportsBoldFonts = $true } $support
# A class's static members belong to the process, not the runspace, so each block starts from the
# built-in profiles
[PSColorStyle]::Profiles = @{}
[PSColorStyle]::InitializeDefaultProfiles()
'@
    $null = Invoke-InRunspace $runspace $setup @($Folder, $ModulePath, $Mode)
    return $runspace
}

$savedVariables = @{}
foreach ($name in $script:ColorVariables) {
    $savedVariables[$name] = [System.Environment]::GetEnvironmentVariable($name)
}
$savedRendering = $PSStyle.OutputRendering
$PSStyle.OutputRendering = 'Ansi'
$ModulePath = (Resolve-Path -LiteralPath $ModulePath).ProviderPath
# The folder holding the module's folder goes first on PSModulePath, so a session's
# Import-Module PSWriteColorEX finds this checkout
$savedModulePath = $env:PSModulePath
$env:PSModulePath = (Split-Path -Parent (Split-Path -Parent $ModulePath)) + [System.IO.Path]::PathSeparator + $env:PSModulePath
$null = New-Item -ItemType Directory -Force -Path $DataPath

$examples = [ordered]@{}
$failures = [System.Collections.Generic.List[string]]::new()
$pageCount = 0
$sessionCount = 0
$commandCount = 0
try {
    $pages = Get-ChildItem -LiteralPath $ContentPath -Recurse -File -Filter '*.md' | Sort-Object FullName
    foreach ($page in $pages) {
        $relative = [System.IO.Path]::GetRelativePath($ContentPath, $page.FullName).Replace('\', '/')
        $pageCount++
        foreach ($block in (Get-CodeBlocks $page.FullName)) {
            $parts = $block.Info.Split(',')
            if ($parts[0] -ne 'powershell' -or -not ($block.Lines | Where-Object { $_.StartsWith('PS> ') })) {
                continue
            }
            $flags = @($parts | Select-Object -Skip 1 | ForEach-Object { $_.Trim().ToLowerInvariant() })
            $mode = 'TrueColor'
            foreach ($flag in $flags) {
                switch ($flag) {
                    'truecolor' { $mode = 'TrueColor' }
                    'ansi8' { $mode = 'ANSI8' }
                    'ansi4' { $mode = 'ANSI4' }
                    'none' { $mode = 'None' }
                    'detect' { $mode = 'Detected' }
                    'clock' { }
                    'norun' { }
                    default { $failures.Add("${relative}:$($block.Line): unknown flag '$flag'") }
                }
            }
            $clock = $flags -contains 'clock'
            $sessionCount++
            $commands = Get-SessionCommands $block
            $lines = [System.Collections.Generic.List[object]]::new()
            if ($flags -contains 'norun') {
                foreach ($command in $commands) {
                    $commandCount++
                    foreach ($line in (Get-CommandLines $command.Text)) { $lines.Add([ordered]@{ k = 'c'; spans = @(ConvertTo-SpanData $line) }) }
                    foreach ($line in (ConvertTo-PlainLines $command.Written)) { $lines.Add([ordered]@{ k = 'o'; spans = @(ConvertTo-SpanData $line) }) }
                }
            } else {
                # A session may set environment variables, which are the process's: each block gets
                # back the environment it started with
                $environment = [System.Environment]::GetEnvironmentVariables()
                Set-ColorMode $mode
                $folder = Join-Path ([System.IO.Path]::GetTempPath()) ('wcx-wiki-' + [guid]::NewGuid().ToString('N'))
                $null = New-Item -ItemType Directory -Path $folder
                $runspace = New-SessionRunspace $folder $mode
                try {
                    for ($c = 0; $c -lt $commands.Count; $c++) {
                        $command = $commands[$c]
                        $commandCount++
                        $command.Output = Invoke-SessionCommand $runspace $command.Text
                        $difference = Compare-Output $command ($c -eq $commands.Count - 1) $clock
                        if ($difference) {
                            $report = [System.Text.StringBuilder]::new()
                            [void]$report.AppendLine("${relative}:$($block.Line): PS> $($command.Text.Split("`n")[0])")
                            [void]$report.AppendLine('  written:')
                            foreach ($line in $difference.Want) { [void]$report.AppendLine("    |$line") }
                            [void]$report.AppendLine('  wrote:')
                            foreach ($line in $difference.Got) { [void]$report.Append("    |$line`n") }
                            $failures.Add($report.ToString().TrimEnd())
                        }
                        foreach ($line in (Get-CommandLines $command.Text)) { $lines.Add([ordered]@{ k = 'c'; spans = @(ConvertTo-SpanData $line) }) }
                        foreach ($line in $command.Output) { $lines.Add([ordered]@{ k = 'o'; spans = @(ConvertTo-SpanData $line) }) }
                    }
                } finally {
                    $runspace.Dispose()
                    Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
                    foreach ($name in @([System.Environment]::GetEnvironmentVariables().Keys)) {
                        if (-not $environment.Contains($name)) {
                            [System.Environment]::SetEnvironmentVariable($name, $null)
                        }
                    }
                    foreach ($name in $environment.Keys) {
                        [System.Environment]::SetEnvironmentVariable($name, $environment[$name])
                    }
                }
            }
            $examples[(Get-BlockKey $block.Info $block.Lines)] = [ordered]@{
                page = $relative
                line = $block.Line
                mode = $mode
                lines = $lines
            }
        }
    }

    Set-ColorMode 'TrueColor'
    $folder = Join-Path ([System.IO.Path]::GetTempPath()) ('wcx-wiki-' + [guid]::NewGuid().ToString('N'))
    $null = New-Item -ItemType Directory -Path $folder
    $runspace = New-SessionRunspace $folder 'TrueColor'
    try {
        Write-Data 'commands.json' (Get-CommandData $runspace)
        Write-Data 'colors.json' (Get-ColorData $runspace)
    } finally {
        $runspace.Dispose()
        Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Data 'examples.json' $examples
} finally {
    foreach ($name in $savedVariables.Keys) {
        [System.Environment]::SetEnvironmentVariable($name, $savedVariables[$name])
    }
    $PSStyle.OutputRendering = $savedRendering
    $env:PSModulePath = $savedModulePath
}

"pages: $pageCount, sessions: $sessionCount, commands: $commandCount"
foreach ($failure in $failures) {
    $failure
}
"$($failures.Count) differences between the pages and what the module wrote"
if ($failures.Count -gt 0) {
    exit 1
}
