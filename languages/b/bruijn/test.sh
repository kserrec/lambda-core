#!/bin/sh
set -eu

command -v bruijn >/dev/null 2>&1 || exit 42
command -v sed >/dev/null 2>&1 || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
raw=$(mktemp)
trap 'rm -f "$raw"' 0 1 2 15

bruijn -v "$dir/lambda-core.bruijn" >"$raw"
LC_ALL=C sed 's/\x1b\[[0-9;]*m//g' "$raw"
