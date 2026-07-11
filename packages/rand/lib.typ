// rand — a tiny seeded PRNG for Typst.
//
// Typst has no Math.random, and closures can't hold mutable state, so every draw
// is a PURE function of (seed, index): the same (seed, i) always returns the same
// value. That is exactly what reproducible teaching figures want — no hidden state,
// re-render to the identical picture. Walk an index i = 0, 1, 2, … for a stream.
//
//   #import "@local/rand:0.1.0" as rnd
//   #let noise = range(50).map(i => rnd.randn(7, i))     // 50 N(0,1) draws, seed 7
//   #let pts   = range(50).map(i => rnd.randnvec(7, i, 2)) // 50 2-D gaussian points

// ── core hash: (seed, i) → uniform [0, 1) ──
// A purely LINEAR (LCG) hash of the index has strong serial correlation —
// consecutive draws land on lattice lines (bad scatter) and Box–Muller on them
// is not Gaussian. Typst has no bitwise ops, so we break the linearity with a
// NONLINEAR step: square mod a Mersenne prime (2^31-1), interleaved with LCG
// rounds. Squaring keeps x < 2^31 so x*x < 2^62 stays inside i64. Verified:
// lag-1/2 correlation ≈ 0, χ²-uniform, 2-D pairs independent, N(0,1) skew/kurt ≈ 0.
#let _M = 2147483647   // 2^31 - 1, a Mersenne prime
#let rand(seed, i) = {
  let x = calc.rem((calc.rem(i, _M) + 1) * 1103515245 + (calc.rem(seed, _M) + 1) * 12345 + 1, _M)
  x = calc.rem(x * x + 1, _M)                 // nonlinear — breaks LCG lattice structure
  x = calc.rem(x * 1103515245 + 12345, _M)
  x = calc.rem(x * x + 1, _M)                 // nonlinear again
  x = calc.rem(x * 1103515245 + 12345, _M)
  x / _M
}

// ── scalar draws ──
#let uniform(seed, i, lo, hi) = lo + rand(seed, i) * (hi - lo)
#let randint(seed, i, lo, hi) = lo + calc.floor(rand(seed, i) * (hi - lo))
#let bernoulli(seed, i, p) = if rand(seed, i) < p { 1 } else { 0 }
// standard-normal sample k via Box–Muller (two uniforms → one normal)
#let randn(seed, k) = {
  let u1 = calc.max(rand(seed, 2 * k), 1e-9)
  let u2 = rand(seed, 2 * k + 1)
  calc.sqrt(-2.0 * calc.ln(u1)) * calc.cos(2.0 * calc.pi * u2)
}
#let normal(seed, k, mu, sigma) = mu + sigma * randn(seed, k)

// ── vector draws (length n; sub-indexed so streams don't collide) ──
#let randvec(seed, i, n) = range(n).map(j => rand(seed, i * 97 + j))
#let randnvec(seed, k, n) = range(n).map(j => randn(seed, k * 97 + j))

// ── collections ──
#let sample(seed, i, arr) = arr.at(randint(seed, i, 0, arr.len()))
// a shuffled COPY (Fisher–Yates, indices drawn from this PRNG)
#let shuffle(seed, arr) = {
  let a = arr
  let i = a.len() - 1
  while i > 0 {
    let j = randint(seed, 1000 + i, 0, i + 1)
    let tmp = a.at(i)
    a.at(i) = a.at(j)
    a.at(j) = tmp
    i = i - 1
  }
  a
}
