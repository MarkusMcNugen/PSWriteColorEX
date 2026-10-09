# Clear-StartupColorEnvironment removes the color variables of the shell that started Pester
# (NO_COLOR, FORCE_COLOR, CLICOLOR, CLICOLOR_FORCE, and TERM when it is dumb) and sets
# $PSStyle.OutputRendering to Host, which PowerShell 7.2 and later start as PlainText when
# NO_COLOR is set. Call it before the module is imported, since the module reads the color
# support once at import. Restore-StartupColorEnvironment puts back what it changed.

function Clear-StartupColorEnvironment {
    $script:StartupColorEnvironment = @{}
    foreach ($name in 'NO_COLOR', 'FORCE_COLOR', 'TERM', 'CLICOLOR', 'CLICOLOR_FORCE') {
        $script:StartupColorEnvironment[$name] = [System.Environment]::GetEnvironmentVariable($name)
    }
    foreach ($name in 'NO_COLOR', 'FORCE_COLOR', 'CLICOLOR', 'CLICOLOR_FORCE') {
        [System.Environment]::SetEnvironmentVariable($name, $null)
    }
    if ($script:StartupColorEnvironment['TERM'] -eq 'dumb') {
        [System.Environment]::SetEnvironmentVariable('TERM', $null)
    }
    $script:StartupOutputRendering = $null
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $script:StartupOutputRendering = $PSStyle.OutputRendering
        $PSStyle.OutputRendering = 'Host'
    }
}

function Restore-StartupColorEnvironment {
    foreach ($name in $script:StartupColorEnvironment.Keys) {
        [System.Environment]::SetEnvironmentVariable($name, $script:StartupColorEnvironment[$name])
    }
    if ($null -ne $script:StartupOutputRendering) {
        $PSStyle.OutputRendering = $script:StartupOutputRendering
    }
}
