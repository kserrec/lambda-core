# ArkScript

This implementation runs on ArkScript 4.

GitHub Actions downloads the official ArkScript 4.7.1 Linux archive and
verifies its SHA-256 digest before running the program. For another platform,
use the matching archive from the
[official ArkScript releases](https://github.com/ArkScript-lang/Ark/releases).
Keep the interpreter and its supplied libraries together when extracting it.

## Run

Place the ArkScript directory on your PATH, then run:

    arkscript -fno-cache lambda-core.ark

The no-cache flag prevents ArkScript from creating a generated
`__arkscript__` directory beside this source file.

## Test

    sh test.sh

The repository test harness compares that command's output byte-for-byte with
`expected-output.txt`. If ArkScript is not installed, the test is reported as
a local toolchain skip; a missing interpreter is a failure in CI.
