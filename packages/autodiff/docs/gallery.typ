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

== the loss is written ONCE — autodiff draws the surface and drives the descent
#let rosen(v) = ad.add(                                    // Rosenbrock: (1-x)² + 100(y-x²)²
  ad.sq(ad.sub(1, v.at(0))),
  ad.mul(100, ad.sq(ad.sub(v.at(1), ad.sq(v.at(0))))))
#fld.contour(ad.fn2(rosen), xlim: (-2, 2), ylim: (-1, 3), samples: 60, levels: 14,
  size: (78mm, 58mm), x-label: [$x$], y-label: [$y$], marks: ((1, 1, [min]),),
  paths: (opt.adam(ad.grad-fn(rosen), (-1.5, 2.5), lr: 0.04, steps: 2000),))

== exact gradients (matched against the analytic derivative)
#let f(v) = ad.add(ad.sin(ad.mul(v.at(0), v.at(1))), ad.exp(v.at(0)))   // sin(xy) + eˣ
At $(0.5, 2)$: value $= #calc.round(ad.value(f, (0.5, 2.0)), digits: 4)$,
$nabla f = #ad.grad(f, (0.5, 2.0)).map(g => calc.round(g, digits: 4))$
(analytic $(y cos x y + e^x, x cos x y) = (2.7290, 0.2702)$).

== activation derivatives fall out for free
#table(columns: 4, stroke: 0.4pt + gray, inset: 6pt,
  [$sigma'(0)$], [$#ad.grad(v => ad.sigmoid(v.at(0)), (0.0,)).at(0)$],
  [$tanh'(0)$], [$#ad.grad(v => ad.tanh(v.at(0)), (0.0,)).at(0)$],
)
