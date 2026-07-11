# convgrid

Conv arithmetic, annotated tensor grids, pooling, receptive fields, patchify
and attention heatmaps for ML/DL teaching — native Typst, built on CeTZ.
The Typst analogue of vdumoulin's `conv_arithmetic`, with two upgrades TikZ
can't offer: figures are **computed** (conv outputs, softmax rows, RF growth
are calculated in Typst from your data) and **animatable** (a single `step:`
parameter drives touying/polylux subslides).

```typst
#import "@local/convgrid:0.1.0": *

#let X = ((1,2,0,1,2), (0,1,3,2,0), (2,1,0,1,3), (1,0,2,0,1), (0,2,1,3,2))
#let K = ((1,1,1), (0,0,0), (-1,-1,-1))

#conv-op(input: X, kernel: K, step: 4, show-expr: true)   // output computed in Typst
#conv-op(input: 5, kernel: 3, padding: 1, stride: 2, step: 1)
#conv-op(input: 7, kernel: 3, dilation: 2, step: 0)
#pool-op(((1,3,2,4),(5,6,1,2),(7,2,3,0),(1,0,4,8)), kinds: ("max", "avg"))
#attn-matrix(("the","cat","sat"), values: S, mask: "causal", softmax: true)
#receptive-field(kernels: (3, 3, 3))
#patchify(image: 8, patch: 4, gap: 3mm)
#grid-map(M, row-labels: ..., col-labels: ...)            // heatmap / confusion matrix
```

Animated convolution in a touying deck:

```typst
#slide(repeat: 9, self => align(center,
  conv-op(input: X, kernel: K, step: self.subslide - 1)))
```

All colors are semantic roles from [`theme`](../theme) — restyle every
figure with one theme override:

```typst
#import "@local/theme:0.1.0": theme
#let mine = theme(accent: rgb("#EB811B"), ramp: (teal, white, orange))
#conv-op(.., theme: mine)      // or bind once:  conv-op.with(theme: mine)
```

Full showcase: [`docs/gallery.typ`](docs/gallery.typ). Exported helpers you can
use in prose so text and figure share one computation: `conv2d`,
`conv-out-size`, `softmax-rows`. Power users can compose raw CeTZ scenes with
`grid-draw` / `window-draw`.
