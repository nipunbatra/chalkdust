// tensor gallery — a numpy-lite n-d array, code + live result.
// Compile: typst compile docs/gallery.typ
#import "@local/tensor:0.1.0" as nd

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/tensor:0.1.0\" as nd"
#let show-mat(M, d: 2) = math.mat(delim: "[", ..M.map(r => if type(r) == array { r.map(x => calc.round(x, digits: d)) } else { (calc.round(r, digits: d),) }))
#let demo(code, ratio: (1.25fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, left + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup", scope: (show-mat: show-mat))),
))

= tensor

A numpy / torch-lite *n-dimensional array*: `(data: <flat>, shape: <dims>)`.
Reshape, transpose, elementwise ops with *full broadcasting*, axis reductions,
indexing, and 2-D `matmul` (routed through `linalg`); random tensors come from
`rand`. `#import "@local/tensor:0.1.0" as nd`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*does*]),
  [`arr(nested)` · `zeros/ones/full`], [build from a nested list / by shape],
  [`arange(n)` · `eye(n)`], [ramp · identity],
  [`reshape` · `transpose` · `flatten`], [views (transpose takes an `axes:` perm)],
  [`add sub mul div` (broadcast)], [elementwise, numpy broadcasting],
  [`map scale neg texp tsqrt`], [apply a function],
  [`sum mean amax` · `sum-axis(t, k)`], [reduce all, or along one axis],
  [`at(t, i, j, …)` · `row(t, i)`], [index],
  [`matmul` (via linalg) · `randn` (via rand)], [linear algebra · random tensors],
)

== Shape, reshape, transpose
#demo(```
#let A = nd.arr(((1, 2, 3), (4, 5, 6)))     // shape (2, 3)
$A = #show-mat(nd.to-nested(A)), quad A^top = #show-mat(nd.to-nested(nd.transpose(A)))$
#[shape #A.shape, reshaped #nd.reshape(A, (3, 2)).shape]
```.text)

== Broadcasting — a row and a column vector against a matrix
#demo(```
#let A = nd.arr(((1, 2, 3), (4, 5, 6)))
// add a row vector (broadcasts down the rows)
$A + #show-mat((nd.arr((10, 20, 30)).data,)) = #show-mat(nd.to-nested(nd.add(A, nd.arr((10, 20, 30)))))$
// add a column vector (broadcasts across the columns)
$A + #show-mat(nd.to-nested(nd.arr(((10,), (100,))))) = #show-mat(nd.to-nested(nd.add(A, nd.arr(((10,), (100,))))))$
```.text)

== Reductions — whole tensor or along an axis
#demo(```
#let A = nd.arr(((1, 2, 3), (4, 5, 6)))
#[sum #nd.sum(A), mean #nd.mean(A), max #nd.amax(A)]
#linebreak()
$"sum axis 0" = #nd.sum-axis(A, 0).data, quad "sum axis 1" = #nd.sum-axis(A, 1).data$
```.text)

== Matmul is routed through `linalg`
#demo(```
#let A = nd.arr(((1, 2, 3), (4, 5, 6)))
$A A^top = #show-mat(nd.to-nested(nd.matmul(A, nd.transpose(A))))$
```.text)

== Random tensors come from `rand`, and elementwise maps compose
#demo(```
// a 3x3 standard-normal tensor, then squashed through a sigmoid map
#let R = nd.randn((3, 3), 7)
$#show-mat(nd.to-nested(nd.map(R, x => 1 / (1 + calc.exp(-x)))), d: 2)$
```.text)
