# chalkdust

A family of Typst packages for ML/DL teaching figures — native, vector,
palette-themed, and computed in Typst so figures cannot disagree with the math
on the slide. Gallery: <https://nipunbatra.github.io/chalkdust/>. Scope and
roadmap: [SCOPE.md](SCOPE.md).

A small **scientific-computing stack for Typst**, split into focused packages:
numerics (random, optimize, distributions, data-frame), visualization
(tensor-grid, plots, fields), and shared tokens.

| Package | Status | What it does |
|---|---|---|
| [`ml-random`](packages/ml-random) | v0.1.0 | seeded, pure PRNG — uniform / normal / integer / Bernoulli draws, random vectors, sampling, Fisher–Yates shuffle |
| [`ml-optim`](packages/ml-optim) | v0.1.0 | numerical optimization — GD, momentum, Nesterov, RMSProp, Adam, SGD (returns the full trajectory, N-dimensional) + finite-difference gradient |
| [`ml-dist`](packages/ml-dist) | v0.1.0 | probability distributions with exact pdf / log-pdf / nll — Normal, Laplace, Student-t, Uniform, Exponential, Bernoulli, Categorical |
| [`ml-data`](packages/ml-data) | v0.1.0 | a tiny data-frame — load csv/json/arrays, select / filter / mutate / group, bridge columns to plots |
| [`tensor-grid`](packages/tensor-grid) | v0.1.0 | conv arithmetic, annotated grids, pooling, receptive fields, patchify (with masking), attention heatmaps (masks, boxed cells) |
| [`ml-plot`](packages/ml-plot) | v0.1.0 | general bar & line plots — distributions (softmax), attention weights, signed gradients, loss / receptive-field curves |
| [`ml-field`](packages/ml-field) | v0.1.0 | 2-D & 3-D fields of f(x,y) — heatmaps, iso-contours (with overlaid descent paths), surfaces |
| [`ml-theme`](packages/ml-theme) | v0.1.0 | shared design tokens: semantic colors, ramps, stroke weights |
| `ml-linalg` | planned | vectors & matrices — matmul, solve, inverse, norms, eig/SVD for small teaching problems |
| `ml-tensor` | planned | numpy/torch-lite — n-d arrays, elementwise ops, reshape, reductions, broadcasting |
| `ml-learn` | planned | basic ML algorithms — linear/logistic regression, k-means, kNN, PCA (fit in Typst, plot the result) |

## Development setup

Packages are consumed through Typst's `@local` namespace via symlinks:

```sh
just install       # symlink packages into ~/Library/Application Support/typst/packages/local
just gallery       # compile every package gallery
```

Consumers import `@local/<name>:<version>`. At Universe publish time the
cross-package imports switch `@local` → `@preview` (see `justfile`).

## Consuming from a deck (e.g. dl-teaching)

Bind the theme once in an adapter file, then every slide is a one-liner:

```typst
#import "@local/ml-theme:0.1.0": theme
#import "@local/tensor-grid:0.1.0" as tg
#let dl-theme = theme(ink: rgb("#23373B"), accent: rgb("#EB811B"), ...)
#let conv-op = tg.conv-op.with(theme: dl-theme)
```

See `dl-teaching/common/mldiag.typ` for the live adapter and
`dl-teaching/tensor-grid-demo.typ` for a full demo deck (animated convolution,
pooling, causal masks, attention heatmaps, receptive fields, patchify).
