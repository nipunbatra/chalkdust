// learn — assert each algorithm recovers a known ground truth. Also confirms the
// stack wires up: linreg→linalg, logreg→optim+dist, kmeans→rand+linalg, pca→linalg.
#import "@local/learn:0.1.0" as ml
#import "@local/linalg:0.1.0" as la
#import "asserts.typ": passed, ok, eq, approx, approx-arr

// linear regression recovers y = 1 + 2x exactly
#approx-arr(ml.linreg-fit((0, 1, 2, 3), (1, 3, 5, 7)), (1, 2), eps: 1e-6, msg: "linreg (intercept, slope)")
// a 2-feature fit: y = 1 + 2a + 3b
#approx-arr(ml.linreg-fit(((0, 0), (1, 0), (0, 1), (1, 1)), (1, 3, 4, 6)), (1, 2, 3), eps: 1e-6,
  msg: "linreg with 2 features")

// logistic regression separates x<0 (label 0) from x>0 (label 1)
#let X = ((1, -3), (1, -2), (1, -1), (1, 1), (1, 2), (1, 3))
#let w = ml.logreg(X, (0, 0, 0, 1, 1, 1), lr: 0.5, steps: 800)
#ok(ml.logreg-prob(w, (1, 2)) > 0.5 and ml.logreg-prob(w, (1, -2)) < 0.5, msg: "logreg classifies both sides")
#ok(w.at(1) > 0, msg: "logreg slope positive (higher x → class 1)")

// k-means splits two well-separated blobs: first 3 together, last 3 together
#let pts = ((0.0, 0.0), (0.2, 0.1), (-0.1, 0.2), (5.0, 5.0), (5.2, 4.9), (4.8, 5.1))
#let (cent, asg) = ml.kmeans(pts, 2, seed: 1)
#ok(asg.at(0) == asg.at(1) and asg.at(1) == asg.at(2), msg: "kmeans: blob A shares a cluster")
#ok(asg.at(3) == asg.at(4) and asg.at(4) == asg.at(5), msg: "kmeans: blob B shares a cluster")
#ok(asg.at(0) != asg.at(3), msg: "kmeans: the two blobs are different clusters")

// kNN majority vote
#let tX = ((0, 0), (1, 0), (0, 1), (5, 5), (6, 5), (5, 6))
#let tY = ("A", "A", "A", "B", "B", "B")
#eq(ml.knn(tX, tY, (4.8, 5), k: 3), "B", msg: "kNN picks the near class")
#eq(ml.knn(tX, tY, (0.3, 0.2), k: 3), "A", msg: "kNN picks the other class")

// PCA finds the (1,1) stretch direction; top axis is unit and aligned with it
#let data = range(24).map(i => { let t = -2.0 + 4.0 * i / 23; (t, t) })
#let model = ml.pca(data, k: 2)
#approx(la.norm(model.components.at(0)), 1.0, msg: "principal axis is unit length")
#approx(calc.abs(la.dot(model.components.at(0), la.normalize((1, 1)))), 1.0, eps: 1e-3,
  msg: "top principal axis aligns with (1,1)")
#ok(model.values.at(0) > model.values.at(1), msg: "variance is largest along the 1st axis")

// standardize → mean 0, variance 1
#let z = ml.standardize((2, 4, 6, 8))
#approx(z.sum() / z.len(), 0.0, msg: "standardized mean 0")

#passed("learn")
