// ml-field gallery — 2-D and 3-D fields of f(x, y).
// Compile:  typst compile docs/gallery.typ
#import "@local/ml-field:0.1.0": *

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= ml-field

Heatmaps, iso-contours, and 3-D surfaces of a function `f(x, y)` — sampled from
the function, so the loss landscape or posterior is the real field, and a descent
path is overlaid in the same coordinates.

== contour — a loss bowl with a gradient-descent path and marked minimum
#contour((x, y) => x * x + 3.0 * y * y, xlim: (-3, 3), ylim: (-2, 2),
  paths: (((-2.6, 1.6), (-1.6, 0.5), (-0.9, 0.16), (-0.4, 0.04), (0, 0)),),
  marks: ((0, 0, [min]),), size: (60mm, 42mm),
  x-label: [$theta_1$], y-label: [$theta_2$])

== heatmap — a 2-D Gaussian density
#heatmap((x, y) => calc.exp(-(x * x + y * y) / 2), xlim: (-3, 3), ylim: (-3, 3), samples: 52)

== surface — a saddle, drawn back-to-front and shaded by height
#surface((x, y) => x * x - y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 24, title: [$x^2 - y^2$])
