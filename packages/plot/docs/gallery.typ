// plot gallery — bar & line plots for ML/DL teaching. Every example shows its
// CODE and the live output (the demo is eval'd from the same source, so the
// picture can't drift from the code). Compile: typst compile docs/gallery.typ
#import "@local/plot:0.1.0" as plot

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

// ── code + live demo, side by side ──────────────────────────────────────────
#let PRELUDE = "#import \"@local/plot:0.1.0\" as plot"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= plot

Native Typst *bar & line plots* for ML/DL teaching, drawn on CeTZ and themed
through semantic colors. Numbers are computed *in Typst* — a softmax bar chart
derives its own probabilities and a curve is sampled from a formula, so the
picture can never disagree with the maths on the slide.
`#import "@local/plot:0.1.0" as plot`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*key arguments*]),
  [`plot.bars(values)`], [`labels:, horizontal:, softmax:, temperature:, highlight:, baseline:, color:, size:, title:`],
  [`plot.lines(...)`], [data via `fn:` + `domain:`, or `x:` / `y:` arrays, or positional `(x,y)` series],
  [], [`labels:, legend:, dashes:, markers:, colors:, log-y:`],
  [], [`fill-under:, points:, vlines:, hlines:, annotations:`],
  [], [`x-label:, y-label:, title:, size:`],
)
Bars accept plain numbers, `(label, value)` pairs, or `(label:, value:, color:)`
dicts. Lines take one series or several; `legend:` is `"tr"/"tl"/"br"/"bl"`.

== bars — a distribution straight from values
#demo(```
#plot.bars(
  (12.0, 30.0, 18.0, 9.0),
  labels: ("cat", "dog", "cow", "owl"),
  title: [counts], size: (70mm, 40mm),
)
```.text)

== bars — logits → probabilities via `softmax: true`
The bars derive their own probabilities; a low `temperature:` sharpens the peak.
#demo(```
#plot.bars(
  (3.0, 1.0, 0.2, -0.5),
  labels: ("the", "cat", "sat", "on"),
  softmax: true, temperature: 0.5,
  title: [softmax(z), T=0.5], size: (70mm, 40mm),
)
```.text)

== bars — `highlight:` an index (the others dim automatically)
#demo(```
#plot.bars(
  (147.0, 41.0, 17.5),
  labels: ("3×3", "sep", "1×1→3×3"),
  horizontal: true, highlight: 2,
  title: [FLOPs (M)], size: (70mm, 40mm),
)
```.text)

== bars — signed values about `baseline: 0`
Negatives take the *negative* role colour, so a gradient $p - y$ reads at a glance.
#demo(```
#plot.bars(
  (0.1, -0.6, 0.3, 0.2),
  labels: ($p_1$, $p_2$, $p_3$, $p_4$),
  baseline: 0, title: [gradient $p - y$],
  size: (70mm, 40mm),
)
```.text)

== lines — a formula is a one-liner (`fn:` + `domain:`)
The curve IS the maths: pass a function, not hand-typed points.
#demo(```
#plot.lines(
  fn: z => 1 / (1 + calc.exp(-z)),
  domain: (-6, 6), markers: false,
  x-label: [z], y-label: [$sigma(z)$],
  title: [logistic], size: (70mm, 40mm),
)
```.text)

== lines — several series with a `legend:` box and `dashes:`
#demo(```
#plot.lines(
  (((1, 2.3), (2, 1.1), (3, 0.7), (4, 0.5), (5, 0.42)),
   ((1, 2.3), (2, 1.6), (3, 1.2), (4, 1.0), (5, 0.9))),
  labels: ("Adam", "SGD"),
  dashes: ("solid", "dashed"), legend: "tr",
  x-label: [epoch], y-label: [loss],
  title: [optimizer race], size: (70mm, 40mm),
)
```.text)

== lines — shade an interval: the $P(a <= Y <= b)$ area
`fill-under: (from:, to:, color:)` shades only the slice with $a <= x <= b$.
#demo(```
#let phi(y) = calc.exp(-y * y / 2) / calc.sqrt(2 * calc.pi)
#plot.lines(
  fn: phi, domain: (-4, 4), markers: false,
  fill-under: (from: -1, to: 1,
    color: rgb("#E8590C").transparentize(55%)),
  vlines: ((-1, [−1]), (1, [+1])),
  x-label: [y], y-label: [p(y)],
  title: [P(−1 ≤ Y ≤ 1)], size: (70mm, 40mm),
)
```.text)

== lines — read-off `points:` with droplines to both axes
#demo(```
#plot.lines(
  range(1, 100).map(k => { let p = k / 100; (p, -calc.ln(p)) }),
  markers: false,
  points: (
    (0.9, -calc.ln(0.9), [0.9 → 0.11]),
    (0.1, -calc.ln(0.1), [0.1 → 2.30]),
    (0.02, -calc.ln(0.02), [0.02 → 3.9]),
  ),
  x-label: [$p_y$], y-label: [$-log p_y$],
  title: [confident mistakes cost more], size: (72mm, 42mm),
)
```.text)

== lines — `vlines:` / `hlines:` reference lines
#demo(```
#plot.lines(
  fn: x => 1 / (1 + calc.exp(-2 * (x - 3))),
  domain: (0, 6), markers: false,
  hlines: ((0.5, [threshold], rgb("#D64550")),),
  vlines: ((3, [x = 3],),),
  x-label: [x], y-label: [$p$],
  title: [decision boundary], size: (72mm, 42mm),
)
```.text)
