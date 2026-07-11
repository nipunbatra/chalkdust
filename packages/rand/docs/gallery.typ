// rand gallery — a seeded, pure PRNG. Every example shows its CODE and the live
// output (eval'd from the same source). Compile: typst compile docs/gallery.typ
#import "@local/rand:0.1.0" as rnd
#import "@local/plot:0.1.0" as plot
#import "@preview/cetz:0.4.2"

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/rand:0.1.0\" as rnd\n#import \"@local/plot:0.1.0\" as plot\n#import \"@preview/cetz:0.4.2\""
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= rand

A tiny *seeded, pure PRNG*: every draw is a function of `(seed, index)`, so figures
are reproducible and hold no hidden state. It is *counter-based* — the index is run
through a strong bit-mixer (MurmurHash3's `fmix32`, the design behind scientific
counter-RNGs) — so consecutive draws and different seeds are statistically
independent, and Box–Muller gives a true bell curve. `#import "@local/rand:0.1.0" as rnd`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*returns*]),
  [`rand(seed, i)`], [uniform in $[0, 1)$],
  [`uniform(seed, i, lo, hi)`], [uniform in `[lo, hi)`],
  [`randint(seed, i, lo, hi)`], [integer in `[lo, hi)`],
  [`bernoulli(seed, i, p)`], [$1$ with probability $p$, else $0$],
  [`randn(seed, k)`], [standard normal $cal(N)(0, 1)$],
  [`normal(seed, k, mu, sigma)`], [normal $cal(N)(mu, sigma)$],
  [`randvec / randnvec(seed, i, n)`], [an $n$-vector of uniform / normal draws],
  [`sample(seed, i, arr)`], [a random element of `arr`],
  [`shuffle(seed, arr)`], [a Fisher–Yates permutation],
)

== Uniform draws are flat — 2000 samples, 20 bins
#demo(```
#let U = range(2000).map(i => rnd.rand(1, i))
#let counts = range(20).map(b => U.filter(u => u >= b/20 and u < (b+1)/20).len())
#plot.bars(counts, title: [rand — uniform], size: (82mm, 32mm))
```.text)

== Normal draws — a real bell curve (this is the fixed PRNG)
#demo(```
#let Z = range(3000).map(k => rnd.randn(2, k))
#let edges = range(-30, 31, step: 6).map(e => e / 10.0)
#let counts = edges.slice(0, -1).enumerate().map(((bi, lo)) =>
  Z.filter(z => z >= lo and z < edges.at(bi + 1)).len())
#plot.bars(counts, title: [randn — bell curve], size: (86mm, 36mm))
```.text)

== 800 points from a 2-D Gaussian — a round, uncorrelated cloud
#demo(ratio: (1.15fr, 1fr), ```
#cetz.canvas({
  import cetz.draw: circle, line
  line((-3.2, 0), (3.2, 0), stroke: 0.4pt + gray)
  line((0, -3.2), (0, 3.2), stroke: 0.4pt + gray)
  for i in range(800) {
    let v = rnd.randnvec(4, i, 2)   // (x, y) ~ N(0, I), independent
    circle((v.at(0), v.at(1)), radius: 1.3pt,
      fill: rgb("#eb811b").transparentize(50%), stroke: none)
  }
})
```.text)

== Discrete draws
#demo(ratio: (1.25fr, 1fr), ```
// roll a d6 twelve times
#range(12).map(i => rnd.randint(7, i, 1, 7))
```.text)
#demo(ratio: (1.25fr, 1fr), ```
// a biased coin: rate of heads over 2000 flips ≈ 0.3
#let flips = range(2000).map(i => rnd.bernoulli(9, i, 0.3))
#[rate = #calc.round(flips.sum() / flips.len(), digits: 3)]
```.text)

== Sampling and shuffling
#demo(ratio: (1.25fr, 1fr), ```
#let deck = ("A", "K", "Q", "J", "10", "9", "8", "7")
#[pick: #rnd.sample(3, 0, deck) · shuffled: #rnd.shuffle(3, deck)]
```.text)

== Reproducible
Same `(seed, index)` always returns the same value — re-render and the figure is
identical. Vary the seed for an independent draw, walk the index for a stream.
