#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <PDF-URL>" >&2
  exit 1
fi

URL="$1"
TMPPDF="$(mktemp /tmp/tmp_pdfXXXX.pdf)"
TMPDIR="$(mktemp -d /tmp/tmp_pagesXXXX)"
CLEANPDF="$(mktemp /tmp/tmp_cleanXXXX.pdf)"

cleanup() {
  rm -f "$TMPPDF" "$CLEANPDF"
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

# Download PDF via curl-impersonate
curl-impersonate -s -L \
  -H "Accept: application/pdf,application/octet-stream" \
  -H "Referer: https://mondaymandala.com/" \
  -o "$TMPPDF" "$URL"

# Konverter hver side til PNG med baggrundsfjernelse
magick -density 300 "$TMPPDF" \
  -fuzz 15% -fill white -opaque "#FEFEFE" \
  -quality 100 "$TMPDIR/page.png"

# Saml PNG-sider tilbage til én PDF
mapfile -t PAGES < <(ls -v "$TMPDIR"/page*.png)
magick "${PAGES[@]}" "$CLEANPDF"

# Send til printer
lp -o media=A4 -o fit-to-page "$CLEANPDF"
