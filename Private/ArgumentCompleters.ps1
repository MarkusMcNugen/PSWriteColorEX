# Tab completion of color names, gradient names and profile names. Each completer runs in the
# module, so it reads the color table and the profiles as they are when Tab is pressed.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'PowerShell passes a completer five parameters; most completers here read only the word typed.')]
param()

# The text typed so far, without an opening quote
function Get-ColorCompletionWord {
    param([string]$Word)
    return $Word.TrimStart([char]39, [char]34)
}

$script:ColorNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $word = Get-ColorCompletionWord -Word $wordToComplete
    $table = Get-ColorTableWithRGB
    foreach ($name in Get-ColorNameOrder -Names @($table.Keys | Where-Object { $_ -like "$word*" })) {
        $rgb = $table[$name][4]
        $tip = '{0}  #{1:X2}{2:X2}{3:X2}' -f $name, $rgb[0], $rgb[1], $rgb[2]
        [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $tip)
    }
}

$script:GradientCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $word = Get-ColorCompletionWord -Word $wordToComplete
    foreach ($name in $script:GradientNames.Keys) {
        if ($name -like "$word*") {
            $tip = '{0}  {1}' -f $name, ($script:GradientNames[$name] -join ' ')
            [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $tip)
        }
    }
    foreach ($result in & $script:ColorNameCompleter $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameters) {
        if (-not $script:GradientNames.Contains($result.CompletionText)) {
            $result
        }
    }
}

$script:RegisteredColorNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $word = Get-ColorCompletionWord -Word $wordToComplete
    foreach ($name in Get-ColorNameOrder -Names @($script:CustomColors.Keys | Where-Object { $_ -like "$word*" })) {
        [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $name)
    }
}

$script:ProfileNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $word = Get-ColorCompletionWord -Word $wordToComplete
    $names = [string[]]@([PSColorStyle]::Profiles.Keys | Where-Object { $_ -like "$word*" })
    $keys = [string[]]@(foreach ($name in $names) { $name.ToUpperInvariant() })
    [Array]::Sort($keys, $names, [System.StringComparer]::Ordinal)
    foreach ($name in $names) {
        [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $name)
    }
}

$colorParameters = @{
    'Write-ColorEX' = @('Color', 'BackGroundColor', 'UnderlineColor')
    'Format-ColorEX' = @('Color', 'BackGroundColor', 'UnderlineColor')
    'New-ColorStyle' = @('ForegroundColor', 'BackgroundColor', 'UnderlineColor')
    'Set-ColorDefault' = @('ForegroundColor', 'BackgroundColor')
    'Register-ColorName' = @('Color')
    'Show-ColorTable' = @('Name')
    'Get-ColorContrast' = @('Color', 'BackGroundColor')
}
foreach ($command in $colorParameters.Keys) {
    foreach ($parameter in $colorParameters[$command]) {
        Register-ArgumentCompleter -CommandName $command -ParameterName $parameter -ScriptBlock $script:ColorNameCompleter
    }
}
$gradientParameters = @{
    'Write-ColorEX' = @('Gradient', 'BackGroundGradient')
    'Format-ColorEX' = @('Gradient', 'BackGroundGradient')
    'New-ColorStyle' = @('Gradient', 'BackgroundGradient')
    'Get-GradientColor' = @('Gradient')
}
foreach ($command in $gradientParameters.Keys) {
    foreach ($parameter in $gradientParameters[$command]) {
        Register-ArgumentCompleter -CommandName $command -ParameterName $parameter -ScriptBlock $script:GradientCompleter
    }
}
Register-ArgumentCompleter -CommandName 'Unregister-ColorName' -ParameterName 'Name' -ScriptBlock $script:RegisteredColorNameCompleter
foreach ($command in 'Get-ColorProfiles', 'Export-ColorProfile', 'Remove-ColorProfile') {
    Register-ArgumentCompleter -CommandName $command -ParameterName 'Name' -ScriptBlock $script:ProfileNameCompleter
}
