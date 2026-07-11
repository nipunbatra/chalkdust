// learn gallery — classic ML fit in Typst, drawn through the rest of the stack.
// Compile: typst compile docs/gallery.typ
#import "@local/learn:0.1.0" as ml
#import "@local/plot:0.1.0" as plot
#import "@local/field:0.1.0" as field
#import "@local/dist:0.1.0" as dist
#import "@local/rand:0.1.0" as rnd
#import "@preview/cetz:0.4.2"

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/learn:0.1.0\" as ml\n#import \"@local/plot:0.1.0\" as plot\n#import \"@local/field:0.1.0\" as field\n#import \"@local/dist:0.1.0\" as dist\n#import \"@local/rand:0.1.0\" as rnd\n#import \"@preview/cetz:0.4.2\""
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= learn

Classic ML algorithms, *fit in Typst*. This is the capstone of the stack: it builds
on `linalg` (matrices, solve, eig), `optim` (gradient descent), `rand` (init) and
`dist` (sigmoid), and its results draw through `plot` / `field`. So a fitted line, a
decision boundary, a clustering or a PCA axis is the real computed thing.
`#import "@local/learn:0.1.0" as ml`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*fits, using…*]),
  [`linreg-fit(xs, y)`], [least squares (normal equations) — via `linalg.solve`],
  [`logreg(X, y)`], [logistic regression — via `optim.gd` + `dist.sigmoid`],
  [`kmeans(points, k)`], [k-means — via `rand` init + `linalg` distances],
  [`knn(X, y, q, k:)`], [k-nearest-neighbours vote — via `linalg` distances],
  [`pca(data, k:)`], [principal components — via `linalg.eig-sym` of the covariance],
)

== Linear regression — fit a noisy line
#demo(```
#let xs = range(24).map(i => -2.0 + 4.0 * i / 23)
#let ys = xs.enumerate().map(((i, x)) => 1 + 2 * x + 0.7 * rnd.randn(1, i))
#let w = ml.linreg-fit(xs, ys)   // (intercept, slope) ≈ (1, 2)
#plot.lines(
  (xs.zip(ys), xs.map(x => (x, ml.linreg-predict(w, x)))),
  markers: (true, false), colors: (rgb("#eb811b"), rgb("#23373b")),
  x-label: [x], y-label: [y], size: (64mm, 44mm))
```.text)

== Logistic regression — the decision boundary
#demo(ratio: (1.1fr, 1fr), ```
// two 2-D classes; logistic regression; shade p(class = 1)
#let A = range(18).map(i => (rnd.normal(2, 2*i, -1.1, 0.6), rnd.normal(2, 2*i+1, -0.6, 0.6)))
#let B = range(18).map(i => (rnd.normal(3, 2*i, 1.1, 0.6), rnd.normal(3, 2*i+1, 0.8, 0.6)))
#let X = (A + B).map(p => (1.0, p.at(0), p.at(1)))
#let y = A.map(_ => 0) + B.map(_ => 1)
#let w = ml.logreg(X, y)
#field.heatmap((x, u) => dist.sigmoid(w.at(0) + w.at(1) * x + w.at(2) * u),
  xlim: (-3, 3), ylim: (-3, 3), samples: 40, cell: 1.1mm)
```.text)

== k-means — three blobs, coloured by cluster
#demo(ratio: (1.1fr, 1fr), ```
#let blob(s, cx, cy) = range(14).map(i => (rnd.normal(s, 2*i, cx, 0.5), rnd.normal(s, 2*i+1, cy, 0.5)))
#let pts = blob(1, -1.5, 1) + blob(2, 1.5, 1.2) + blob(3, 0, -1.5)
#let (cent, asg) = ml.kmeans(pts, 3, seed: 4)
#let cols = (rgb("#eb811b"), rgb("#2c7a7b"), rgb("#2e8b57"))
#cetz.canvas({
  import cetz.draw: circle
  for (i, p) in pts.enumerate() {
    circle((p.at(0), p.at(1)), radius: 1.6pt, fill: cols.at(asg.at(i)).transparentize(30%), stroke: none)
  }
  for (c, ct) in cent.enumerate() { circle((ct.at(0), ct.at(1)), radius: 3pt, fill: white, stroke: 1.2pt + cols.at(c)) }
})
```.text)

== PCA — the principal axes of a correlated cloud
#demo(ratio: (1.1fr, 1fr), ```
// stretch a gaussian cloud along a tilted direction
#let data = range(120).map(i => {
  let a = 1.6 * rnd.randn(5, i); let b = 0.4 * rnd.randn(6, i)
  (a - b, a + b)     // correlated
})
#let m = ml.pca(data)
#cetz.canvas({
  import cetz.draw: circle, line
  for p in data { circle((p.at(0), p.at(1)), radius: 1pt, fill: rgb("#eb811b").transparentize(55%), stroke: none) }
  for (k, v) in m.components.enumerate() {
    let s = 1.6 * calc.sqrt(m.values.at(k))
    line((m.mean.at(0) - s * v.at(0), m.mean.at(1) - s * v.at(1)),
         (m.mean.at(0) + s * v.at(0), m.mean.at(1) + s * v.at(1)), stroke: 1.6pt + rgb("#23373b"))
  }
})
```.text)
