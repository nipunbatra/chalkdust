// tensor-grid gallery — one section per component, default theme.
// Compile:  typst compile docs/gallery.typ
#import "@local/tensor-grid:0.1.0": *

#set page(width: 24cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let X = ((1, 2, 0, 1, 2),
          (0, 1, 3, 2, 0),
          (2, 1, 0, 1, 3),
          (1, 0, 2, 0, 1),
          (0, 2, 1, 3, 2))
#let K = ((1, 1, 1), (0, 0, 0), (-1, -1, -1))   // horizontal-edge detector

= tensor-grid gallery

== conv-op — numeric, step 0 (with worked expression)
#conv-op(input: X, kernel: K, step: 0, show-expr: true)

== conv-op — numeric, mid-computation (step 4, accumulating)
#conv-op(input: X, kernel: K, step: 4)

== conv-op — padding 1, stride 2 (shape-only)
#conv-op(input: 5, kernel: 3, padding: 1, stride: 2, step: 1)

== conv-op — dilation 2
#conv-op(input: 7, kernel: 3, dilation: 2, step: 0)

== pool-op — max and avg, 4×4 → 2×2
#pool-op(((1, 3, 2, 4), (5, 6, 1, 2), (7, 2, 3, 0), (1, 0, 4, 8)),
  window: 2, kinds: ("max", "avg"))

== attn-matrix — worked QKᵀ scores
#attn-matrix(($x_1$, $x_2$, $x_3$),
  values: ((1, 0, 1), (0, 1, 1), (1, 1, 2)))

== attn-matrix — causal mask (structure only)
#attn-matrix(("1", "2", "3", "4", "5"), mask: "causal",
  q-label: [query position $i$], k-label: [key position $j$])

== attn-matrix — softmaxed rows, causal, colorbar
#attn-matrix(("the", "cat", "sat", "on", "mat"),
  values: ((3, 0, 0, 0, 0),
           (1.8, 1.4, 0, 0, 0),
           (0.2, 2.0, 1.4, 0, 0),
           (0.1, 0.4, 1.5, 1.4, 0),
           (0.3, 0.2, 0.5, 1.6, 1.4)),
  mask: "causal", softmax: true, min-annotate: 0.05, colorbar: true)

== receptive-field — three stacked 3×3 convs
#receptive-field(kernels: (3, 3, 3))

== grid-map — bare heatmap with labels
#grid-map(((0.9, 0.1), (0.2, 0.8)), cell: 12mm,
  row-labels: ([true 0], [true 1]), col-labels: ([pred 0], [pred 1]))

== patchify — 8×8 image, 4×4 patches
#patchify(image: 8, patch: 4, cell: 6mm)

== patchify — exploded
#patchify(image: 8, patch: 4, cell: 6mm, gap: 3mm)
