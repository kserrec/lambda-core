#!/bin/sh
set -eu

command -v clang >/dev/null 2>&1 || exit 42
command -v make >/dev/null 2>&1 || exit 42

language84_home=${LANGUAGE84_HOME:-}
[ -n "$language84_home" ] || exit 42
[ -f "$language84_home/84_stable.c" ] || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -r "$build_dir"' 0 1 2 15

cp "$language84_home"/*.84 "$build_dir"/
cp "$language84_home/84_stable.c" "$language84_home/support.c" \
  "$language84_home/support.h" "$language84_home/Makefile" "$build_dir"/
cp "$dir/lambda-core.84" "$dir/local.make" "$build_dir"/

(
  cd "$build_dir"
  make CC=clang 1>&2
)
"$build_dir/lambda-core"
