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
- [x] **Step 4 — OCaml, Elixir, Clojure, F#.** `test.sh` for all four
      (`ocaml lambda_core.ml`, `elixir lambda-core.exs`, `dotnet fsi
      lambda-core.fsx`, and `cd lambda-core && clojure -M:test` for Clojure's
      deps.edn test runner). Workflow installs `ocaml`+`elixir` via apt and the
      Clojure CLI via its official installer; F# uses the runner's preinstalled
      dotnet. OCaml + Elixir captured locally; F# and Clojure captured from the
      CI log (PR #31). Clojure uses `clojure`, not the interactive `clj` wrapper
      (which printed an rlwrap notice instead of running). All four green on CI.
- [x] **Step 5 — Java and Kotlin.** Java's numeral fix and `test.sh` landed in
      PR #29; its expected output was captured from that PR's actual CI run.
      Kotlin's existing implementation compiles unchanged with Kotlin 2.4.10;
      its test builds a temporary runnable jar. GitHub's `ubuntu-latest` runner
      already provides Kotlin 2.4.10 and Java 17, so no installer is needed.
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

Most additions land one language at a time with an implementation, README,
test.sh, and observed expected output. The five-language batch below is one
explicitly requested single-pass phase.

### Phase 1 — 2025 popularity expansion

Selection method: filter the Stack Overflow 2025 "have used" language ranking
against the repository's existing implementations, excluding HTML/CSS because
it is markup. The five highest absent entries are SQL (58.6%), Bash/Shell
(48.7%), PowerShell (23.2%), PHP (18.9%), and Rust (14.8%). GitHub's 2025
Octoverse independently places PHP and Shell in its top ten, while the August
2026 TIOBE index ranks SQL eighth, Rust tenth, and PHP thirteenth.

- [x] **Step 1 — verify the selection and starting state.** None of the five
      language folders existed before this phase; choosing them creates new
      implementations rather than fixing existing ones.
- [x] **Step 2 — implement all five cores.** Add Church booleans, Church
      numerals, native output adapters, and self-checking examples for Bash,
      PHP, PowerShell, Rust, and SQL. SQL may use an explicitly documented
      relational emulation because SQLite has no first-class functions.
- [x] **Step 3 — add verification artifacts.** Every folder gets README.md,
      test.sh, and expected-output.txt captured from an observed run.
- [x] **Step 4 — integrate and verify.** Verify the five toolchains in the
      current GitHub runner inventory (all are preinstalled), list the new
      implementations in the README, run focused checks, and run the repository
      harness. All five focused baseline checks pass; the full local harness
      reports 11 passed, 0 failed, 10 skipped for unavailable local toolchains,
      and the pre-existing Java baseline still pending.

### Phase 2 — next five languages by 2025 usage

Selection method: continue down the Stack Overflow 2025 "have used" language
ranking after removing repository implementations and C#, whose implementation
already exists in active PR #37. The next five absent languages are Assembly
(7.1%), Dart (5.9%), Swift (5.4%), R (4.9%), and Groovy (4.8%).

- [x] **Step 1 — verify the selection and starting state.** None of
      `languages/a/assembly`, `languages/d/dart`, `languages/s/swift`,
      `languages/r/r`, or `languages/g/groovy` exists on main. This phase
      creates five new implementations; it does not modify an existing
      language implementation.
- [x] **Step 2 — implement all five cores.** Add Church booleans, Church
      numerals, native output observers, and self-checking examples for
      Assembly, Dart, Swift, R, and Groovy. Assembly uses an explicitly
      documented x86-64 System V closure ABI because GNU assembler has no
      first-class closure type.
- [x] **Step 3 — add verification artifacts.** Every folder gets README.md,
      test.sh, and expected-output.txt captured from an observed run.
- [x] **Step 4 — integrate and verify.** Use the runner's preinstalled GCC,
      Swift, and Gradle toolchains; install only the R and Dart runtimes; list
      the new implementations in the README; run every focused check and the
      repository harness. GitHub CI reports 25 passed, 0 failed, 0 skipped,
      and the pre-existing Java baseline still pending (PR #39).

### Later major-language phases

- [ ] C#
- [ ] Scala
- [ ] Zig
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
