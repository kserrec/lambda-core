# Language 84

Language 84 version 0.8 runs on x86-64 Linux and uses a self-hosting compiler.
Build it with Clang. During verification, the 0.8 bootstrap compiler
segfaulted when built with GCC 13.3, while the documented Clang build completed
and ran successfully.

## Build and run

Download the
[official Language 84 0.8 archive](https://norstrulde.org/language84/language84-0.8.tar.xz)
and unpack it. Its SHA-256 digest is:

    b51807d1b7d06f1fdba762fdbf99c8c7fe762ec1a0c96c0be054657c9551cec0

Copy `lambda-core.84` and `local.make` from this folder into the extracted
`language84-0.8` directory, then run:

    make CC=clang
    ./lambda-core

## Test

Point the test at the extracted, otherwise unmodified Language 84 source tree:

    LANGUAGE84_HOME=/path/to/language84-0.8 sh test.sh

The test copies only the compiler's required `.84`, `.c`, and `.h`
sources into a temporary directory, builds with Clang, runs the resulting
program, and removes the temporary build. The output is compared byte-for-byte
with `expected-output.txt`.

Several functions are shown both with and without Language 84's syntactic
sugar. Search the source for `BITTER`, `SWEET`, and `SWEETEST` to compare
the forms.
