// ml-dist — standard probability distributions with EXACT pdf / log-pdf.
//
// The point: a teaching loss curve should be the true negative log-likelihood of
// a properly-parameterised distribution, not a coefficient tuned to look right.
// Each constructor returns a dict carrying its (log-)density as a closure, so it
// drops straight into ml-plot:
//
//   #import "@local/ml-dist:0.1.0" as dist
//   #import "@local/ml-plot:0.1.0": lines
//   #let g = dist.normal(sigma: 1.0)
//   #lines(fn: x => g.pdf(x), domain: (-4, 4))          // the density
//   #lines(fn: x => dist.nll0(g, x), domain: (-3, 3))   // the loss (NLL, min at 0)

#let _ln2pi = calc.ln(2 * calc.pi)
#let _NEG-INF = -1e18                       // stands in for −∞ (outside a support)

// Lanczos approximation to log Γ(x) — the normaliser for the Student-t density.
#let _lgamma(x) = {
  let g = 7
  let c = (0.99999999999980993, 676.5203681218851, -1259.1392167224028,
           771.32342877765313, -176.61502916214059, 12.507343278686905,
           -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7)
  if x < 0.5 {
    calc.ln(calc.pi / calc.sin(calc.pi * x)) - _lgamma(1.0 - x)   // reflection
  } else {
    let y = x - 1.0
    let a = c.at(0)
    let tt = y + g + 0.5
    for i in range(1, 9) { a += c.at(i) / (y + i) }
    0.5 * _ln2pi + (y + 0.5) * calc.ln(tt) - tt + calc.ln(a)
  }
}

// ── continuous ──
#let normal(mu: 0.0, sigma: 1.0) = (
  name: "Normal", kind: "continuous", mean: mu, var: sigma * sigma,
  pdf: x => calc.exp(-calc.pow((x - mu) / sigma, 2) / 2) / (sigma * calc.sqrt(2 * calc.pi)),
  logpdf: x => -calc.pow((x - mu) / sigma, 2) / 2 - calc.ln(sigma) - _ln2pi / 2,
)

#let laplace(mu: 0.0, b: 1.0) = (
  name: "Laplace", kind: "continuous", mean: mu, var: 2 * b * b,
  pdf: x => calc.exp(-calc.abs(x - mu) / b) / (2 * b),
  logpdf: x => -calc.abs(x - mu) / b - calc.ln(2 * b),
)

#let student-t(nu: 3.0, mu: 0.0, sigma: 1.0) = (
  name: "Student-t", kind: "continuous", mean: mu,
  logpdf: x => {
    let z = (x - mu) / sigma
    (_lgamma((nu + 1) / 2) - _lgamma(nu / 2) - 0.5 * calc.ln(nu * calc.pi)
      - calc.ln(sigma) - ((nu + 1) / 2) * calc.ln(1 + z * z / nu))
  },
)  // pdf falls back to exp(logpdf) via the top-level pdf() helper below

#let uniform(a: 0.0, b: 1.0) = (
  name: "Uniform", kind: "continuous", mean: (a + b) / 2, var: calc.pow(b - a, 2) / 12,
  pdf: x => if x >= a and x <= b { 1.0 / (b - a) } else { 0.0 },
  logpdf: x => if x >= a and x <= b { -calc.ln(b - a) } else { _NEG-INF },
)

#let exponential(rate: 1.0) = (
  name: "Exponential", kind: "continuous", mean: 1.0 / rate, var: 1.0 / (rate * rate),
  pdf: x => if x >= 0 { rate * calc.exp(-rate * x) } else { 0.0 },
  logpdf: x => if x >= 0 { calc.ln(rate) - rate * x } else { _NEG-INF },
)

// ── discrete ──
#let bernoulli(p: 0.5) = (
  name: "Bernoulli", kind: "discrete", mean: p, var: p * (1 - p),
  pmf: k => if k == 1 { p } else { 1 - p },
  logpmf: k => if k == 1 { calc.ln(p) } else { calc.ln(1 - p) },
)

#let categorical(probs: (0.5, 0.5)) = (
  name: "Categorical", kind: "discrete",
  pmf: k => probs.at(k),
  logpmf: k => calc.ln(probs.at(k)),
)

// ── likelihood helpers (functional accessors — no `(d.pdf)(x)` paren dance) ──
#let logpdf(d, x) = if "logpdf" in d { (d.logpdf)(x) } else { (d.logpmf)(x) }
#let pdf(d, x) = if "pdf" in d { (d.pdf)(x) } else if "pmf" in d { (d.pmf)(x) } else { calc.exp(logpdf(d, x)) }
// negative log-likelihood at x — the loss a model pays for the observation x
#let nll(d, x) = -logpdf(d, x)
// NLL shifted so its minimum sits at 0 — to compare loss SHAPES across models
#let nll0(d, x, at: 0.0) = nll(d, x) - nll(d, at)

// ── common transforms (link functions) ──
#let sigmoid(z) = 1.0 / (1.0 + calc.exp(-z))
#let softmax(zs, temperature: 1.0) = {
  let m = calc.max(..zs)
  let e = zs.map(z => calc.exp((z - m) / temperature))
  let s = e.sum()
  e.map(v => v / s)
}
