# Swift Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as callable Swift values. It includes `TRUE`, `FALSE`, `NOT`, `AND`,
`OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, then checks every printed example.

## Requirements

- A current stable Swift compiler
- No packages or other external dependencies

Swift is preinstalled on GitHub's current `ubuntu-latest` runner, so this
folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The test script compiles with warnings promoted to errors in a temporary
directory, runs the binary, and removes the build artifact. The repository
test harness compares its standard output with `expected-output.txt`.

## How the representation works

Swift cannot directly name the infinitely recursive type `Term = Term ->
Term`. The small `Term` reference type therefore stores a `(Term) -> Term`
closure and implements `callAsFunction`. Each core definition remains a direct
translation of its lambda-calculus form. The encodings do not store Swift
booleans or integers; only the output observers produce those native values.

Swift's lexical closure behavior is documented in the official
[closures chapter](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/).
