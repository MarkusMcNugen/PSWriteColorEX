"""Draws the README's console images.

Reads a JSON spec of images, each a list of strings with the escape codes Format-ColorEX or
Write-ColorEX wrote, and writes each as an SVG: a terminal panel with every letter drawn from
Cascadia Mono's outlines, so the image looks the same in every browser. Colors follow the spec's
16-color palette, the 256-color cube and grays, and TrueColor; bold and italic take Cascadia Mono's
bold and italic faces. A wide character takes two cells, as a terminal gives it.

Usage: python -I readme_svg.py SPEC.json FONT_FOLDER OUTPUT_FOLDER
"""

import json
import re
import sys
import unicodedata
from pathlib import Path

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

FACES = {
    (False, False): ("r", "CascadiaMono-Regular.ttf"),
    (True, False): ("b", "CascadiaMono-Bold.ttf"),
    (False, True): ("i", "CascadiaMono-Italic.ttf"),
    (True, True): ("z", "CascadiaMono-BoldItalic.ttf"),
}

# Emoji Cascadia Mono lacks, drawn in a square from 0 to 1 that fills the two cells they take
EMOJI = {
    "✅": (
        '<rect x="0.06" y="0.06" width="0.88" height="0.88" rx="0.18" fill="#3FB950"/>'
        '<path d="M0.27 0.52 L0.44 0.69 L0.75 0.34" fill="none" stroke="#FFFFFF" stroke-width="0.13"'
        ' stroke-linecap="round" stroke-linejoin="round"/>'
    ),
}

# An SGR sequence, any other CSI sequence, or an OSC sequence such as a link, ended by BEL or ST
TOKEN = re.compile(r"\x1b\[([0-9;:]*)m|\x1b\[[0-9;?]*[A-Za-z]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)")

CUBE = (0, 95, 135, 175, 215, 255)


def plain_style():
    return {
        "fg": None, "bg": None, "bold": False, "faint": False, "italic": False,
        "underline": False, "ul": None, "crossed": False, "overline": False, "reverse": False,
    }


def cells_wide(ch):
    """The cells a character takes: two for wide and fullwidth ones, else one."""
    return 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1


def width_of(cells):
    return sum(cells_wide(ch) for ch, _ in cells)


def color_256(n, palette):
    if n < 16:
        return palette[n]
    if n < 232:
        n -= 16
        return "#{:02X}{:02X}{:02X}".format(CUBE[n // 36], CUBE[(n // 6) % 6], CUBE[n % 6])
    level = 8 + 10 * (n - 232)
    return "#{0:02X}{0:02X}{0:02X}".format(level)


def apply_sgr(style, params, palette):
    """Changes the style as one SGR sequence's parameters say."""
    codes = params.split(";") if params else ["0"]
    i = 0
    while i < len(codes):
        code = codes[i]
        if ":" in code:
            # 4:0 to 4:5 set the underline's kind, 4:0 none
            parts = code.split(":")
            if parts[0] == "4":
                style["underline"] = parts[1] != "0"
            i += 1
            continue
        n = int(code) if code else 0
        if n == 0:
            style.clear()
            style.update(plain_style())
        elif n == 1:
            style["bold"] = True
        elif n == 2:
            style["faint"] = True
        elif n == 3:
            style["italic"] = True
        elif n in (4, 21):
            style["underline"] = True
        elif n == 7:
            style["reverse"] = True
        elif n == 9:
            style["crossed"] = True
        elif n == 22:
            style["bold"] = False
            style["faint"] = False
        elif n == 23:
            style["italic"] = False
        elif n == 24:
            style["underline"] = False
        elif n == 27:
            style["reverse"] = False
        elif n == 29:
            style["crossed"] = False
        elif n == 53:
            style["overline"] = True
        elif n == 55:
            style["overline"] = False
        elif 30 <= n <= 37:
            style["fg"] = palette[n - 30]
        elif n == 39:
            style["fg"] = None
        elif 40 <= n <= 47:
            style["bg"] = palette[n - 40]
        elif n == 49:
            style["bg"] = None
        elif n == 59:
            style["ul"] = None
        elif 90 <= n <= 97:
            style["fg"] = palette[n - 90 + 8]
        elif 100 <= n <= 107:
            style["bg"] = palette[n - 100 + 8]
        elif n in (38, 48, 58) and i + 1 < len(codes):
            if codes[i + 1] == "5":
                color = color_256(int(codes[i + 2]), palette)
                i += 2
            else:
                r, g, b = (int(v) for v in codes[i + 2:i + 5])
                color = "#{:02X}{:02X}{:02X}".format(r, g, b)
                i += 4
            style[{38: "fg", 48: "bg", 58: "ul"}[n]] = color
        i += 1


def cells_of(segments, palette):
    """The characters of the segments, each with its style; each segment starts unstyled."""
    cells = []
    for segment in segments:
        style = plain_style()
        position = 0
        for match in TOKEN.finditer(segment):
            for ch in segment[position:match.start()]:
                cells.append((ch, dict(style)))
            if match.group(1) is not None:
                apply_sgr(style, match.group(1), palette)
            position = match.end()
        for ch in segment[position:]:
            cells.append((ch, dict(style)))
    return cells


def lines_of(cells, columns, wrap):
    """The cells cut into lines at line ends, and with wrap at spaces to fit the columns."""
    lines = [[]]
    for cell in cells:
        if cell[0] == "\n":
            lines.append([])
        else:
            lines[-1].append(cell)
    if not wrap:
        return lines
    wrapped = []
    for line in lines:
        current = []
        word = []
        for cell in line + [(" ", None)]:
            if cell[0] == " ":
                if word:
                    needed = width_of(word) if not current else width_of(current) + 1 + width_of(word)
                    if needed > columns and current:
                        wrapped.append(current)
                        current = list(word)
                    else:
                        if current:
                            current.append(space)
                        current.extend(word)
                    word = []
                space = cell if cell[1] is not None else (" ", plain_style())
            else:
                word.append(cell)
        wrapped.append(current)
    return wrapped


def mix(color, other, weight):
    a = [int(color[k:k + 2], 16) for k in (1, 3, 5)]
    b = [int(other[k:k + 2], 16) for k in (1, 3, 5)]
    return "#{:02X}{:02X}{:02X}".format(*(round(x * (1 - weight) + y * weight) for x, y in zip(a, b)))


def number(value):
    text = "{:.2f}".format(value).rstrip("0").rstrip(".")
    return text if text not in ("-0", "") else "0"


def attribute(text):
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def draw(image, spec, faces, metrics):
    size = image["size"]
    scale = size / metrics["upm"]
    advance = metrics["advance"] * scale
    line_height = size * image["lineHeight"]
    width = spec["width"]
    columns = int((width - 2 * image["padX"]) // advance)
    lines = lines_of(cells_of(image["segments"], spec["palette"]), columns, image["wrap"])
    height = 2 * image["padY"] + line_height * len(lines)
    ascent = metrics["ascent"] * scale
    descent = -metrics["descent"] * scale
    background = spec["background"]
    foreground = spec["foreground"]

    defs = {}
    backs = []
    glyphs = []
    rules = []
    alt_lines = []
    for row, line in enumerate(lines):
        alt_lines.append("".join(ch for ch, _ in line).rstrip())
        if image["align"] == "center":
            left = (width - width_of(line) * advance) / 2
        else:
            left = image["padX"]
        top = image["padY"] + row * line_height
        baseline = top + (line_height - ascent - descent) / 2 + ascent
        column = 0
        for ch, style in line:
            x = left + column * advance
            span = cells_wide(ch) * advance
            column += cells_wide(ch)
            fg = style["fg"] or foreground
            bg = style["bg"]
            if style["reverse"]:
                fg, bg = bg or background, fg
            if style["faint"]:
                fg = mix(fg, background, 0.5)
            if bg:
                backs.append('<rect x="{}" y="{}" width="{}" height="{}" fill="{}"/>'.format(
                    number(x), number(top), number(span + 0.4), number(line_height), bg))
            if ch in EMOJI:
                side = min(span, ascent + descent) * 0.95
                glyphs.append('<g transform="translate({} {}) scale({})">{}</g>'.format(
                    number(x + (span - side) / 2), number(baseline - ascent + (ascent + descent - side) / 2),
                    number(side), EMOJI[ch]))
            elif ch != " ":
                prefix, _ = FACES[(style["bold"], style["italic"])]
                key = "{}{:x}".format(prefix, ord(ch))
                if key not in defs:
                    defs[key] = faces[prefix].path(ch)
                glyphs.append('<use href="#{}" x="{}" y="{}" fill="{}"/>'.format(key, number(x), number(baseline), fg))
            thickness = max(metrics["ulThickness"] * scale, 1.0)
            if style["underline"]:
                y = baseline - metrics["ulPosition"] * scale
                rules.append('<rect x="{}" y="{}" width="{}" height="{}" fill="{}"/>'.format(
                    number(x), number(y), number(span + 0.4), number(thickness), style["ul"] or fg))
            if style["crossed"]:
                y = baseline - metrics["strike"] * scale
                rules.append('<rect x="{}" y="{}" width="{}" height="{}" fill="{}"/>'.format(
                    number(x), number(y), number(span + 0.4), number(thickness), fg))
            if style["overline"]:
                rules.append('<rect x="{}" y="{}" width="{}" height="{}" fill="{}"/>'.format(
                    number(x), number(top + 1), number(span + 0.4), number(thickness), fg))

    alt = image.get("altSeparator", " ").join(line for line in alt_lines if line)
    out = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="{0}" height="{1}" viewBox="0 0 {0} {1}" role="img" aria-label="{2}">'.format(
            number(width), number(height), attribute(alt)),
        "<title>{}</title>".format(attribute(alt)),
        "<defs>",
    ]
    for key, path in defs.items():
        out.append('<path id="{0}" transform="scale({1} -{1})" d="{2}"/>'.format(key, repr(scale), path))
    out.append("</defs>")
    out.append('<rect x="0.5" y="0.5" width="{}" height="{}" rx="{}" fill="{}" stroke="{}"/>'.format(
        number(width - 1), number(height - 1), spec["radius"], background, spec["border"]))
    out.extend(backs)
    out.extend(glyphs)
    out.extend(rules)
    out.append("</svg>")
    return "\n".join(out) + "\n", alt, len(lines)


class Face:
    """One Cascadia Mono face: each character's outline as SVG path data in font units."""

    def __init__(self, path):
        self.font = TTFont(path)
        self.glyphs = self.font.getGlyphSet()
        self.cmap = self.font.getBestCmap()

    def path(self, ch):
        name = self.cmap.get(ord(ch))
        if name is None:
            raise SystemExit("Cascadia Mono has no glyph for {!r}, and readme_svg.py draws no shape for it".format(ch))
        pen = SVGPathPen(self.glyphs)
        self.glyphs[name].draw(pen)
        return pen.getCommands()


def main():
    if len(sys.argv) != 4:
        raise SystemExit("usage: readme_svg.py SPEC.json FONT_FOLDER OUTPUT_FOLDER")
    # The report quotes each image's text, emoji among it, whatever the console's code page
    sys.stdout.reconfigure(encoding="utf-8")
    spec = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    font_folder = Path(sys.argv[2])
    output = Path(sys.argv[3])
    faces = {prefix: Face(font_folder / file) for prefix, file in FACES.values()}
    regular = faces["r"].font
    upm = regular["head"].unitsPerEm
    advance = regular["hmtx"]["space"][0]
    for prefix, face in faces.items():
        if face.font["head"].unitsPerEm != upm or face.font["hmtx"]["space"][0] != advance:
            raise SystemExit("the Cascadia Mono faces differ in size: " + prefix)
    metrics = {
        "upm": upm,
        "advance": advance,
        "ascent": regular["hhea"].ascent,
        "descent": regular["hhea"].descent,
        "ulPosition": regular["post"].underlinePosition,
        "ulThickness": regular["post"].underlineThickness,
        "strike": regular["OS/2"].yStrikeoutPosition,
    }
    for image in spec["images"]:
        svg, alt, count = draw(image, spec, faces, metrics)
        target = output / image["file"]
        target.write_bytes(svg.encode("utf-8"))
        print("{}: {} bytes, {} lines: {}".format(image["file"], len(svg.encode("utf-8")), count, alt))


if __name__ == "__main__":
    main()
