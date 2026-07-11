// theme gallery — the semantic tokens, shown as swatches.
// Compile:  typst compile docs/gallery.typ
#import "@local/theme:0.1.0": default-theme, ramp-color

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)
#let t = default-theme

= theme

Semantic colour roles — override any one and every sibling figure restyles.

#let swatch(name, col) = box(inset: 0pt)[
  #box(width: 22mm, height: 12mm, radius: 3pt, fill: col)
  #v(2pt) #text(size: 9pt, raw(name)) #v(1pt) #text(size: 8pt, fill: rgb("#888"), raw(repr(col)))
]

#grid(columns: 4, gutter: 12pt,
  swatch("ink", t.ink), swatch("muted", t.muted), swatch("bg", t.bg), swatch("paper", t.paper),
  swatch("accent", t.accent), swatch("accent2", t.accent2), swatch("positive", t.positive), swatch("negative", t.negative),
)

#v(10pt)
*Diverging value ramp* (used by heatmaps / grids):
#v(4pt)
#box(stroke: 0.5pt + t.muted)[#grid(columns: 40, rows: 10mm,
  ..range(40).map(i => box(width: 5mm, height: 10mm, fill: ramp-color(i / 39, t.ramp))))]

#v(10pt)
*Multi-series cycle* (line/overlay colours):
#v(4pt)
#grid(columns: t.cycle.len(), gutter: 8pt,
  ..t.cycle.map(c => box(width: 24mm, height: 10mm, radius: 3pt, fill: c)))
