// ml-random gallery — a seeded, pure PRNG. Compile: typst compile docs/gallery.typ
#import "@local/ml-random:0.1.0" as rnd
#import "@local/ml-plot:0.1.0" as mp
#import "@preview/cetz:0.4.2"

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= ml-random

A tiny seeded PRNG: every draw is a pure function of `(seed, index)`, so figures
are reproducible and hold no hidden state. Walk `i = 0, 1, 2, …` for a stream.

== 600 standard-normal draws, binned — the bell shape falls out
#let Z = range(600).map(k => rnd.randn(5, k))
#let edges = range(-30, 31, step: 6).map(e => e / 10.0)   // −3 … 3 in 0.6 bins
#let counts = edges.slice(0, -1).enumerate().map(((bi, lo)) => {
  let hi = edges.at(bi + 1)
  Z.filter(z => z >= lo and z < hi).len()
})
#mp.bars(counts)

== 400 points from a 2-D Gaussian (each point is randnvec(seed, i, 2))
#cetz.canvas({
  import cetz.draw: circle, line, content
  line((-3, 0), (3, 0), stroke: 0.5pt + gray)
  line((0, -3), (0, 3), stroke: 0.5pt + gray)
  for i in range(400) {
    let v = rnd.randnvec(5, i, 2)
    circle((v.at(0), v.at(1)), radius: 1.4pt, fill: rgb("#eb811b").transparentize(45%), stroke: none)
  }
})

== reproducible & varied
- `rand(seed, i)` → uniform $[0, 1)$; `uniform / randint / bernoulli` for ranges & flips
- `randn / normal` (Box–Muller); `randvec / randnvec` for vectors
- `sample(seed, i, arr)` picks an element; `shuffle(seed, arr)` is a Fisher–Yates permutation
- e.g. `shuffle(2, range(8))` = #rnd.shuffle(2, range(8))
