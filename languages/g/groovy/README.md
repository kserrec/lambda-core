# Groovy Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as Groovy closures. It includes `TRUE`, `FALSE`, `NOT`, `AND`, `OR`,
`ZERO`, `SUCC`, `PRED`, and `ONE`, then checks every printed example.

## Requirements

- A current Groovy runtime, or a current Gradle installation
- No downloaded modules or other external dependencies

The test script prefers the `groovy` command. When it is unavailable, it uses
the Groovy runtime embedded in Gradle; Gradle is preinstalled on GitHub's
current `ubuntu-latest` runner. The fallback runs offline and resolves no
packages.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The repository-level `run-tests.sh` compares the program's standard output
with `expected-output.txt`.

## How the representation works

Groovy closures are first-class values with lexical capture, so the core terms
map directly to nested, curried closures. The encodings do not store Groovy
booleans or integers; only the output observers produce those native values.

Groovy's closure semantics are documented in the official
[closures guide](https://docs.groovy-lang.org/latest/html/documentation/core-closures.html).
