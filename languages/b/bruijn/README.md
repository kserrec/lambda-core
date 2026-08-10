# bruijn

This implementation requires the
[bruijn interpreter](https://github.com/marvinborner/bruijn). Bruijn does not
publish release binaries, so GitHub Actions builds upstream commit
`9f1ac8856d09666a7444874f80b91b876929eecf` using the project's locked
Stack snapshot (LTS 22.12).

## Install

    git clone https://github.com/marvinborner/bruijn.git
    cd bruijn
    git checkout 9f1ac8856d09666a7444874f80b91b876929eecf
    stack install

## Run

    bruijn -v lambda-core.bruijn

Verbose mode prints one success line for every `:test` expression in the
source. The final `main` term is printed after those checks.

## Test

    sh test.sh

The interpreter always emits terminal color codes, even when output is not a
terminal. The test removes only those ANSI color codes before comparing the
actual text with `expected-output.txt`; all test results and the final term
remain in the comparison.

Further examples are available in bruijn's
[samples](https://bruijn.marvinborner.de/samples/) and
[standard library](https://bruijn.marvinborner.de/std/).
