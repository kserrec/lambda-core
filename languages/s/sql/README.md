# SQL Lambda Core

This implementation uses SQLite to demonstrate the Lambda Core through a
relational emulation. SQLite does not have first-class functions, so Church
booleans are stored by the argument branch they select, while a Church numeral
is stored as one row per function application. Views implement `NOT`, `AND`,
and `OR`; triggers implement reusable `SUCC` and `PRED` transformations.

## Requirements

- SQLite 3
- No extensions or external packages

SQLite is included in GitHub's current
[`ubuntu-latest` runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#databases),
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The script evaluates `lambda-core.sql` in a fresh in-memory database. Each
example is inserted into a table whose `CHECK` constraint compares actual and
expected values, so an incorrect operation exits nonzero before output. The
repository-level `run-tests.sh` compares the observed output with
`expected-output.txt`.

## Why this is an emulation

The project explicitly permits languages to express *or emulate* the core
lambda-calculus concepts. SQL's reusable abstraction is a relation rather
than a closure. The implementation preserves Church behavior—the boolean
selects one branch, and a numeral describes repeated application—without
claiming that SQLite rows are first-class lambda terms.

The implementation relies only on SQLite's documented
[`CREATE TRIGGER`](https://www.sqlite.org/lang_createtrigger.html) behavior.
