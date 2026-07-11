// optim gallery — optimizers RUN in Typst; the trajectory is the real thing.
// Every example shows its CODE and the live output. Compile: typst compile docs/gallery.typ
#import "@local/optim:0.1.0" as opt
#import "@local/field:0.1.0" as field

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/optim:0.1.0\" as opt\n#import \"@local/field:0.1.0\" as field"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= optim

Small **numerical optimization**: `gd / momentum / nesterov / rmsprop / adam / sgd`
run in Typst and return the full descent **trajectory** (a list of N-dimensional
parameter vectors), so a loss-landscape figure and the optimizer can never
disagree. `#import "@local/optim:0.1.0" as opt`

== What's available
Every optimizer has the signature `opt.NAME(grad, x0, lr:, steps:, …)` and returns
the list `(x0, x1, …, x_steps)`. Feed the path to `field.contour(paths:)`.
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*optimizer*], [*update / extra args*]),
  [`opt.gd`], [$x <- x - eta gradient$],
  [`opt.momentum`], [velocity $v <- beta v + gradient$ (`beta: 0.9`)],
  [`opt.nesterov`], [momentum with a look-ahead gradient],
  [`opt.rmsprop`], [per-coordinate scaling by recent gradient size (`beta: 0.9`)],
  [`opt.adam`], [momentum + RMSProp with bias correction (`b1:, b2:, eps:`)],
  [`opt.sgd`], [`gd` with seeded Gaussian gradient `noise:` (`seed:`)],
)
Gradients: `opt.numgrad(f)` (f of a vector) or `opt.grad2d(f)` (f of `x, y`) —
finite differences, no hand-derivation. Vector ops: `add sub scale dot norm`.

== The same bowl, six optimizers — each path is the real iteration
#demo(ratio: (0.85fr, 1.15fr), ```
#let g = opt.grad2d((x, y) => x*x + 12*y*y)   // one loss, no hand-derived ∇
#let x0 = (-3.4, 1.5)
#let runs = (
  ([GD],       opt.gd(g, x0, lr: 0.04, steps: 40)),
  ([momentum], opt.momentum(g, x0, lr: 0.018, steps: 40)),
  ([Nesterov], opt.nesterov(g, x0, lr: 0.018, steps: 40)),
  ([RMSProp],  opt.rmsprop(g, x0, lr: 0.20, steps: 40)),
  ([Adam],     opt.adam(g, x0, lr: 0.30, steps: 40)),
)
#grid(columns: 3, gutter: 5mm, ..runs.map(r =>
  field.contour((x, y) => x*x + 12*y*y, xlim: (-4, 4), ylim: (-2, 2),
    samples: 40, size: (34mm, 17mm), paths: (r.at(1),),
    marks: ((0, 0, [·]),), title: r.at(0))))
```.text)

== SGD — seeded gradient noise gives a reproducible stochastic path
#demo(ratio: (1fr, 1fr), ```
#let g = opt.grad2d((x, y) => x*x + 3*y*y)
#field.contour((x, y) => x*x + 3*y*y, xlim: (-3, 3), ylim: (-2, 2),
  samples: 44, size: (66mm, 44mm),
  paths: (opt.sgd(g, (-2.6, 1.6), lr: 0.08, noise: 2.5, seed: 3, steps: 40),))
```.text)

== Optimize a function without deriving its gradient
#demo(ratio: (1.2fr, 1fr), ```
// grad2d builds ∇ by finite differences; adam finds the minimum
#let f(x, y) = calc.pow(x - 1, 2) + calc.pow(y + 0.5, 2)
#let path = opt.adam(opt.grad2d(f), (-2, 2), lr: 0.2, steps: 80)
#[reached #path.last().map(c => calc.round(c, digits: 2)) — true min (1, -0.5)]
```.text)

== Exact gradients via autodiff (write the loss as a string)
#demo(ratio: (1.2fr, 1fr), ```
#import "@local/autodiff:0.1.0" as ad
#let loss = ad.expr("(x - 3)^2 + 2*(y + 1)^2", ("x", "y"))
#let path = opt.adam(ad.grad-fn(loss), (0, 0), lr: 0.2, steps: 60)
#[reached #path.last().map(c => calc.round(c, digits: 2)) — true min (3, -1)]
```.text)

== N-dimensional too
#demo(ratio: (1.3fr, 1fr), ```
// a 4-D quadratic bowl, gradient 2x, descends to the origin
#let path = opt.gd(v => v.map(c => 2 * c), (1.0, -2.0, 3.0, -1.5), lr: 0.2, steps: 40)
#[final #path.last().map(c => calc.round(c, digits: 3))]
```.text)
