#!/bin/sh
set -eu

command -v php >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec php "$directory/lambda-core.php"
