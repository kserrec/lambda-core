#!/bin/sh
set -eu

command -v arkscript >/dev/null 2>&1 || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
arkscript -fno-cache "$dir/lambda-core.ark"
