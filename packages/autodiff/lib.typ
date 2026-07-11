// autodiff — reverse-mode automatic differentiation in Typst (micrograd, tiny).
//
// Typst has no operator overloading, so you build a scalar expression out of the
// differentiable primitives below. Each returns an immutable node that remembers
// its value and, for each parent, the LOCAL derivative ∂self/∂parent. `grad` then
// does one reverse pass (chain rule) and returns the exact gradient — no finite
// differences, no mutable state.
//
//   #import "@local/autodiff:0.1.0" as ad
//   #let f(v) = ad.add(ad.sq(v.at(0)), ad.mul(100, ad.sq(v.at(1))))  // x² + 100y²
//   #ad.value(f, (-2.3, 0.45))   // 26.5…   (the loss, e.g. for a contour)
//   #ad.grad(f, (-2.3, 0.45))    // (-4.6, 90.0) exactly   (feed to optim)

// ── nodes ──
// A node: (v: value, kids: ((parent, local-deriv), …), slot: input-index | none)
#let _const(c) = (v: c, kids: (), slot: none)
#let var(i, x) = (v: x, kids: (), slot: i)         // the i-th input variable
#let _lift(a) = if type(a) == dictionary { a } else { _const(a) }   // scalars → constants

// ── differentiable primitives (each records local derivatives) ──
#let add(a, b) = { let (a, b) = (_lift(a), _lift(b)); (v: a.v + b.v, kids: ((a, 1.0), (b, 1.0)), slot: none) }
#let sub(a, b) = { let (a, b) = (_lift(a), _lift(b)); (v: a.v - b.v, kids: ((a, 1.0), (b, -1.0)), slot: none) }
#let mul(a, b) = { let (a, b) = (_lift(a), _lift(b)); (v: a.v * b.v, kids: ((a, b.v), (b, a.v)), slot: none) }
#let div(a, b) = { let (a, b) = (_lift(a), _lift(b))
  (v: a.v / b.v, kids: ((a, 1.0 / b.v), (b, -a.v / (b.v * b.v))), slot: none) }
#let neg(a) = { let a = _lift(a); (v: -a.v, kids: ((a, -1.0),), slot: none) }
#let powc(a, p) = { let a = _lift(a)               // constant real power
  (v: calc.pow(a.v, p), kids: ((a, p * calc.pow(a.v, p - 1.0)),), slot: none) }
#let sq(a) = { let a = _lift(a); (v: a.v * a.v, kids: ((a, 2.0 * a.v),), slot: none) }
#let sqrt(a) = { let a = _lift(a); let s = calc.sqrt(a.v); (v: s, kids: ((a, 0.5 / s),), slot: none) }
#let exp(a) = { let a = _lift(a); let e = calc.exp(a.v); (v: e, kids: ((a, e),), slot: none) }
#let ln(a) = { let a = _lift(a); (v: calc.ln(a.v), kids: ((a, 1.0 / a.v),), slot: none) }
#let sin(a) = { let a = _lift(a); (v: calc.sin(a.v), kids: ((a, calc.cos(a.v)),), slot: none) }
#let cos(a) = { let a = _lift(a); (v: calc.cos(a.v), kids: ((a, -calc.sin(a.v)),), slot: none) }
#let tanh(a) = { let a = _lift(a)
  let e2 = calc.exp(2.0 * a.v); let t = (e2 - 1.0) / (e2 + 1.0)
  (v: t, kids: ((a, 1.0 - t * t),), slot: none) }
#let sigmoid(a) = { let a = _lift(a); let s = 1.0 / (1.0 + calc.exp(-a.v))
  (v: s, kids: ((a, s * (1.0 - s)),), slot: none) }
#let relu(a) = { let a = _lift(a)
  (v: calc.max(a.v, 0.0), kids: ((a, if a.v > 0.0 { 1.0 } else { 0.0 }),), slot: none) }

// sum / dot over arrays of nodes-or-scalars (handy for linear models)
#let sum(xs) = xs.fold(_const(0.0), (a, b) => add(a, b))
#let dot(xs, ys) = sum(xs.zip(ys).map(((x, y)) => mul(x, y)))

// ── the reverse pass ──
// push gradient g down `node`, accumulating into `grads` (one slot per input)
#let _back(node, g, grads) = {
  if node.slot != none { grads.at(node.slot) = grads.at(node.slot) + g; grads }
  else {
    for pair in node.kids { grads = _back(pair.at(0), g * pair.at(1), grads) }
    grads
  }
}

// ── user-facing API ──
// f: (array of nodes) → node.   x: array of scalars (the evaluation point).
#let value(f, x) = (f(x.enumerate().map(((i, xi)) => var(i, xi)))).v
#let grad(f, x) = {
  let out = f(x.enumerate().map(((i, xi)) => var(i, xi)))
  _back(out, 1.0, range(x.len()).map(_ => 0.0))
}
#let value-and-grad(f, x) = {
  let out = f(x.enumerate().map(((i, xi)) => var(i, xi)))
  (out.v, _back(out, 1.0, range(x.len()).map(_ => 0.0)))
}
// adapters: a gradient function for optim, and a plain f(x,y) for a 2-D contour
#let grad-fn(f) = x => grad(f, x)
#let fn2(f) = (x, y) => value(f, (x, y))
