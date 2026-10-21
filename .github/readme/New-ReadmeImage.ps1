#Requires -Version 7.2
<#
.SYNOPSIS
Writes the README's title, tagline and description images from PSWriteColorEX's own output.

.DESCRIPTION
Each part is what Format-ColorEX returns for its text, colored and styled as the part shows it.
readme_svg.py draws it as an SVG on a terminal panel: the background and 16 colors of Windows
Terminal's Campbell scheme, as the wiki's terminals use, and every letter from Cascadia Mono's
outlines. FORCE_COLOR=3 is set before the module is imported, so colors are TrueColor and -Bold is
a bold font wherever this runs.

The fonts are the static faces of Cascadia Mono 2407.24, from Microsoft's cascadia-code release
under the SIL Open Font License. When -FontFolder lacks them, the release zip is downloaded, or
read from -FontArchive, checked against its SHA-256, and the four faces kept in -FontFolder.

Needs Python 3 with fontTools.

.PARAMETER ModulePath
The PSWriteColorEX manifest whose output the images show.

.PARAMETER FontFolder
The folder holding CascadiaMono-Regular.ttf, -Bold, -Italic and -BoldItalic.

.PARAMETER FontArchive
The Cascadia Code 2407.24 release zip, already downloaded.

.PARAMETER OutputPath
The folder the images are written to.

.PARAMETER Python
The Python to run readme_svg.py with.

.EXAMPLE
pwsh ./.github/readme/New-ReadmeImage.ps1
#>
[CmdletBinding()]
param(
    [string]$ModulePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'PSWriteColorEX.psd1'),
    [string]$FontFolder = (Join-Path ([System.IO.Path]::GetTempPath()) 'cascadia-mono-2407.24'),
    [string]$FontArchive,
    [string]$OutputPath = $PSScriptRoot,
    [string]$Python = 'python'
)

$ErrorActionPreference = 'Stop'

$releaseUri = 'https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip'
$releaseHash = 'E67A68EE3386DB63F48B9054BD196EA752BC6A4EBB4DF35ADCE6733DA50C8474'
$faceFiles = 'CascadiaMono-Regular.ttf', 'CascadiaMono-Bold.ttf', 'CascadiaMono-Italic.ttf', 'CascadiaMono-BoldItalic.ttf'

$missing = @($faceFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $FontFolder $_)) })
if ($missing.Count -gt 0) {
    $archive = $FontArchive
    if (-not $archive) {
        $archive = Join-Path ([System.IO.Path]::GetTempPath()) "CascadiaCode-2407.24-$([guid]::NewGuid().ToString('N')).zip"
        Write-Verbose "Downloading $releaseUri"
        Invoke-WebRequest -Uri $releaseUri -OutFile $archive -UseBasicParsing
    }
    $hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    if ($hash -ne $releaseHash) {
        throw "$archive has SHA-256 $hash, not the Cascadia Code 2407.24 release's $releaseHash."
    }
    $null = New-Item -ItemType Directory -Force -Path $FontFolder
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($archive)
    try {
        foreach ($name in $missing) {
            $entry = $zip.GetEntry("ttf/static/$name")
            if (-not $entry) {
                throw "The Cascadia Code release holds no ttf/static/$name."
            }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $FontFolder $name), $true)
        }
    } finally {
        $zip.Dispose()
    }
    if (-not $FontArchive) {
        Remove-Item -LiteralPath $archive
    }
}

$savedForceColor = $env:FORCE_COLOR
$env:FORCE_COLOR = '3'
try {
    Import-Module $ModulePath -Force

    # The title's and the tagline's text, and the description's pieces, each with the colors and
    # styles of what it names
    $title = Format-ColorEX -Text 'PSWriteColorEX' -Gradient '#00C6FF', '#7B2FF7' -Bold
    $tagline = Format-ColorEX -Text 'Pure PowerShell colored and styled console output for PowerShell 5+' -Color '#5391FE' -Italic
    $description = @(
        Format-ColorEX -Text 'Write-ColorEX' -Color Yellow
        Format-ColorEX -Text ' writes text to the PowerShell host, as '
        Format-ColorEX -Text 'Write-Host' -Color Yellow
        Format-ColorEX -Text ' does, with far more control: '
        Format-ColorEX -Text 'any color your terminal can show' -Gradient Red, Magenta -GradientSpace OKLCH -GradientHue Longer
        Format-ColorEX -Text ', '
        Format-ColorEX -Text 'text styles' -Color White -Bold -Italic -Underline
        Format-ColorEX -Text ', '
        Format-ColorEX -Text 'gradients' -Gradient Atlas
        Format-ColorEX -Text ', '
        Format-ColorEX -Text '[bold red]markup[/] [bold cyan]tags[/]' -Markup
        Format-ColorEX -Text ', '
        Format-ColorEX -Text 'highlighted patterns' -Highlight @{ 'highlighted' = 'black on yellow' }
        Format-ColorEX -Text ', '
        Format-ColorEX -Text 'links' -Color '#3B78FF' -Underline -Link 'https://markusmcnugen.github.io/PSWriteColorEX/docs/how-to/write-links/'
        Format-ColorEX -Text ', padding that counts emoji and CJK characters correctly, and '
        Format-ColorEX -Text 'logging to a file' -Faint
        Format-ColorEX -Text '. It finds what your terminal supports and falls back gracefully where it supports less.'
    )

    # The Quick start's output: the code block right above quick-start.svg in the README, run in a
    # folder of its own, and every line it writes to the host
    $readme = @(Get-Content -LiteralPath (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'README.md') -Encoding utf8)
    $imageLine = @(0..($readme.Count - 1) | Where-Object { $readme[$_] -match 'quick-start\.svg' })[0]
    if ($null -eq $imageLine) {
        throw 'The README has no image of quick-start.svg.'
    }
    $close = $imageLine - 1
    while ($close -ge 0 -and $readme[$close] -notmatch '^```\s*$') { $close-- }
    $open = $close - 1
    while ($open -ge 0 -and $readme[$open] -notmatch '^```powershell') { $open-- }
    if ($open -lt 0) {
        throw 'The README has no powershell code block above quick-start.svg.'
    }
    $quickStart = [scriptblock]::Create(($readme[($open + 1)..($close - 1)] -join "`n"))
    $folder = Join-Path ([System.IO.Path]::GetTempPath()) "readme-quick-start-$([guid]::NewGuid().ToString('N'))"
    $null = New-Item -ItemType Directory -Path $folder
    $savedModulePath = $env:PSModulePath
    $env:PSModulePath = (Split-Path -Parent (Split-Path -Parent (Resolve-Path -LiteralPath $ModulePath).ProviderPath)) + [System.IO.Path]::PathSeparator + $env:PSModulePath
    Push-Location -LiteralPath $folder
    try {
        $written = @(& $quickStart 6>&1)
    } finally {
        Pop-Location
        $env:PSModulePath = $savedModulePath
        Remove-Item -LiteralPath $folder -Recurse -Force
    }
    $lines = [System.Collections.Generic.List[string]]::new()
    $line = ''
    foreach ($record in $written) {
        if ($record -isnot [System.Management.Automation.InformationRecord] -or $record.MessageData -isnot [System.Management.Automation.HostInformationMessage]) {
            throw "The Quick start wrote something other than host output: $record"
        }
        $line += $record.MessageData.Message
        if (-not $record.MessageData.NoNewLine) {
            $lines.Add($line)
            $line = ''
        }
    }
    if ($line) {
        $lines.Add($line)
    }
} finally {
    $env:FORCE_COLOR = $savedForceColor
}

$spec = [ordered]@{
    width = 800
    radius = 10
    background = '#0C0C0C'
    border = '#30363D'
    foreground = '#CCCCCC'
    palette = @(
        '#0C0C0C', '#C50F1F', '#13A10E', '#C19C00', '#0037DA', '#881798', '#3A96DD', '#CCCCCC',
        '#767676', '#E74856', '#16C60C', '#F9F1A5', '#3B78FF', '#B4009E', '#61D6D6', '#F2F2F2'
    )
    images = @(
        [ordered]@{ file = 'title.svg'; size = 44; lineHeight = 1.3; padX = 32; padY = 18; align = 'center'; wrap = $false; segments = @($title) }
        [ordered]@{ file = 'tagline.svg'; size = 18; lineHeight = 1.4; padX = 32; padY = 14; align = 'center'; wrap = $true; segments = @($tagline) }
        [ordered]@{ file = 'description.svg'; size = 16; lineHeight = 1.5; padX = 32; padY = 20; align = 'left'; wrap = $true; segments = $description }
        [ordered]@{ file = 'quick-start.svg'; size = 16; lineHeight = 1.5; padX = 32; padY = 18; align = 'left'; wrap = $false; altSeparator = ' / '; segments = @($lines -join "`n") }
    )
}

$specPath = Join-Path ([System.IO.Path]::GetTempPath()) "readme-images-$([guid]::NewGuid().ToString('N')).json"
try {
    [System.IO.File]::WriteAllText($specPath, (ConvertTo-Json -InputObject $spec -Depth 6), [System.Text.UTF8Encoding]::new($false))
    & $Python -I (Join-Path $PSScriptRoot 'readme_svg.py') $specPath $FontFolder $OutputPath
    if ($LASTEXITCODE -ne 0) {
        throw "readme_svg.py exited with code $LASTEXITCODE."
    }
} finally {
    Remove-Item -LiteralPath $specPath -ErrorAction SilentlyContinue
}
