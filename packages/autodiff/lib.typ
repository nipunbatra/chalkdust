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

// ── expr: build the graph from a STRING, since Typst has no operator overloading ──
// Typst's * and + can't be redefined for autodiff nodes, so `x*x` written directly
// can't be traced. Instead parse a formula string into the graph — you write the
// loss ONCE, readably, and still get the exact gradient.
//   #let f = expr("x*x + 100*y*y", ("x", "y"))
//   grad(f, (-2.3, 0.45))   // (-4.6, 90.0) exactly

#let _tokenize(s) = {
  let cs = s.clusters()
  let digits = "0123456789"
  let idstart = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
  let idchar = idstart + digits
  let toks = ()
  let i = 0
  while i < cs.len() {
    let c = cs.at(i)
    if c == " " or c == "\t" { i += 1 }
    else if digits.contains(c) or (c == "." and i + 1 < cs.len() and digits.contains(cs.at(i + 1))) {
      let j = i
      while j < cs.len() and (digits.contains(cs.at(j)) or cs.at(j) == ".") { j += 1 }
      toks.push(("num", float(cs.slice(i, j).join())))
      i = j
    } else if idstart.contains(c) {
      let j = i
      while j < cs.len() and idchar.contains(cs.at(j)) { j += 1 }
      toks.push(("id", cs.slice(i, j).join()))
      i = j
    } else if "+-*/^(),".contains(c) {
      toks.push((c,))
      i += 1
    } else { panic("autodiff.expr: unexpected character '" + c + "'") }
  }
  toks
}
#let _prec(op) = if op == "+" or op == "-" { 1 } else if op == "*" or op == "/" { 2 } else if op == "^" { 3 } else { 0 }
// one self-recursive precedence-climbing parser (Typst has no mutual recursion) →
// returns (ast, next-pos). ast nodes: ("num", v) ("var", n) ("neg", a) ("bin", op, l, r) ("call", name, arg)
#let _parse(toks, pos, min-prec) = {
  let t = toks.at(pos)
  let (left, p) = if t.at(0) == "-" {
    let (a, pp) = _parse(toks, pos + 1, 3); (("neg", a), pp)
  } else if t.at(0) == "num" {
    (("num", t.at(1)), pos + 1)
  } else if t.at(0) == "(" {
    let (inner, pp) = _parse(toks, pos + 1, 0); (inner, pp + 1)   // skip ")"
  } else if t.at(0) == "id" {
    if pos + 1 < toks.len() and toks.at(pos + 1).at(0) == "(" {
      let (arg, pp) = _parse(toks, pos + 2, 0); (("call", t.at(1), arg), pp + 1)
    } else { (("var", t.at(1)), pos + 1) }
  } else { panic("autodiff.expr: parse error near " + repr(t)) }
  let node = left
  let cur = p
  while cur < toks.len() and _prec(toks.at(cur).at(0)) >= min-prec and _prec(toks.at(cur).at(0)) > 0 {
    let op = toks.at(cur).at(0)
    let next-min = if op == "^" { _prec(op) } else { _prec(op) + 1 }   // ^ right-assoc
    let (rhs, pp) = _parse(toks, cur + 1, next-min)
    node = ("bin", op, node, rhs)
    cur = pp
  }
  (node, cur)
}
#let _eval-ast(node, vars, names) = {
  let k = node.at(0)
  if k == "num" { node.at(1) }
  else if k == "var" {
    let idx = names.position(nm => nm == node.at(1))
    if idx == none { panic("autodiff.expr: unknown variable '" + node.at(1) + "'") }
    vars.at(idx)
  }
  else if k == "neg" { neg(_eval-ast(node.at(1), vars, names)) }
  else if k == "bin" {
    let l = _eval-ast(node.at(2), vars, names)
    let r = _eval-ast(node.at(3), vars, names)
    let op = node.at(1)
    if op == "+" { add(l, r) } else if op == "-" { sub(l, r) }
    else if op == "*" { mul(l, r) } else if op == "/" { div(l, r) }
    else if op == "^" { if node.at(3).at(0) == "num" { powc(l, node.at(3).at(1)) } else { exp(mul(r, ln(l))) } }
  }
  else if k == "call" {
    let a = _eval-ast(node.at(2), vars, names)
    let fn = node.at(1)
    if fn == "exp" { exp(a) } else if fn == "ln" or fn == "log" { ln(a) }
    else if fn == "sin" { sin(a) } else if fn == "cos" { cos(a) }
    else if fn == "tanh" { tanh(a) } else if fn == "sigmoid" { sigmoid(a) }
    else if fn == "relu" { relu(a) } else if fn == "sqrt" { sqrt(a) } else if fn == "sq" { sq(a) }
    else { panic("autodiff.expr: unknown function '" + fn + "'") }
  } else { panic("autodiff.expr: bad node " + repr(node)) }
}
// expr(s, names) → an f(nodes) → node, usable with value / grad / grad-fn / fn2.
#let expr(s, names) = {
  let toks = _tokenize(s)
  let (ast, _) = _parse(toks, 0, 0)
  vars => _eval-ast(ast, vars, names)
}
