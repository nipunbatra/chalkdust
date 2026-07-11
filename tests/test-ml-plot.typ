// ml-plot — smoke tests: every input mode and option must render without error
// (bars/lines return content, so a drawing/signature bug shows up as a failed
// compile here). Rendered into a scratch page we never look at.
#import "@local/ml-plot:0.1.0" as mp
#import "asserts.typ": passed
#set page(width: 20cm, height: auto, margin: 10pt)

// bars: distribution via softmax, signed baseline, horizontal + highlight, dict input
#mp.bars((3.0, 1.0, 0.2), labels: ("a", "b", "c"), softmax: true)
#mp.bars((0.1, -0.6, 0.3), baseline: 0)
#mp.bars((147.0, 17.5), labels: ("3x3", "1x1"), horizontal: true, highlight: 1)
#mp.bars((1, 5, 2), labels: ("p", "q", "r"))       // integer values + labels

// lines: fn, multi-fn + legend + dashes, x/y arrays + log, points + droplines,
// series + fill-under + reference lines
#mp.lines(fn: x => x * x, domain: (-2, 2))
#mp.lines(fn: (x => x, x => x * x), domain: (0, 3), legend: "tr",
  labels: ("lin", "quad"), dashes: ("solid", "dashed"))
#mp.lines(x: (1, 2, 3), y: (2.0, 4.0, 8.0), log-y: true)
#mp.lines(y: ((1.0, 2.0, 3.0), (3.0, 2.0, 1.0)), labels: ("up", "down"), legend: "bl")
#mp.lines(((0, 1), (1, 0.5), (2, 0.2)), fill-under: 0,
  hlines: ((0.5, [chance]),), vlines: ((1.0, [t]),), annotations: ((1.5, 0.4, [note]),))
#mp.lines(fn: p => -calc.ln(p), domain: (0.01, 1), markers: false,
  points: ((0.5, -calc.ln(0.5), [half]),))
// two series with per-series markers: a smooth curve + a marked trajectory on it
#mp.lines((range(0, 20).map(i => { let t = i / 5.0; (t, (t - 2) * (t - 2)) }),
  ((0, 4), (1, 1), (2, 0))), markers: (false, true), y-ticks: false)

#passed("ml-plot (smoke)")
