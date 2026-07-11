// linalg — small dense linear algebra for Typst.
//
// A matrix is a list of rows (each a list of numbers); a vector is a list. Enough
// to fit a regression (normal equations via `solve`) or run PCA (`eig-sym` of a
// covariance) inside a slide.
//
//   #import "@local/linalg:0.1.0" as la
//   #la.matmul(((1, 2), (3, 4)), ((5,), (6,)))   // ((17,), (39,))
//   #la.solve(((2, 1), (1, 3)), (3, 5))           // (0.8, 1.4)

// ── vectors ──
#let vadd(a, b) = a.zip(b).map(((x, y)) => x + y)
#let vsub(a, b) = a.zip(b).map(((x, y)) => x - y)
#let scale(a, s) = a.map(x => x * s)
#let dot(a, b) = a.zip(b).map(((x, y)) => x * y).sum()
#let norm(a) = calc.sqrt(a.map(x => x * x).sum())
#let dist(a, b) = norm(vsub(a, b))
#let normalize(a) = { let n = norm(a); if n == 0 { a } else { scale(a, 1.0 / n) } }
#let mean(vs) = scale(vs.fold(vs.at(0).map(_ => 0.0), vadd), 1.0 / vs.len())

// ── matrix shape & construction ──
#let nrows(M) = M.len()
#let ncols(M) = if M.len() == 0 { 0 } else { M.at(0).len() }
#let row(M, i) = M.at(i)
#let col(M, j) = M.map(r => r.at(j))
#let transpose(M) = range(ncols(M)).map(j => M.map(r => r.at(j)))
#let identity(n) = range(n).map(i => range(n).map(j => if i == j { 1.0 } else { 0.0 }))
#let zeros(r, c) = range(r).map(_ => range(c).map(_ => 0.0))
#let diag(vals) = range(vals.len()).map(i => range(vals.len()).map(j => if i == j { vals.at(i) } else { 0.0 }))

// ── matrix arithmetic ──
#let madd(A, B) = A.zip(B).map(((ra, rb)) => vadd(ra, rb))
#let msub(A, B) = A.zip(B).map(((ra, rb)) => vsub(ra, rb))
#let mscale(A, s) = A.map(r => scale(r, s))
#let matvec(M, v) = M.map(r => dot(r, v))
#let matmul(A, B) = {
  let Bt = transpose(B)
  A.map(arow => Bt.map(bcol => dot(arow, bcol)))
}

// ── Gaussian elimination: solve, inverse, determinant (partial pivoting) ──
#let solve(A, b) = {
  let n = A.len()
  let M = range(n).map(i => A.at(i).map(x => x * 1.0) + (b.at(i) * 1.0,))   // augmented
  for c in range(n) {
    let piv = c
    let best = calc.abs(M.at(c).at(c))
    for r in range(c + 1, n) { if calc.abs(M.at(r).at(c)) > best { best = calc.abs(M.at(r).at(c)); piv = r } }
    if piv != c { let t = M.at(c); M.at(c) = M.at(piv); M.at(piv) = t }
    let pv = M.at(c).at(c)
    for r in range(c + 1, n) {
      let f = M.at(r).at(c) / pv
      M.at(r) = range(n + 1).map(k => M.at(r).at(k) - f * M.at(c).at(k))
    }
  }
  let x = range(n).map(_ => 0.0)
  for ri in range(n) {
    let i = n - 1 - ri
    let s = M.at(i).at(n)
    for j in range(i + 1, n) { s = s - M.at(i).at(j) * x.at(j) }
    x.at(i) = s / M.at(i).at(i)
  }
  x
}
#let inv(M) = {
  let n = M.len()
  let cols = range(n).map(j => solve(M, range(n).map(i => if i == j { 1.0 } else { 0.0 })))
  range(n).map(i => range(n).map(j => cols.at(j).at(i)))       // columns → rows
}
#let det(A) = {
  let n = A.len()
  let M = A.map(r => r.map(x => x * 1.0))
  let d = 1.0
  for c in range(n) {
    let piv = c
    let best = calc.abs(M.at(c).at(c))
    for r in range(c + 1, n) { if calc.abs(M.at(r).at(c)) > best { best = calc.abs(M.at(r).at(c)); piv = r } }
    if best == 0.0 { return 0.0 }
    if piv != c { let t = M.at(c); M.at(c) = M.at(piv); M.at(piv) = t; d = d * -1.0 }
    d = d * M.at(c).at(c)
    for r in range(c + 1, n) {
      let f = M.at(r).at(c) / M.at(c).at(c)
      M.at(r) = range(n).map(k => M.at(r).at(k) - f * M.at(c).at(k))
    }
  }
  d
}

// ── symmetric eigendecomposition via cyclic Jacobi rotations ──
// Returns (values, vectors): `values.at(k)` with eigenvector `vectors.at(k)` (a
// column). Assumes A is symmetric (e.g. a covariance matrix) — perfect for PCA.
#let eig-sym(A0, sweeps: 60) = {
  let n = A0.len()
  let A = A0.map(r => r.map(x => x * 1.0))
  let V = identity(n)
  for _ in range(sweeps) {
    // largest off-diagonal magnitude
    let p = 0
    let q = 1
    let mx = 0.0
    for i in range(n) {
      for j in range(i + 1, n) {
        if calc.abs(A.at(i).at(j)) > mx { mx = calc.abs(A.at(i).at(j)); p = i; q = j }
      }
    }
    if mx < 1e-14 { break }
    let theta = 0.5 * calc.atan2(A.at(p).at(p) - A.at(q).at(q), 2.0 * A.at(p).at(q))
    let c = calc.cos(theta)
    let s = calc.sin(theta)
    let J = identity(n)
    J.at(p).at(p) = c
    J.at(q).at(q) = c
    J.at(p).at(q) = -s
    J.at(q).at(p) = s
    A = matmul(matmul(transpose(J), A), J)
    V = matmul(V, J)
  }
  let vals = range(n).map(i => A.at(i).at(i))
  let vecs = range(n).map(j => col(V, j))          // eigenvector j = column j of V
  // sort by descending eigenvalue (PCA convention)
  let order = range(n).sorted(key: k => -vals.at(k))
  (order.map(k => vals.at(k)), order.map(k => vecs.at(k)))
}
