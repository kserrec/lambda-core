# Bash Lambda Core

Bash has shell functions, but it does not have first-class functions or
lexical closures. This implementation therefore uses a small closure runtime:
each lambda term has an opaque ID, and Bash associative arrays attach a
handler plus captured terms to that ID. The handlers directly implement
`TRUE`, `FALSE`, `NOT`, `AND`, `OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`.

## Requirements

- Bash 4 or newer (for associative arrays)
- No external commands or packages at runtime

Bash is part of the base operating system on GitHub's `ubuntu-latest` runner,
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The repository-level `run-tests.sh` runs the same script and compares its
standard output with `expected-output.txt`.

## How the representation works

The term registry is the only emulation layer. Applying a term dispatches its
handler in the current shell process, and nested handlers allocate terms that
capture their arguments. The Church definitions never store native boolean or
numeral values. Output observers use two marker terms for booleans and count
function applications for numerals.

The GNU Bash manual documents
[shell functions](https://www.gnu.org/software/bash/manual/bash.html#Shell-Functions)
and [associative arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html).
