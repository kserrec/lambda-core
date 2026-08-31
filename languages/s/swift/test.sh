#!/bin/sh
set -eu

command -v swiftc >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_directory=$(mktemp -d)
trap 'rm -rf "$build_directory"' EXIT HUP INT TERM

swiftc \
    -warnings-as-errors \
    "$directory/lambda-core.swift" \
    -o "$build_directory/lambda-core"

"$build_directory/lambda-core"
