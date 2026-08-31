# Assembly Lambda Core

This implementation expresses the project's Church booleans and Church
numerals in x86-64 GNU assembler. It includes `TRUE`, `FALSE`, `NOT`, `AND`,
`OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, then checks every printed example.

## Requirements

- An x86-64 System V environment, such as 64-bit Linux
- GCC and the system C library
- No additional packages or libraries

GCC and GNU binutils are preinstalled on GitHub's `ubuntu-latest` runner.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The test script compiles a position-independent executable into a temporary
directory, runs it, and removes the build artifact. The repository-level
`run-tests.sh` compares its standard output with `expected-output.txt`.

## How the representation works

GNU assembler has no first-class closure type, so each term uses an explicit
three-word closure: a code pointer followed by two captured-value slots. Every
code pointer follows the x86-64 System V calling convention and receives its
own closure plus one argument. The core encodings do not store native booleans
or integers; only the output observers create those values.

The syntax is documented in the
[GNU assembler manual](https://sourceware.org/binutils/docs/as/Manual.html),
and the calling convention comes from the
[x86-64 System V ABI](https://gitlab.com/x86-psABIs/x86-64-ABI).
