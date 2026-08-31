# Kotlin Lambda Core

This implementation requires the Kotlin command-line compiler and a Java
Development Kit. It is tested with Kotlin 2.4.10 and Java 17 or newer; both are
preinstalled on GitHub's `ubuntu-latest` runner.

## Build and run

```sh
kotlinc lambda-core.kt -include-runtime -d lambda-core.jar
java -jar lambda-core.jar
```

## Test

From this folder, run:

```sh
sh test.sh
```

The test compiles into a temporary directory, runs the resulting jar, and
removes the build artifact afterward. The repository's root `run-tests.sh`
compares the output with `expected-output.txt` on every pull request.
