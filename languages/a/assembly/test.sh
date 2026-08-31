#!/bin/sh
set -eu

command -v gcc >/dev/null 2>&1 || exit 42

case $(uname -m) in
    x86_64|amd64) ;;
    *) exit 42 ;;
esac

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_directory=$(mktemp -d)
trap 'rm -rf "$build_directory"' EXIT HUP INT TERM

gcc \
    -Wall \
    -Wextra \
    -Werror \
    -fPIE \
    -pie \
    "$directory/lambda-core.S" \
    -Wl,-z,noexecstack \
    -o "$build_directory/lambda-core"

"$build_directory/lambda-core"
