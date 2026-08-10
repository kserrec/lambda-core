# C# Lambda Core

This implementation expresses the project's Church booleans and Church
numerals as callable C# values. It includes `TRUE`, `FALSE`, `NOT`, `AND`,
`OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, then checks and prints examples of
each operation.

## Requirements

- The .NET 8 SDK or newer
- No NuGet packages or other external dependencies

The .NET 8 SDK is included in GitHub's current
[`ubuntu-latest` runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#net-tools),
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The test script builds and runs `LambdaCore.csproj` with warnings treated as
errors. It redirects all compiler output into a temporary directory and
removes that directory afterward, so it leaves no `bin` or `obj` artifacts in
the repository. From the repository root, `./run-tests.sh` also runs this
script and compares its output with `expected-output.txt`.

## How the representation works

A lambda-calculus term accepts one term and returns another. That definition
is recursive, so the `Term` class wraps a standard C# delegate of type
`Func<Term, Term>`:

```csharp
private sealed class Term
{
    private readonly Func<Term, Term> function;
}
```

The wrapper only makes the recursive function type possible. It does not
contain a boolean, number, or special case for any operation.

The core definitions are direct translations of their lambda-calculus forms.
For example, `TRUE` returns its first argument, `FALSE` returns its second,
and `SUCC` applies a supplied function once more than its input numeral does.
`PRED` uses the standard higher-order predecessor expression shown beside its
implementation.

Only the two output helpers cross back into native C# values. The boolean
helper gives a term two distinct marker objects and reports which one it
selects. The numeral helper gives a term an incrementing function and counts
how many times it is applied. The encodings and operations themselves never
store or inspect a C# `bool` or integer.
