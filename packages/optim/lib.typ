// optim — small numerical optimization in Typst.
//
// Gradient-based optimizers that RUN in Typst and return the full descent
// trajectory (a list of parameter vectors). The path is the actual iteration,
// so a loss-landscape figure can never disagree with the optimizer on the slide
// — hand the path straight to `field.contour(paths:)`.
//
// Everything is N-dimensional (a parameter is an array of any length); the 2-D
// case is just length-2 vectors, which is what the field plots consume.
//
//   #import "@local/optim:0.1.0" as opt
//   #let grad(p) = (2*p.at(0), 200*p.at(1))          // ∇ of x² + 100y²
//   #let path = opt.momentum(grad, (-2.3, 0.45), lr: 0.0035, steps: 34)
//   // path == ((-2.3, 0.45), (…​), …) — feed to contour(paths: (path,))

#import "@local/rand:0.1.0" as rnd   // seeded PRNG for SGD gradient noise

// ── vector ops (arrays of any length) ──
#let add(a, b) = a.zip(b).map(((x, y)) => x + y)
#let sub(a, b) = a.zip(b).map(((x, y)) => x - y)
#let scale(a, s) = a.map(x => x * s)
#let dot(a, b) = a.zip(b).map(((x, y)) => x * y).sum()
#let norm(a) = calc.sqrt(a.map(x => x * x).sum())

// an n-vector of independent N(0, sigma) gradient noise for step i (seeded)
#let _noise-vec(seed, i, n, sigma) = range(n).map(j => sigma * rnd.randn(seed, i * 97 + j))

// ── finite-difference gradient of a scalar f(vector) ──────────────────────
// numgrad(f) returns a gradient function so you can optimize f without deriving
// ∇f by hand:  minimize(numgrad(f), x0, …).
#let numgrad(f, h: 1e-4) = x => range(x.len()).map(j => {
  let xp = x; xp.at(j) = xp.at(j) + h
  let xm = x; xm.at(j) = xm.at(j) - h
  (f(xp) - f(xm)) / (2.0 * h)
})

// grad2d(f): the gradient of a 2-D loss written as f(x, y) → scalar, as a
// p → (gx, gy) function ready for the optimizers. Write the loss ONCE (it also
// draws the contour) and the descent gradient can never disagree with it.
#let grad2d(f, h: 1e-4) = numgrad(v => f(v.at(0), v.at(1)), h: h)

// ── the unified optimizer ─────────────────────────────────────────────────
// grad: vector → vector.  x0: starting vector.  Returns [x0, x1, …, x_steps].
//   method: "gd" | "momentum" | "nesterov" | "rmsprop" | "adam"
//   noise > 0 adds seeded Gaussian gradient noise → an SGD-style stochastic path.
#let minimize(
  grad, x0, method: "gd", lr: 0.01, steps: 30,
  beta: 0.9, b1: 0.9, b2: 0.999, eps: 1e-8, noise: 0.0, seed: 1,
) = {
  let n = x0.len()
  let x = x0.map(v => v * 1.0)
  let vel = range(n).map(_ => 0.0)   // momentum velocity / rmsprop & adam 2nd moment
  let m = range(n).map(_ => 0.0)     // adam 1st moment
  let path = (x,)
  for i in range(steps) {
    // Nesterov evaluates the gradient at a look-ahead point
    let gp = if method == "nesterov" { add(x, scale(vel, beta)) } else { x }
    let g = grad(gp)
    if noise > 0.0 { g = add(g, _noise-vec(seed, i, n, noise)) }
    if method == "momentum" {
      vel = add(scale(vel, beta), g)
      x = sub(x, scale(vel, lr))
    } else if method == "nesterov" {
      vel = sub(scale(vel, beta), scale(g, lr))
      x = add(x, vel)
    } else if method == "rmsprop" {
      vel = range(n).map(j => beta * vel.at(j) + (1.0 - beta) * g.at(j) * g.at(j))
      x = range(n).map(j => x.at(j) - lr * g.at(j) / (calc.sqrt(vel.at(j)) + eps))
    } else if method == "adam" {
      let t = i + 1
      m = range(n).map(j => b1 * m.at(j) + (1.0 - b1) * g.at(j))
      vel = range(n).map(j => b2 * vel.at(j) + (1.0 - b2) * g.at(j) * g.at(j))
      let bc1 = 1.0 - calc.pow(b1, t)
      let bc2 = 1.0 - calc.pow(b2, t)
      x = range(n).map(j => x.at(j) - lr * (m.at(j) / bc1) / (calc.sqrt(vel.at(j) / bc2) + eps))
    } else {   // gd
      x = sub(x, scale(g, lr))
    }
    path.push(x)
  }
  path
}

// ── named wrappers (read at the call site like the optimizer you mean) ──────
#let gd(grad, x0, ..a) = minimize(grad, x0, method: "gd", ..a)
#let momentum(grad, x0, ..a) = minimize(grad, x0, method: "momentum", ..a)
#let nesterov(grad, x0, ..a) = minimize(grad, x0, method: "nesterov", ..a)
#let rmsprop(grad, x0, ..a) = minimize(grad, x0, method: "rmsprop", ..a)
#let adam(grad, x0, ..a) = minimize(grad, x0, method: "adam", ..a)
// stochastic GD: plain GD with seeded gradient noise
#let sgd(grad, x0, noise: 1.0, ..a) = minimize(grad, x0, method: "gd", noise: noise, ..a)
