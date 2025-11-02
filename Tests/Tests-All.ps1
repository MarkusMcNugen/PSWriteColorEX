<#
.SYNOPSIS
    Master test runner for PSWriteColorEX module using Pester V5

.DESCRIPTION
    This script runs all Pester tests for the PSWriteColorEX module with proper
    configuration for CI/CD pipelines including GitHub Actions. It generates
    test results in multiple formats and provides code coverage metrics.

.PARAMETER OutputFormat
    Format for test results. Options: NUnitXml, JUnitXml, NUnit2.5, or NUnit3
    Default: NUnitXml (compatible with most CI/CD systems)

.PARAMETER OutputFile
    Path to save test results. Default: TestResults.xml

.PARAMETER CodeCoverage
    Enable code coverage analysis. Default: $true

.PARAMETER CodeCoverageOutputFile
    Path to save code coverage results. Default: Coverage.xml

.PARAMETER MinimumCoverage
    Minimum code coverage percentage required (0-100). Default: 0 (no minimum)

.PARAMETER ExcludePath
    Array of paths to exclude from code coverage analysis

.PARAMETER PassThru
    Return the Pester result object

.PARAMETER Show
    Control Pester output verbosity. Options: None, Normal, Detailed, Diagnostic
    Default: Normal

.EXAMPLE
    .\Tests-All.ps1

.EXAMPLE
    .\Tests-All.ps1 -CodeCoverage -MinimumCoverage 70

.EXAMPLE
    .\Tests-All.ps1 -OutputFormat JUnitXml -OutputFile junit-results.xml

.EXAMPLE
    .\Tests-All.ps1 -Show Detailed -PassThru

.NOTES
    Requires Pester v5.0.0 or higher
    Compatible with PowerShell 5.1+ and PowerShell Core 6+
#>

[CmdletBinding()]
param(
    [ValidateSet('NUnitXml', 'JUnitXml', 'NUnit2.5', 'NUnit3')]
    [string]$OutputFormat = 'NUnitXml',

    [string]$OutputFile = 'TestResults.xml',

    [switch]$CodeCoverage = $true,

    [string]$CodeCoverageOutputFile = 'Coverage.xml',

    [ValidateRange(0, 100)]
    [int]$MinimumCoverage = 0,

    [string[]]$ExcludePath = @(),

    [switch]$PassThru,

    [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
    [string]$Show = 'Normal'
)

# Ensure we're using Pester v5
$requiredPesterVersion = [version]'5.0.0'
$pesterModule = Get-Module -Name Pester -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if (-not $pesterModule -or $pesterModule.Version -lt $requiredPesterVersion) {
    Write-Host "Pester v5.0.0+ not found. Installing..." -ForegroundColor Yellow

    try {
        Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck -Scope CurrentUser -ErrorAction Stop
        Write-Host "Pester v5 installed successfully" -ForegroundColor Green
        $pesterModule = Get-Module -Name Pester -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    }
    catch {
        Write-Error "Failed to install Pester v5: $_"
        Write-Error "Please install manually: Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck"
        exit 1
    }
}

# Import Pester
Import-Module Pester -MinimumVersion 5.0.0 -Force

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSWriteColorEX Test Suite Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pester Version: " -NoNewline
Write-Host $pesterModule.Version -ForegroundColor Green
Write-Host "PowerShell Version: " -NoNewline
Write-Host $PSVersionTable.PSVersion -ForegroundColor Green
Write-Host "Operating System: " -NoNewline
Write-Host $PSVersionTable.OS -ForegroundColor Green
Write-Host ""

# Get module root and test paths
$moduleRoot = Split-Path -Parent $PSScriptRoot
$testRoot = $PSScriptRoot

# Define all test files
$testFiles = @(
    'Tests-PSColorStyle.ps1'
    'Tests-TestAnsiSupport.ps1'
    'Tests-ConvertColorValue.ps1'
    'Tests-NewGradientColorArray.ps1'
    'Tests-WriteColorHelpers.ps1'
    'Tests-WriteColorEX.ps1'
    'Tests-WriteColorEXAutoPad.ps1'
)

# Verify all test files exist
$missingTests = @()
foreach ($testFile in $testFiles) {
    $testPath = Join-Path $testRoot $testFile
    if (-not (Test-Path $testPath)) {
        $missingTests += $testFile
    }
}

if ($missingTests.Count -gt 0) {
    Write-Warning "The following test files are missing:"
    $missingTests | ForEach-Object { Write-Warning "  - $_" }
    Write-Warning "Continuing with available tests..."
}

# Get all existing test files
$existingTestFiles = $testFiles | Where-Object {
    Test-Path (Join-Path $testRoot $_)
} | ForEach-Object {
    Join-Path $testRoot $_
}

Write-Host "Running tests from $($existingTestFiles.Count) test files:" -ForegroundColor Yellow
$existingTestFiles | ForEach-Object {
    Write-Host "  - $(Split-Path $_ -Leaf)" -ForegroundColor Gray
}
Write-Host ""

# Define code coverage paths
$codeCoveragePaths = @(
    "$moduleRoot\Classes\*.ps1"
    "$moduleRoot\Private\*.ps1"
    "$moduleRoot\Public\*.ps1"
    "$moduleRoot\PSWriteColorEX.psm1"
)

# Filter out excluded paths
if ($ExcludePath.Count -gt 0) {
    $codeCoveragePaths = $codeCoveragePaths | Where-Object {
        $path = $_
        $excluded = $false
        foreach ($exclude in $ExcludePath) {
            if ($path -like "*$exclude*") {
                $excluded = $true
                break
            }
        }
        -not $excluded
    }
}

# Create Pester configuration
$pesterConfig = New-PesterConfiguration

# Run configuration
$pesterConfig.Run.Path = $existingTestFiles
$pesterConfig.Run.PassThru = $true
$pesterConfig.Run.Exit = $false

# Output configuration
$pesterConfig.Output.Verbosity = $Show

# TestResult configuration
$pesterConfig.TestResult.Enabled = $true
$pesterConfig.TestResult.OutputFormat = $OutputFormat
$pesterConfig.TestResult.OutputPath = $OutputFile

# CodeCoverage configuration
if ($CodeCoverage) {
    $pesterConfig.CodeCoverage.Enabled = $true
    $pesterConfig.CodeCoverage.Path = $codeCoveragePaths
    $pesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'
    $pesterConfig.CodeCoverage.OutputPath = $CodeCoverageOutputFile
    $pesterConfig.CodeCoverage.OutputEncoding = 'UTF8'

    if ($MinimumCoverage -gt 0) {
        $pesterConfig.CodeCoverage.CoveragePercentTarget = $MinimumCoverage
    }
}

Write-Host "Starting test execution..." -ForegroundColor Yellow
Write-Host ""

# Run tests
$result = Invoke-Pester -Configuration $pesterConfig

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Display results
Write-Host ""
Write-Host "Total Tests: " -NoNewline
Write-Host $result.TotalCount -ForegroundColor White

Write-Host "Passed: " -NoNewline
Write-Host $result.PassedCount -ForegroundColor Green

Write-Host "Failed: " -NoNewline
if ($result.FailedCount -gt 0) {
    Write-Host $result.FailedCount -ForegroundColor Red
} else {
    Write-Host $result.FailedCount -ForegroundColor Green
}

Write-Host "Skipped: " -NoNewline
Write-Host $result.SkippedCount -ForegroundColor Yellow

Write-Host "Not Run: " -NoNewline
Write-Host $result.NotRunCount -ForegroundColor Gray

Write-Host ""
Write-Host "Duration: " -NoNewline
Write-Host "$($result.Duration.TotalSeconds) seconds" -ForegroundColor White

# Code coverage summary
if ($CodeCoverage -and $result.CodeCoverage) {
    Write-Host ""
    Write-Host "Code Coverage:" -ForegroundColor Cyan

    $coverage = $result.CodeCoverage
    $coveragePercent = 0

    if ($coverage.CommandsAnalyzedCount -gt 0) {
        $coveragePercent = [math]::Round(($coverage.CommandsExecutedCount / $coverage.CommandsAnalyzedCount) * 100, 2)
    }

    Write-Host "  Commands Analyzed: " -NoNewline
    Write-Host $coverage.CommandsAnalyzedCount -ForegroundColor White

    Write-Host "  Commands Executed: " -NoNewline
    Write-Host $coverage.CommandsExecutedCount -ForegroundColor White

    Write-Host "  Commands Missed: " -NoNewline
    Write-Host $coverage.CommandsMissedCount -ForegroundColor $(if ($coverage.CommandsMissedCount -gt 0) { 'Yellow' } else { 'Green' })

    Write-Host "  Coverage Percentage: " -NoNewline
    $coverageColor = if ($coveragePercent -ge 80) { 'Green' } elseif ($coveragePercent -ge 60) { 'Yellow' } else { 'Red' }
    Write-Host "$coveragePercent%" -ForegroundColor $coverageColor

    if ($MinimumCoverage -gt 0) {
        Write-Host "  Minimum Required: " -NoNewline
        Write-Host "$MinimumCoverage%" -ForegroundColor White

        if ($coveragePercent -lt $MinimumCoverage) {
            Write-Host ""
            Write-Host "  WARNING: Code coverage $coveragePercent% is below minimum $MinimumCoverage%" -ForegroundColor Red
        }
    }
}

# Output file locations
Write-Host ""
Write-Host "Output Files:" -ForegroundColor Cyan
Write-Host "  Test Results: " -NoNewline
if (Test-Path $OutputFile) {
    Write-Host $OutputFile -ForegroundColor Green
} else {
    Write-Host "Not generated" -ForegroundColor Yellow
}

if ($CodeCoverage) {
    Write-Host "  Code Coverage: " -NoNewline
    if (Test-Path $CodeCoverageOutputFile) {
        Write-Host $CodeCoverageOutputFile -ForegroundColor Green
    } else {
        Write-Host "Not generated" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Exit with appropriate code for CI/CD
if ($result.FailedCount -gt 0) {
    Write-Host ""
    Write-Host "TESTS FAILED" -ForegroundColor Red -BackgroundColor Black
    Write-Host ""

    # Show failed tests
    if ($result.Failed.Count -gt 0) {
        Write-Host "Failed Tests:" -ForegroundColor Red
        foreach ($test in $result.Failed) {
            Write-Host "  [$($test.ExpandedPath -replace '\.', ' > ')] " -ForegroundColor Gray -NoNewline
            Write-Host $test.ErrorRecord.Exception.Message -ForegroundColor Red
        }
        Write-Host ""
    }

    if ($PassThru) {
        return $result
    }
    exit 1
}

# Check code coverage minimum if specified
if ($CodeCoverage -and $MinimumCoverage -gt 0 -and $coveragePercent -lt $MinimumCoverage) {
    Write-Host ""
    Write-Host "CODE COVERAGE BELOW MINIMUM" -ForegroundColor Red -BackgroundColor Black
    Write-Host "Coverage: $coveragePercent% | Required: $MinimumCoverage%" -ForegroundColor Red
    Write-Host ""

    if ($PassThru) {
        return $result
    }
    exit 1
}

Write-Host ""
Write-Host "ALL TESTS PASSED" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

if ($PassThru) {
    return $result
}

exit 0
