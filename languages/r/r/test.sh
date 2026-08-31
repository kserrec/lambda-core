#!/bin/sh
set -eu

command -v Rscript >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
Rscript --vanilla "$directory/lambda-core.R"
