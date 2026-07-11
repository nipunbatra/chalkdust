// frame — a tiny data-frame for Typst.
//
// The maintainability idea: teaching data should live in a FILE (or a computed
// array), not be hand-typed into a figure. Load it once, pick columns by name,
// filter/mutate, and hand columns to plot. The plot then reflects the data —
// it cannot silently disagree with the numbers the way a pasted SVG can.
//
//   #import "@local/frame:0.1.0" as md
//   #import "@local/plot:0.1.0" as mp
//   #let f = md.frame(csv("runs.csv"))            // header row + data rows
//   #mp.lines(md.xy(f, "epoch", ("adam", "sgd")), labels: ("Adam", "SGD"))

// coerce a cell to a number (csv() yields strings; arrays may already be numeric)
#let num(v) = if type(v) in (int, float) { v } else { float(str(v).trim()) }

// Build a frame from:
//   • an array of arrays (rows) — first row is the header unless `header:` is given
//   • the result of Typst's built-in csv(path) (array of string rows)
//   • an array of dictionaries (already keyed by column)
// A frame is `(cols: (name…), rows: (dict-per-row…))`.
#let frame(source, header: auto) = {
  if source.len() == 0 { return (cols: (), rows: ()) }
  if type(source.first()) == dictionary {
    return (cols: source.first().keys(), rows: source)
  }
  let hdr = if header == auto { source.first() } else { header }
  let body = if header == auto { source.slice(1) } else { source }
  (cols: hdr, rows: body.map(r => {
    let d = (:)
    for (i, h) in hdr.enumerate() { d.insert(h, r.at(i)) }
    d
  }))
}

#let nrow(f) = f.rows.len()
#let head(f, n: 5) = (cols: f.cols, rows: f.rows.slice(0, calc.min(n, f.rows.len())))

// a column as an array; `map:` coerces each cell (default num; pass none to keep raw, or str/int)
#let col(f, name, map: num) = f.rows.map(r => if map == none { r.at(name) } else { map(r.at(name)) })

#let filter(f, pred) = (cols: f.cols, rows: f.rows.filter(pred))

#let select(f, ..names) = (cols: names.pos(),
  rows: f.rows.map(r => { let d = (:); for n in names.pos() { d.insert(n, r.at(n)) }; d }))

// add or replace a computed column: mutate(f, "gap", r => num(r.test) - num(r.train))
#let mutate(f, name, fn) = (
  cols: if f.cols.contains(name) { f.cols } else { f.cols + (name,) },
  rows: f.rows.map(r => { let d = r; d.insert(name, fn(r)); d }),
)

// group rows by a column and aggregate another (default: mean)
#let _mean(xs) = xs.sum() / xs.len()
#let group-agg(f, by, value, fn: _mean, name: "agg") = {
  let keys = ()
  for r in f.rows { if not keys.contains(r.at(by)) { keys.push(r.at(by)) } }
  (cols: (by, name), rows: keys.map(k => {
    let vals = f.rows.filter(r => r.at(by) == k).map(r => num(r.at(value)))
    let d = (:); d.insert(by, k); d.insert(name, fn(vals)); d
  }))
}

// ── bridges to plot ──
// (x, y) pairs for lines(); if `y` is an array of names → a list of series (multi)
#let xy(f, x, y) = {
  let xs = col(f, x)
  if type(y) == array { y.map(yc => xs.zip(col(f, yc)).map(((a, b)) => (a, b))) }
  else { xs.zip(col(f, y)).map(((a, b)) => (a, b)) }
}
// (label, value) pairs for bars(): a categorical column + a numeric column
#let bars-of(f, label, value) = f.rows.map(r => (r.at(label), num(r.at(value))))
