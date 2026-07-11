// bits — assert every op against hand-checked hex values (a wrong shift/table
// entry would fail immediately).
#import "@local/bits:0.1.0" as bits
#import "asserts.typ": passed, eq

// logic ops on 0xF0F0 and 0x00FF
#eq(bits.bxor(61680, 255), 61455, msg: "xor: 0xF0F0 ^ 0x00FF = 0xF00F")
#eq(bits.band(61680, 255), 240, msg: "and: 0xF0F0 & 0x00FF = 0x00F0")
#eq(bits.bor(61680, 255), 61695, msg: "or: 0xF0F0 | 0x00FF = 0xF0FF")
#eq(bits.bxor(123456789, 123456789), 0, msg: "x ^ x = 0")
#eq(bits.bnot(0), 4294967295, msg: "~0 = 0xFFFFFFFF")

// shifts & rotates
#eq(bits.shl(1, 31), 2147483648, msg: "1 << 31")
#eq(bits.shr(2147483648, 31), 1, msg: "0x80000000 >> 31 = 1")
#eq(bits.rotl(2147483649, 1), 3, msg: "rotl(0x80000001, 1) = 3")
#eq(bits.rotr(3, 1), 2147483649, msg: "rotr(3, 1) = 0x80000001")
#eq(bits.rotl(bits.rotr(305419896, 7), 7), 305419896, msg: "rotr then rotl is identity")

// modular 32-bit arithmetic (wraparound) + high product
#eq(bits.add(4294967295, 1), 0, msg: "0xFFFFFFFF + 1 wraps to 0")
#eq(bits.mul(4294967295, 4294967295), 1, msg: "(2^32-1)^2 mod 2^32 = 1")
#eq(bits.mulhi(4294967295, 4294967295), 4294967294, msg: "high 32 bits of (2^32-1)^2 = 0xFFFFFFFE")
#eq(bits.mulhi(65536, 65536), 1, msg: "high 32 bits of 2^16 * 2^16 = 1")

#passed("bits")
