# ml-theme

Shared design tokens for the ml diagram package family (`tensor-grid`,
`ml-plot`, `nn-arch`, `plate-note`). Colors are semantic roles — `ink`,
`muted`, `accent`, `accent2`, `positive`, `negative`, a diverging `ramp`, a
series `cycle` — plus stroke weights and text-size fractions. Fonts are never
set; figures inherit the document's text settings.

```typst
#import "@local/ml-theme:0.1.0": theme, default-theme

// derive a deck theme once, pass it to any figure in the family
#let metro = theme(
  ink: rgb("#23373B"), accent: rgb("#EB811B"), accent2: rgb("#2C7A7B"),
  ramp: (rgb("#2C7A7B"), rgb("#EFEEEB"), rgb("#EB811B")),
)
```

Also exports the small color utilities the family shares: `ramp-color(t, ramp)`
(oklab multi-stop interpolation), `norm`, `clamp`, `contrast-text`.
