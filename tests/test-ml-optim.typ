// ml-optim — assert every optimizer converges on a known bowl, numgrad matches
// the analytic gradient, and stochastic runs stay reproducible.
#import "@local/ml-optim:0.1.0" as opt
#import "asserts.typ": passed, ok, eq, approx, approx-arr

// vector ops
#approx-arr(opt.add((1, 2), (3, 4)), (4, 6), msg: "add")
#approx-arr(opt.sub((5, 5), (1, 2)), (4, 3), msg: "sub")
#approx-arr(opt.scale((2, 3), 2), (4, 6), msg: "scale")
#approx(opt.dot((1, 2, 3), (4, 5, 6)), 32, msg: "dot")

// finite-difference gradient of x²+50y² at (1,1) is (2, 100)
#let f(p) = p.at(0) * p.at(0) + 50.0 * p.at(1) * p.at(1)
#approx-arr((opt.numgrad(f))((1.0, 1.0)), (2.0, 100.0), eps: 1e-2, msg: "numgrad ≈ analytic gradient")

// ill-conditioned bowl: grad (2x, 100y); every optimizer must reach near 0
#let g(p) = (2.0 * p.at(0), 100.0 * p.at(1))
#let x0 = (-2.4, 0.85)
#let reaches(path, tol) = calc.abs(path.last().at(0)) < tol and calc.abs(path.last().at(1)) < tol
#ok(reaches(opt.gd(g, x0, lr: 0.014, steps: 120), 0.6), msg: "gd descends")
#ok(reaches(opt.momentum(g, x0, lr: 0.006, steps: 120), 0.3), msg: "momentum descends")
#ok(reaches(opt.nesterov(g, x0, lr: 0.006, steps: 120), 0.3), msg: "nesterov descends")
#ok(reaches(opt.rmsprop(g, x0, lr: 0.05, steps: 120), 0.3), msg: "rmsprop descends")
#ok(reaches(opt.adam(g, x0, lr: 0.16, steps: 120), 0.3), msg: "adam descends")

// path shape: length steps+1, starts at x0
#let p = opt.gd(g, x0, lr: 0.01, steps: 20)
#eq(p.len(), 21, msg: "path has steps+1 points")
#approx-arr(p.first(), x0, msg: "path starts at x0")

// N-dimensional (3-D quadratic) works too
#let g3(v) = v.map(c => 2.0 * c)
#ok(opt.gd(g3, (1.0, -2.0, 3.0), lr: 0.2, steps: 40).last().all(c => calc.abs(c) < 0.05),
  msg: "gd works in 3-D")

// stochastic is reproducible: same seed → identical path
#eq(opt.sgd(g, x0, lr: 0.01, noise: 3.0, seed: 5, steps: 10),
    opt.sgd(g, x0, lr: 0.01, noise: 3.0, seed: 5, steps: 10), msg: "sgd reproducible per seed")

#passed("ml-optim")
