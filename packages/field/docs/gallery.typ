// field gallery — 2-D and 3-D fields of a function f(x, y): contours, heatmaps,
// and surfaces. Every example shows its CODE and the live rendered output (the
// demo is eval'd from the same source, so it can't drift). Descent paths come
// from the sibling `optim` package. Compile: typst compile docs/gallery.typ
#import "@local/field:0.1.0" as field
#import "@local/optim:0.1.0" as opt   // descent trajectories to overlay

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

// ── code + live demo, side by side ──────────────────────────────────────────
#let PRELUDE = "#import \"@local/field:0.1.0\" as field\n#import \"@local/optim:0.1.0\" as opt"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= field

Heatmaps, iso-contours, and 3-D surfaces of a function `f(x, y)` — everything is
*sampled from the function*, so a loss landscape or a posterior contour is the
real field, not a drawing. A descent path (computed by `optim`) overlays on the
*same coordinates* the contour is drawn in, so figure and optimizer can never
disagree. `#import "@local/field:0.1.0" as field`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*function*], [*draws*]),
  [`field.contour(fn, …)`],
    [iso-contours of $f(x,y)$ via marching squares. `fn` may be *one* function or
     an *array* of functions (overlaid families, e.g. likelihood / prior /
     posterior). Overlay descent `paths:` and `marks:`.],
  [`field.heatmap(fn, …)`], [a colored value grid of $f(x,y)$.],
  [`field.surface(fn, …)`], [an oblique, height-shaded 3-D surface of $f(x,y)$.],
)
Shared args: `xlim:, ylim:, samples:, size:, title:`. `contour` adds
`levels:, color:, colors:, fill:, paths:, marks:, x-label:, y-label:`. A `mark`
is `(x, y[, label[, color]])`; a `path` is a list of `(x, y)` points — feed it
one straight from `opt.gd / momentum / adam / …`.

== contour — a loss bowl with a marked minimum
#demo(ratio: (1.15fr, 1fr), ```
#field.contour(
  (x, y) => x*x + 3*y*y,
  xlim: (-3, 3), ylim: (-3, 3), samples: 50,
  marks: ((0, 0, [min]),),
  size: (44mm, 44mm),
  x-label: [$theta_1$], y-label: [$theta_2$],
)
```.text)

== contour — a *computed* gradient-descent path
The gradient is built from the same loss by finite differences (`opt.grad2d`),
and `opt.gd` runs the real iteration — no hand-typed points.
#demo(ratio: (1.1fr, 1fr), ```
#let f(x, y) = x*x + 8*y*y
#field.contour(f,
  xlim: (-4, 4), ylim: (-2, 2), samples: 48,
  size: (60mm, 40mm),
  paths: (opt.gd(opt.grad2d(f), (-3.4, 1.6),
                 lr: 0.05, steps: 40),),
  marks: ((0, 0, [min]),),
)
```.text)

== contour — GD vs momentum on a ravine (both paths run in Typst)
#demo(ratio: (0.8fr, 1.2fr), ```
#let f(x, y) = x*x + 100*y*y
#let g = opt.grad2d(f)
#grid(columns: 2, gutter: 6mm,
  field.contour(f, xlim: (-2.6, 2.6), ylim: (-0.55, 0.55),
    samples: 60, levels: 10, size: (52mm, 22mm),
    paths: (opt.gd(g, (-2.3, 0.45), lr: 0.009, steps: 34),),
    marks: ((0, 0, [·]),), title: [plain GD]),
  field.contour(f, xlim: (-2.6, 2.6), ylim: (-0.55, 0.55),
    samples: 60, levels: 10, size: (52mm, 22mm),
    paths: (opt.momentum(g, (-2.3, 0.45), lr: 0.0035, steps: 34),),
    marks: ((0, 0, [·]),), title: [with momentum]),
)
```.text)

== contour — several families at once (Bayesian MAP = likelihood × prior)
Pass an *array* of functions; give each its own colour with `colors:`, and
colour the `marks:` to match. Here the posterior peak (MAP) sits between the
likelihood peak (MLE) and the prior mean at the origin.
#demo(ratio: (0.95fr, 1fr), ```
#let lik(x, y)   = calc.exp(-((x - 2)*(x - 2)
                     + (y - 1.5)*(y - 1.5)) / (2*0.8*0.8))
#let prior(x, y) = calc.exp(-(x*x + y*y) / (2*1.2*1.2))
#let post(x, y)  = lik(x, y) * prior(x, y)
#field.contour((lik, prior, post),
  xlim: (-2.5, 4), ylim: (-2, 3.5), samples: 64, levels: 4,
  colors: (orange, blue, olive),
  marks: (
    (2, 1.5, [MLE], orange),
    (0, 0, [prior], blue),
    (1.39, 1.04, [MAP], olive),
  ),
  size: (60mm, 52mm),
  x-label: [$theta_1$], y-label: [$theta_2$])
```.text)

== contour — filled bands from a single field
#demo(ratio: (1.15fr, 1fr), ```
#field.contour(
  (x, y) => calc.exp(-(x*x + y*y) / 2),
  xlim: (-3, 3), ylim: (-3, 3), samples: 52,
  levels: 6, fill: true, size: (44mm, 44mm),
)
```.text)

== heatmap — a 2-D Gaussian density as a value grid
#demo(ratio: (1.25fr, 1fr), ```
#field.heatmap(
  (x, y) => calc.exp(-(x*x + y*y) / 2),
  xlim: (-3, 3), ylim: (-3, 3),
  samples: 52, cell: 1.4mm,
)
```.text)

== surface — a saddle, drawn back-to-front and shaded by height
#demo(ratio: (1.1fr, 1fr), ```
#field.surface(
  (x, y) => x*x - y*y,
  xlim: (-2, 2), ylim: (-2, 2),
  samples: 24, title: [$x^2 - y^2$],
)
```.text)
