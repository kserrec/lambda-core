#!/bin/sh
set -eu

command -v kotlinc >/dev/null 2>&1 || exit 42
command -v java >/dev/null 2>&1 || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -r "$build_dir"' 0 1 2 15

kotlinc "$dir/lambda-core.kt" -include-runtime -d "$build_dir/lambda-core.jar"
java -jar "$build_dir/lambda-core.jar"
