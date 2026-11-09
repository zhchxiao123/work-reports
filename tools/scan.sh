#!/usr/bin/env bash
# Refuse to publish pages that leak server addresses, credentials, internal paths or user identities.
# Usage: tools/scan.sh [file.html ...]   (default: every .html in the repo root)
# Exit 1 and print each hit when anything matches. Third-party IPs quoted in research
# pages go in ALLOW below, one per line.
set -euo pipefail
cd "$(dirname "$0")/.."
files=("$@"); [ ${#files[@]} -eq 0 ] && files=(*.html)

ALLOW='^(127\.0\.0\.1|0\.0\.0\.0|198\.19\.0\.2|157\.240\.11\.141)$'

PATTERNS=(
  'root@[0-9a-z]'                                  # ssh targets
  '/root/|/data/byai|/opt/byclaw|/home/byclaw|/byclaw-all|/workspace/reports'
  '\.scratch/|gq\.sh|byai-watch'
  'ghp_[A-Za-z0-9]{20}|github_pat_|sk-[A-Za-z0-9]{20}|LTAI[A-Za-z0-9]{12}|AKIA[A-Z0-9]{16}'
  '(password|passwd|secret|token)\s*[=:]\s*["'"'"']?[A-Za-z0-9+/_-]{8,}'
  'beyond-token=[A-Za-z0-9]'
  '\b00[0-9]{8}\b'                                 # employee user codes
  '[A-Za-z0-9._%+-]+@(iwhalecloud|gmail|proton|qq|163)\.[a-z.]+'
)

fail=0
for f in "${files[@]}"; do
  for p in "${PATTERNS[@]}"; do
    hits=$(grep -oP "$p" "$f" | grep -v '^root@\[' | sort -u || true)
    [ -n "$hits" ] && { echo "$f: $(echo "$hits" | head -3 | tr '\n' ' ')"; fail=1; }
  done
  ips=$(grep -oP '\b(\d{1,3}\.){3}\d{1,3}\b' "$f" | grep -vP '^(0|1|2)\.\d+\.' | grep -vP "$ALLOW" | sort -u || true)
  [ -n "$ips" ] && { echo "$f: IP $(echo "$ips" | tr '\n' ' ')"; fail=1; }
done
[ $fail -eq 0 ] && echo "scan: clean (${#files[@]} files)"
exit $fail
