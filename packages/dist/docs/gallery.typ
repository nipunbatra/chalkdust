// dist gallery — exact densities and the losses they imply.
// Every example shows the CODE and its live output (the demo is eval'd from the
// same source, so it can't drift). Compile:  typst compile docs/gallery.typ
#import "@local/dist:0.1.0" as dist
#import "@local/plot:0.1.0" as plot

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

// ── code + live demo, side by side ──────────────────────────────────────────
#let PRELUDE = "#import \"@local/dist:0.1.0\" as dist\n#import \"@local/plot:0.1.0\" as plot"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= dist

Exact `pdf` / `logpdf` / `nll` for standard distributions — so a loss curve is the
*true* negative log-likelihood of a parameterised distribution, not a coefficient
tuned to look right. `#import "@local/dist:0.1.0" as dist`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*constructor*], [*parameters (defaults)*]),
  [`dist.normal`], [`mu: 0, sigma: 1`],
  [`dist.laplace`], [`mu: 0, b: 1`],
  [`dist.student-t`], [`nu: 3, mu: 0, sigma: 1`],
  [`dist.uniform`], [`a: 0, b: 1`],
  [`dist.exponential`], [`rate: 1`],
  [`dist.bernoulli`], [`p: 0.5`],
  [`dist.categorical`], [`probs: (0.5, 0.5)`],
  [`dist.gaussian-2d`], [`mu: (0,0), sigma: ((1,0),(0,1))` — a bivariate density $f(x,y)$],
)
Accessors work on any of them: `pdf(d, x)`, `logpdf(d, x)`, `nll(d, x)`,
`nll0(d, x)` (nll shifted so its min is 0). Plus `sigmoid`, `softmax`.

== Continuous densities
#demo(```
#plot.lines(
  fn: (
    x => dist.pdf(dist.normal(), x),
    x => dist.pdf(dist.laplace(b: 0.8), x),
    x => dist.pdf(dist.student-t(nu: 2), x),
  ),
  domain: (-4, 4), markers: false, legend: "tr",
  labels: ("Normal", "Laplace", "Student-t"),
  x-label: [x], y-label: [p(x)], size: (74mm, 44mm),
)
```.text)

== Uniform and Exponential — support matters
#demo(```
#plot.lines(
  fn: (
    x => dist.pdf(dist.uniform(a: -1, b: 1), x),
    x => dist.pdf(dist.exponential(rate: 1), x),
  ),
  domain: (-2, 3), markers: false, legend: "tr",
  labels: ("Uniform(-1,1)", "Exp(1)"),
  x-label: [x], y-label: [p(x)], size: (74mm, 40mm),
)
```.text)

== The loss each density implies — `nll0` ($-log p$, min at 0)
Gaussian → squared error, Laplace → absolute error, Student-t → a robust,
tail-flattening loss. Same maths, one function each.
#demo(```
#plot.lines(
  fn: (
    r => dist.nll0(dist.normal(), r),
    r => dist.nll0(dist.laplace(b: 1), r),
    r => dist.nll0(dist.student-t(nu: 2), r),
  ),
  domain: (-3, 3), markers: false, legend: "tl",
  labels: ("squared", "absolute", "robust"),
  x-label: [residual r], y-label: [$-log p$], size: (74mm, 44mm),
)
```.text)

== Discrete: Categorical pmf
#demo(```
#let cat = dist.categorical(probs: (0.5, 0.3, 0.15, 0.05))
#plot.bars(
  (0, 1, 2, 3).map(k => dist.pdf(cat, k)),   // pdf() also reads a pmf
  labels: ("a", "b", "c", "d"),
  title: [Categorical pmf], size: (62mm, 36mm),
)
```.text)

== A bivariate Gaussian, straight into a contour
`gaussian-2d` returns a plain $f(x,y)$ (it inverts $Sigma$ for you), ready for
`field.contour`:
#demo(ratio: (1.3fr, 1fr), ```
#import "@local/field:0.1.0" as field
#field.contour(
  dist.gaussian-2d(sigma: ((1.4, 0.8), (0.8, 1.0))),
  xlim: (-3, 3), ylim: (-3, 3), samples: 46,
  color: rgb("#eb811b"), size: (44mm, 44mm),
)
```.text)

== Transforms: `sigmoid` and `softmax`
#demo(ratio: (1.2fr, 1fr), ```
#plot.lines(fn: x => dist.sigmoid(x), domain: (-6, 6),
  markers: false, x-label: [z], y-label: [$sigma(z)$], size: (56mm, 34mm))
```.text)
#demo(ratio: (1.2fr, 1fr), ```
// temperature sharpens (small) or flattens (large) the distribution
#plot.bars(dist.softmax((1.0, 2.0, 3.0), temperature: 0.5),
  labels: ("a", "b", "c"), title: [softmax, T=0.5], size: (52mm, 32mm))
```.text)

== Accessors return exact numbers
#demo(ratio: (1.3fr, 1fr), ```
#let g = dist.normal(mu: 0, sigma: 1)
#table(columns: 2, inset: 6pt, stroke: 0.5pt + gray,
  [`pdf(g,0)`],  [#calc.round(dist.pdf(g, 0.0), digits: 4)],
  [`logpdf(g,0)`], [#calc.round(dist.logpdf(g, 0.0), digits: 4)],
  [`nll(bern.8,1)`], [#calc.round(dist.nll(dist.bernoulli(p: 0.8), 1), digits: 4)],
)
```.text)
