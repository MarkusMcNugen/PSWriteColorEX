# The rules PSScriptAnalyzer applies to this repository, here and in test.yml; VS Code's PowerShell
# extension reads this file from the repository root. Write-Host is what the module writes with and
# what its examples show, so its rule is left out; a finding the analyzer cannot see past is
# suppressed where it stands, with the reason.
@{
    ExcludeRules = @('PSAvoidUsingWriteHost')
}
