# R Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as R closures. It includes `TRUE`, `FALSE`, `NOT`, `AND`, `OR`,
`ZERO`, `SUCC`, `PRED`, and `ONE`, then checks every printed example.

## Requirements

- A current R runtime with `Rscript`
- No add-on packages or other external dependencies

The CI workflow installs the minimal `r-base-core` runtime package.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The repository-level `run-tests.sh` compares the program's standard output
with `expected-output.txt`.

## How the representation works

R functions are lexical closures, so the core terms map directly to nested,
curried functions. The encodings do not store R logicals or integers; only the
output observers produce those native values. Distinct environments act as
identity markers when observing booleans.

The language mechanism is documented in R's official
[`function` reference](https://stat.ethz.ch/R-manual/R-devel/library/base/html/function.html).
