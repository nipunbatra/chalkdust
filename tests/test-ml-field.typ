// ml-field — smoke tests: heatmap / contour / surface render without error
// across their options (they return content, so a bug shows up as a failed
// compile here). Rendered to a scratch page we never look at.
#import "@local/ml-field:0.1.0" as fld
#import "asserts.typ": passed
#set page(width: 22cm, height: auto, margin: 10pt)

// heatmap: default ramp, custom samples
#fld.heatmap((x, y) => x * x + y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 20)

// contour: auto levels, explicit levels, filled, with a path + marks
#fld.contour((x, y) => x * x + 3 * y * y, xlim: (-3, 3), ylim: (-2, 2), size: (30mm, 24mm))
#fld.contour((x, y) => x * x + y * y, xlim: (-2, 2), ylim: (-2, 2), levels: (0.5, 1.0, 2.0),
  fill: true, paths: (((-1.8, 1.8), (-0.5, 0.4), (0, 0)),), marks: ((0, 0, [min]),), size: (30mm, 30mm))

// surface: a bowl and a saddle
#fld.surface((x, y) => x * x + y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 16)
#fld.surface((x, y) => x * x - y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 16, title: [saddle])

#passed("ml-field (smoke)")
