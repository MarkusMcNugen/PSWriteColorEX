---
title: Performance
weight: 50
---

A script may write thousands of lines, so each call has to be cheap.

## PSWriteColorEX

Measured in PowerShell 7.6 on Linux, recorded in the changelog, a call takes:

| Call | 1.1.0 | 1.2.0 |
|---|---:|---:|
| Plain text | 254 microseconds | 158 microseconds |
| A hex color with `-Bold` | 504 microseconds | 199 microseconds |

The work done for every segment is in two classes, `ColorCode` and `ColorLine`, whose methods cost
a fraction of a function call; the color variables are read from .NET rather than through the
`Env:` drive; colors that need no conversion skip it; and the helpers are defined once, at import,
with debug messages built only under `-Debugging`. A gradient's colors come from the `ColorMath`
class, which computes 1000 OKLab steps in about 11 milliseconds.

## PWRSWriteColorEX

PWRSWriteColorEX is compiled from Rust. Both modules at 1.2.1, each call run 2000 times after 200
warm-up calls with its output discarded, each module in a process of its own, in pwsh 7.6.7 on
Windows 11 on an AMD Ryzen 9 7900X with `FORCE_COLOR=3`:

| Call | PSWriteColorEX 1.2.1 | PWRSWriteColorEX 1.2.1 |
|---|---:|---:|
| `Write-ColorEX -Text 'Status: ', 'OK' -Color Gray, Green` | 705 microseconds | 139 microseconds |
| `Write-ColorEX -Text 'x' -Color '#FF8000' -Bold` | 611 microseconds | 128 microseconds |
| `Write-ColorEX -Text ('=' * 40) -Gradient Red, Blue` | 1195 microseconds | 144 microseconds |
| `Write-ColorEX -Text '世界' -AutoPad 20` | 454 microseconds | 127 microseconds |
| `Write-ColorInfo 'message'` | 431 microseconds | 128 microseconds |

The same call costs more on one machine and operating system than another, so compare the two
modules on one machine, as here, rather than across tables.

Most of the time left is spent in the .NET calls that build each write to the host.

## Measuring a call

Timings depend on the machine, the host and what the output goes to. To time a call yourself,
discard its output and divide:

```powershell
$runs = 2000
$time = Measure-Command {
    for ($i = 0; $i -lt $runs; $i++) {
        Write-ColorEX -Text 'Status: ', 'OK' -Color Gray, Green 6>$null
    }
}
'{0:N0} microseconds per call' -f ($time.TotalMilliseconds * 1000 / $runs)
```
