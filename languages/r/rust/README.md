# Rust Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as callable Rust values. It includes `TRUE`, `FALSE`, `NOT`, `AND`,
`OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, then checks every printed example.

## Requirements

- A current stable Rust compiler
- No Cargo crates or other external dependencies

Rust is included in GitHub's current
[`ubuntu-latest` runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#rust-tools),
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The test script compiles with warnings denied into a temporary directory,
runs the binary, and removes the build artifact. The repository-level
`run-tests.sh` compares its standard output with `expected-output.txt`.

## How the representation works

Rust cannot spell the infinitely recursive type `Term = Term -> Term`
directly. The small `Term` wrapper therefore holds an `Rc<dyn Fn(Term) ->
Term>`. `Rc` supplies shared ownership for captured terms, while each core
definition remains a direct translation of its lambda-calculus form. The
encodings do not store Rust booleans or integers; only the output observers
produce those native values.

The relevant standard-library mechanism is documented under
[`std::rc`](https://doc.rust-lang.org/std/rc/), and the Rust book explains
[closure capture](https://doc.rust-lang.org/book/ch13-01-closures.html).
