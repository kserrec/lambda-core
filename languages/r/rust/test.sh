#!/bin/sh
set -eu

command -v rustc >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_directory=$(mktemp -d)
trap 'rm -rf "$build_directory"' EXIT HUP INT TERM

rustc \
    --edition=2021 \
    -D warnings \
    "$directory/lambda-core.rs" \
    -o "$build_directory/lambda-core"

"$build_directory/lambda-core"
