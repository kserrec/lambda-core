#!/bin/sh
set -eu

command -v bash >/dev/null 2>&1 || exit 42
bash -c '(( BASH_VERSINFO[0] >= 4 ))' >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec bash "$directory/lambda-core.sh"
