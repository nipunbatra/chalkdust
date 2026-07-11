# optim

Small **numerical optimization** in Typst — part of [chalkdust](https://github.com/nipunbatra/chalkdust).

Gradient-based optimizers that run in Typst and return the full descent **trajectory**
(a list of N-dimensional parameter vectors), so a loss-landscape figure and the optimizer
can never disagree. Gradients come from `numgrad` / `grad2d` (finite differences) or exact
`autodiff`.

```typ
#import "@local/optim:0.1.0" as opt
#let g = opt.grad2d((x, y) => x*x + 100*y*y)          // ∇ of a 2-D loss, no hand-derivation
#opt.gd(g, (-2.3, 0.45), lr: 0.009, steps: 34)         // → the trajectory
#opt.momentum(g, (-2.3, 0.45), lr: 0.0035, steps: 34)
#opt.adam(g, (-2.4, 0.85), lr: 0.16, steps: 60)
#opt.sgd(g, (-2.2, 2.0), lr: 0.1, noise: 2.0, seed: 3) // seeded stochastic descent
```

Optimizers: `gd momentum nesterov rmsprop adam sgd` (and the unified `minimize`).
Depends on `rand` for seeded SGD noise.
