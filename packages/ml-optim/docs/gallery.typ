// ml-optim gallery — optimizers RUN in Typst; the trajectory is the real thing.
// Compile:  typst compile docs/gallery.typ
#import "@local/ml-optim:0.1.0" as opt
#import "@local/ml-field:0.1.0" as fld

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= ml-optim

Gradient-based optimizers that return the full descent trajectory (a list of
parameter vectors), computed in Typst — so a loss-landscape figure and the
optimizer on the slide can never disagree. Feed a path to `ml-field.contour(paths:)`.

== the same ill-conditioned bowl, five optimizers — each path is the real iteration
#let g(p) = (2.0 * p.at(0), 24.0 * p.at(1))   // ∇ of L = x² + 12y²
#let x0 = (-3.4, 1.5)
#let runs = (
  ([GD], opt.gd(g, x0, lr: 0.04, steps: 40)),
  ([momentum], opt.momentum(g, x0, lr: 0.018, steps: 40)),
  ([Nesterov], opt.nesterov(g, x0, lr: 0.018, steps: 40)),
  ([RMSProp], opt.rmsprop(g, x0, lr: 0.20, steps: 40)),
  ([Adam], opt.adam(g, x0, lr: 0.30, steps: 40)),
)
#grid(columns: 5, gutter: 5mm,
  ..runs.map(r => fld.contour((x, y) => x * x + 12.0 * y * y, xlim: (-4, 4), ylim: (-2, 2),
    samples: 44, levels: 8, size: (30mm, 15mm),
    paths: (r.at(1),), marks: ((0, 0, [·]),), title: r.at(0))))

== SGD — seeded gradient noise makes a stochastic path (reproducible)
#fld.contour((x, y) => x * x + 3.0 * y * y, xlim: (-3, 3), ylim: (-2, 2),
  samples: 48, size: (70mm, 46mm), x-label: [$theta_1$], y-label: [$theta_2$],
  paths: (opt.sgd(p => (2.0 * p.at(0), 6.0 * p.at(1)), (-2.6, 1.6),
    lr: 0.08, noise: 2.5, seed: 3, steps: 40),))

== optimize a function without deriving its gradient (finite differences)
#let f(p) = calc.pow(p.at(0) - 1.0, 2) + calc.pow(p.at(1) + 0.5, 2)   // min at (1, -0.5)
#let path = opt.adam(opt.numgrad(f), (-2.0, 2.0), lr: 0.2, steps: 60)
Reached #path.last().map(c => calc.round(c, digits: 2)) — the true minimum is $(1, -0.5)$.
