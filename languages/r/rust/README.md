# Rust Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as callable Rust values. It includes `TRUE`, `FALSE`, `NOT`, `AND`,
`OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, then checks and prints examples of
each operation.

## Requirements

- A stable Rust compiler (`rustc`)
- No external crates or other dependencies

Rust is included in GitHub's current
[`ubuntu-latest` runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#rust-tools),
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The test script compiles `lambda-core.rs` with warnings treated as errors,
runs it, and removes the temporary executable. From the repository root,
`./run-tests.sh` also runs this script and compares its output with
`expected-output.txt`.

## How the representation works

A lambda-calculus term accepts one term and returns another. Rust cannot give
a directly recursive closure type a finite size, so `Term` stores the closure
behind `Rc`:

```rust
struct Term(Rc<dyn Fn(Term) -> Term>);
```

`Rc` is part of Rust's standard library. It supplies the required indirection
and lets a captured term be referenced more than once; it does not implement
any boolean or numeral behavior itself.

The core definitions are direct translations of the lambda-calculus forms.
For example, `TRUE` selects its first argument, `FALSE` selects its second,
and `SUCC` applies a supplied function once more than its input numeral does.
`PRED` uses the standard higher-order predecessor expression shown beside its
implementation.

Only the two output helpers cross back into native Rust values. The boolean
helper gives a term two distinct markers and reports which marker it selects.
The numeral helper gives a term an incrementing function and counts how many
times that function is applied. The encodings and operations themselves never
store or inspect a Rust `bool` or integer.
