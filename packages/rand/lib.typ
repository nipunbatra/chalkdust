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

// ── core: Threefry-2x32, a real counter-based RNG ──
// rand(seed, i) encrypts the counter i under the key seed with THREEFRY-2x32-20 —
// the Random123 generator (Salmon et al. 2011) that also backs JAX's PRNG, and a
// sibling of numpy's Philox. It's a reduced ARX block cipher: 20 rounds of
// add / rotate / xor. Being counter-based, the same (seed, i) always maps to the
// same value with no hidden state, and it passes the empirical RNG test suites.
//
// Typst has no bitwise ops; the sibling `bits` package supplies xor / rotate / add
// (rotate is arithmetic, xor via a 4-bit table). The implementation is exact — it
// reproduces the official Threefry known-answer test (see test-rand).
#import "@local/bits:0.1.0" as bits
#let _2p32 = 4294967296
#let _R32x2 = (13, 15, 26, 6, 17, 29, 16, 24)   // Threefry-2x32 rotation constants
// encrypt counter (c0, c1) under key (k0, k1); returns two 32-bit words
#let threefry2x32(c0, c1, k0, k1) = {
  let ks2 = bits.bxor(bits.bxor(466688986, k0), k1)   // 0x1BD11BDA ^ k0 ^ k1 (Skein parity)
  let ks = (k0, k1, ks2)
  let x0 = bits.add(c0, k0)
  let x1 = bits.add(c1, k1)
  for r in range(20) {
    x0 = bits.add(x0, x1)
    x1 = bits.rotl(x1, _R32x2.at(calc.rem(r, 8)))
    x1 = bits.bxor(x1, x0)
    if calc.rem(r, 4) == 3 {                      // inject the key every 4 rounds
      let j = calc.floor(r / 4) + 1
      x0 = bits.add(x0, ks.at(calc.rem(j, 3)))
      x1 = bits.add(bits.add(x1, ks.at(calc.rem(j + 1, 3))), j)
    }
  }
  (x0, x1)
}
#let rand(seed, i) = threefry2x32(i, 0, seed, 0).at(0) / _2p32

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
