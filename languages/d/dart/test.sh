#!/bin/sh
set -eu

command -v dart >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
dart run "$directory/lambda-core.dart"
