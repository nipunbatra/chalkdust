// autodiff gallery — exact gradients, and a descent driven by them.
// Compile:  typst compile docs/gallery.typ
#import "@local/autodiff:0.1.0" as ad
#import "@local/optim:0.1.0" as opt
#import "@local/field:0.1.0" as fld

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= autodiff

Reverse-mode automatic differentiation — micrograd in miniature. Build a scalar
expression from differentiable primitives; one backward pass gives the *exact*
gradient (no finite differences). Purely functional, so it drops into `optim`.

== the loss is a readable STRING, written ONCE — parsed to the graph, exact gradient
// Typst has no operator overloading, so `expr` parses the formula into the graph:
// you write it once, it draws the surface AND drives the descent (exact ∇).
#let rosen = ad.expr("(1 - x)^2 + 100*(y - x^2)^2", ("x", "y"))   // Rosenbrock
#fld.contour(ad.fn2(rosen), xlim: (-2, 2), ylim: (-1, 3), samples: 60, levels: 14,
  size: (78mm, 58mm), x-label: [$x$], y-label: [$y$], marks: ((1, 1, [min]),),
  paths: (opt.adam(ad.grad-fn(rosen), (-1.5, 2.5), lr: 0.04, steps: 2000),))

== exact gradients (matched against the analytic derivative)
#let f(v) = ad.add(ad.sin(ad.mul(v.at(0), v.at(1))), ad.exp(v.at(0)))   // sin(xy) + eˣ
At $(0.5, 2)$: value $= #calc.round(ad.value(f, (0.5, 2.0)), digits: 4)$,
$nabla f = #ad.grad(f, (0.5, 2.0)).map(g => calc.round(g, digits: 4))$
(analytic $(y cos x y + e^x, x cos x y) = (2.7290, 0.2702)$).

== the whole computation graph, drawn — every value and adjoint auto-derived
// (w*x + b - y)² at w=2, x=3, b=1, y=10 — the classic scalar backprop example
#ad.graph(ad.expr("(w*x + b - y)^2", ("w", "x", "b", "y")), (2, 3, 1, 10),
  names: ("w", "x", "b", "y"))
Each node shows its forward `= value` and backward `∂ adjoint`; nothing is typed by
hand — it is exactly what the reverse pass computed.

== activation derivatives fall out for free
#table(columns: 4, stroke: 0.4pt + gray, inset: 6pt,
  [$sigma'(0)$], [$#ad.grad(v => ad.sigmoid(v.at(0)), (0.0,)).at(0)$],
  [$tanh'(0)$], [$#ad.grad(v => ad.tanh(v.at(0)), (0.0,)).at(0)$],
)
