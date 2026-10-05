# PowerShell 7.2 and later remove escape codes from transcripts and from the output of a host
# without virtual terminal support
$script:RemovesEscapeCodes = $PSVersionTable.PSVersion -ge [version]'7.2'

# Whether the host lets escape codes through, read on first use; it stays the same for the session
$script:HostVirtualTerminal = $null

function Test-ColorHostVirtualTerminal {
    <#
    .SYNOPSIS
    Answers whether the host lets escape codes through to the screen.

    .DESCRIPTION
    PowerShell 7.2 and later remove escape codes from the output of a host without virtual
    terminal support, such as a process with no console. Windows PowerShell 5.1 passes them
    through.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not $script:RemovesEscapeCodes) {
        return $true
    }
    try {
        return [bool]$Host.UI.SupportsVirtualTerminal
    } catch {
        return $false
    }
}

function Test-ColorHostAnsi {
    <#
    .SYNOPSIS
    Answers whether escape codes in host output reach the screen.

    .DESCRIPTION
    PowerShell 7.2 and later remove escape codes from host output when the host has no virtual
    terminal support or $PSStyle.OutputRendering is PlainText.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ($null -eq $script:HostVirtualTerminal) {
        $script:HostVirtualTerminal = Test-ColorHostVirtualTerminal
    }
    if (-not $script:HostVirtualTerminal) {
        return $false
    }
    # $PSStyle.OutputRendering can change at any time, so it is read on each call
    $style = $ExecutionContext.SessionState.PSVariable.GetValue('PSStyle')
    if ($null -ne $style -and "$($style.OutputRendering)" -eq 'PlainText') {
        return $false
    }
    return $true
}

function Test-ColorLineComposition {
    <#
    .SYNOPSIS
    Answers whether a line of plain console colors is written as one string of escape codes.

    .DESCRIPTION
    A transcript records each Write-Host call as its own line, so a line written in several
    calls is split in the transcript. PowerShell 7.2 and later remove escape codes from
    transcripts, so there a line of console colors goes out as one call with the colors as
    escape codes, when the host renders them. Windows PowerShell 5.1 keeps escape codes in
    transcripts, so there each color is its own Write-Host call.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not $script:RemovesEscapeCodes) {
        return $false
    }
    if ($script:CachedANSISupport -eq 'None') {
        return $false
    }
    return (Test-ColorHostAnsi)
}

function Get-ColorHostWidth {
    <#
    .SYNOPSIS
    Answers the width of the console in cells, or 0 when there is no console to measure.

    .DESCRIPTION
    With output redirected to a file or a pipe, PowerShell reports a width of -1, and some
    hosts have no RawUI at all. Either way this answers 0, and callers skip what needs a width.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param()

    try {
        $raw = $Host.UI.RawUI
        if ($null -ne $raw) {
            $window = $raw.WindowSize.Width
            if ($window -gt 0) {
                return $window
            }
            $buffer = $raw.BufferSize.Width
            if ($buffer -gt 0) {
                return $buffer
            }
        }
    } catch {
        return 0
    }
    return 0
}

function Resolve-ColorLogFolder {
    <#
    .SYNOPSIS
    Answers the folder a log file named without a folder goes in.

    .DESCRIPTION
    The calling script's folder, or the current file-system location when the caller is the
    prompt and has no script folder.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()]
        [string]$ScriptRoot
    )

    if (-not [string]::IsNullOrEmpty($ScriptRoot)) {
        return $ScriptRoot
    }
    return (Get-Location -PSProvider FileSystem).ProviderPath
}

function Get-ColorLogEncoding {
    <#
    .SYNOPSIS
    Answers the text encoding a log file is written in, by the name -Encoding takes.

    .DESCRIPTION
    Each name gives the same bytes on Windows PowerShell 5.1 and PowerShell 7: utf8 and
    utf8NoBOM and default write UTF-8 without a byte order mark, utf8BOM with one, and unicode,
    string and unknown write UTF-16 little-endian with one. ansi and oem write the system's
    code pages on Windows and UTF-8 elsewhere, where the system's text is UTF-8.
    #>
    [CmdletBinding()]
    [OutputType([System.Text.Encoding])]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $onWindows = [System.Environment]::OSVersion.Platform -eq 'Win32NT'
    switch ($Name) {
        'utf8BOM' { return [System.Text.UTF8Encoding]::new($true) }
        'unicode' { return [System.Text.UnicodeEncoding]::new($false, $true) }
        'string' { return [System.Text.UnicodeEncoding]::new($false, $true) }
        'unknown' { return [System.Text.UnicodeEncoding]::new($false, $true) }
        'bigendianunicode' { return [System.Text.UnicodeEncoding]::new($true, $true) }
        'utf32' { return [System.Text.UTF32Encoding]::new($false, $true) }
        'bigendianutf32' { return [System.Text.UTF32Encoding]::new($true, $true) }
        'ascii' { return [System.Text.ASCIIEncoding]::new() }
        'utf7' { return [System.Text.UTF7Encoding]::new() }
        'ansi' {
            if ($onWindows) { return [System.Text.Encoding]::GetEncoding([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ANSICodePage) }
            return [System.Text.UTF8Encoding]::new($false)
        }
        'oem' {
            if ($onWindows) { return [System.Text.Encoding]::GetEncoding([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage) }
            return [System.Text.UTF8Encoding]::new($false)
        }
        default { return [System.Text.UTF8Encoding]::new($false) }
    }
}
