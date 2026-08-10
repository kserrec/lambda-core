#!/bin/sh
set -eu

command -v java >/dev/null 2>&1 || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
java "$dir/LambdaCore.java"
