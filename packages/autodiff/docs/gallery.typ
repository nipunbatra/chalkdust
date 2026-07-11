// autodiff gallery — exact gradients + the computation graph, drawn.
// Every example shows its CODE and the live output. Compile: typst compile docs/gallery.typ
#import "@local/autodiff:0.1.0" as ad
#import "@local/optim:0.1.0" as opt
#import "@local/field:0.1.0" as field

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/autodiff:0.1.0\" as ad\n#import \"@local/optim:0.1.0\" as opt\n#import \"@local/field:0.1.0\" as field"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= autodiff

*Reverse-mode automatic differentiation* — micrograd in miniature. Build a scalar
expression (or parse a formula string); one backward pass gives the *exact*
gradient — no finite differences. Purely functional, so it drops into `optim` and
can draw its own graph. `#import "@local/autodiff:0.1.0" as ad`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*does*]),
  [`ad.expr(s, names)`], [parse a formula string into a graph function],
  [`ad.value(f, x)`], [the scalar value at point `x`],
  [`ad.grad(f, x)`], [the exact gradient (one reverse pass)],
  [`ad.value-and-grad(f, x)`], [both at once],
  [`ad.grad-fn(f)` / `ad.fn2(f)`], [adapters for `optim` and `field.contour`],
  [`ad.graph(f, x, names:)`], [draw the computation graph],
  [primitives], [`add sub mul div neg powc sq sqrt exp ln sin cos tanh sigmoid relu`, `sum dot`],
)
Typst has no operator overloading, so a loss is built from these primitives — or,
more readably, parsed from a string with `expr`.

== Exact gradient from a formula string
#demo(ratio: (1.25fr, 1fr), ```
#let f = ad.expr("x*x + 100*y*y", ("x", "y"))
#[value #calc.round(ad.value(f, (-2.3, 0.45)), digits: 3),
  grad #ad.grad(f, (-2.3, 0.45)).map(g => calc.round(g, digits: 2))]
// analytic ∇ = (2x, 200y) = (-4.6, 90) — exact
```.text)

== The computation graph, drawn — every value and adjoint auto-derived
Each node shows its forward `= value` and backward `∂ adjoint`; nothing is typed by
hand — it is exactly what the reverse pass computed.
#align(center, block(above: 12pt, ad.graph(
  ad.expr("(w*x + b - y)^2", ("w", "x", "b", "y")), (2, 3, 1, 10),
  names: ("w", "x", "b", "y"), spacing: (22mm, 12mm),
)))
```typ
#ad.graph(ad.expr("(w*x + b - y)^2", ("w", "x", "b", "y")), (2, 3, 1, 10),
  names: ("w", "x", "b", "y"))
```

== A reused variable sums its paths — `x·x → 2x`, not `x`
#demo(ratio: (1.25fr, 1fr), ```
// x appears twice; the reverse pass adds both branches
#[grad of x*x at 3: #ad.grad(v => ad.mul(v.at(0), v.at(0)), (3,))]
#linebreak()
#[grad of x*x*x at 2: #ad.grad(v => ad.mul(ad.mul(v.at(0), v.at(0)), v.at(0)), (2,))]
```.text)

== Drive an exact descent — the loss is written ONCE
#demo(ratio: (0.9fr, 1.1fr), ```
#let rosen = ad.expr("(1 - x)^2 + 100*(y - x^2)^2", ("x", "y"))
#field.contour(ad.fn2(rosen), xlim: (-2, 2), ylim: (-1, 3),
  samples: 60, levels: 14, size: (66mm, 50mm), marks: ((1, 1, [min]),),
  paths: (opt.adam(ad.grad-fn(rosen), (-1.5, 2.5), lr: 0.04, steps: 2000),))
```.text)

== Activation derivatives fall out for free
#demo(ratio: (1.25fr, 1fr), ```
#table(columns: 4, stroke: 0.4pt + gray, inset: 6pt, align: center,
  [$sigma'(0)$],   [#ad.grad(v => ad.sigmoid(v.at(0)), (0,)).at(0)],
  [$tanh'(0)$],    [#ad.grad(v => ad.tanh(v.at(0)), (0,)).at(0)],
  [$"relu"'(-1)$], [#ad.grad(v => ad.relu(v.at(0)), (-1,)).at(0)],
  [$"relu"'(2)$],  [#ad.grad(v => ad.relu(v.at(0)), (2,)).at(0)],
)
```.text)
