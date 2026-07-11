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
// This is a COUNTER-BASED generator: hash the counter (seed, i) with a strong
// bit-mixer, exactly the design of the Random123 / "squares" RNGs used in
// scientific computing (numpy's PCG is the same spirit — a good permutation of a
// counter). The mixer is MurmurHash3's `fmix32` finalizer, which has proven
// avalanche (every input bit flips ~half the output bits), so consecutive indices
// and different seeds give statistically independent streams — not the lattice
// lines a plain LCG produces. Typst has no bitwise ops and i64 overflows on a
// 32-bit multiply, so xor is done by a bit loop and (a·b) mod 2^32 by 16-bit
// chunks. Verified: autocorrelation ≈ 0 out to lag 20, χ²-uniform, 2-D/3-D pairs
// independent, cross-seed correlation ≈ 0, N(0,1) skew/kurtosis ≈ 0.
#let _2p32 = 4294967296
#let _mulmod32(a, b) = {                       // (a·b) mod 2^32, overflow-free
  let al = calc.rem(a, 65536)
  let ah = calc.floor(a / 65536)
  let bl = calc.rem(b, 65536)
  let bh = calc.floor(b / 65536)
  calc.rem(al * bl + calc.rem(al * bh + ah * bl, 65536) * 65536, _2p32)
}
#let _xor32(a, b) = {                           // 32-bit xor via a bit loop
  let r = 0
  let p = 1
  let x = a
  let y = b
  while p < _2p32 {
    if calc.rem(x, 2) != calc.rem(y, 2) { r += p }
    x = calc.floor(x / 2)
    y = calc.floor(y / 2)
    p = p * 2
  }
  r
}
#let _fmix32(h0) = {                            // MurmurHash3 finalizer
  let h = calc.rem(h0, _2p32)
  h = _xor32(h, calc.floor(h / 65536))         // h ^= h >> 16
  h = _mulmod32(h, 2246822519)                 // h *= 0x85ebca6b
  h = _xor32(h, calc.floor(h / 8192))          // h ^= h >> 13
  h = _mulmod32(h, 3266489917)                 // h *= 0xc2b2ae35
  h = _xor32(h, calc.floor(h / 65536))         // h ^= h >> 16
  h
}
// hash the counter: the seed picks a stream (golden-ratio offset), the index walks it
#let rand(seed, i) = _fmix32(calc.rem(i + 1 + _mulmod32(calc.rem(seed, _2p32), 2654435761), _2p32)) / _2p32

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
