// Tiny assertion helpers for the chalkdust test suite.
// A test file that imports these and calls them will FAIL TO COMPILE if any
// assertion is false — so `typst compile tests/test-*.typ` is the test run.

#let eq(a, b, msg: "") = assert(a == b,
  message: "eq FAIL " + msg + ": " + repr(a) + " != " + repr(b))

#let approx(a, b, eps: 1e-6, msg: "") = assert(calc.abs(a - b) < eps,
  message: "approx FAIL " + msg + ": " + repr(a) + " vs " + repr(b) + " (eps " + repr(eps) + ")")

#let approx-arr(a, b, eps: 1e-6, msg: "") = {
  eq(a.len(), b.len(), msg: msg + " (length)")
  for i in range(a.len()) { approx(a.at(i), b.at(i), eps: eps, msg: msg + "[" + str(i) + "]") }
}

#let ok(cond, msg: "") = assert(cond, message: "FAIL " + msg)

// a small banner so a passing test file renders something
#let passed(name) = align(center, text(fill: rgb("#188A42"), weight: 700, name + " ✓"))
