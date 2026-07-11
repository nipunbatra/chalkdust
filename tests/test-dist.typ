// dist — exact density / log-density / nll values.
#import "@local/dist:0.1.0" as dist
#import "asserts.typ": approx, eq, ok, approx-arr, passed
#set page(width: auto, height: auto, margin: 10pt)

// ── Normal(0, 1) ──
#let g = dist.normal(mu: 0.0, sigma: 1.0)
#approx(dist.pdf(g, 0.0), 0.3989422804014327, msg: "N pdf(0) = 1/sqrt(2pi)")
#approx(dist.logpdf(g, 0.0), -0.9189385332046727, msg: "N logpdf(0) = -0.5 ln(2pi)")
#approx(dist.nll0(g, 1.0), 0.5, msg: "N nll0(1) = 1/(2 sigma^2)")
#approx(dist.nll0(g, 2.0), 2.0, msg: "N nll0(2)")
// sigma = 1/sqrt(2) makes the NLL shape exactly r^2
#approx(dist.nll0(dist.normal(sigma: 1.0 / calc.sqrt(2)), 1.5), 1.5 * 1.5, msg: "N(1/sqrt2) nll0 = r^2")

// ── Laplace(0, 1) ──
#let l = dist.laplace(b: 1.0)
#approx(dist.pdf(l, 0.0), 0.5, msg: "Laplace pdf(0) = 1/(2b)")
#approx(dist.logpdf(l, 0.0), -0.6931471805599453, msg: "Laplace logpdf(0) = -ln 2")
#approx(dist.nll0(l, 2.0), 2.0, msg: "Laplace nll0 = |r|/b")

// ── Student-t(nu = 2) ──
#let s = dist.student-t(nu: 2.0)
#approx(dist.pdf(s, 0.0), 0.3535533905932738, eps: 1e-9, msg: "t2 pdf(0)")
#approx(dist.logpdf(s, 0.0), -1.0397207708399179, eps: 1e-9, msg: "t2 logpdf(0)")
// heavier tails than Laplace: at large r the t-loss is BELOW the Laplace loss
#ok(dist.nll0(s, 3.0) < dist.nll0(l, 3.0), msg: "Student-t is more robust than Laplace in the tail")

// ── Uniform(0, 2) ──
#let u = dist.uniform(a: 0.0, b: 2.0)
#approx(dist.pdf(u, 1.0), 0.5, msg: "U pdf inside")
#approx(dist.pdf(u, 3.0), 0.0, msg: "U pdf outside")
#ok(dist.logpdf(u, 5.0) < -1e12, msg: "U logpdf = -inf outside support")

// ── Exponential(rate = 1) ──
#let e = dist.exponential(rate: 1.0)
#approx(dist.pdf(e, 0.0), 1.0, msg: "Exp pdf(0) = rate")
#approx(dist.pdf(e, 1.0), 0.36787944117144233, msg: "Exp pdf(1) = e^-1")

// ── Bernoulli(0.8) ──
#let b = dist.bernoulli(p: 0.8)
#approx(dist.pdf(b, 1), 0.8, msg: "Bern pmf(1)")
#approx(dist.pdf(b, 0), 0.2, msg: "Bern pmf(0)")
#approx(dist.nll(b, 1), 0.2231435513142097, msg: "Bern nll(1) = -ln 0.8")

// ── Categorical ──
#let c = dist.categorical(probs: (0.2, 0.3, 0.5))
#approx(dist.pdf(c, 2), 0.5, msg: "Cat pmf(2)")
#approx(dist.nll(c, 0), 1.6094379124341003, msg: "Cat nll(0) = -ln 0.2")

// ── link functions ──
#approx(dist.sigmoid(0.0), 0.5, msg: "sigmoid(0)")
#ok(dist.sigmoid(20.0) > 0.999999, msg: "sigmoid saturates")
#let sm = dist.softmax((1.0, 2.0, 3.0))
#approx(sm.sum(), 1.0, msg: "softmax sums to 1")
#approx-arr(dist.softmax((0.0, 0.0, 0.0)), (1.0/3, 1.0/3, 1.0/3), msg: "uniform softmax")
// temperature -> 0 sharpens toward argmax
#ok(dist.softmax((1.0, 2.0, 3.0), temperature: 0.1).at(2) > 0.99, msg: "low temperature is peaky")

#passed("dist")
