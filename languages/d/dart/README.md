# Dart Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as callable Dart values. It includes `TRUE`, `FALSE`, `NOT`, `AND`,
`OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, then checks every printed example.

## Requirements

- A current stable Dart SDK
- No packages or other external dependencies

The CI workflow installs Dart with Dart's official setup action.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The repository-level `run-tests.sh` compares the program's standard output
with `expected-output.txt`.

## How the representation works

Dart cannot directly name the infinitely recursive type `Term = Term -> Term`.
The small `Term` wrapper therefore stores a `Term Function(Term)` and exposes
function-call syntax. Each core definition remains a direct translation of its
lambda-calculus form. The encodings do not store Dart booleans or integers;
only the output observers produce those native values.

Dart's first-class functions and lexical closure behavior are documented in
the official [functions guide](https://dart.dev/language/functions).
