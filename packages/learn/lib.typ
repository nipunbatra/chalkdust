// learn — classic ML algorithms, fit in Typst.
//
// The capstone of the chalkdust stack: it builds on `linalg` (matrices / solve /
// eig), `optim` (gradient descent), `rand` (k-means init) and `dist` (sigmoid), and
// its results plot straight through `field` / `plot`. Everything is computed, so a
// fitted line, a decision boundary, a clustering or a PCA axis on a slide is the
// real thing — not a drawing.
//
//   #import "@local/learn:0.1.0" as ml
//   #let w = ml.linreg-fit((0, 1, 2, 3), (1, 3, 5, 7))   // (intercept, slope) = (1, 2)
//   #let (mu, comps, ev) = ml.pca(points)                // principal axes

#import "@local/linalg:0.1.0" as la
#import "@local/optim:0.1.0" as opt
#import "@local/rand:0.1.0" as rnd
#import "@local/dist:0.1.0" as dist

// helper: prepend a 1 (bias) to a scalar or vector feature
#let _design(x) = (1.0,) + (if type(x) == array { x } else { (x,) })

// ── linear regression by the normal equations (via linalg) ──
// linreg(X, y): X already a design matrix (rows = samples). Returns weights w.
#let linreg(X, y) = {
  let Xt = la.transpose(X)
  la.solve(la.matmul(Xt, X), la.matvec(Xt, y))
}
// linreg-fit(xs, y): xs a list of scalar-or-vector features; adds the bias column.
// Returns (intercept, slope…).
#let linreg-fit(xs, y) = linreg(xs.map(_design), y)
#let linreg-predict(w, x) = la.dot(w, _design(x))

// ── logistic regression by gradient descent (via optim + dist) ──
// X: design matrix (include a bias column), y: 0/1 labels. Returns weights.
#let logreg(X, y, lr: 0.5, steps: 800) = {
  let n = X.len()
  let d = X.at(0).len()
  let Xt = la.transpose(X)
  let grad(w) = {                                   // ∇ = (1/n) Xᵀ(σ(Xw) − y)
    let err = X.zip(y).map(((row, yi)) => dist.sigmoid(la.dot(row, w)) - yi)
    la.scale(la.matvec(Xt, err), 1.0 / n)
  }
  opt.gd(grad, range(d).map(_ => 0.0), lr: lr, steps: steps).last()
}
#let logreg-prob(w, x) = dist.sigmoid(la.dot(w, x))

// ── k-means (via rand for init, linalg for distances) ──
// points: list of vectors. Returns (centroids, assignments).
#let kmeans(points, k, seed: 0, iters: 25) = {
  let centroids = rnd.shuffle(seed, range(points.len())).slice(0, k).map(i => points.at(i))
  let assign = points.map(_ => 0)
  for _ in range(iters) {
    assign = points.map(p => {
      let best = 0
      let bd = la.dist(p, centroids.at(0))
      for c in range(1, k) {
        let dd = la.dist(p, centroids.at(c))
        if dd < bd { bd = dd; best = c }
      }
      best
    })
    centroids = range(k).map(c => {
      let members = points.enumerate().filter(it => assign.at(it.at(0)) == c).map(it => it.at(1))
      if members.len() == 0 { centroids.at(c) } else { la.mean(members) }
    })
  }
  (centroids, assign)
}

// ── k-nearest-neighbours classification (via linalg distances) ──
#let knn(train-X, train-y, query, k: 3) = {
  let nearest = train-X.enumerate()
    .map(it => (la.dist(it.at(1), query), train-y.at(it.at(0))))
    .sorted(key: it => it.at(0))
    .slice(0, k).map(it => it.at(1))
  let labels = nearest.dedup()
  labels.map(l => (l, nearest.filter(x => x == l).len())).sorted(key: c => -c.at(1)).first().at(0)
}

// ── PCA (via linalg eigendecomposition of the covariance) ──
// data: list of vectors. Returns a dict (mean, components, values) — components
// are the top-k principal axes (unit vectors), values the variance along each.
#let pca(data, k: 2) = {
  let mu = la.mean(data)
  let centered = data.map(x => la.vsub(x, mu))
  let n = data.len()
  let d = mu.len()
  let cov = range(d).map(a => range(d).map(b => centered.map(x => x.at(a) * x.at(b)).sum() / n))
  let (vals, vecs) = la.eig-sym(cov)
  (mean: mu, components: vecs.slice(0, k), values: vals.slice(0, k))
}
// project a point onto the top-k principal axes
#let pca-project(model, x) = model.components.map(v => la.dot(la.vsub(x, model.mean), v))

// ── standardise a feature column to mean 0, variance 1 ──
#let standardize(xs) = {
  let m = xs.sum() / xs.len()
  let sd = calc.sqrt(xs.map(x => calc.pow(x - m, 2)).sum() / xs.len())
  if sd == 0 { xs.map(_ => 0.0) } else { xs.map(x => (x - m) / sd) }
}
