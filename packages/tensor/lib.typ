// tensor — a numpy/torch-lite n-dimensional array for Typst.
//
// A tensor is `(data: <flat, row-major list>, shape: <list of dims>)`. It carries
// reshape / transpose, elementwise ops with full numpy broadcasting, axis
// reductions, indexing, and 2-D matmul (via `linalg`); random tensors come from
// `rand` — so it both feeds on and feeds the rest of the stack.
//
//   #import "@local/tensor:0.1.0" as nd
//   #let A = nd.arr(((1, 2, 3), (4, 5, 6)))     // shape (2, 3)
//   #nd.add(A, (10, 20, 30))                     // broadcasts the row vector
//   #nd.matmul(A, nd.transpose(A))               // (2,3) · (3,2) → (2,2)

#import "@local/linalg:0.1.0" as la
#import "@local/rand:0.1.0" as rnd

// ── shape helpers ──
#let _prod(xs) = xs.fold(1, (a, b) => a * b)
#let _unravel(flat, shape) = {
  let idx = ()
  let rem = flat
  for s in shape.rev() { idx.push(calc.rem(rem, s)); rem = calc.floor(rem / s) }
  idx.rev()
}
#let _ravel(idx, shape) = {
  let flat = 0
  for k in range(shape.len()) { flat = flat * shape.at(k) + idx.at(k) }
  flat
}

// ── constructors ──
#let tensor(data, shape) = (data: data, shape: shape)
#let full(shape, v) = (data: range(_prod(shape)).map(_ => v * 1.0), shape: shape)
#let zeros(shape) = full(shape, 0.0)
#let ones(shape) = full(shape, 1.0)
#let arange(n) = (data: range(n).map(i => i * 1.0), shape: (n,))
#let eye(n) = (data: range(n * n).map(i => if calc.rem(i, n + 1) == 0 { 1.0 } else { 0.0 }), shape: (n, n))
// build from a nested list (a scalar, a list, or a list of lists …)
#let _shape-of(nested) = if type(nested) == array { (nested.len(),) + _shape-of(nested.at(0)) } else { () }
#let _flat-of(nested) = if type(nested) == array { nested.map(_flat-of).flatten() } else { (nested * 1.0,) }
#let arr(nested) = (data: _flat-of(nested), shape: _shape-of(nested))

// ── shape / view ──
#let shape(t) = t.shape
#let ndim(t) = t.shape.len()
#let size(t) = t.data.len()
#let reshape(t, shape) = {
  assert(_prod(shape) == t.data.len(), message: "reshape: size mismatch")
  (data: t.data, shape: shape)
}
#let flatten(t) = (data: t.data, shape: (t.data.len(),))
// general axis permutation (default: reverse = ordinary transpose)
#let transpose(t, axes: none) = {
  let n = t.shape.len()
  let perm = if axes == none { range(n).rev() } else { axes }
  let ns = perm.map(k => t.shape.at(k))
  let data = range(_prod(ns)).map(flat => {
    let idx = _unravel(flat, ns)
    let orig = range(n).map(_ => 0)
    for k in range(n) { orig.at(perm.at(k)) = idx.at(k) }
    t.data.at(_ravel(orig, t.shape))
  })
  (data: data, shape: ns)
}
// nested list, for display or handing to linalg
#let to-nested(t) = {
  if t.shape.len() <= 1 { return t.data }
  let outer = t.shape.at(0)
  let inner = _prod(t.shape.slice(1))
  range(outer).map(i => to-nested((data: t.data.slice(i * inner, (i + 1) * inner), shape: t.shape.slice(1))))
}

// ── indexing ──
#let at(t, ..idx) = t.data.at(_ravel(idx.pos(), t.shape))
#let row(t, i) = { let inner = _prod(t.shape.slice(1)); (data: t.data.slice(i * inner, (i + 1) * inner), shape: t.shape.slice(1)) }

// ── elementwise with full broadcasting ──
#let _as-tensor(x) = if type(x) == dictionary { x } else { (data: (x * 1.0,), shape: ()) }
#let _binop(a, b, f) = {
  let ta = _as-tensor(a)
  let tb = _as-tensor(b)
  let n = calc.max(ta.shape.len(), tb.shape.len())
  let pa = range(n - ta.shape.len()).map(_ => 1) + ta.shape
  let pb = range(n - tb.shape.len()).map(_ => 1) + tb.shape
  let os = range(n).map(k => calc.max(pa.at(k), pb.at(k)))
  let data = range(_prod(os)).map(flat => {
    let idx = _unravel(flat, os)
    let ia = range(n).map(k => if pa.at(k) == 1 { 0 } else { idx.at(k) })
    let ib = range(n).map(k => if pb.at(k) == 1 { 0 } else { idx.at(k) })
    f(ta.data.at(_ravel(ia, pa)), tb.data.at(_ravel(ib, pb)))
  })
  (data: data, shape: os)
}
#let add(a, b) = _binop(a, b, (x, y) => x + y)
#let sub(a, b) = _binop(a, b, (x, y) => x - y)
#let mul(a, b) = _binop(a, b, (x, y) => x * y)       // elementwise (Hadamard)
#let div(a, b) = _binop(a, b, (x, y) => x / y)
#let map(t, f) = (data: t.data.map(f), shape: t.shape)
#let neg(t) = map(t, x => -x)
#let scale(t, s) = map(t, x => x * s)
#let texp(t) = map(t, calc.exp)
#let tsqrt(t) = map(t, calc.sqrt)
#let tabs(t) = map(t, calc.abs)

// ── reductions (whole tensor, or along one axis) ──
#let sum(t) = t.data.sum()
#let mean(t) = t.data.sum() / t.data.len()
#let amax(t) = calc.max(..t.data)
#let amin(t) = calc.min(..t.data)
#let prod(t) = t.data.fold(1.0, (a, b) => a * b)
// reduce along `axis`, dropping it (numpy `sum(axis=…)`)
#let _reduce-axis(t, axis, init, op) = {
  let ns = t.shape.enumerate().filter(it => it.at(0) != axis).map(it => it.at(1))
  let out = range(_prod(ns)).map(_ => init)
  for flat in range(t.data.len()) {
    let idx = _unravel(flat, t.shape)
    let oidx = idx.enumerate().filter(it => it.at(0) != axis).map(it => it.at(1))
    let o = _ravel(oidx, ns)
    out.at(o) = op(out.at(o), t.data.at(flat))
  }
  (data: out, shape: ns)
}
#let sum-axis(t, axis) = _reduce-axis(t, axis, 0.0, (a, b) => a + b)
#let mean-axis(t, axis) = scale(sum-axis(t, axis), 1.0 / t.shape.at(axis))
#let max-axis(t, axis) = _reduce-axis(t, axis, -1e18, (a, b) => calc.max(a, b))

// ── linear algebra bridges (2-D, via linalg) ──
#let matmul(a, b) = arr(la.matmul(to-nested(a), to-nested(b)))
#let matvec(a, v) = { let vv = if type(v) == dictionary { v.data } else { v }; arr(la.matvec(to-nested(a), vv)) }

// ── random tensors (via rand) ──
#let randn(shape, seed) = (data: range(_prod(shape)).map(i => rnd.randn(seed, i)), shape: shape)
#let rand-uniform(shape, seed) = (data: range(_prod(shape)).map(i => rnd.rand(seed, i)), shape: shape)
