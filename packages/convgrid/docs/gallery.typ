// convgrid gallery — a code + live-demo catalog.
// Every example shows its CODE and the live output (the demo is eval'd from the
// same source, so it can't drift). Compile: typst compile docs/gallery.typ
#import "@local/convgrid:0.1.0" as cg

#set page(width: 23cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

// ── code + live demo, side by side ──────────────────────────────────────────
#let PRELUDE = "#import \"@local/convgrid:0.1.0\" as cg"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= convgrid

Diagrams of *convolutional and attention networks* that compute every number
*in Typst* — so the picture can never disagree with the arithmetic. Convolution
outputs, pooled values, softmax rows and receptive-field growth are all derived,
not typed by hand. `step` is a first-class argument, so a subslide loop animates
a computation for free. `#import "@local/convgrid:0.1.0" as cg`

== What's available
Every renderer takes a semantic `theme:` dict (defaults to the shared
`default-theme`, used throughout here). Shapes accept an int (`n`$times n$), an
`(r, c)` pair, or a 2-D value array — pass numbers to compute, pass a shape to
draw structure only.
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*function*], [*key arguments*]),
  [`cg.conv-op`], [`input:, kernel:, stride:, padding:, dilation:, step:, show-expr:`],
  [`cg.pool-op`], [`window:, stride:, kinds: ("max", "avg")`],
  [`cg.receptive-field`], [`kernels:, strides:` — nested RF squares + growth formula],
  [`cg.patchify`], [`image:, patch:, gap:, mask:` (raster indices to hide, MAE-style)],
  [`cg.attn-matrix`], [`values:, mask: "causal", softmax:, boxes:, colorbar:`],
  [`cg.grid-map`], [bare annotated grid / heatmap: `row-labels:, col-labels:, highlight:`],
)
Helpers are exported too: `cg.conv2d`, `cg.conv-out-size`, `cg.softmax-rows`.

== conv-op — one worked multiply–add (numbers computed in Typst)
#demo(ratio: (1fr, 1.05fr), ```
#let X = ((1, 2, 0, 1, 2),
          (0, 1, 3, 2, 0),
          (2, 1, 0, 1, 3),
          (1, 0, 2, 0, 1),
          (0, 2, 1, 3, 2))
#let K = ((1, 1, 1), (0, 0, 0), (-1, -1, -1))  // edge detector
#cg.conv-op(input: X, kernel: K, step: 0, show-expr: true, cell: 6mm)
```.text)

== conv-op — mid-computation, output accumulating (step 4)
#demo(ratio: (1fr, 1.05fr), ```
#let X = ((1, 2, 0, 1, 2), (0, 1, 3, 2, 0), (2, 1, 0, 1, 3),
          (1, 0, 2, 0, 1), (0, 2, 1, 3, 2))
#let K = ((1, 1, 1), (0, 0, 0), (-1, -1, -1))
#cg.conv-op(input: X, kernel: K, step: 4, cell: 6mm)
```.text)

== conv-op — padding 1, stride 2 (shape-only, no values)
#demo(ratio: (0.9fr, 1.1fr), ```
#cg.conv-op(input: 5, kernel: 3, padding: 1, stride: 2, step: 1, cell: 5mm)
```.text)

== conv-op — dilation 2 (à-trous taps)
#demo(ratio: (0.9fr, 1.1fr), ```
#cg.conv-op(input: 7, kernel: 3, dilation: 2, step: 0, cell: 5mm)
```.text)

== pool-op — max and avg, 4×4 → 2×2
#demo(ratio: (1fr, 1fr), ```
#cg.pool-op(
  ((1, 3, 2, 4), (5, 6, 1, 2), (7, 2, 3, 0), (1, 0, 4, 8)),
  window: 2, kinds: ("max", "avg"), cell: 8mm,
)
```.text)

== receptive-field — three stacked 3×3 convs
#demo(ratio: (0.85fr, 1.15fr), ```
#cg.receptive-field(kernels: (3, 3, 3), cell: 7mm)
```.text)

== patchify — an 8×8 image cut into 4×4 patch tokens
#demo(ratio: (1fr, 1fr), ```
#cg.patchify(image: 8, patch: 4, cell: 6mm)
```.text)

== patchify — exploded, with masked patches (MAE-style)
#demo(ratio: (1fr, 1fr), ```
#cg.patchify(image: 12, patch: 4, cell: 4mm, gap: 3mm, mask: (1, 5, 6))
```.text)

== attn-matrix — worked QKᵀ scores, self-attention diagonal boxed
#demo(ratio: (1fr, 1fr), ```
#cg.attn-matrix(($x_1$, $x_2$, $x_3$),
  values: ((1, 0, 1), (0, 1, 1), (1, 1, 2)),
  boxes: ((0, 0), (1, 1), (2, 2)))
```.text)

== attn-matrix — causal mask (structure only)
#demo(ratio: (1fr, 1fr), ```
#cg.attn-matrix(("1", "2", "3", "4", "5"), mask: "causal",
  q-label: [query position $i$], k-label: [key position $j$])
```.text)

== attn-matrix — causal, row-softmaxed, with colorbar
#demo(ratio: (0.9fr, 1.1fr), ```
#cg.attn-matrix(("the", "cat", "sat", "on", "mat"),
  values: ((3, 0, 0, 0, 0),
           (1.8, 1.4, 0, 0, 0),
           (0.2, 2.0, 1.4, 0, 0),
           (0.1, 0.4, 1.5, 1.4, 0),
           (0.3, 0.2, 0.5, 1.6, 1.4)),
  mask: "causal", softmax: true, min-annotate: 0.05, colorbar: true)
```.text)

== grid-map — a bare annotated heatmap (confusion matrix)
#demo(ratio: (1fr, 1fr), ```
#cg.grid-map(((0.9, 0.1), (0.2, 0.8)), cell: 13mm,
  row-labels: ([true 0], [true 1]), col-labels: ([pred 0], [pred 1]))
```.text)
