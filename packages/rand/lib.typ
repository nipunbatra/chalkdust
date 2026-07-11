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
// Typst has no bitwise ops, so: rotate is arithmetic (shift = ×/÷ by powers of two,
// and the two halves of a rotate are disjoint bits → OR is +), and xor uses a
// precomputed 4-bit nibble table (8 lookups per 32-bit xor). The implementation is
// exact — it reproduces the official Threefry known-answer test (see test-rand).
#let _2p32 = 4294967296
// 4-bit xor table, so a 32-bit xor is 8 table lookups instead of 32 bit tests
#let _XOR4 = range(16).map(a => range(16).map(b => {
  let r = 0; let p = 1; let x = a; let y = b
  for _ in range(4) { if calc.rem(x, 2) != calc.rem(y, 2) { r += p }; x = calc.floor(x / 2); y = calc.floor(y / 2); p = p * 2 }
  r
}))
#let _xor32(a, b) = {
  let r = 0; let p = 1; let x = a; let y = b
  for _ in range(8) { r += _XOR4.at(calc.rem(x, 16)).at(calc.rem(y, 16)) * p; x = calc.floor(x / 16); y = calc.floor(y / 16); p = p * 16 }
  r
}
#let _add32(a, b) = calc.rem(a + b, _2p32)
#let _rotl32(x, k) = calc.rem(x * calc.pow(2, k), _2p32) + calc.floor(x / calc.pow(2, 32 - k))
#let _R32x2 = (13, 15, 26, 6, 17, 29, 16, 24)   // Threefry-2x32 rotation constants
// encrypt counter (c0, c1) under key (k0, k1); returns two 32-bit words
#let threefry2x32(c0, c1, k0, k1) = {
  let ks2 = _xor32(_xor32(466688986, k0), k1)    // 0x1BD11BDA ^ k0 ^ k1 (Skein parity)
  let ks = (k0, k1, ks2)
  let x0 = _add32(c0, k0)
  let x1 = _add32(c1, k1)
  for r in range(20) {
    x0 = _add32(x0, x1)
    x1 = _rotl32(x1, _R32x2.at(calc.rem(r, 8)))
    x1 = _xor32(x1, x0)
    if calc.rem(r, 4) == 3 {                      // inject the key every 4 rounds
      let j = calc.floor(r / 4) + 1
      x0 = _add32(x0, ks.at(calc.rem(j, 3)))
      x1 = _add32(_add32(x1, ks.at(calc.rem(j + 1, 3))), j)
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
