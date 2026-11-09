#!/usr/bin/env python3
"""Give every page a link back to index.html. Usage: tools/add_home_link.py [file.html ...]

Pages that already link to index.html are left alone (only the old "研究资料首页" label is renamed).
Otherwise the link goes at the top of the left sidebar, or at the top of the first <header>.
Exits 1 if a page has neither and needs a hand edit.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LABEL = "← 工作报告首页"
LINK = f'<a class="wr-home" href="index.html">{LABEL}</a>'
STYLE = (
    '<style id="wr-home-style">.wr-home{display:inline-block;margin-bottom:14px;font-size:12px;'
    'color:#87867F;text-decoration:none;font-family:system-ui,-apple-system,"PingFang SC",sans-serif}'
    '.wr-home:hover{color:#B04A3F}</style>'
)
HOME = re.compile(r'href="(\./)?index\.html(#[^"]*)?"')

files = [Path(a) for a in sys.argv[1:]] or sorted(ROOT.glob("*.html"))
failed = []
for path in files:
    if path.name == "index.html":
        continue
    text = path.read_text(encoding="utf-8")
    new = text.replace("研究资料首页", "工作报告首页")
    if not HOME.search(new):
        for anchor in (r'<aside class="sidenav"[^>]*>', r"<header[^>]*>"):
            m = re.search(anchor, new)
            if m:
                new = new[: m.end()] + "\n    " + LINK + new[m.end():]
                new = new.replace("</head>", STYLE + "\n</head>", 1)
                break
        else:
            failed.append(path.name)
            continue
    if new != text:
        path.write_text(new, encoding="utf-8")
        print(f"updated {path.name}")
if failed:
    raise SystemExit(f"no sidebar or header to put the home link in: {failed}")
