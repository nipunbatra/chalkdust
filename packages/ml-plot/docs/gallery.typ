// ml-plot gallery — one section per component, default theme.
// Compile:  typst compile docs/gallery.typ
#import "@local/ml-plot:0.1.0": *

#set page(width: 22cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= ml-plot gallery

== bars — a distribution via softmax (probabilities computed in Typst)
#bars((3.0, 1.0, 0.2, -0.5), labels: ("the", "cat", "sat", "on"), softmax: true, title: [softmax(z)])

== bars — signed values (baseline 0; negatives take the "negative" role colour)
#bars((0.1, -0.6, 0.3, 0.2), labels: ($p_1$, $p_2$, $p_3$, $p_4$), title: [gradient $p - y$])

== bars — horizontal cost comparison with a highlighted bar
#bars((147.0, 17.5), labels: ("direct 3×3", "1×1 → 3×3"), horizontal: true, highlight: 1, title: [FLOPs (M)])

== lines — receptive-field growth on a log-scaled axis
#lines((2, 4, 8, 16, 32, 64), log-y: true, x-label: [layer], y-label: [RF], title: [dilated stack])

== lines — an annotated function curve with read-off points (droplines)
#lines(
  range(1, 100).map(k => { let p = k / 100; (p, -calc.ln(p)) }),
  markers: false, x-label: [$p_y$], y-label: [$-log p_y$], title: [confident mistakes cost more],
  points: ((0.9, -calc.ln(0.9), [0.9 → 0.11]), (0.1, -calc.ln(0.1), [0.1 → 2.30]), (0.02, -calc.ln(0.02), [0.02 → 3.9])))

== lines — two loss curves with a legend box + dashed series
#lines(
  (((1, 2.3), (2, 1.1), (3, 0.7), (4, 0.5), (5, 0.42)),
   ((1, 2.3), (2, 1.6), (3, 1.2), (4, 1.0), (5, 0.9))),
  labels: ("Adam", "SGD"), dashes: ("solid", "dashed"), legend: "tr",
  x-label: [epoch], y-label: [loss], title: [optimizer race])

== lines — a formula is a one-liner (fn + domain), with an area fill under it
// The curve IS the maths: pass a function, not hand-typed points.
#lines(fn: r => 1.0 - 0.5 * r * r, domain: (0, 1), fill-under: 0, markers: false,
  hlines: ((0.5, [chance]),), x-label: [recall], y-label: [precision], title: [precision = 1 − r²/2])

== lines — several formulas at once (the residual-loss family)
#lines(fn: (r => r * r, r => 1.6 * calc.abs(r), r => 2.2 * calc.ln(1 + r * r)),
  domain: (-3, 3), labels: ("Gaussian", "Laplace", "Student-t"), legend: "tr", markers: false,
  x-label: [residual r], y-label: [$-log p(r)$])
