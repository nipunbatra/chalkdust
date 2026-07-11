// ml-data — the data-frame: build, select, filter, mutate, group, bridge.
#import "@local/ml-data:0.1.0" as md
#import "asserts.typ": approx, eq, approx-arr, passed
#set page(width: auto, height: auto, margin: 10pt)

// build from an array-of-arrays (first row = header)
#let f = md.frame((("a", "b"), (1, 10), (2, 20), (3, 30)))
#eq(md.nrow(f), 3, msg: "nrow")
#eq(f.cols, ("a", "b"), msg: "cols")
#approx-arr(md.col(f, "a"), (1.0, 2.0, 3.0), msg: "col a (num-coerced)")
#approx-arr(md.col(f, "b"), (10.0, 20.0, 30.0), msg: "col b")

// build from an array of dicts
#let f2 = md.frame(((a: 1, b: 2), (a: 3, b: 4)))
#approx-arr(md.col(f2, "b"), (2.0, 4.0), msg: "frame from dicts")

// num() coerces strings (as csv() yields)
#approx(md.num("2.5"), 2.5, msg: "num parses a string")

// filter
#let big = md.filter(f, r => md.num(r.a) > 1)
#eq(md.nrow(big), 2, msg: "filter keeps a>1")

// mutate: a computed column
#let g = md.mutate(f, "c", r => md.num(r.a) + md.num(r.b))
#approx-arr(md.col(g, "c"), (11.0, 22.0, 33.0), msg: "mutate a+b")

// select
#let s = md.select(g, "a", "c")
#eq(s.cols, ("a", "c"), msg: "select subsets columns")

// group-agg (mean by default)
#let f3 = md.frame((("k", "v"), ("x", 2), ("x", 4), ("y", 9)))
#let ga = md.group-agg(f3, "k", "v")
#eq(md.nrow(ga), 2, msg: "group-agg one row per key")
#approx(ga.rows.at(0).agg, 3.0, msg: "mean of x-group = 3")

// bridge to ml-plot
#let pts = md.xy(f, "a", "b")
#eq(pts.at(0), (1.0, 10.0), msg: "xy single series")
#let multi = md.xy(g, "a", ("b", "c"))
#eq(multi.len(), 2, msg: "xy multi-series count")
#eq(multi.at(1).at(2), (3.0, 33.0), msg: "xy multi-series values")

#let bo = md.bars-of(f, "a", "b")
#eq(bo.at(0), (1, 10.0), msg: "bars-of (label, value)")

#passed("ml-data")
