#!/bin/sh
set -eu

command -v docker >/dev/null 2>&1 || exit 42

image='fatscript/fry@sha256:fa8bfe0d759ce4bd7146ce9c97521b2cc72f1905d496468a1537fd9e36addc80'
docker image inspect "$image" >/dev/null 2>&1 || exit 42

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
docker run --rm --network none --read-only \
  -v "$dir:/app:ro" \
  "$image" \
  lambda-core.fat
