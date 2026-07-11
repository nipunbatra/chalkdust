// bits — 32-bit bitwise operations for Typst, built from integer arithmetic.
//
// Typst has no bitwise operators, but they all reduce to arithmetic on 32-bit words:
//   • shifts / rotates ARE base-2 arithmetic — multiply / divide by powers of two;
//     a rotate's two halves occupy disjoint bit positions, so OR becomes +.
//   • and / or / xor have no arithmetic shortcut, so they use a precomputed 4-bit
//     lookup table (8 table hits per 32-bit op instead of 32 single-bit tests).
//   • the i64 ceiling (2^63) overflows a full 32×32 product, so `mul` and `mulhi`
//     multiply in 16-bit chunks.
// Enough to implement counter RNGs, hashes and checksums (Threefry, PCG, Murmur, …).
//
//   #import "@local/bits:0.1.0" as bits
//   #bits.bxor(0xF0F0, 0x00FF)      // 0xF00F
//   #bits.rotl(0x80000001, 1)       // 0x00000003

#let W = 4294967296              // 2^32
#let mask(x) = calc.rem(x, W)    // keep the low 32 bits (also normalises negatives’ rem)

// ── shifts & rotates (free — powers of two) ──
#let shl(x, k) = calc.rem(x * calc.pow(2, k), W)
#let shr(x, k) = calc.floor(x / calc.pow(2, k))
#let rotl(x, k) = calc.rem(x * calc.pow(2, k), W) + calc.floor(x / calc.pow(2, 32 - k))
#let rotr(x, k) = rotl(x, 32 - k)
#let bnot(x) = W - 1 - calc.rem(x, W)

// ── and / or / xor via 4-bit nibble tables ──
#let _nib(f) = range(16).map(a => range(16).map(b => {
  let r = 0
  let p = 1
  let x = a
  let y = b
  for _ in range(4) {
    if f(calc.rem(x, 2), calc.rem(y, 2)) == 1 { r += p }
    x = calc.floor(x / 2)
    y = calc.floor(y / 2)
    p = p * 2
  }
  r
}))
#let _XOR = _nib((a, b) => if a != b { 1 } else { 0 })
#let _AND = _nib((a, b) => a * b)
#let _OR = _nib((a, b) => if a + b > 0 { 1 } else { 0 })
#let _apply(tbl, a, b) = {
  let r = 0
  let p = 1
  let x = a
  let y = b
  for _ in range(8) {                                 // 8 nibbles = 32 bits
    r += tbl.at(calc.rem(x, 16)).at(calc.rem(y, 16)) * p
    x = calc.floor(x / 16)
    y = calc.floor(y / 16)
    p = p * 16
  }
  r
}
#let bxor(a, b) = _apply(_XOR, a, b)
#let band(a, b) = _apply(_AND, a, b)
#let bor(a, b) = _apply(_OR, a, b)

// ── 32-bit modular arithmetic (overflow-safe) ──
#let add(a, b) = calc.rem(a + b, W)
#let sub(a, b) = calc.rem(a - b + W, W)
#let mul(a, b) = {                                    // (a·b) mod 2^32
  let al = calc.rem(a, 65536)
  let ah = calc.floor(a / 65536)
  let bl = calc.rem(b, 65536)
  let bh = calc.floor(b / 65536)
  calc.rem(al * bl + calc.rem(al * bh + ah * bl, 65536) * 65536, W)
}
#let mulhi(a, b) = {                                  // high 32 bits of the 64-bit product
  let al = calc.rem(a, 65536)
  let ah = calc.floor(a / 65536)
  let bl = calc.rem(b, 65536)
  let bh = calc.floor(b / 65536)
  ah * bh + calc.floor((al * bl + (al * bh + ah * bl) * 65536) / W)
}
