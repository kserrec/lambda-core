# PHP Lambda Core

This implementation uses PHP closures to express `TRUE`, `FALSE`, `NOT`,
`AND`, `OR`, `ZERO`, `SUCC`, `PRED`, and `ONE` directly as curried callable
values. Native booleans and integers appear only in the output observers and
self-checks.

## Requirements

- PHP 8.0 or newer
- No Composer packages or other external dependencies

PHP is included in GitHub's current
[`ubuntu-latest` runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#php-tools),
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The repository-level `run-tests.sh` runs the same script and compares its
standard output with `expected-output.txt`.

## How the representation works

PHP arrow functions are closure objects and automatically capture values from
their enclosing scope. That permits a close transcription of the curried
lambda terms; for example, `TRUE` is `fn($x) => fn($_y) => $x`, and `SUCC`
applies a supplied function once more than its input numeral does.

Only `churchToBool` and `churchToInt` cross into native PHP values. See the
official PHP documentation for
[anonymous functions](https://www.php.net/manual/en/functions.anonymous.php)
and [arrow functions](https://www.php.net/manual/en/functions.arrow.php).
