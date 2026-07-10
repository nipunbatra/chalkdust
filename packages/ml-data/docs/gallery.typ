// ml-data gallery — load, pick columns, plot.
// Compile:  typst compile docs/gallery.typ
#import "@local/ml-data:0.1.0" as md
#import "@local/ml-plot:0.1.0" as mp

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= ml-data

Data lives in a file or a computed array — not hand-typed into a figure. Load it
once, pick columns by name, filter/mutate, and hand columns to `ml-plot`.

```typ
#let f = md.frame(csv("runs.csv"))              // header row + data rows
#mp.lines(md.xy(f, "epoch", ("adam", "sgd")))   // plot two named columns
```

#let f = md.frame((
  ("epoch", "adam", "sgd"),
  (1, 2.3, 2.3), (2, 1.1, 1.6), (3, 0.7, 1.2), (4, 0.5, 1.0), (5, 0.42, 0.9),
))

== the frame
#table(columns: f.cols.len(), inset: 6pt, align: center,
  ..f.cols.map(c => text(weight: 700, raw(c))),
  ..f.rows.map(r => f.cols.map(c => [#r.at(c)])).flatten())

== plot named columns straight from it
#mp.lines(md.xy(f, "epoch", ("adam", "sgd")), labels: ("Adam", "SGD"), legend: "tr",
  x-label: [epoch], y-label: [loss], markers: true)

== a computed column (mutate), then a bar chart
#mp.bars(md.bars-of(md.mutate(f, "gap", r => md.num(r.adam) - md.num(r.sgd)), "epoch", "gap"),
  baseline: 0, title: [adam − sgd])
