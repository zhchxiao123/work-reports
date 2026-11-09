#!/usr/bin/env bash
# Publish pages: copy drafts in, scan, rebuild the index, commit and push (GitHub Pages serves main /).
# Usage: tools/publish.sh [-m "commit message"] [draft.html ...]
# Each copied page must already have an entry in pages.json; the scan must be clean.
set -euo pipefail
cd "$(dirname "$0")/.."
msg=""
[ "${1:-}" = "-m" ] && { msg="$2"; shift 2; }
for src in "$@"; do cp "$src" .; done
python3 -I tools/add_home_link.py
tools/scan.sh
python3 -I tools/build_index.py
git add -A
git diff --cached --quiet && { echo "nothing to publish"; exit 0; }
git commit -q -m "${msg:-Publish $(git diff --cached --name-only | grep -v '^index.html$' | head -3 | tr '\n' ' ')}"
git -c credential.helper='!gh auth git-credential' push -q origin main
echo "pushed; https://zhchxiao123.github.io/work-reports/ updates in 1-2 minutes"
