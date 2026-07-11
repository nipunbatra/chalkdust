// frame gallery — a tiny data-frame: load, pick columns, plot.
// Every example shows the CODE and its live output (the demo is eval'd from the
// same source, so it can't drift). Compile:  typst compile docs/gallery.typ
#import "@local/frame:0.1.0" as fr
#import "@local/plot:0.1.0" as plot

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

// ── code + live demo, side by side ──────────────────────────────────────────
#let PRELUDE = "#import \"@local/frame:0.1.0\" as fr\n#import \"@local/plot:0.1.0\" as plot"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= frame

A tiny *data-frame*: load teaching data from an inline array, a `csv()`, or a list
of dictionaries, pick columns by name, `filter` / `mutate` / `group-agg`, and hand
columns straight to `plot`. The figure then plots the *data* — it cannot silently
disagree with the numbers the way a pasted SVG can. `#import "@local/frame:0.1.0" as fr`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*call*], [*does*]),
  [`fr.frame(src, header: auto)`], [build from rows (first row = header), `csv()`, or dicts],
  [`fr.nrow(f)` · `fr.head(f, n: 5)`], [row count · the first `n` rows as a frame],
  [`fr.col(f, name, map: num)`], [one column as an array (`map` coerces each cell)],
  [`fr.select(f, ..names)`], [keep only the named columns],
  [`fr.filter(f, pred)`], [keep rows where `pred(row-dict)` is true],
  [`fr.mutate(f, name, fn)`], [add / replace a computed column `fn(row-dict)`],
  [`fr.group-agg(f, by, value, fn:, name:)`], [split by a column, aggregate another (default mean)],
  [`fr.xy(f, x, y)`], [$(x, y)$ pairs for `plot.lines` (`y` a list → multi-series)],
  [`fr.bars-of(f, label, value)`], [`(label, value)` pairs for `plot.bars`],
)
Cells arrive from `csv()` as strings; `fr.num(v)` coerces one to a number.

== Build a frame, then `head` / `nrow`
#demo(```
#let f = fr.frame((
  ("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2),
  (4, 0.5, 1.0), (5, 0.42, 0.9),
))
#[*#fr.nrow(f)* rows, columns: #f.cols.join(", ")]
#let h = fr.head(f, n: 3)
#table(columns: h.cols.len(), inset: 5pt, align: center,
  ..h.cols.map(c => text(weight: 700, raw(c))),
  ..h.rows.map(r => h.cols.map(c => [#r.at(c)])).flatten())
```.text)

== Pull one column with `col`
#demo(ratio: (1.3fr, 1fr), ```
#let f = fr.frame((("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2),
  (4, 0.5, 1.0), (5, 0.42, 0.9)))
#let a = fr.col(f, "adam")   // a numeric array
#[adam = #a · final #a.last(), min #calc.min(..a)]
```.text)

== `filter` rows, then `select` columns
#demo(```
#let f = fr.frame((
  ("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2),
  (4, 0.5, 1.0), (5, 0.42, 0.9),
))
// keep the late epochs, then two columns
#let g = fr.select(fr.filter(f, r => r.epoch >= 3), "epoch", "adam")
#table(columns: g.cols.len(), inset: 5pt, align: center,
  ..g.cols.map(c => text(weight: 700, raw(c))),
  ..g.rows.map(r => g.cols.map(c => [#r.at(c)])).flatten())
```.text)

== `mutate` — add a computed column
#demo(```
#let f = fr.frame((
  ("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2),
  (4, 0.5, 1.0), (5, 0.42, 0.9),
))
// gap = sgd − adam, computed per row
#let g = fr.mutate(f, "gap", r => fr.num(r.sgd) - fr.num(r.adam))
#table(columns: g.cols.len(), inset: 5pt, align: center,
  ..g.cols.map(c => text(weight: 700, raw(c))),
  ..g.rows.map(r => g.cols.map(c =>
    [#calc.round(fr.num(r.at(c)), digits: 2)])).flatten())
```.text)

== `group-agg` — split, apply, combine
#demo(```
#let d = fr.frame((
  ("model", "acc"),
  ("cnn", 0.91), ("cnn", 0.89), ("mlp", 0.82),
  ("mlp", 0.80), ("cnn", 0.93),
))
// mean accuracy per model (fn: defaults to mean)
#let m = fr.group-agg(d, "model", "acc")
#table(columns: m.cols.len(), inset: 5pt, align: center,
  ..m.cols.map(c => text(weight: 700, raw(c))),
  ..m.rows.map(r => m.cols.map(c => [#r.at(c)])).flatten())
```.text)

== Plot named columns → `plot.lines` (via `xy`)
#demo(ratio: (1fr, 1.15fr), ```
#let f = fr.frame((
  ("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2),
  (4, 0.5, 1.0), (5, 0.42, 0.9),
))
// y is a list of names → one series each
#plot.lines(fr.xy(f, "epoch", ("adam", "sgd")),
  labels: ("Adam", "SGD"), legend: "tr", markers: true,
  x-label: [epoch], y-label: [loss], size: (74mm, 44mm))
```.text)

== A computed column → `plot.bars` (via `bars-of`)
#demo(ratio: (1fr, 1.1fr), ```
#let f = fr.frame((
  ("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2),
  (4, 0.5, 1.0), (5, 0.42, 0.9),
))
#let g = fr.mutate(f, "gap", r => fr.num(r.sgd) - fr.num(r.adam))
#plot.bars(fr.bars-of(g, "epoch", "gap"),
  baseline: 0, title: [sgd − adam], size: (70mm, 34mm))
```.text)

== `group-agg` straight into a bar chart
#demo(ratio: (1.05fr, 1fr), ```
#let d = fr.frame((
  ("model", "acc"),
  ("cnn", 0.91), ("cnn", 0.89), ("mlp", 0.82),
  ("mlp", 0.80), ("cnn", 0.93),
))
#let m = fr.group-agg(d, "model", "acc")   // cols: (model, agg)
#plot.bars(fr.bars-of(m, "model", "agg"),
  title: [mean accuracy], size: (58mm, 32mm))
```.text)

== A frame from an array of dictionaries
#demo(ratio: (1.1fr, 1fr), ```
// already keyed by column — no header row needed
#let f = fr.frame((
  (city: "Delhi", pop: 32), (city: "Mumbai", pop: 21),
  (city: "Pune", pop: 7), (city: "Surat", pop: 8),
))
#plot.bars(fr.bars-of(f, "city", "pop"),
  title: [population (M)], size: (58mm, 34mm))
```.text)
