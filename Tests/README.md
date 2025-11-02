# PSWriteColorEX Tests

Comprehensive Pester V5 test suite for the PSWriteColorEX PowerShell module.

## Table of Contents

- [Overview](#overview)
- [Test Files](#test-files)
- [Requirements](#requirements)
- [Running Tests](#running-tests)
- [GitHub Actions CI/CD](#github-actions-cicd)
- [Test Structure](#test-structure)
- [Code Coverage](#code-coverage)
- [Contributing](#contributing)

## Overview

This test suite provides comprehensive coverage of all PSWriteColorEX functionality using Pester V5, the PowerShell testing framework. The tests are organized into individual files by component for better maintainability and faster targeted testing.

**Total Test Files:** 6 individual test files + 1 master test runner

**Test Coverage:**
- Classes (PSColorStyle)
- Private Functions (ANSI detection, color conversion, gradient generation)
- Public Functions (Write-ColorEX and all helper functions)
- Module loading and initialization

## Test Files

### Individual Test Files

| Test File | Component | Description |
|-----------|-----------|-------------|
| `Tests-PSColorStyle.ps1` | Class | Tests for PSColorStyle class including constructors, properties, methods, and static members |
| `Tests-TestAnsiSupport.ps1` | Private Function | Tests for ANSI terminal detection across platforms and terminals |
| `Tests-ConvertColorValue.ps1` | Private Functions | Tests for color conversion utilities (Hex→RGB, RGB→ANSI8, RGB→ANSI4, color table) |
| `Tests-NewGradientColorArray.ps1` | Private Function | Tests for gradient color generation with multi-stop support |
| `Tests-WriteColorHelpers.ps1` | Public Functions | Tests for helper functions (Error, Warning, Info, Success, Critical, Debug) and style management |
| `Tests-WriteColorEX.ps1` | Main Function | Comprehensive tests for the main Write-ColorEX function with all features |
| `Tests-WriteColorEXAutoPad.ps1` | Feature Tests | Tests for AutoPad feature with Unicode support |

### Master Test Runner

| File | Purpose |
|------|---------|
| `Tests-All.ps1` | Master test runner with Pester V5 configuration for CI/CD pipelines |

## Requirements

- **Pester v5.0.0 or higher** (required)
- **PowerShell 5.1+** or **PowerShell Core 6+**
- PSWriteColorEX module (automatically imported by tests)

### Installing Pester V5

```powershell
# Install Pester v5
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck

# Verify installation
Get-Module -Name Pester -ListAvailable
```

## Running Tests

### Run All Tests

```powershell
# Navigate to Tests folder
cd Tests

# Run all tests with default settings
.\Tests-All.ps1
```

### Run All Tests with Code Coverage

```powershell
# Run with code coverage enabled (default)
.\Tests-All.ps1 -CodeCoverage

# Run with minimum coverage requirement
.\Tests-All.ps1 -CodeCoverage -MinimumCoverage 70
```

### Run Individual Test Files

```powershell
# Run a specific test file
Invoke-Pester .\Tests-PSColorStyle.ps1 -Output Detailed

# Run tests for a specific component
Invoke-Pester .\Tests-WriteColorEX.ps1

# Run with tag filtering
Invoke-Pester -Path . -Tag 'Unit'
Invoke-Pester -Path . -Tag 'Function', 'Class'
```

### Advanced Options

```powershell
# Custom output format (for CI/CD)
.\Tests-All.ps1 -OutputFormat JUnitXml -OutputFile junit-results.xml

# Detailed output
.\Tests-All.ps1 -Show Detailed

# Return Pester result object
$result = .\Tests-All.ps1 -PassThru

# Exclude paths from code coverage
.\Tests-All.ps1 -CodeCoverage -ExcludePath @('Examples', 'Docs')
```

## GitHub Actions CI/CD

### Workflow Overview

The test suite is fully integrated with GitHub Actions for continuous integration. The workflow (`.github/workflows/test.yml`) automatically runs on:

- Push to `main`, `master`, or `develop` branches
- Pull requests targeting these branches
- Manual workflow dispatch

### Test Matrix

Tests run across multiple environments:

| Operating System | PowerShell Versions |
|-----------------|---------------------|
| Windows (latest) | 5.1, 7.2, 7.4 |
| Ubuntu (latest) | 7.2, 7.4 |
| macOS (latest) | 7.2, 7.4 |

*Note: PowerShell 5.1 only runs on Windows*

### Workflow Features

✅ **Multi-OS Testing** - Windows, Linux, macOS
✅ **Multi-Version Testing** - PowerShell 5.1 through 7.4
✅ **Automatic Pester Installation** - Ensures Pester V5 is available
✅ **Test Result Artifacts** - Uploads test results for each OS/version
✅ **Code Coverage Artifacts** - Generates and uploads coverage reports
✅ **Test Result Publishing** - Displays results in GitHub Actions UI
✅ **Codecov Integration** - Optional upload to Codecov (requires token)

### Viewing Test Results

1. Navigate to the **Actions** tab in your GitHub repository
2. Select the latest workflow run
3. View the test summary in the workflow summary
4. Download test result artifacts for detailed analysis
5. Check individual job logs for verbose output

### Setting Up Codecov (Optional)

To enable Codecov integration:

1. Sign up at [codecov.io](https://codecov.io)
2. Add your repository
3. Get your Codecov token
4. Add `CODECOV_TOKEN` as a repository secret in GitHub
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `CODECOV_TOKEN`
   - Value: Your Codecov token

## Test Structure

All tests follow Pester V5 best practices:

### Test Organization

```
Describe 'ComponentName'
  Context 'Feature or Scenario'
    It 'Specific test case'
```

### BeforeAll/AfterAll Blocks

```powershell
BeforeAll {
    # Module import and setup
    $ModuleRoot = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModuleRoot\PSWriteColorEX.psd1" -Force
}

BeforeEach {
    # Per-test setup
}

AfterEach {
    # Per-test cleanup
}
```

### Assertions

Tests use Pester V5 assertion syntax:

```powershell
# Equality
$result | Should -Be $expected

# Type checking
$object | Should -BeOfType [PSColorStyle]

# Null checking
$value | Should -Not -BeNullOrEmpty

# Exception testing
{ SomeFunction } | Should -Throw

# Collection testing
$array.Count | Should -BeGreaterThan 0
```

### Tags

Tests are tagged for filtering:

- `Unit` - Unit tests
- `Function` - Function tests
- `Class` - Class tests
- `Helper` - Helper function tests
- `Main` - Main function tests
- `ColorConversion` - Color conversion tests
- `Gradient` - Gradient generation tests
- `StyleManagement` - Style management tests

## Code Coverage

### Coverage Targets

| Component | Target Coverage |
|-----------|----------------|
| Classes | 90%+ |
| Private Functions | 85%+ |
| Public Functions | 90%+ |
| Overall Module | 80%+ |

### Viewing Coverage Reports

After running tests with code coverage:

```powershell
# Coverage.xml is generated in JaCoCo format
# View in CI/CD systems or import to coverage tools

# Check coverage percentage in test output
.\Tests-All.ps1 -CodeCoverage
```

### Coverage Exclusions

Some code is intentionally excluded from coverage:

- Example scripts
- Documentation generators
- Debug-only code paths
- Platform-specific fallbacks

## Contributing

When adding new functionality to PSWriteColorEX:

### 1. Create Tests First (TDD)

```powershell
# Create a new test file or add to existing
Describe 'New-Feature' {
    It 'Does something specific' {
        # Test implementation
    }
}
```

### 2. Run Tests Locally

```powershell
# Run individual test file during development
Invoke-Pester .\YourNew.Tests.ps1 -Output Detailed

# Run all tests before commit
.\Tests-All.ps1
```

### 3. Ensure Coverage

Aim for **80%+ code coverage** for new code:

```powershell
.\Tests-All.ps1 -CodeCoverage -MinimumCoverage 80
```

### 4. Test Across Platforms

If adding platform-specific functionality:

```powershell
# Use -Skip conditionally
It 'Works on Windows' -Skip:($PSVersionTable.Platform -eq 'Unix') {
    # Windows-specific test
}

It 'Works on Unix' -Skip:($PSVersionTable.Platform -eq 'Win32NT') {
    # Unix-specific test
}
```

### 5. Update Test Documentation

- Add test file to table in this README
- Document any special test requirements
- Add examples to test file headers

## Common Test Commands

```powershell
# Quick test during development
Invoke-Pester .\Tests-PSColorStyle.ps1

# Run all tests with detailed output
.\Tests-All.ps1 -Show Detailed

# Run only Unit tests
Invoke-Pester -Path . -Tag Unit

# Run specific Context
Invoke-Pester .\Tests-PSColorStyle.ps1 -Output Detailed

# Get code coverage for specific files
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '../Public/Write-ColorEX.ps1'
Invoke-Pester -Configuration $config

# Debug a failing test
Invoke-Pester .\FailingTest.Tests.ps1 -Output Diagnostic
```

## Troubleshooting

### Pester Version Conflicts

```powershell
# Remove all Pester versions
Get-Module Pester -ListAvailable | Uninstall-Module -Force

# Install clean Pester V5
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck
```

### Import Errors

```powershell
# Ensure module can be imported
Import-Module ..\PSWriteColorEX.psd1 -Force -Verbose

# Check for syntax errors
Get-Command -Module PSWriteColorEX
```

### Test Failures

```powershell
# Run with diagnostic output
.\Tests-All.ps1 -Show Diagnostic

# Check specific test
Invoke-Pester .\FailingTest.Tests.ps1 -Output Detailed

# Verify environment
$PSVersionTable
Test-AnsiSupport
```

## Resources

- [Pester Documentation](https://pester.dev)
- [Pester V5 Quick Start](https://pester.dev/docs/quick-start)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PSWriteColorEX Documentation](../README.md)

---

**Note:** All tests are designed to run without console output using the `-NoConsoleOutput` parameter to avoid cluttering test results while still validating functionality.
