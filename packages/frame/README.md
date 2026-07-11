# frame

A tiny **data-frame** for Typst — part of [chalkdust](https://github.com/nipunbatra/chalkdust).

Build one from `csv()` / `json()` / arrays, pick columns by name, `select` / `filter` /
`mutate` / `group-agg`, and hand columns straight to `plot`. So a figure plots the data,
not a hand-typed guess.

```typ
#import "@local/frame:0.1.0" as fr
#import "@local/plot:0.1.0" as plot
#let f = fr.frame(csv("runs.csv"))
#plot.lines(fr.xy(f, "epoch", ("adam", "sgd")), labels: ("Adam", "SGD"))
```
