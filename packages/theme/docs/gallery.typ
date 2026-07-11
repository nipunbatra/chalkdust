// theme gallery — the shared design tokens, shown as live swatches.
// Every example shows its CODE and the live output (eval'd from the same source,
// so it can't drift). Compile:  typst compile docs/gallery.typ
#import "@local/theme:0.1.0" as th

#set page(width: 21cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

// ── code + live demo, side by side ──────────────────────────────────────────
#let PRELUDE = "#import \"@local/theme:0.1.0\" as th"
#let demo(code, ratio: (1fr, 1fr)) = block(breakable: false, above: 15pt, below: 4pt, grid(
  columns: ratio, column-gutter: 16pt, align: (left + horizon, center + horizon),
  block(fill: rgb("#f6f5f2"), inset: 9pt, radius: 5pt, width: 100%, stroke: 0.5pt + rgb("#e6e1d6"),
    text(size: 8.5pt, raw(code.trim(), lang: "typ", block: true))),
  block(eval(PRELUDE + "\n" + code.trim(), mode: "markup")),
))

= theme

Shared *design tokens* for the whole diagram-package family. Colors are
*semantic roles* — not raw values — so every sibling package (`plot`, `convgrid`,
`nn-arch`, `plate-note`, …) accepts the same dictionary through a `theme:`
argument. Override one role and every figure restyles at once; fonts are never
set, so figures inherit the document. `#import "@local/theme:0.1.0" as th`

== What's available
#table(columns: 2, stroke: 0.5pt + rgb("#e6e1d6"), inset: (x: 9pt, y: 6pt), align: (left, left),
  table.header([*token / helper*], [*meaning*]),
  [`th.default-theme`], [the built-in token dictionary],
  [`th.theme(..overrides)`], [copy `default-theme`, swap only the named roles],
  [`th.ramp-color(t, ramp)`], [map $t in [0, 1]$ through a color ramp (oklab mix)],
  [`th.norm(v, vmin, vmax)`], [normalise a value to $[0, 1]$ for the ramp],
  [`th.clamp(v, lo, hi)`], [constrain a value into a range],
  [`th.contrast-text(t, theme)`], [ink or paper — whichever reads on a ramp fill],
)
Token fields: semantic colors `ink muted paper bg accent accent2 positive
negative`; a diverging value `ramp`; a multi-series `cycle`; and stroke weights
`grid-stroke frame-stroke window-stroke arrow-stroke`.

== Semantic color roles
Each color names a *job*, not a hue: `ink` for text/strokes, `accent` for the
current/active element, `accent2` for the alternate, `positive` / `negative` for
signed quantities.
#demo(```
#let t = th.default-theme
#let sw(name, col) = box(inset: 0pt)[
  #box(width: 21mm, height: 11mm, radius: 3pt, fill: col)
  #v(2pt) #text(size: 8.5pt, raw(name))
]
#grid(columns: 3, gutter: 9pt,
  sw("ink", t.ink),          sw("muted", t.muted),   sw("accent", t.accent),
  sw("accent2", t.accent2),  sw("positive", t.positive), sw("negative", t.negative),
)
```.text)

== The diverging value ramp — `ramp-color(norm(v, …))`
`ramp` goes low → mid → high (`accent2` → neutral → `accent`). Feed it a value
through `norm` to place it on the strip; `ramp-color` interpolates in oklab.
#demo(```
#let t = th.default-theme
// 30 values across [-1, 1], each placed on the ramp via norm → ramp-color
#box(stroke: 0.5pt + t.muted, grid(columns: 30, rows: 11mm,
  ..range(30).map(i => {
    let v = -1 + 2 * i / 29
    box(width: 100%, height: 11mm, fill: th.ramp-color(th.norm(v, -1, 1), t.ramp))
  })))
```.text)

== Same ramp on 2-D data — a tiny heatmap
Any grid of numbers becomes a heatmap by normalising against its own min/max and
reading `ramp-color`. Here a $5 times 5$ field of $x + y$.
#demo(ratio: (1.15fr, 1fr), ```
#let t = th.default-theme
#let vals = range(5).map(y => range(5).map(x => x + y))
#let (lo, hi) = (0, 8)
#grid(columns: 5, rows: 5, gutter: 1.5pt,
  ..vals.flatten().map(v => box(width: 9mm, height: 9mm, radius: 2pt,
    fill: th.ramp-color(th.norm(v, lo, hi), t.ramp))[
      #set align(center + horizon)
      #text(size: 8pt, fill: th.contrast-text(th.norm(v, lo, hi), t))[#v]
    ]))
```.text)

== The multi-series cycle
`cycle` is the ordered palette for overlaid series — line 0 takes `cycle.at(0)`,
line 1 the next, wrapping when they run out.
#demo(```
#let cyc = th.default-theme.cycle
#grid(columns: cyc.len(), gutter: 7pt,
  ..cyc.enumerate().map(((i, c)) => box[
    #box(width: 22mm, height: 10mm, radius: 3pt, fill: c)
    #v(2pt) #text(size: 8.5pt, fill: rgb("#888"))[series #i]
  ]))
```.text)

== Stroke weights
Weights are roles too: hairline `grid-stroke` for cell edges up to a bold
`window-stroke` for highlights — so line hierarchy stays consistent everywhere.
#demo(ratio: (1.1fr, 1fr), ```
#let t = th.default-theme
#let bar(w, name) = grid(
  columns: (30mm, 1fr), column-gutter: 7pt,
  align: (right + horizon, left + horizon),
  text(size: 8pt, raw(name)), line(length: 100%, stroke: w + t.ink))
#stack(spacing: 7pt,
  bar(t.grid-stroke,   "grid-stroke"),
  bar(t.frame-stroke,  "frame-stroke"),
  bar(t.window-stroke, "window-stroke"),
  bar(t.arrow-stroke,  "arrow-stroke"),
)
```.text)

== A custom theme — one override cascades
`theme(...)` copies `default-theme` and swaps only the roles you name; everything
else is inherited. Hand the result to any sibling package and every figure picks
up the new palette.
#demo(```
// two overrides — a violet accent and a teal alternate
#let mine = th.theme(accent: rgb("#7048E8"), accent2: rgb("#0CA678"))
#let row(t) = grid(columns: 4, gutter: 6pt,
  ..("ink", "accent", "accent2", "positive").map(k =>
    box(width: 18mm, height: 9mm, radius: 3pt, fill: t.at(k))))
#stack(spacing: 6pt,
  text(size: 8.5pt)[*default-theme*],                 row(th.default-theme),
  text(size: 8.5pt)[*theme(accent: violet, accent2: teal)*], row(mine),
)
```.text)
