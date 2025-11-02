# Analyze Pester Code Coverage (Command-based, not line-based)
param(
    [string]$CoverageFile = "Coverage.xml"
)

if (-not (Test-Path $CoverageFile)) {
    Write-Error "Coverage file not found: $CoverageFile"
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Pester Code Coverage Analysis (Commands)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

[xml]$coverage = Get-Content $CoverageFile

# Calculate overall metrics by summing all files
$sourceFiles = $coverage.report.package.sourcefile
$totalCoveredCommands = 0
$totalMissedCommands = 0

foreach ($file in $sourceFiles) {
    foreach ($line in $file.line) {
        $totalCoveredCommands += [int]$line.ci
        $totalMissedCommands += [int]$line.mi
    }
}

$totalCommands = $totalCoveredCommands + $totalMissedCommands
$coveragePercent = if ($totalCommands -gt 0) {
    [math]::Round(($totalCoveredCommands / $totalCommands) * 100, 2)
} else {
    0
}

Write-Host "Overall Coverage (Pester Commands)" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow
Write-Host "Total Commands:    " -NoNewline; Write-Host $totalCommands -ForegroundColor White
Write-Host "Covered Commands:  " -NoNewline; Write-Host $totalCoveredCommands -ForegroundColor Green
Write-Host "Missed Commands:   " -NoNewline; Write-Host $totalMissedCommands -ForegroundColor Red
Write-Host "Coverage Percent:  " -NoNewline
$color = if ($coveragePercent -ge 75) { 'Green' } elseif ($coveragePercent -ge 60) { 'Yellow' } else { 'Red' }
Write-Host "$coveragePercent%" -ForegroundColor $color

# Analyze per-file coverage
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Per-File Command Coverage" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$fileStats = @()

foreach ($file in $sourceFiles) {
    $fileName = $file.name

    # Count covered and missed instructions per line
    $coveredCommands = 0
    $missedCommands = 0

    foreach ($line in $file.line) {
        $covered = [int]$line.ci
        $missed = [int]$line.mi

        $coveredCommands += $covered
        $missedCommands += $missed
    }

    $totalCommands = $coveredCommands + $missedCommands

    $filePercent = if ($totalCommands -gt 0) {
        [math]::Round(($coveredCommands / $totalCommands) * 100, 2)
    } else {
        0
    }

    $fileStats += [PSCustomObject]@{
        File = $fileName
        TotalCommands = $totalCommands
        CoveredCommands = $coveredCommands
        MissedCommands = $missedCommands
        CoveragePercent = $filePercent
    }
}

# Sort by coverage percentage (lowest first)
$fileStats = $fileStats | Sort-Object CoveragePercent

foreach ($stat in $fileStats) {
    $color = if ($stat.CoveragePercent -ge 80) { 'Green' }
             elseif ($stat.CoveragePercent -ge 60) { 'Yellow' }
             else { 'Red' }

    Write-Host "$($stat.File.PadRight(45)) " -NoNewline
    Write-Host "$($stat.CoveragePercent.ToString().PadLeft(6))% " -NoNewline -ForegroundColor $color
    Write-Host "($($stat.CoveredCommands.ToString().PadLeft(4))/$($stat.TotalCommands.ToString().PadLeft(4)) commands)" -ForegroundColor Gray
}

# Method-level analysis
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Method/Function Coverage" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$classes = $coverage.report.package.class
$methodStats = @()

foreach ($class in $classes) {
    $sourceFile = $class.sourcefilename

    foreach ($method in $class.method) {
        $methodName = $method.name
        $methodLine = $method.line

        # Get method counters
        $methodInstructions = $method.counter | Where-Object { $_.type -eq 'INSTRUCTION' }

        if ($methodInstructions) {
            $methodCovered = [int]$methodInstructions.covered
            $methodMissed = [int]$methodInstructions.missed
            $methodTotal = $methodCovered + $methodMissed

            $methodPercent = if ($methodTotal -gt 0) {
                [math]::Round(($methodCovered / $methodTotal) * 100, 2)
            } else {
                0
            }

            $methodStats += [PSCustomObject]@{
                File = $sourceFile
                Method = $methodName
                Line = $methodLine
                CoveragePercent = $methodPercent
                CoveredCommands = $methodCovered
                TotalCommands = $methodTotal
            }
        }
    }
}

# Show methods with low coverage
$lowCoverageMethods = $methodStats | Where-Object { $_.CoveragePercent -lt 70 } | Sort-Object CoveragePercent

if ($lowCoverageMethods.Count -gt 0) {
    Write-Host "Methods with < 70% Coverage:" -ForegroundColor Yellow
    foreach ($method in $lowCoverageMethods | Select-Object -First 20) {
        $color = if ($method.CoveragePercent -ge 50) { 'Yellow' } else { 'Red' }
        Write-Host "  $($method.File):$($method.Line) " -NoNewline -ForegroundColor Gray
        Write-Host "$($method.Method) " -NoNewline -ForegroundColor White
        Write-Host "($($method.CoveragePercent)%)" -ForegroundColor $color
    }

    if ($lowCoverageMethods.Count -gt 20) {
        Write-Host "  ... and $($lowCoverageMethods.Count - 20) more" -ForegroundColor Gray
    }
} else {
    Write-Host "All methods have good coverage (>= 70%)!" -ForegroundColor Green
}

# Summary and recommendations
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Coverage Improvement Recommendations" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$lowCoverageFiles = $fileStats | Where-Object { $_.CoveragePercent -lt 70 }

if ($lowCoverageFiles.Count -gt 0) {
    Write-Host "Files needing attention (< 70% command coverage):" -ForegroundColor Yellow
    foreach ($file in $lowCoverageFiles) {
        $commandsNeeded = [math]::Ceiling($file.TotalCommands * 0.70) - $file.CoveredCommands
        Write-Host "  $($file.File):" -ForegroundColor Red
        Write-Host "    Current: $($file.CoveragePercent)% ($($file.CoveredCommands)/$($file.TotalCommands) commands)" -ForegroundColor Gray
        Write-Host "    To reach 70%: Need $commandsNeeded more commands covered" -ForegroundColor Gray
    }
} else {
    Write-Host "All files have good coverage (>= 70%)!" -ForegroundColor Green
}

Write-Host "`nNote: Pester measures 'commands' (executable statements) not 'lines'" -ForegroundColor Cyan
Write-Host "One line of code may contain multiple commands or no commands at all." -ForegroundColor Cyan
Write-Host ""
