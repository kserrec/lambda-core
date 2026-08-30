#!/bin/sh
set -eu

command -v sqlite3 >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec sqlite3 :memory: < "$directory/lambda-core.sql"
