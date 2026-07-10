# typst-ml-diagrams

A family of Typst packages for ML/DL teaching figures — native, vector,
palette-themed, and computed in Typst so figures cannot disagree with the math
on the slide. Scope and roadmap: [SCOPE.md](SCOPE.md).

| Package | Status | What it does |
|---|---|---|
| [`ml-theme`](packages/ml-theme) | v0.1.0 | shared design tokens: semantic colors, ramps, stroke weights |
| [`tensor-grid`](packages/tensor-grid) | v0.1.0 | conv arithmetic, annotated grids, pooling, receptive fields, patchify, attention heatmaps |
| `ml-plot` | planned (M2) | activation curves, loss contours + descent paths, schedules — on lilaq |
| `nn-arch` | planned (M3) | MLP/RNN/transformer semantic blocks — on fletcher |
| `plate-note` | planned (M4) | PGM plate notation à la tikz-bayesnet |

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
