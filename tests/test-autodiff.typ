// autodiff — gradients are EXACT, so we assert against hand-computed analytics
// (finite-diff would need a tolerance; here eps is tiny).
#import "@local/autodiff:0.1.0" as ad
#import "asserts.typ": passed, approx, approx-arr, eq

// value passes through
#approx(ad.value(v => ad.add(ad.sq(v.at(0)), ad.mul(100, ad.sq(v.at(1)))), (-2.3, 0.45)),
  2.3 * 2.3 + 100 * 0.45 * 0.45, msg: "value = the plain evaluation")

// ∇(x² + 100y²) = (2x, 200y) — exact
#approx-arr(ad.grad(v => ad.add(ad.sq(v.at(0)), ad.mul(100, ad.sq(v.at(1)))), (-2.3, 0.45)),
  (-4.6, 90.0), eps: 1e-9, msg: "quadratic gradient exact")

// product / chain rule: f = sin(x·y) + exp(x)
#let h(v) = ad.add(ad.sin(ad.mul(v.at(0), v.at(1))), ad.exp(v.at(0)))
#approx-arr(ad.grad(h, (0.5, 2.0)),
  (2.0 * calc.cos(1.0) + calc.exp(0.5), 0.5 * calc.cos(1.0)), eps: 1e-9, msg: "chain + product rule")

// a variable used TWICE accumulates both paths: f = x·x → f' = 2x (not x)
#approx-arr(ad.grad(v => ad.mul(v.at(0), v.at(0)), (3.0,)), (6.0,), eps: 1e-9,
  msg: "reused variable sums its paths (2x)")
// f = x·x·x → 3x²
#approx-arr(ad.grad(v => ad.mul(ad.mul(v.at(0), v.at(0)), v.at(0)), (2.0,)), (12.0,), eps: 1e-9,
  msg: "x³ → 3x²")

// activations: exact known derivatives
#approx(ad.grad(v => ad.tanh(v.at(0)), (0.0,)).at(0), 1.0, msg: "tanh'(0) = 1")
#approx(ad.grad(v => ad.sigmoid(v.at(0)), (0.0,)).at(0), 0.25, msg: "sigmoid'(0) = 1/4")
#approx(ad.grad(v => ad.relu(v.at(0)), (2.0,)).at(0), 1.0, msg: "relu'(+) = 1")
#approx(ad.grad(v => ad.relu(v.at(0)), (-2.0,)).at(0), 0.0, msg: "relu'(−) = 0")

// div and ln: f = ln(x) / y → (1/(xy), -ln(x)/y²)
#approx-arr(ad.grad(v => ad.div(ad.ln(v.at(0)), v.at(1)), (2.0, 4.0)),
  (1.0 / (2.0 * 4.0), -calc.ln(2.0) / 16.0), eps: 1e-9, msg: "div + ln")

// dot for a linear model: f(w) = w·x  → ∇_w = x
#approx-arr(ad.grad(w => ad.dot(w, (1.0, -2.0, 3.0)), (0.0, 0.0, 0.0)), (1.0, -2.0, 3.0),
  eps: 1e-9, msg: "∇(w·x) = x")

#passed("autodiff")
