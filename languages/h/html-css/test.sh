#!/bin/sh
set -eu

command -v google-chrome >/dev/null 2>&1 || exit 42
command -v pdftotext >/dev/null 2>&1 || exit 42

dir=$(cd "$(dirname "$0")" && pwd)
render_dir=$(mktemp -d)
trap 'rm -r "$render_dir"' 0 1 2 15
pdf="$render_dir/lambda-core.pdf"

google-chrome \
    --headless=new \
    --disable-gpu \
    --no-pdf-header-footer \
    --user-data-dir="$render_dir/chrome" \
    --print-to-pdf="$pdf" \
    "file://$dir/lambda-core.html" >/dev/null 2>&1

pdftotext -layout "$pdf" - |
    sed -e '/^[[:space:]]*$/d' \
        -e 's/^[[:space:]]*//' \
        -e 's/[[:space:]]*$//'
