# PowerShell Lambda Core

This implementation uses PowerShell script blocks as callable values for the
project's Church booleans and Church numerals. It includes `TRUE`, `FALSE`,
`NOT`, `AND`, `OR`, `ZERO`, `SUCC`, `PRED`, and `ONE`, with self-checking
examples for every operation.

## Requirements

- PowerShell 7 or newer (`pwsh`)
- No PowerShell modules or other external dependencies

PowerShell is included in GitHub's current
[`ubuntu-latest` runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#powershell-tools),
so this folder does not require a workflow installation step.

## Run and verify

From this directory, run:

```sh
sh test.sh
```

The script starts PowerShell without profiles or interactive behavior. The
repository-level `run-tests.sh` compares its standard output with
`expected-output.txt`.

## How the representation works

A PowerShell script block is callable, and `GetNewClosure()` captures the
current values needed by a returned, nested script block. That makes the
curried lambda terms expressible without native booleans or integers in the
core definitions. Only the two `ConvertFrom-Church*` observers cross into
native values for output.

Microsoft documents script-block closure creation in
[`ScriptBlock.GetNewClosure`](https://learn.microsoft.com/dotnet/api/system.management.automation.scriptblock.getnewclosure).
