# HTML + CSS

This implementation is one self-contained HTML document evaluated by a web
browser's native HTML and CSS engines. It contains no JavaScript, SVG, external
resources, generated source, or browser extension code. A Content Security
Policy in the document prevents external resources from loading.

## How it works

The HTML is the expression tree and the CSS is the evaluator.

For a complete, beginner-friendly tour of every moving part, read
[HOW-IT-WORKS.md](HOW-IT-WORKS.md).

- `lc-true` displays its first child and suppresses its second; `lc-false` does
  the reverse. The examples expand the actual Church definitions `NOT b = b
  FALSE TRUE`, `AND b1 b2 = b1 b2 FALSE`, and `OR b1 b2 = b1 TRUE b2` into
  nested selection trees. The browser's CSS selector engine performs each
  selection.
- A Church numeral is observed by applying it to CSS `counter-increment`.
  `lc-zero` contributes no applications and each `lc-succ` contributes one.
  `lc-pred` suppresses exactly the outermost successor, so predecessor
  saturates at zero.

This is deliberately not described as "HTML alone." HTML supplies the terms;
CSS supplies the computation. The important constraint is that the browser
runs no imperative scripting language.

## Run

Open `lambda-core.html` in a current browser. The page renders the same boolean
and numeral results as the other Lambda Core implementations.

## Test

The test asks headless Google Chrome to print the rendered page to PDF, then
uses `pdftotext` only as an observer of the text that CSS made visible. Neither
tool computes the lambda expressions. The test requires `google-chrome` and
`pdftotext` on `PATH`.

```sh
sh test.sh
```
