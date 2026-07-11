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

// ── STATISTICAL QUALITY (these catch the serial-correlation bug a mean/var
//    check misses — a linear LCG hash passes mean≈0.5 yet fails all of these) ──
#let NN = 1500
#let W = range(NN).map(i => rnd.rand(11, i))
#let wm = W.sum() / NN
#let wden = W.map(u => calc.pow(u - wm, 2)).sum()
// lag-1 and lag-2 serial correlation ≈ 0 (the old LCG gave lag-1 ≈ -0.49)
#let lag1 = range(NN - 1).map(i => (W.at(i) - wm) * (W.at(i + 1) - wm)).sum() / wden
#let lag2 = range(NN - 2).map(i => (W.at(i) - wm) * (W.at(i + 2) - wm)).sum() / wden
#ok(calc.abs(lag1) < 0.1, msg: "lag-1 serial correlation ≈ 0")
#ok(calc.abs(lag2) < 0.1, msg: "lag-2 serial correlation ≈ 0")
// χ² uniformity over 10 bins: neither non-uniform (χ² too big) nor a suspiciously
// regular sweep (χ² ≈ 0, as the old LCG gave). For 9 dof, ~9 is ideal.
#let bins = range(10).map(b => W.filter(u => u >= b / 10 and u < (b + 1) / 10).len())
#let chi2 = bins.map(c => calc.pow(c - NN / 10, 2) / (NN / 10)).sum()
#ok(chi2 > 1.0 and chi2 < 21.0, msg: "χ² uniformity in a healthy range (not too regular, not skewed)")
// 2-D independence: the pair (rand 2i, rand 2i+1) used for a scatter point must
// be uncorrelated (the old LCG made these lattice-correlated)
#let PX = range(NN).map(i => rnd.rand(11, 2 * i))
#let PY = range(NN).map(i => rnd.rand(11, 2 * i + 1))
#let pmx = PX.sum() / NN
#let pmy = PY.sum() / NN
#let pcorr = range(NN).map(i => (PX.at(i) - pmx) * (PY.at(i) - pmy)).sum() / calc.sqrt(PX.map(x => calc.pow(x - pmx, 2)).sum() * PY.map(y => calc.pow(y - pmy, 2)).sum())
#ok(calc.abs(pcorr) < 0.1, msg: "consecutive draws are 2-D independent (no lattice)")
// normality of Box–Muller: skew ≈ 0 and excess kurtosis ≈ 0 (the old PRNG gave
// skew ≈ -0.9, excess kurt ≈ 0.7 — the reason the histogram wasn't a bell curve)
#let ZZ = range(2000).map(k => rnd.randn(5, k))
#let zzm = ZZ.sum() / ZZ.len()
#let z2 = ZZ.map(z => calc.pow(z - zzm, 2)).sum() / ZZ.len()
#let z3 = ZZ.map(z => calc.pow(z - zzm, 3)).sum() / ZZ.len()
#let z4 = ZZ.map(z => calc.pow(z - zzm, 4)).sum() / ZZ.len()
#ok(calc.abs(z3 / calc.pow(z2, 1.5)) < 0.2, msg: "randn skewness ≈ 0")
#ok(calc.abs(z4 / (z2 * z2) - 3.0) < 0.3, msg: "randn excess kurtosis ≈ 0 (it IS a bell curve)")

#passed("rand")
