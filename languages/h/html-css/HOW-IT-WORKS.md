# How Lambda Core Works in Native HTML and CSS

This is a guided tour of the HTML and CSS implementation. It assumes no prior
knowledge of lambda calculus, Church encodings, or the less familiar parts of
CSS.

Keep [lambda-core.html](lambda-core.html) open beside this guide if you want to
follow each explanation in the complete source.

The surprising idea is simple:

- A Church boolean is a choice between two things. CSS can choose which child
  element is visible.
- A Church numeral describes how many times to apply something. CSS counters
  can count repeated elements.

The HTML describes the expressions as nested elements. The CSS interprets
those shapes while the browser renders the page. There is no JavaScript.

## 1. What Lambda Core asks each implementation to show

The project has two small groups of ideas.

The boolean group contains:

- `TRUE`
- `FALSE`
- `NOT`
- `AND`
- `OR`

The numeral group contains:

- `ZERO`
- `SUCC`, short for successor, which adds one
- `PRED`, short for predecessor, which subtracts one without going below zero
- `ONE`, built by applying `SUCC` to `ZERO`

Every implementation also needs examples with observable results. In this
version, the browser page itself is the program output.

## 2. The two browser features doing the work

### HTML supplies a tree

HTML is not stored as one flat line. The browser parses nested elements into a
tree called the Document Object Model, usually shortened to DOM.

For example:

```html
<lc-true>
  <span>BOOLEAN TRUE</span>
  <span>BOOLEAN FALSE</span>
</lc-true>
```

The `lc-true` element has exactly two children. Their order matters: the first
child represents the first choice and the second child represents the second
choice.

Names such as `lc-true` and `lc-succ` are deliberately descriptive. A browser
can parse and style these hyphenated element names without registering a Web
Component. They have no built-in behavior and no JavaScript is attached to
them. Their meaning comes entirely from the CSS rules in this document.

### CSS reacts to the tree

A CSS selector finds elements with a particular name, position, or
relationship. A CSS declaration then changes how those matched elements are
rendered.

This implementation uses two kinds of CSS action:

1. Boolean rules hide one of two child branches.
2. Numeral rules increment a counter and print its final value.

That is the whole mechanism. The rest of the file constructs useful expression
trees for those rules to evaluate.

## 3. Church booleans are selectors

An ordinary boolean is often imagined as a stored value: true or false. A
Church boolean behaves differently. It receives two arguments and returns one
of them.

In lambda-calculus notation:

```text
TRUE  = λx.λy.x
FALSE = λx.λy.y
```

The Greek letter lambda means "a function follows." Read those definitions as:

- `TRUE` receives `x` and `y`, then chooses `x`.
- `FALSE` receives `x` and `y`, then chooses `y`.

The HTML representation also gives each boolean two arguments, as its first
and second child elements. These two CSS selectors make the choice:

```css
lc-true > :nth-child(2),
lc-false > :first-child {
  display: none;
}
```

Break the selectors apart:

- `lc-true > :nth-child(2)` finds the second direct child of every `lc-true`.
- `lc-false > :first-child` finds the first direct child of every `lc-false`.
- `display: none` removes the matched branch from rendering.

Therefore:

- `lc-true` hides its second child, leaving its first child.
- `lc-false` hides its first child, leaving its second child.

Here is `TRUE` applied to two printable arguments:

```html
<lc-output>
  <lc-true>
    <span>BOOLEAN TRUE</span>
    <span>BOOLEAN FALSE</span>
  </lc-true>
</lc-output>
```

The browser hides `BOOLEAN FALSE`, so the visible result is:

```text
BOOLEAN TRUE
```

Changing only `lc-true` to `lc-false` makes the same tree render `BOOLEAN
FALSE`. The text at the leaves supplies the two arguments; the CSS boolean
decides which argument becomes observable. This is the same role played by
helper functions such as `readBool(b) = b("TRUE")("FALSE")` in conventional
language implementations.

## 4. Why `display: contents` appears

The document also contains this rule:

```css
lc-true,
lc-false,
lc-not,
lc-and,
lc-or {
  display: contents;
}
```

`display: contents` makes an element participate as a logical wrapper without
creating a visible layout box of its own. Its children still render normally.

For `lc-true` and `lc-false`, the actual choosing behavior comes from the
`display: none` rules described above. The `lc-not`, `lc-and`, and `lc-or`
elements are readable labels around complete expression trees. They do not
perform a second, hidden kind of computation. The nested `lc-true` and
`lc-false` elements inside them perform every choice.

## 5. `NOT` reverses the two choices

The Church definition of `NOT` is:

```text
NOT b = b FALSE TRUE
```

Because a Church boolean chooses one of two arguments, giving it `FALSE` first
and `TRUE` second reverses its result.

Consider `NOT TRUE`. After placing `TRUE` in the definition, the expression is:

```text
TRUE FALSE TRUE
```

The corresponding part of the HTML has this shape:

```html
<lc-true>
  <lc-false>
    <span>BOOLEAN TRUE</span>
    <span>BOOLEAN FALSE</span>
  </lc-false>
  <lc-true>
    <span>BOOLEAN TRUE</span>
    <span>BOOLEAN FALSE</span>
  </lc-true>
</lc-true>
```

Follow the browser's choices from the outside inward:

1. The outer `lc-true` selects its first child.
2. That first child is `lc-false`.
3. The selected `lc-false` chooses its second printable argument.
4. The visible result is `BOOLEAN FALSE`.

For `NOT FALSE`, the outer element is `lc-false`. It selects the second child,
which is `lc-true`, and the final result is `BOOLEAN TRUE`.

Nothing in those two traces asks CSS to recognize the words "true" or
"false." CSS follows child positions, exactly as the Church definitions do.

## 6. `AND` chooses its second input or `FALSE`

The Church definition of `AND` is:

```text
AND b1 b2 = b1 b2 FALSE
```

Read it as: use the first boolean, `b1`, to choose between the second boolean,
`b2`, and the constant `FALSE`.

- If `b1` is `TRUE`, it selects `b2`, so the result depends on `b2`.
- If `b1` is `FALSE`, it selects the constant `FALSE` immediately.

For example, `AND FALSE TRUE` expands to:

```text
FALSE TRUE FALSE
```

The outer `FALSE` chooses its second child, the constant `FALSE`. That inner
`FALSE` then chooses the `BOOLEAN FALSE` printable branch.

By contrast, `AND TRUE TRUE` expands to:

```text
TRUE TRUE FALSE
```

The outer `TRUE` chooses its first child, the second input. That input is also
`TRUE`, so it chooses the `BOOLEAN TRUE` printable branch.

The HTML includes all four input combinations, so the browser demonstrates the
complete `AND` truth table rather than one favorable example.

## 7. `OR` chooses `TRUE` or its second input

The Church definition of `OR` is:

```text
OR b1 b2 = b1 TRUE b2
```

Read it as: use the first boolean, `b1`, to choose between the constant `TRUE`
and the second boolean, `b2`.

- If `b1` is `TRUE`, it selects the constant `TRUE` immediately.
- If `b1` is `FALSE`, it selects `b2`, so the result depends on `b2`.

For example, `OR FALSE TRUE` becomes:

```text
FALSE TRUE TRUE
```

The outer `FALSE` chooses its second child. That child is the second input,
`TRUE`, which ultimately displays `BOOLEAN TRUE`.

`OR FALSE FALSE` instead selects a second input of `FALSE`, so it displays
`BOOLEAN FALSE`. Again, the document includes all four combinations.

## 8. Why the boolean trees repeat some markup

Languages such as JavaScript can name a function, pass it an argument, and
construct a new value while the program runs. Native HTML and CSS do not
provide that kind of function call or variable substitution.

Instead, this document writes each Church application as its expanded element
tree. For example, it writes the shape `b FALSE TRUE` for each `NOT` example.
That is why the same two printable leaf spans occur more than once.

The repeated leaves are not the computed answers. They are the final two
arguments supplied to a Church boolean. Only one becomes visible, and the
nested boolean selectors determine which one. If an operand element changes
from `lc-true` to `lc-false`, the visible result follows that changed tree.

## 9. Church numerals are repetition

A Church numeral does not store a decimal digit. It receives a function `f`
and a starting value `x`, then applies `f` a particular number of times.

```text
ZERO f x = x
ONE  f x = f(x)
TWO  f x = f(f(x))
```

The successor operation adds one more application:

```text
SUCC n f x = f(n f x)
```

This HTML represents each application added by `SUCC` as one nested `lc-succ`
element:

```html
<!-- ZERO -->
<lc-zero></lc-zero>

<!-- ONE = SUCC ZERO -->
<lc-succ>
  <lc-zero></lc-zero>
</lc-succ>

<!-- TWO = SUCC ONE -->
<lc-succ>
  <lc-succ>
    <lc-zero></lc-zero>
  </lc-succ>
</lc-succ>
```

Notice that there is no separately hardcoded `lc-one` element. `ONE` really is
represented as one `SUCC` wrapped around `ZERO`, as the project requires.

## 10. A CSS counter observes the numeral

To turn a Church numeral into a familiar number, conventional implementations
apply it to an increment function and a starting value of zero:

```text
n(x -> x + 1)(0)
```

This version uses a CSS counter as that observer.

```css
lc-number {
  counter-reset: church 0;
}

lc-number lc-succ {
  counter-increment: church 1;
}

lc-number::after {
  content: counter(church);
}
```

Step by step:

1. `counter-reset: church 0` creates a counter named `church` and starts it at
   zero for each `lc-number` output.
2. `lc-number lc-succ` matches every `lc-succ` inside that output.
3. Each match increments the counter by one.
4. The `::after` pseudo-element inserts the final counter value into the
   rendered page.

Therefore a tree containing no `lc-succ` renders `0`, one `lc-succ` renders
`1`, and two nested `lc-succ` elements render `2`.

The `::after` output is worth noticing: the digit is not present as text in the
HTML source. The browser creates it from the evaluated CSS counter during
rendering.

## 11. `PRED` removes one successor

`PRED` means predecessor. For a positive numeral it removes one application;
for `ZERO` it stays at zero.

The numeral trees in this document are in a regular form: a chain of
`lc-succ` elements ending in `lc-zero`. Applying `PRED` wraps that chain in
`lc-pred`:

```html
<!-- PRED TWO -->
<lc-pred>
  <lc-succ>
    <lc-succ>
      <lc-zero></lc-zero>
    </lc-succ>
  </lc-succ>
</lc-pred>
```

Normally both `lc-succ` elements would increment the counter. This selector
turns off the increment belonging to the outermost successor:

```css
lc-number lc-pred > lc-succ {
  counter-increment: none;
}
```

The `>` symbol means "direct child." It matches the first `lc-succ` directly
inside `lc-pred`, but it does not match the inner `lc-succ`. The remaining
inner successor increments the counter once, so `PRED TWO` renders `1`.

For `PRED ONE`, the only successor is suppressed and the result is `0`. For
`PRED ZERO`, there is no successor to suppress, so the reset value remains
`0`. This gives predecessor its required floor at zero.

## 12. Reading all 18 output lines

The HTML examples render in source order. The expected output maps to the
expressions like this:

| Lines | Expressions | Rendered results |
| --- | --- | --- |
| 1–2 | `TRUE`, `FALSE` | `TRUE`, `FALSE` |
| 3–4 | `NOT TRUE`, `NOT FALSE` | `FALSE`, `TRUE` |
| 5–8 | `AND FALSE FALSE`, `AND TRUE FALSE`, `AND FALSE TRUE`, `AND TRUE TRUE` | `FALSE`, `FALSE`, `FALSE`, `TRUE` |
| 9–12 | `OR FALSE FALSE`, `OR TRUE FALSE`, `OR FALSE TRUE`, `OR TRUE TRUE` | `FALSE`, `TRUE`, `TRUE`, `TRUE` |
| 13–15 | `ZERO`, `ONE`, `TWO` | `0`, `1`, `2` |
| 16–18 | `PRED TWO`, `PRED ONE`, `PRED ZERO` | `1`, `0`, `0` |

The boolean lines include the word `BOOLEAN` so they remain unambiguous beside
the numeral output.

## 13. What happens when the page opens

From beginning to end, the browser performs this sequence:

1. It parses `lambda-core.html` into an element tree.
2. It parses the inline CSS.
3. It matches selectors against the tree.
4. It removes each unchosen boolean branch from rendering.
5. It resets and increments the numeral counters.
6. It creates the counter text through `lc-number::after`.
7. It lays out the remaining visible text in document order.

There is no event handler, animation loop, network request, or script startup
between these steps. Ordinary parsing, selector matching, counter evaluation,
and layout produce the result.

## 14. How the automated test observes CSS output

The test must inspect what the browser rendered. Reading the HTML source would
not be enough:

- It would include both the selected and hidden boolean branches.
- It would not include the digits created by `content: counter(church)`.

The folder's [test.sh](test.sh) therefore follows this path:

```text
lambda-core.html
        |
        v
headless Google Chrome renders HTML + CSS
        |
        v
Chrome prints the rendered page to a temporary PDF
        |
        v
pdftotext extracts the visible text
        |
        v
sed removes blank lines and outside whitespace
        |
        v
run-tests.sh compares it with expected-output.txt
```

Headless Chrome is the normal Chrome browser engine running without a visible
window. Printing to PDF captures layout decisions, including hidden branches,
generated counter text, and document order. `pdftotext` then reads the text
already present in that rendered PDF. It does not decide any boolean or numeral
result.

The test creates a fresh temporary directory for Chrome and deletes that
directory when it finishes. If Chrome or `pdftotext` is unavailable, the test
returns the repository's standard "toolchain unavailable" status. On GitHub
Actions both tools are available, so a missing tool is treated as a failure.
The root [run-tests.sh](../../../run-tests.sh) performs the exact comparison
with this folder's [expected-output.txt](expected-output.txt).

## 15. How the document enforces its no-JavaScript constraint

The implementation contains one inline `<style>` element and no `<script>`
element. It also contains this Content Security Policy:

```html
<meta http-equiv="Content-Security-Policy"
      content="default-src 'none'; style-src 'unsafe-inline'">
```

The policy denies resources by default and permits only the inline CSS needed
by the document. There are no external stylesheets, images, fonts, frames, or
other resource URLs. The page is therefore self-contained and its result does
not depend on a server or network connection.

## 16. Small experiments to build intuition

The easiest way to understand the mechanism is to make one local change and
refresh the page.

### Change a boolean operand

Find a `NOT` example and change only its outer `lc-true` to `lc-false`. The
outer selector will choose the other nested boolean, and the visible answer
will flip.

### Construct `THREE`

Add another `lc-number` containing three `lc-succ` wrappers around one
`lc-zero`. The counter will render `3`; no CSS rule needs to change.

### Take the predecessor of `THREE`

Wrap that three-successor chain in `lc-pred`. The direct-child rule will
suppress the first successor, leaving two increments and a rendered result of
`2`.

These experiments reveal the central pattern: the HTML changes the expression,
while the same small set of CSS rules continues to evaluate it.

## 17. The complete idea in one sentence

This implementation turns Church booleans into nested first-or-second-child
choices and Church numerals into nested counter increments, then lets the
browser's native CSS engine make those choices and count those increments while
rendering the HTML tree.
