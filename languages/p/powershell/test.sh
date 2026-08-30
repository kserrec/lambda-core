#!/bin/sh
set -eu

command -v pwsh >/dev/null 2>&1 || exit 42

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec pwsh -NoLogo -NoProfile -NonInteractive -File "$directory/lambda-core.ps1"
