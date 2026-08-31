# Java Lambda Core

This implementation requires a Java Development Kit version 11 or newer.
Java's source-file mode compiles and runs `LambdaCore.java` directly, so no
separate build command or external package is needed.

## Run

```sh
java LambdaCore.java
```

## Test

From this folder, run:

```sh
sh test.sh
```

The repository's root `run-tests.sh` compares the program's output with
`expected-output.txt` on every pull request.
