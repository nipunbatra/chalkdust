# dist

**Probability distributions** with exact pdf / log-pdf / nll for Typst — part of
[chalkdust](https://github.com/nipunbatra/chalkdust).

A loss curve becomes the *true* negative log-likelihood of a parameterised distribution,
computed in Typst (Student-t via a Lanczos log-Gamma), not a fudged coefficient.

```typ
#import "@local/dist:0.1.0" as dist
#let g = dist.normal(mu: 0, sigma: 1)
#dist.pdf(g, 0.0)                 // 0.3989…
#dist.nll0(g, r)                  // the true NLL loss shape (min shifted to 0)
#dist.gaussian-2d(sigma: ((2.2, 0), (0, 0.55)))   // a bivariate density f(x,y)
#dist.softmax((1.0, 2.0, 3.0), temperature: 0.5)
```

Distributions: `normal laplace student-t uniform exponential bernoulli categorical`,
plus `gaussian-2d`, `sigmoid`, `softmax` and the accessors `pdf logpdf nll nll0`.
