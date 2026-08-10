#!/bin/sh
set -eu

command -v bash >/dev/null 2>&1 || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bash "$dir/lambda-core.bash"
