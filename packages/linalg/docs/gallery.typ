// linalg gallery — vectors & matrices, code + live result.
// Compile: typst compile docs/gallery.typ
#import "@local/linalg:0.1.0" as la

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/linalg:0.1.0\" as la"
// render a matrix (list of rows) as bracketed rows — available inside the demos too
#let show-mat(M, d: 3) = math.mat(delim: "[", ..M.map(r => r.map(x => calc.round(x, digits: d))))
#let demo(code, ratio: (1.15fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, left + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup", scope: (show-mat: show-mat))),
))

= linalg

Small dense *linear algebra*: a matrix is a list of rows, a vector is a list.
Transpose, matmul, `solve` / `inv` / `det` by Gaussian elimination, and a Jacobi
symmetric eigendecomposition — enough to fit a regression or run PCA in a slide.
`#import "@local/linalg:0.1.0" as la`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*returns*]),
  [`vadd vsub scale dot norm dist`], [vector arithmetic],
  [`transpose matvec matmul`], [matrix products],
  [`madd msub mscale`], [matrix arithmetic],
  [`identity zeros diag`], [constructors],
  [`solve(A, b)`], [$x$ with $A x = b$ (partial-pivot elimination)],
  [`inv(A)` · `det(A)`], [inverse · determinant],
  [`eig-sym(A)`], [`(values, vectors)` of a symmetric $A$, sorted],
)

== Matrix product
#demo(```
#let A = ((1, 2), (3, 4))
#let B = ((5, 6), (7, 8))
$#show-mat(A) #show-mat(B) = #show-mat(la.matmul(A, B))$
```.text)

== Solve a linear system $A x = b$
#demo(```
#let A = ((1, 1, 1), (0, 2, 5), (2, 5, -1))
#let b = (6, -4, 27)
$x = #la.solve(A, b).map(v => calc.round(v, digits: 2))$
// check: A x should equal b
$A x = #la.matvec(A, la.solve(A, b)).map(v => calc.round(v))$
```.text)

== Inverse and determinant
#demo(```
#let A = ((4, 7), (2, 6))
$A^(-1) = #show-mat(la.inv(A)), quad det A = #la.det(A)$
$A A^(-1) = #show-mat(la.matmul(A, la.inv(A)), d: 0)$
```.text)

== Symmetric eigendecomposition (the engine behind PCA)
#demo(ratio: (1.25fr, 1fr), ```
// a covariance-like matrix: eigenvectors are the principal axes
#let C = ((2.0, 0.9), (0.9, 1.0))
#let (vals, vecs) = la.eig-sym(C)
$lambda = #vals.map(v => calc.round(v, digits: 3))$
#linebreak()
$v_1 = #vecs.at(0).map(v => calc.round(v, digits: 3))$ (top principal axis)
```.text)

== Least squares by the normal equations
#demo(ratio: (1.1fr, 1fr), ```
// fit y ≈ w0 + w1 x through (0,1),(1,3),(2,5),(3,7): slope 2, intercept 1
#let X = ((1, 0), (1, 1), (1, 2), (1, 3))
#let y = (1, 3, 5, 7)
#let Xt = la.transpose(X)
#let w = la.solve(la.matmul(Xt, X), la.matvec(Xt, y))
$w = #w.map(v => calc.round(v, digits: 3))$ (intercept, slope)
```.text)
