# Lambda Core

Welcome to *Lambda Core*, a repository dedicated to showcasing implementations of the "core" of lambda calculus in every programming language. We aim to create a living library of code snippets that demonstrate:

1. *Boolean Functions*: true, false, not, and, and or.
2. *Church Numerals*: zero, successor and predecessor functions, and the numeral one (derived from successor of zero).
3. *Examples using the above*: Prove they work!

This project is inspired by the classic "hello-world" repo idea, but takes things a step further by introducing some of the most fundamental concepts in functional programming and lambda calculus.

---

## Implemented Languages

Lambda Core currently has implementations in:

- [ArkScript](languages/a/arkscript), [Bash](languages/b/bash), and
  [bruijn](languages/b/bruijn)
- [C](languages/c/c), [C++](languages/c/c++), and
  [Clojure](languages/c/clojure)
- [Elixir](languages/e/elixir), [FatScript](languages/f/fatscript), and
  [F#](languages/f/fsharp)
- [Go](languages/g/go), [Haskell](languages/h/haskell),
  [Java](languages/j/java), and [JavaScript](languages/j/javascript)
- [Kotlin](languages/k/kotlin), [Language 84](languages/l/language84), and
  [Lua](languages/l/lua)
- [OCaml](languages/o/ocaml), [Perl](languages/p/perl),
  [PHP](languages/p/php), [PowerShell](languages/p/powershell), and
  [Python](languages/p/python)
- [Racket](languages/r/racket), [Ruby](languages/r/ruby),
  [Rust](languages/r/rust), [SQL](languages/s/sql), and
  [TypeScript](languages/t/typescript)

The August 2026 expansion added Bash, PHP, PowerShell, Rust, and SQL by
filtering the [2025 Stack Overflow language usage results](https://survey.stackoverflow.co/2025/technology)
against the implementations already present. GitHub's
[2025 Octoverse language ranking](https://github.blog/news-insights/octoverse/what-the-fastest-growing-tools-reveal-about-how-software-is-being-built/)
and the [August 2026 TIOBE index](https://www.tiobe.com/tiobe-index/) were used
as cross-checks.

Still wanted: Swift, Scala, Zig, Dart, Gleam, Prolog, Erlang, APL, and Idris.

---

## What is the "Lambda Core"?

The *Lambda Core* refers to:

- *Boolean Operations* in lambda calculus:
    - *True* and *False* (often represented as λx.λy.x and λx.λy.y).
    - *not* (logical negation).
    - *and* (logical conjunction).
    - *or* (logical disjunction).
- *Church Numerals*:
    - *Zero* (often λf.λx.x).
    - *Successor Function* (to increment a Church numeral).
    - *Predecessor Function* (to decrement a Church numeral).
    - *One* (either defined directly or via successor of zero).

By implementing these features, you will demonstrate how your chosen language can express or emulate these classic functional concepts.

---

## How to Contribute

We invite you to contribute by adding a folder for a programming language that is not yet present. To do so:

1. *Create a new folder* under languages/firstletterorsymbol/ named after the language you are implementing (e.g., languages/h/haskell, languages/p/python, languages/g/go, etc.).
2. Inside this folder, create:
     - A file named **lambda-core** with the appropriate file extension (e.g., lambda-core.py, lambda-core.hs, lambda-core.go).
     - A *README.md* that explains:
         - How to run your implementation (any dependencies, compilation steps, interpreter requirements, etc.).

3. *Open a Pull Request*:
     - Briefly describe what you did.
     - Link to any official references or documentation used if relevant.

---

## Folder Structure

The repository is organized as follows:

Each language's folder should stand on its own. Ideally, someone could clone the repo, enter your language's folder, follow your instructions, and verify your Lambda Core implementation right away.

---

## Example Contribution Workflow

Here’s a quick example workflow:

1. *Fork* this repository.
2. Create a branch named after your new language or a feature fix.
3. Add a new folder languages/letterorsymbol/mylanguage.
4. Add lambda-core.my-lang and a supporting README.md.
5. Commit and push your changes.
6. *Open a Pull Request* from your fork’s branch into the main branch of this repository.

We will review your submission, ask any clarifying questions, and then merge it once everything looks good.

---

## Why Contribute?

By contributing, you can:
- Show how your favorite language handles functional constructs.
- Learn about the power and simplicity of lambda calculus.
- Collaborate with others who share a passion for languages and functional programming.
- Expand your knowledge by seeing how other languages implement the same concepts.

---

## Need Inspiration?

If you are unfamiliar with lambda calculus, check out these resources:
- [Wikipedia: Lambda Calculus](https://en.wikipedia.org/wiki/Lambda_calculus)
- [Church Booleans](https://en.wikipedia.org/wiki/Church_boolean)
- [Church Numerals](https://en.wikipedia.org/wiki/Church_encoding#Church_numerals)
- [A Tutorial Introduction to the Lambda Calculus](https://personal.utdallas.edu/~gupta/courses/apl/lambda.pdf)

---

## License

This project is licensed under the [MIT License](LICENSE), so please feel free to fork, adapt, and share as you wish.

---

## Final Thoughts

Thank you for checking out *Lambda Core*! We encourage you to join this challenge and contribute. The goal is to build a fun, educational resource that demonstrates the universality of lambda calculus across the diverse landscape of programming languages.

*Happy Coding!*

---

## Bonus Challenge: Recursion with Combinators!

Want to take your implementation to the next level? Here's a bonus challenge:

- Implement recursion using a fixed-point combinator (Y, Z, or another variant) using your already made church numerals and logical operators.
    - Write a factorial, fibonacci, or some other classic recursive function using your combinator.
    - Include examples showing the recursive function in action.

Note: In many languages, achieving recursion or advanced combinators in a pure lambda style can be extremely difficult or even impossible without writing or embedding a specialized lambda interpreter.
