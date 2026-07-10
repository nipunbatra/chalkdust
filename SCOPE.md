# typst-ml-diagrams — scope

A family of Typst packages for ML/DL teaching figures, built on CeTZ / fletcher / lilaq,
inspired by the best of the TikZ ecosystem (vdumoulin's conv_arithmetic, tikz-bayesnet,
neuralnetwork, PlotNeuralNet, pgfplots idioms).

First consumers: `dl-teaching` (ES 667), then `ml-teaching`, `pml-teaching`.
Target: Typst Universe (`@preview/...`) quality from day one.

## Decisions (2026-07-10)

1. **Structure** — monorepo, 4 independently publishable packages + a shared theme core.
2. **First target** — `tensor-grid` (conv arithmetic / grids / attention heatmaps).
3. **Audience** — universe-quality v1: theme-neutral defaults, docs + gallery per package,
   semver. Course decks consume via a metropolis theme override.
4. **Python bridge** — v2. All APIs take plain data (dicts/arrays) so a
   `torchinfo → JSON → Typst` exporter can slot in later; v1 ships pure Typst.

## Evidence base

From the `dl-teaching` figure inventory (~180 live figures):

- ~80 fletcher diagrams (native, fine) — architecture/block/flow. Ad-hoc, no shared vocabulary.
- ~100 matplotlib figures forced through the SVG+PNG twin dance because resvg mangles
  matplotlib SVGs (`metropolis.typ:49`). These are the retirement targets.
- `common/dlviz.typ` — good API sketch (activation-plot, loss-contour, gd-path), but
  imported by zero lectures. `ml-plot` supersedes it.
- Repeated ad-hoc Python helpers (`draw_grid`, `cell`, `arrow`, `bare3d`, `sig`) mark
  exactly the primitives the libraries should own.

Ecosystem gaps (verified 2026-07): no Typst package for plate notation/PGMs, none for
conv-arithmetic grids, none for transformer/attention primitives, no opinionated ML
plotting vocabulary. Foundations are ready: cetz 0.5, fletcher 0.5.8, lilaq 0.6
(contour fill, colormesh, quiver, colorbars).

## The family

Working names are descriptive placeholders; universe prefers distinctive names — final
names checked for collisions at publish time (candidates: `tessera`, `axon`, `synapse`,
`deft` — a neuron-themed family).

### 0. `ml-theme` (shared core, tiny)

Design tokens all packages consume; user-facing theme override in one place.

- Semantic color roles, not raw colors: `input`, `weight`, `activation`, `output`,
  `highlight`, `positive`, `negative`, `muted`, `ink`.
- Stroke weights, corner radii, cell sizes, 16:9-friendly figure sizing defaults.
- Fonts inherit from the document (never set a font family).
- `theme(overrides) => dict`, passed explicitly or set via context/state.
- The metropolis palette for the decks is one `theme(...)` call in `common/`.

### 1. `tensor-grid` — conv arithmetic, grids, heatmaps  ← BUILD FIRST

TikZ ancestor: vdumoulin/conv_arithmetic (the standard for teaching convolutions).
Base: raw cetz. Typst's real loops/functions make this *nicer* than TikZ.

Covers (~25 figs): sliding kernels, numeric conv, padding/stride/dilation, pooling,
output-size, receptive fields, pixel grids, patchify/ViT, attention matrices,
causal masks, feature-map stacks, tensor shape flows, segmentation grids, dice overlap.

API sketch (v0.1):

```typst
// primitive: the annotated grid every figure is made of
grid-map(values, cell: 8mm, fmt: auto, fill: none | colormap | fn,
         labels: (rows: none, cols: none), highlight: ((r, c), ...))

// one frame of a convolution at position `step`; composes input/kernel/output
conv-op(input: 5, kernel: 3, stride: 1, padding: 0, dilation: 1,
        step: 4,                       // which window position to show
        values: none | (input: .., kernel: ..),  // numeric mode computes the output
        show: ("input", "kernel", "output"))

pool-op(input: 4, window: 2, kind: "max" | "avg", step: ..)
receptive-field(layers: ((kernel: 3, stride: 1), ...), unit: (r, c))
patchify(image: (8, 8), patch: 4)                    // ViT patch extraction
attn-matrix(tokens, values: none, mask: none | "causal" | fn,
            colormap: auto, annotate: true)          // annotated heatmap
tensor(c, h, w, label: auto)                          // isometric block, cetz ortho
shape-flow((3,224,224), "conv3x3/2", (64,112,112), ...) // shape-transform pipeline
```

Design notes:
- `step` as a first-class parameter → multi-frame sequences fall out for free
  (touying/polylux subslides animate the sliding window — TikZ needs a Makefile+GIF).
- Numeric mode computes the conv output *in Typst* — the figure cannot disagree
  with the math on the slide.
- `grid-map` doubles as the confusion-matrix / mask / one-hot renderer.

### 2. `ml-plot` — the plotting vocabulary (dlviz grown up)

TikZ ancestor: pgfplots idioms. Base: lilaq 0.6.

Covers (~60 figs): activation curves (+derivatives), loss contours + descent
trajectories, optimizer races, LR schedules, decision regions/boundaries, train/val
curves, double descent, PR/ROC, gaussians & density areas, softmax bars, gradient-flow
vs depth, positional-encoding waves, embedding scatters, param bar charts.

```typst
activation-plot("relu" | "sigmoid" | "tanh" | "gelu", deriv: true)
curve(f, xrange: ..) · tangent(f, x0)
loss-contour(f, path: gd-path(grad, start, eta, steps))
optimizer-race(f, grad, ("gd", "momentum", "adam"), start)   // trajectories in Typst
lr-schedule("cosine" | "step" | "warmup-cosine", ..)
decision-regions(score-fns) · scatter-2class(a, b, boundary: ..)
train-curves(train, val) · pr-curve(..) · roc-curve(..)
gaussian(mu, sigma, area: (a, b)) · softmax-bars(logits, temperature: 1)
```

Key property: trajectories/derivatives/regions computed in Typst from the same
function the slide's math states. 3-D surfaces stay matplotlib (policy unchanged;
plotsy-3d's z-sorting isn't reliable for saddles yet).

### 3. `nn-arch` — semantic architecture diagrams

TikZ ancestors: neuralnetwork (MLPs) + the widely-copied Vaswani transformer styles.
Base: fletcher. Formalizes the ~80 ad-hoc fletcher diagrams into a vocabulary.

```typst
neuron(d: 3) · mlp((4, 8, 8, 2), show-weights: ..)
rnn-cell("rnn" | "lstm" | "gru") · unrolled(cell, steps: 4, bptt: false)
enc-dec(enc: .., dec: .., attention: true)
mha-block(heads: 8) · transformer-block("encoder" | "decoder")
residual(inner) · block-stack(blocks, xN: ..)      // ×N stacking à la Vaswani Fig. 1
badge(node, forward: .., backward: ..)             // backprop value annotations
```

Fills the ecosystem's "transformer gap". Distinct from neural-netz (3-D exploded CNN
views) — we don't compete there; contribute upstream if the decks ever need that style.

### 4. `plate-note` — PGMs / plate notation

TikZ ancestor: tikz-bayesnet (also: daft in Python). Base: fletcher/cetz.
Wide-open niche; primary consumer is pml-teaching.

```typst
latent("z") · observed("x") · det("mu") · const("alpha") · factor(..)
edges("alpha" -> "z" -> "x")
plate(("z", "x"), label: $n = 1..N$)   // auto-bounding, nestable
```

Smallest package; also the reference implementation of the theme-core contract.

## Non-goals

- A plotting engine (lilaq owns that; we file issues/PRs upstream when we hit limits).
- 3-D exploded CNN views (neural-netz exists).
- Native 3-D surfaces (matplotlib stays for bowls/saddles).
- Interactivity (that's the interactive-articles site).
- Auto-layout from live PyTorch models in v1 (data-shaped APIs keep the door open).

## Repo layout

```
packages/
  ml-theme/        typst.toml, lib.typ, README
  tensor-grid/     typst.toml, src/, docs/ (gallery.typ → gallery.pdf), tests/
  ml-plot/
  nn-arch/
  plate-note/
gallery/           cross-package showcase, one page per figure type
justfile           compile all galleries + visual regression via typst compile
```

Each package: own semver, own README with rendered examples, gallery compiled in CI.
Universe submission via typst/packages PR once API survives one real lecture port.

## Milestones

1. **M1** — `ml-theme` + `tensor-grid` v0.1 (`grid-map`, `conv-op`, `attn-matrix`,
   `patchify`) + gallery. Acceptance: port the ~11 conv-arithmetic figures of L8/L8b
   and the causal-mask/attention figures of L15 with no visual regressions.
   *Status 2026-07-10: packages built and installed to `@local`; gallery compiles;
   `dl-teaching/common/mldiag.typ` adapter + `tensor-grid-demo.typ` deck render the
   L8/L15 figure set natively (incl. 9-step animated convolution). Remaining for
   acceptance: replace the figures inside `L8-cnns.typ` / `L15-transformers-i.typ`.*
2. **M2** — `ml-plot` v0.1 (activation, contour+paths, schedules, scatter).
   Acceptance: L2/L3a/L5 matplotlib 2-D figures retired.
3. **M3** — `nn-arch` v0.1 (mlp, rnn cells, unrolled, mha/transformer blocks).
   Acceptance: L12/L15 diagrams re-expressed, shorter than the ad-hoc fletcher.
4. **M4** — `plate-note` v0.1. Acceptance: 3–4 canonical PGMs (GMM, LDA-style
   hierarchy, HMM) match tikz-bayesnet output quality.
5. **M5** — universe submission (names finalized), announce, port remaining lectures.
