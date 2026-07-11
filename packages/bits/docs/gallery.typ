// bits gallery — 32-bit bitwise ops from arithmetic. Every example shows its code
// and the live result. Compile: typst compile docs/gallery.typ
#import "@local/bits:0.1.0" as bits

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

#let PRELUDE = "#import \"@local/bits:0.1.0\" as bits"
#let demo(code, ratio: (1.2fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, left + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))
#let hex(n) = "0x" + upper(str(n, base: 16))

= bits

32-bit *bitwise operations* built from integer arithmetic — Typst has no native bit
ops. Shifts and rotates are just multiply/divide by powers of two; `and / or / xor`
use a 4-bit lookup table; `mul / mulhi` chunk into 16 bits to dodge the i64 overflow.
Enough to implement RNGs, hashes and checksums. `#import "@local/bits:0.1.0" as bits`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*32-bit result*]),
  [`shl(x, k)` / `shr(x, k)`], [logical shift left / right],
  [`rotl(x, k)` / `rotr(x, k)`], [rotate (bits wrap around)],
  [`band` / `bor` / `bxor`], [bitwise and / or / xor],
  [`bnot(x)`], [one's complement (`0xFFFFFFFF − x`)],
  [`add(a, b)` / `sub(a, b)`], [modular ± (wraps at $2^32$)],
  [`mul(a, b)`], [`(a·b) mod 2^32`, overflow-free],
  [`mulhi(a, b)`], [the *high* 32 bits of the 64-bit product],
)

== Logic ops (shown in hex)
#demo(```
#let a = 61680     // 0xF0F0
#let b = 255       // 0x00FF
xor = #upper(str(bits.bxor(a, b), base: 16)),
and = #upper(str(bits.band(a, b), base: 16)),
or = #upper(str(bits.bor(a, b), base: 16))
```.text)

== Rotate wraps bits around the word
#demo(```
// 0x80000001 rotated left by 1 → 0x00000003
#bits.rotl(2147483649, 1)
```.text)

== Modular arithmetic wraps at 2³²
#demo(```
#[0xFFFFFFFF + 1 = #bits.add(4294967295, 1) (wraps to 0)]
#linebreak()
#[(2³²−1)² mod 2³² = #bits.mul(4294967295, 4294967295)]
```.text)

== These build the `rand` package's Threefry cipher
`rand` is `bits` in action: Threefry-2x32 is 20 rounds of `add` + `rotl` + `bxor`.
#demo(ratio: (1.4fr, 1fr), ```
// one Threefry round: x0 += x1; x1 = rotl(x1, R); x1 ^= x0
#let (x0, x1) = (305419896, 2596069104)      // some state
#let y0 = bits.add(x0, x1)
#let y1 = bits.bxor(bits.rotl(x1, 13), y0)
#[(#upper(str(y0, base: 16)), #upper(str(y1, base: 16)))]
```.text)
