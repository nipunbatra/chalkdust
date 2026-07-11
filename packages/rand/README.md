# rand

A tiny **seeded, pure PRNG** for Typst — part of [chalkdust](https://github.com/nipunbatra/chalkdust).

Typst has no `Math.random`, and closures can't hold mutable state, so every draw is a pure
function of `(seed, index)`: the same `(seed, i)` always returns the same value. Reproducible
figures, no hidden state. Walk `i = 0, 1, 2, …` for a stream.

```typ
#import "@local/rand:0.1.0" as rnd
#rnd.rand(7, 0)                 // uniform [0,1)
#rnd.randn(7, 0)               // standard normal (Box–Muller)
#rnd.uniform(7, 1, -2, 2)      // uniform in [-2, 2)
#rnd.randint(7, 2, 0, 10)      // integer in [0, 10)
#rnd.bernoulli(7, 3, 0.3)      // 1 with prob 0.3
#rnd.randnvec(7, 4, 2)         // a 2-vector of N(0,1)
#rnd.shuffle(7, range(8))      // a Fisher–Yates permutation
```
