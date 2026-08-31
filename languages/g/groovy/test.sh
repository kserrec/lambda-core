#!/bin/sh
set -eu

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if command -v groovy >/dev/null 2>&1; then
    exec groovy "$directory/lambda-core.groovy"
fi

if command -v gradle >/dev/null 2>&1; then
    cache_directory=$(mktemp -d)
    build_directory=$(mktemp -d)
    trap 'rm -rf "$cache_directory" "$build_directory"' EXIT HUP INT TERM
    gradle \
        --no-daemon \
        --quiet \
        --console=plain \
        --offline \
        -PlambdaCoreBuildDirectory="$build_directory" \
        --project-cache-dir "$cache_directory" \
        --project-dir "$directory" \
        lambdaCore
    exit 0
fi

exit 42
