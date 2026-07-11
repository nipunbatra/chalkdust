# chalkdust

A family of Typst packages for ML/DL teaching figures — native, vector,
palette-themed, and computed in Typst so figures cannot disagree with the math
on the slide. Gallery: <https://nipunbatra.github.io/chalkdust/>. Scope and
roadmap: [SCOPE.md](SCOPE.md).

A small **scientific-computing stack for Typst**, split into focused packages:
numerics (random, optimize, distributions, data-frame), visualization
(convgrid, plots, fields), and shared tokens.

| Package | Status | What it does |
|---|---|---|
| [`bits`](packages/bits) | v0.1.0 | 32-bit bitwise ops (shift/rotate/and/or/xor, mul-high) from integer arithmetic — the base for RNGs, hashes, checksums |
| [`rand`](packages/rand) | v0.1.0 | seeded, pure PRNG — uniform / normal / integer / Bernoulli draws, random vectors, sampling, Fisher–Yates shuffle |
| [`autodiff`](packages/autodiff) | v0.1.0 | reverse-mode automatic differentiation (micrograd in miniature) — build a scalar expression, get the exact gradient in one backward pass |
| [`optim`](packages/optim) | v0.1.0 | numerical optimization — GD, momentum, Nesterov, RMSProp, Adam, SGD (returns the full trajectory, N-dimensional) + finite-difference / autodiff gradients |
| [`linalg`](packages/linalg) | v0.1.0 | small dense linear algebra — transpose, matmul, solve / inverse / determinant, Jacobi symmetric eigendecomposition (fit a regression, run PCA) |
| [`dist`](packages/dist) | v0.1.0 | probability distributions with exact pdf / log-pdf / nll — Normal, Laplace, Student-t, Uniform, Exponential, Bernoulli, Categorical |
| [`frame`](packages/frame) | v0.1.0 | a tiny data-frame — load csv/json/arrays, select / filter / mutate / group, bridge columns to plots |
| [`convgrid`](packages/convgrid) | v0.1.0 | conv arithmetic, annotated grids, pooling, receptive fields, patchify (with masking), attention heatmaps (masks, boxed cells) |
| [`plot`](packages/plot) | v0.1.0 | general bar & line plots — distributions (softmax), attention weights, signed gradients, loss / receptive-field curves |
| [`field`](packages/field) | v0.1.0 | 2-D & 3-D fields of f(x,y) — heatmaps, iso-contours (with overlaid descent paths), surfaces |
| [`theme`](packages/theme) | v0.1.0 | shared design tokens: semantic colors, ramps, stroke weights |
| `tensor` | planned | numpy/torch-lite — n-d arrays, elementwise ops, reshape, reductions, broadcasting |
| `learn` | planned | basic ML algorithms — linear/logistic regression, k-means, kNN, PCA (fit in Typst, plot the result) |

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
#import "@local/theme:0.1.0": theme
#import "@local/convgrid:0.1.0" as tg
#let dl-theme = theme(ink: rgb("#23373B"), accent: rgb("#EB811B"), ...)
#let conv-op = tg.conv-op.with(theme: dl-theme)
```

See `dl-teaching/common/mldiag.typ` for the live adapter and
`dl-teaching/convgrid-demo.typ` for a full demo deck (animated convolution,
pooling, causal masks, attention heatmaps, receptive fields, patchify).
