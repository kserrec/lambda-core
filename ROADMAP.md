# Roadmap

Working agreement: every step is sized to be completed (and verified) in one
sitting. An implementation only gets an `expected-output.txt` captured from an
actual observed run — never written from reading the source. Anything that
can't be run locally gets verified on the CI runner before merge.

## Milestone 1 — CI backfill: every existing language tested on every PR

The harness: `run-tests.sh` loops over `languages/*/*/test.sh`, runs each, and
diffs stdout against that folder's `expected-output.txt`. The GitHub Actions
workflow (`.github/workflows/test.yml`) runs it on every PR and push to main.
Folders without a `test.sh` are skipped until backfilled.

- [x] **Step 1 — harness + locally verifiable languages.** Workflow file,
      `run-tests.sh`, and test.sh/expected-output.txt for Python, JavaScript,
      TypeScript (Bun), Perl, Racket, and C. All six verified locally.
- [x] **Step 2 — C++ and Go.** C++ needs GCC 14 (`<print>` header) — not on
      the dev machine, so capture its output from the CI runner log on the PR,
      then commit it as the expected file. Go is preinstalled on runners.
- [x] **Step 3 — Ruby, Lua, Haskell.** `test.sh` added for all three
      (`ruby lambda-core.rb`, `lua5.4 lambda-core.lua`, `runghc lambda-core.hs`),
      the apt installs (`ruby lua5.4 ghc`) added to the workflow, and each
      folder's `expected-output.txt` captured from a real local run. All three
      PASS locally.
- [ ] **Step 4 — OCaml, Elixir, Clojure, F#.** apt/preinstalled on runners
      (`ocaml`, `elixir`, `clojure`; F# via preinstalled dotnet). Clojure runs
      through its own deps.edn test runner — wrap it in test.sh.
- [ ] **Step 5 — Java and Kotlin.** Java: PR #29 (the `java` branch) fixes the
      numeral typing so PRED works; add test.sh + expected output to that
      branch, let CI validate it, then merge #29. Kotlin: runner has a JDK;
      install kotlinc in the workflow.
- [ ] **Step 6 — exotic languages: ArkScript, FatScript, bruijn, Language 84.**
      Each needs its own toolchain acquisition (GitHub releases, cargo/stack
      installs, or building from source). If one is genuinely unobtainable in
      CI, document that in its folder instead of leaving it silently untested.
- [ ] **Step 7 — flip the default and update the front door.** Once all
      folders have tests: make `run-tests.sh` fail on folders *missing* a
      test.sh, update README contribution instructions to require
      test.sh + expected-output.txt in new-language PRs, and enable branch
      protection so PRs need a green check to merge.

## Milestone 2 — fill out the missing major languages

One language per step, each landing as its own PR with implementation, README,
test.sh, and expected output, CI-green before merge. Order roughly by reach:

- [ ] Rust
- [ ] C#
- [ ] Swift
- [ ] Scala
- [ ] Zig
- [ ] PHP
- [ ] Dart
- [ ] Gleam (reopens the slot from closed PR #28)

Keep a "wanted" list in the README for languages left open to contributors
(Prolog, Erlang, APL, Idris, …).

## Milestone 3 — housekeeping

- [ ] Remove the committed binary `languages/c/c/app` and add a root
      `.gitignore` for build artifacts.
- [ ] TypeScript implementation only exercises Church numerals at runtime —
      booleans exist at the type level only. Decide whether that satisfies the
      spec or needs a runtime supplement.
- [ ] Comment on merged PR #6 noting the `Function<Term, Term>` fix, closing
      the loop on the thread there.
- [ ] Java README still describes an Oracle JDK manual install — point it at
      apt/Temurin and the test.sh instead.
