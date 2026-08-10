# FatScript

This implementation requires the
[fry interpreter](https://fatscript.org/en/general/setup.html).

## Run with a native fry installation

    fry lambda-core.fat

## Run and test with Docker

The automated test uses the official FatScript 4.5.0 image pinned by its
multi-platform digest:

    docker pull fatscript/fry@sha256:fa8bfe0d759ce4bd7146ce9c97521b2cc72f1905d496468a1537fd9e36addc80
    sh test.sh

The container receives this folder read-only and runs without network access.
The test does not silently switch to a newer image. Its output is compared
byte-for-byte with `expected-output.txt`.

The [FatScript playground](https://fatscript.org/playground/) is also useful
for interactive exploration, but it is not used for automated verification.
