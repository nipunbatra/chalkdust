# field

**2-D and 3-D fields** of a function `f(x, y)` for Typst — part of
[chalkdust](https://github.com/nipunbatra/chalkdust).

Heatmaps, iso-contours (marching squares) with overlaid descent paths and marked points,
and back-to-front shaded 3-D surfaces. Everything is *sampled from the function*, so a loss
landscape or a posterior is the real field, not a drawing — and a descent path (from `optim`)
is overlaid in the same coordinates.

```typ
#import "@local/field:0.1.0": *
#contour((x, y) => x*x + 3*y*y, xlim: (-3, 3), ylim: (-2, 2), marks: ((0, 0, [min]),))
#heatmap((x, y) => calc.exp(-(x*x + y*y)/2), xlim: (-3, 3), ylim: (-3, 3))
#surface((x, y) => x*x - y*y, xlim: (-2, 2), ylim: (-2, 2))
```

`contour` also takes several functions at once (e.g. likelihood × prior → posterior) and
per-family / per-mark colours.
