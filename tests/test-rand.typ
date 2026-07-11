// rand — the PRNG is pure, so we assert distribution stats, ranges,
// reproducibility, and that shuffle is a permutation.
#import "@local/rand:0.1.0" as rnd
#import "asserts.typ": passed, ok, eq, approx

// reproducible: same (seed, i) → same draw
#eq(rnd.rand(3, 7), rnd.rand(3, 7), msg: "rand is a pure function of (seed, i)")
#ok(rnd.rand(3, 7) != rnd.rand(3, 8), msg: "different index → different draw")

// uniform [0,1): mean ≈ 0.5 over 600 draws, all in range
#let U = range(600).map(i => rnd.rand(11, i))
#approx(U.sum() / U.len(), 0.5, eps: 0.05, msg: "uniform mean ≈ 0.5")
#ok(U.all(u => u >= 0.0 and u < 1.0), msg: "uniform in [0,1)")

// standard normal: mean ≈ 0, variance ≈ 1 over 600 draws
#let Z = range(600).map(k => rnd.randn(11, k))
#let zm = Z.sum() / Z.len()
#approx(zm, 0.0, eps: 0.12, msg: "randn mean ≈ 0")
#approx(Z.fold(0.0, (a, b) => a + calc.pow(b - zm, 2)) / Z.len(), 1.0, eps: 0.15, msg: "randn var ≈ 1")

// randint in [lo, hi)
#let R = range(300).map(i => rnd.randint(4, i, 3, 9))
#ok(R.all(r => r >= 3 and r < 9), msg: "randint in [3,9)")

// bernoulli(0.3): empirical rate ≈ 0.3
#let B = range(600).map(i => rnd.bernoulli(6, i, 0.3))
#approx(B.sum() / B.len(), 0.3, eps: 0.06, msg: "bernoulli rate ≈ p")

// shuffle is a permutation (same multiset), and deterministic per seed
#let base = range(12)
#let s1 = rnd.shuffle(2, base)
#eq(s1.sorted(), base, msg: "shuffle preserves the multiset")
#eq(rnd.shuffle(2, base), s1, msg: "shuffle is deterministic per seed")
#ok(s1 != base, msg: "shuffle actually permutes")

// randnvec length
#eq(rnd.randnvec(1, 0, 5).len(), 5, msg: "randnvec has the requested length")

#passed("rand")
