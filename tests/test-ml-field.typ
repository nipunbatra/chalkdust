// ml-field — smoke tests: heatmap / contour / surface render without error
// across their options (they return content, so a bug shows up as a failed
// compile here). Rendered to a scratch page we never look at.
#import "@local/ml-field:0.1.0" as fld
#import "asserts.typ": passed, approx-arr, ok
#set page(width: 22cm, height: auto, margin: 10pt)

// descent: GD on x²+3y² (grad (2x,6y)) from (-2.6,1.6) must march toward 0.
#let path = fld.descent(p => (2.0 * p.at(0), 6.0 * p.at(1)),
  start: (-2.6, 1.6), lr: 0.12, steps: 12)
#ok(path.len() == 13, msg: "descent returns steps+1 points")
#approx-arr(path.first(), (-2.6, 1.6), msg: "descent starts at start")
// after 12 steps x=(-2.6)(0.76)^12, y=(1.6)(0.28)^12 → essentially at the min
#ok(calc.abs(path.last().at(0)) < 0.15 and calc.abs(path.last().at(1)) < 1e-4, msg: "descent converges to 0")
// momentum overshoots the min in y at least once (sign flip) — it's not monotone
#ok(path.at(1).at(1) > 0, msg: "gd first y-step stays positive (no overshoot on this bowl)")

// heatmap: default ramp, custom samples
#fld.heatmap((x, y) => x * x + y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 20)

// contour: auto levels, explicit levels, filled, with a path + marks
#fld.contour((x, y) => x * x + 3 * y * y, xlim: (-3, 3), ylim: (-2, 2), size: (30mm, 24mm))
#fld.contour((x, y) => x * x + y * y, xlim: (-2, 2), ylim: (-2, 2), levels: (0.5, 1.0, 2.0),
  fill: true, paths: (((-1.8, 1.8), (-0.5, 0.4), (0, 0)),), marks: ((0, 0, [min]),), size: (30mm, 30mm))

// contour: several overlaid families (multi-fn) with per-family colours
#let a(x, y) = calc.exp(-((x - 1.0) * (x - 1.0) + y * y))
#let b(x, y) = calc.exp(-(x * x + y * y))
#fld.contour((a, b, (x, y) => a(x, y) * b(x, y)), xlim: (-2, 3), ylim: (-2, 2),
  levels: 3, marks: ((1.0, 0, [mle], orange), (0.5, 0, [map], green)), size: (34mm, 28mm))

// surface: a bowl and a saddle
#fld.surface((x, y) => x * x + y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 16)
#fld.surface((x, y) => x * x - y * y, xlim: (-2, 2), ylim: (-2, 2), samples: 16, title: [saddle])

#passed("ml-field (smoke)")
