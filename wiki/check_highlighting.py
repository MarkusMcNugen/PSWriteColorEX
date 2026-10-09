"""Check the code highlighting of a built docs site.

Reads every .html file under a built site (Hugo's public/ folder) and, for
each code block, its language and whether Chroma highlighted it. Chroma marks
text a lexer could not read with the `err` class, which the theme paints; each
such token is printed with its page, the block's language and its line. A
block Chroma did not highlight, other than a `text` block or a `terminal`
block (a session generate.ps1 drew from what the module wrote), is printed
with its page and first line. Exits 1 when either is found, 0 otherwise, after
a count of blocks per language.

Usage, from wiki/ after a build:
    pwsh ./generate.ps1
    hugo --minify
    python3 check_highlighting.py public
"""
import collections
import html
import os
import re
import sys

# A minified site writes attributes without quotes, so each attribute pattern
# takes a value quoted or bare.
BLOCK = re.compile(r"<pre\b([^>]*)>\s*<code\b([^>]*)>(.*?)</code>\s*</pre>", re.S)
LANG = re.compile(r"""data-lang=["']?([^"'\s>]+)""")
LANG_CLASS = re.compile(r"""class=["']?language-([^"'\s>]+)""")
LINE = re.compile(r"""<span class=["']?line["']?>""")
ERR = re.compile(r"""<span class=["']?err["']?>(.*?)</span>""", re.S)

# Blocks that are not Chroma's to highlight
UNHIGHLIGHTED = {"text", "terminal"}


def text_of(fragment):
    return html.unescape(re.sub(r"<[^>]+>", "", fragment))


def main(site):
    census = collections.Counter()
    errors = []
    plain = []
    pages = 0
    for dirpath, _, files in os.walk(site):
        for name in sorted(files):
            if not name.endswith(".html"):
                continue
            path = os.path.join(dirpath, name)
            page = os.path.relpath(path, site).replace(os.sep, "/")
            with open(path, encoding="utf-8", errors="replace") as f:
                body = f.read()
            pages += 1
            for m in BLOCK.finditer(body):
                pre_attrs, code_attrs, inner = m.groups()
                found = LANG.search(code_attrs) or LANG_CLASS.search(code_attrs)
                lang = found.group(1) if found else "(none)"
                census[lang] += 1
                if "chroma" not in pre_attrs:
                    if lang not in UNHIGHLIGHTED:
                        first = text_of(inner).strip().splitlines()
                        plain.append((page, lang, first[0] if first else ""))
                    continue
                # A line is the text from one line span's start to the next;
                # an error token belongs to the line its offset falls in.
                starts = [s.start() for s in LINE.finditer(inner)] + [len(inner)]
                for e in ERR.finditer(inner):
                    i = 0
                    for k in range(len(starts) - 1):
                        if starts[k] <= e.start():
                            i = k
                    line = text_of(inner[starts[i]:starts[i + 1]]).strip()
                    errors.append((page, lang, text_of(e.group(1)), line))
    print("pages: %d" % pages)
    for lang, n in census.most_common():
        print("  %-12s %5d blocks" % (lang, n))
    for page, lang, token, line in errors:
        print("ERROR TOKEN %s [%s] %r in: %s" % (page, lang, token, line[:160]))
    for page, lang, first in plain:
        print("NOT HIGHLIGHTED %s [%s] %s" % (page, lang, first[:160]))
    print("%d error tokens, %d blocks not highlighted" % (len(errors), len(plain)))
    return 1 if errors or plain else 0


if __name__ == "__main__":
    if len(sys.argv) != 2 or not os.path.isdir(sys.argv[1]):
        sys.exit("usage: check_highlighting.py BUILT_SITE_DIR")
    sys.exit(main(sys.argv[1]))
