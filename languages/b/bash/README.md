# Bash Lambda Core

This implementation uses GNU Bash functions to express the Lambda Core
booleans and Church numerals. It requires Bash 4 or newer and no external
packages.

## Run

```sh
bash lambda-core.bash
```

## How it works

Bash functions cannot be stored and passed around as ordinary values, so this
implementation passes each function's name instead. Expanding a quoted variable
in command position, as in `"$boolean"`, calls the function with that name.

- `church_true` returns its first argument and `church_false` returns its
  second. `church_not`, `church_and`, and `church_or` combine those selectors
  using their Church definitions.
- A numeral receives the name of a function and a starting value.
  `church_zero` returns the starting value unchanged, while `church_succ`
  applies the function once more. `church_one` is defined as `SUCC ZERO`.
- `church_pred` advances a `(previous, current)` pair once per numeral
  application, then returns the previous value. That produces one fewer
  application while keeping `PRED ZERO` at zero.

Standard output contains the full boolean truth tables followed by examples of
`ZERO`, `ONE`, `SUCC`, and `PRED`.

## Test

From this folder, run:

```sh
sh test.sh
```

The repository's root `run-tests.sh` compares that output with
`expected-output.txt` on every pull request.
