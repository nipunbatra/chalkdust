# plot

General **bar & line plots** for Typst — part of [chalkdust](https://github.com/nipunbatra/chalkdust).

Plot from a function + domain, `x` / `y` columns, or explicit points: distributions
(softmax / temperature), attention weights, signed gradients, loss curves. Legends,
reference lines, read-off points, per-series markers/dashes, and area fills (including a
`(from:, to:)` interval to shade the `P(a≤Y≤b)` area under a curve).

```typ
#import "@local/plot:0.1.0": *
#bars((3.0, 1.0, 0.2), labels: ("cat", "dog", "cow"), softmax: true)
#lines(fn: r => 1.0 - 0.5*r*r, domain: (0, 1), fill-under: 0)   // the curve is the maths
```
