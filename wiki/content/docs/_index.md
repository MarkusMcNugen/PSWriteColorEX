---
title: Documentation
linkTitle: Docs
weight: 1
sidebar:
  open: true
---

PSWriteColorEX writes colored and styled text to the PowerShell host: TrueColor, 256 and 16
colors, gradients, markup, highlighting, links, text styles, style profiles, padding and wrapping
that count wide characters, and logging to a file. PWRSWriteColorEX has the same commands,
parameters and output, compiled from Rust, so every page here covers both.

The documentation follows the [Diataxis](https://diataxis.fr/) structure: four sections, each
answering a different question.

{{< cards >}}
  {{< card link="tutorial/" title="Tutorial" subtitle="From a first colored line to gradients, markup, layout, style profiles and logging." icon="academic-cap" >}}
  {{< card link="how-to/" title="How-to guides" subtitle="One task each: align columns, color log lines, build colored strings, turn colors off, and more." icon="book-open" >}}
  {{< card link="reference/" title="Reference" subtitle="Every command and parameter, the color names, the markup syntax, styles and environment variables." icon="document-text" >}}
  {{< card link="explanation/" title="Explanation" subtitle="Color modes and fallback, OKLab gradients, how output reaches the host, display width, PWRSWriteColorEX." icon="light-bulb" >}}
{{< /cards >}}

Every example that shows output ran through the module when the site was built, and the colors
on the page are the ones it wrote, drawn in Windows Terminal's default color scheme. A block
marked 256 colors or 16 colors ran in that color mode.
