#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import the module
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module "$ModulePath\PSWriteColorEX.psd1" -Force
}

Describe "Write-ColorEX AutoPad Feature" -Tags 'AutoPad', 'Unit' {

    Context "Basic AutoPad Functionality" {

        It "Should execute with AutoPad parameter" {
            { Write-ColorEX "Test" -AutoPad 20 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should create log file with padded text" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -AutoPad 10 -LogFile $tempLog -NoConsoleOutput 2>&1 | Out-Null
                Test-Path $tempLog | Should -Be $true
                $content = Get-Content $tempLog -Raw
                $content.Length | Should -BeGreaterThan 4  # More than "Test"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should handle Unicode bullet correctly" {
            { Write-ColorEX "Server ●" -AutoPad 21 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should handle CJK characters" {
            { Write-ColorEX "世界" -AutoPad 10 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should pad mixed ASCII and Unicode" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Server ●" -AutoPad 21 -LogFile $tempLog -NoConsoleOutput 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $displayWidth = Measure-DisplayWidth $content
                $displayWidth | Should -Be 21
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }
    }

    Context "PadLeft Functionality (Right-Align)" {

        It "Should execute with PadLeft switch" {
            { Write-ColorEX "Test" -AutoPad 10 -PadLeft -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should right-align text with PadLeft" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -AutoPad 10 -PadLeft -LogFile $tempLog -NoConsoleOutput 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                # Should start with spaces
                $content | Should -Match "^\s+Test"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should right-align Unicode text" {
            { Write-ColorEX "●" -AutoPad 10 -PadLeft -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }
    }

    Context "Custom PadChar" {

        It "Should use custom padding character" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -AutoPad 10 -PadChar '.' -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "Test......"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should use dash as PadChar" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -AutoPad 10 -PadChar '-' -PadLeft -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "------Test"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should use underscore as PadChar" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Field" -AutoPad 12 -PadChar '_' -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "Field_______"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }
    }

    Context "Edge Cases" {

        It "Should not pad when text is already wider than AutoPad" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Very long text here" -AutoPad 5 -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "Very long text here"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should not pad when text width equals AutoPad" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -AutoPad 4 -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "Test"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should handle empty text" {
            { Write-ColorEX "" -AutoPad 10 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should do nothing when AutoPad is 0 (disabled)" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -AutoPad 0 -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "Test"
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should handle negative AutoPad as disabled" {
            { Write-ColorEX "Test" -AutoPad -5 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should handle very large AutoPad values" {
            { Write-ColorEX "Test" -AutoPad 1000 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }
    }

    Context "Multiple Text Segments" {

        It "Should concatenate multiple segments before padding" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Hello", " ", "World" -AutoPad 20 -LogFile $tempLog -NoConsoleOutput 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Match "^Hello World"
                $displayWidth = Measure-DisplayWidth $content
                $displayWidth | Should -Be 20
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should handle array of text with Unicode" {
            { Write-ColorEX "Server", " ●" -AutoPad 21 -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }
    }

    Context "Integration with Other Features" {

        It "Should work with -Color parameter" {
            { Write-ColorEX "Test" -AutoPad 10 -Color Green -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should work with -Bold parameter" {
            { Write-ColorEX "Test" -AutoPad 10 -Bold -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should work with -NoNewLine parameter" {
            { Write-ColorEX "Test" -AutoPad 10 -NoNewLine -NoConsoleOutput 2>&1 } | Should -Not -Throw
        }

        It "Should work with -LogFile parameter" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                { Write-ColorEX "Test" -AutoPad 10 -LogFile $tempLog -NoConsoleOutput 2>&1 } | Should -Not -Throw
                Test-Path $tempLog | Should -Be $true
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }
    }

    Context "PSColorStyle AutoPad Properties" {

        It "Should create style with AutoPad via New-ColorStyle" {
            $style = New-ColorStyle -Name "TableStyle" -ForegroundColor Cyan -AutoPad 25
            $style.AutoPad | Should -Be 25
        }

        It "Should create style with all AutoPad parameters" {
            $style = New-ColorStyle -Name "RightAlign" -AutoPad 20 -PadLeft -PadChar '.'
            $style.AutoPad | Should -Be 20
            $style.PadLeft | Should -Be $true
            $style.PadChar | Should -Be '.'
        }

        It "Should apply AutoPad from StyleProfile" {
            $style = New-ColorStyle -Name "TestStyle" -AutoPad 15 -PadChar '.'
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Test" -StyleProfile $style -LogFile $tempLog -NoConsoleOutput -NoNewLine 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Be "Test..........."
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }
    }

    Context "Performance" {

        It "Should handle large AutoPad values efficiently" {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            Write-ColorEX "Test" -AutoPad 10000 -NoConsoleOutput 2>&1 | Out-Null
            $sw.Stop()
            $sw.ElapsedMilliseconds | Should -BeLessThan 500
        }

        It "Should handle long text efficiently" {
            $longText = "A" * 1000
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            Write-ColorEX $longText -AutoPad 1500 -NoConsoleOutput 2>&1 | Out-Null
            $sw.Stop()
            $sw.ElapsedMilliseconds | Should -BeLessThan 500
        }

        It "Should handle multiple AutoPad calls efficiently" {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            1..100 | ForEach-Object {
                Write-ColorEX "Test $_" -AutoPad 20 -NoConsoleOutput 2>&1 | Out-Null
            }
            $sw.Stop()
            # Increased threshold to account for code coverage overhead and slower machines
            $sw.ElapsedMilliseconds | Should -BeLessThan 10000
        }
    }

    Context "Real-World Scenarios" {

        It "Should create aligned table rows with different widths" {
            $tempLog1 = [System.IO.Path]::GetTempFileName()
            $tempLog2 = [System.IO.Path]::GetTempFileName()
            $tempLog3 = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Web Server" -AutoPad 21 -LogFile $tempLog1 -NoConsoleOutput 2>&1 | Out-Null
                Write-ColorEX "Database ●" -AutoPad 21 -LogFile $tempLog2 -NoConsoleOutput 2>&1 | Out-Null
                Write-ColorEX "Cache" -AutoPad 21 -LogFile $tempLog3 -NoConsoleOutput 2>&1 | Out-Null

                $width1 = Measure-DisplayWidth (Get-Content $tempLog1 -Raw)
                $width2 = Measure-DisplayWidth (Get-Content $tempLog2 -Raw)
                $width3 = Measure-DisplayWidth (Get-Content $tempLog3 -Raw)

                $width1 | Should -Be 21
                $width2 | Should -Be 21
                $width3 | Should -Be 21
            }
            finally {
                if (Test-Path $tempLog1) { Remove-Item $tempLog1 -Force }
                if (Test-Path $tempLog2) { Remove-Item $tempLog2 -Force }
                if (Test-Path $tempLog3) { Remove-Item $tempLog3 -Force }
            }
        }

        It "Should create table of contents style" {
            $tempLog = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "Chapter 1" -AutoPad 40 -PadChar '.' -LogFile $tempLog -NoConsoleOutput 2>&1 | Out-Null
                $content = Get-Content $tempLog -Raw
                $content | Should -Match "^Chapter 1\.+"
                $displayWidth = Measure-DisplayWidth $content
                $displayWidth | Should -Be 40
            }
            finally {
                if (Test-Path $tempLog) { Remove-Item $tempLog -Force }
            }
        }

        It "Should right-align numbers in columns" {
            $tempLog1 = [System.IO.Path]::GetTempFileName()
            $tempLog2 = [System.IO.Path]::GetTempFileName()
            try {
                Write-ColorEX "1,234" -AutoPad 12 -PadLeft -LogFile $tempLog1 -NoConsoleOutput 2>&1 | Out-Null
                Write-ColorEX "56" -AutoPad 12 -PadLeft -LogFile $tempLog2 -NoConsoleOutput 2>&1 | Out-Null

                $width1 = Measure-DisplayWidth (Get-Content $tempLog1 -Raw)
                $width2 = Measure-DisplayWidth (Get-Content $tempLog2 -Raw)

                $width1 | Should -Be 12
                $width2 | Should -Be 12
            }
            finally {
                if (Test-Path $tempLog1) { Remove-Item $tempLog1 -Force }
                if (Test-Path $tempLog2) { Remove-Item $tempLog2 -Force }
            }
        }
    }
}
