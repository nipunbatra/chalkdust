# autodiff

**Reverse-mode automatic differentiation** in Typst — micrograd in miniature.
Part of [chalkdust](https://github.com/nipunbatra/chalkdust).

Typst has no operator overloading, so build a scalar expression from differentiable
primitives (or parse a formula string with `expr`); each node records the local
derivative w.r.t. its parents, and one reverse pass gives the **exact** gradient — no
finite differences, purely functional (no mutable graph). It also draws the graph.

```typ
#import "@local/autodiff:0.1.0" as ad
#let f = ad.expr("(w*x + b - y)^2", ("w", "x", "b", "y"))
#ad.value(f, (2, 3, 1, 10))     // 9
#ad.grad(f,  (2, 3, 1, 10))     // (-18, -12, -6, 6) exactly
#ad.graph(f, (2, 3, 1, 10), names: ("w","x","b","y"))   // draw the computation graph
```

`grad-fn(f)` and `fn2(f)` adapt it to `optim` (drive a descent) and `field.contour`
(draw the surface) from one definition. Primitives: `add sub mul div neg powc sq sqrt
exp ln sin cos tanh sigmoid relu`, plus `sum` / `dot` for linear models.
