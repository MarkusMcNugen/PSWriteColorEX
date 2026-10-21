# PowerShell 7.2 and later remove escape codes from transcripts and from the output of a host
# without virtual terminal support
$script:RemovesEscapeCodes = $PSVersionTable.PSVersion -ge [version]'7.2'

# Whether the host lets escape codes through, read on first use; it stays the same for the session
$script:HostVirtualTerminal = $null

# Whether the process's console is a window of the Windows console host, read on first use
$script:ConsoleHostWindow = $null

# The Windows calls the console checks make, declared on first use
$script:ConsoleNative = $null

function Test-ColorHostVirtualTerminal {
    <#
    .SYNOPSIS
    Returns whether the host lets escape codes through to the screen.

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

function Get-ColorConsoleNative {
    <#
    .SYNOPSIS
    Returns a type with the Windows calls the console checks make.

    .DESCRIPTION
    GetConsoleWindow, GetClassNameW, CreateFileW, GetCurrentConsoleFontEx, CloseHandle,
    GetStdHandle, GetConsoleMode and SetConsoleMode, declared once per session. Reflection.Emit
    declares them in about 10 ms; Add-Type takes 170 to 290 ms in pwsh.
    #>
    [CmdletBinding()]
    [OutputType([type])]
    param()

    if ($null -ne $script:ConsoleNative) {
        return $script:ConsoleNative
    }
    $assembly = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly(
        [System.Reflection.AssemblyName]::new('PSWriteColorEXConsole'), [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $type = $assembly.DefineDynamicModule('PSWriteColorEXConsole').DefineType('PSWriteColorEXConsole', 'Public, Abstract, Sealed')
    $attributes = [System.Reflection.MethodAttributes]'Public, Static, PinvokeImpl'
    # Each call: its name, its library, what it returns, and what it takes
    $calls = @(
        @('GetConsoleWindow', 'kernel32.dll', [IntPtr], [Type[]]@()),
        @('GetClassNameW', 'user32.dll', [int], [Type[]]@([IntPtr], [System.Text.StringBuilder], [int])),
        @('CreateFileW', 'kernel32.dll', [IntPtr], [Type[]]@([string], [uint32], [uint32], [IntPtr], [uint32], [uint32], [IntPtr])),
        @('GetCurrentConsoleFontEx', 'kernel32.dll', [bool], [Type[]]@([IntPtr], [bool], [byte[]])),
        @('CloseHandle', 'kernel32.dll', [bool], [Type[]]@([IntPtr])),
        @('GetStdHandle', 'kernel32.dll', [IntPtr], [Type[]]@([int])),
        @('GetConsoleMode', 'kernel32.dll', [bool], [Type[]]@([IntPtr], [uint32].MakeByRefType())),
        @('SetConsoleMode', 'kernel32.dll', [bool], [Type[]]@([IntPtr], [uint32]))
    )
    foreach ($call in $calls) {
        $method = $type.DefinePInvokeMethod($call[0], $call[1], $attributes, 'Standard', $call[2], $call[3], 'Winapi', 'Unicode')
        $method.SetImplementationFlags('PreserveSig')
    }
    $script:ConsoleNative = $type.CreateType()
    return $script:ConsoleNative
}

function Test-ColorConsoleHostWindow {
    <#
    .SYNOPSIS
    Returns whether the process's console is a window of the Windows console host itself.

    .DESCRIPTION
    The console host's own window has the class ConsoleWindowClass. A terminal that runs
    PowerShell through a pseudoconsole, such as Windows Terminal or VS Code, gives the console a
    hidden window of the class PseudoConsoleWindow, and a process with no console window, such as
    a CI job, has none. Returns $false outside Windows.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ($null -ne $script:ConsoleHostWindow) {
        return $script:ConsoleHostWindow
    }
    $script:ConsoleHostWindow = $false
    if ([System.Environment]::OSVersion.Platform -ne 'Win32NT') {
        return $false
    }
    try {
        $native = Get-ColorConsoleNative
        $window = $native::GetConsoleWindow()
        if ($window -ne [IntPtr]::Zero) {
            $name = [System.Text.StringBuilder]::new(64)
            $length = $native::GetClassNameW($window, $name, $name.Capacity)
            $script:ConsoleHostWindow = $length -gt 0 -and $name.ToString(0, $length) -eq 'ConsoleWindowClass'
        }
    } catch {
        $script:ConsoleHostWindow = $false
    }
    return $script:ConsoleHostWindow
}

function Test-ColorRasterFont {
    <#
    .SYNOPSIS
    Returns whether the console's screen buffer draws with a raster font.

    .DESCRIPTION
    Reads the font of the console's own screen buffer, CONOUT$, so redirected standard output does
    not change the answer. Returns $false where there is no console or its font cannot be read.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ([System.Environment]::OSVersion.Platform -ne 'Win32NT') {
        return $false
    }
    try {
        $native = Get-ColorConsoleNative
        # GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, OPEN_EXISTING
        $handle = $native::CreateFileW('CONOUT$', [uint32]3221225472, [uint32]3, [IntPtr]::Zero, [uint32]3, [uint32]0, [IntPtr]::Zero)
        if ($handle -eq [IntPtr]::new(-1)) {
            return $false
        }
        try {
            # CONSOLE_FONT_INFOEX, 84 bytes: cbSize, nFont, dwFontSize, then FontFamily at byte 12
            $info = [byte[]]::new(84)
            [System.BitConverter]::GetBytes([uint32]84).CopyTo($info, 0)
            if (-not $native::GetCurrentConsoleFontEx($handle, $false, $info)) {
                return $false
            }
            # TMPF_TRUETYPE, 4, is clear for a raster font
            return ([System.BitConverter]::ToUInt32($info, 12) -band 4) -eq 0
        } finally {
            $null = $native::CloseHandle($handle)
        }
    } catch {
        return $false
    }
}

function Test-ColorUtf8Locale {
    <#
    .SYNOPSIS
    Returns whether a locale's character set is UTF-8.

    .DESCRIPTION
    The character set is the part after the first '.', before any '@' modifier: en_US.UTF-8,
    C.utf8 and de_DE.UTF-8@euro are UTF-8. A locale with no '.' is read whole, as macOS sets
    LC_CTYPE=UTF-8. C and POSIX are not.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string]$Locale)

    $codeset = if ($Locale.Contains('.')) { $Locale.Substring($Locale.IndexOf('.') + 1) } else { $Locale }
    $modifier = $codeset.IndexOf('@')
    if ($modifier -ge 0) {
        $codeset = $codeset.Substring(0, $modifier)
    }
    return ($codeset -replace '-', '') -eq 'utf8'
}

function Test-ColorUnicode {
    <#
    .SYNOPSIS
    Returns whether the terminal can show Unicode.

    .DESCRIPTION
    WRITECOLOREX_UNICODE, true or false, decides first; any other value is warned about, unless
    -Silent, and set aside. Otherwise, on Linux, macOS and FreeBSD the terminal cannot when the
    locale's character set is not UTF-8: the first of LC_ALL, LC_CTYPE and LANG that is set, and
    the C locale when none is. On Windows it cannot when the console is a window of the Windows
    console host itself and its screen buffer draws with a raster font.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([switch]$Silent)

    $forced = [System.Environment]::GetEnvironmentVariable('WRITECOLOREX_UNICODE')
    if (-not [string]::IsNullOrEmpty($forced)) {
        if ($forced -eq 'true') {
            return $true
        }
        if ($forced -eq 'false') {
            return $false
        }
        if (-not $Silent) {
            Write-Warning "WRITECOLOREX_UNICODE is '$forced'; it takes true or false, so whether the terminal can show Unicode is detected."
        }
    }
    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
        return -not ((Test-ColorConsoleHostWindow) -and (Test-ColorRasterFont))
    }
    foreach ($name in 'LC_ALL', 'LC_CTYPE', 'LANG') {
        $locale = [System.Environment]::GetEnvironmentVariable($name)
        if (-not [string]::IsNullOrEmpty($locale)) {
            return Test-ColorUtf8Locale -Locale $locale
        }
    }
    return $false
}

function Test-ColorHostAnsi {
    <#
    .SYNOPSIS
    Returns whether escape codes in host output reach the screen.

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
    Returns whether a line of plain console colors is written as one string of escape codes.

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
    # Test-ColorHostAnsi's checks, made here rather than through a second call, since every line
    # of console colors asks
    if ($null -eq $script:HostVirtualTerminal) {
        $script:HostVirtualTerminal = Test-ColorHostVirtualTerminal
    }
    if (-not $script:HostVirtualTerminal) {
        return $false
    }
    $style = $ExecutionContext.SessionState.PSVariable.GetValue('PSStyle')
    return -not ($null -ne $style -and "$($style.OutputRendering)" -eq 'PlainText')
}

function Get-ColorHostWidth {
    <#
    .SYNOPSIS
    Returns the width of the console in cells, or 0 when there is no console to measure.

    .DESCRIPTION
    With output redirected to a file or a pipe, PowerShell reports a width of -1, and some
    hosts have no RawUI at all. Either way this returns 0, and callers skip what needs a width.
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
    Returns the folder a log file named without a folder goes in.

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
    Returns the text encoding a log file is written in, by the name -Encoding takes.

    .DESCRIPTION
    Each name gives the same bytes on Windows PowerShell 5.1 and PowerShell 7: utf8 and
    utf8NoBOM and default write UTF-8 without a byte order mark, utf8BOM with one, and unicode,
    string and unknown write UTF-16 little-endian with one. ansi and oem write the system's
    code pages on Windows and UTF-8 elsewhere, where the system's text is UTF-8.
    #>
    [CmdletBinding()]
    [OutputType([System.Text.Encoding])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Each encoding returned derives from the declared System.Text.Encoding; the rule compares exact types.')]
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
