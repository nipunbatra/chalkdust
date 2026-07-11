#!/usr/bin/env bash
# Build the GitHub Pages site for chalkdust: a landing page + one page per
# package (ml-theme, tensor-grid, ml-plot), each showing that package's gallery.
# Assumes the packages are installed on Typst's @local namespace (`just install`).
# Usage: bash scripts/build-site.sh [out-dir]   (default: _site)
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-_site}"
rm -rf "$OUT"; mkdir -p "$OUT"

# Render each gallery to crisp vector SVGs (one per page).
typst compile --format svg packages/ml-theme/docs/gallery.typ    "$OUT/ml-theme-{p}.svg"
typst compile --format svg packages/tensor-grid/docs/gallery.typ "$OUT/tensor-grid-{p}.svg"
typst compile --format svg packages/ml-plot/docs/gallery.typ     "$OUT/ml-plot-{p}.svg"
typst compile --format svg packages/ml-data/docs/gallery.typ     "$OUT/ml-data-{p}.svg"
typst compile --format svg packages/ml-dist/docs/gallery.typ     "$OUT/ml-dist-{p}.svg"

collect() {  # $1 = prefix → <img> tags for that gallery, in order
  local out=""
  for f in $(ls "$OUT/$1"-*.svg 2>/dev/null | sort -V); do
    out+="      <img src=\"$(basename "$f")\" alt=\"$1 figure\" />\n"
  done
  printf "%b" "$out"
}

HEAD='<!doctype html><html lang="en"><head><meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<style>
 :root{ --bg:#fdfcf9; --paper:#fff; --ink:#23373b; --muted:#6e7f82; --accent:#eb811b; --teal:#2c7a7b; --border:#e6e1d6; }
 *{ box-sizing:border-box; } body{ margin:0; background:var(--bg); color:var(--ink);
   font:16px/1.6 "Iowan Old Style","Palatino Linotype",Georgia,serif; }
 nav{ position:sticky; top:0; background:rgba(253,252,249,.92); backdrop-filter:blur(6px);
   border-bottom:1px solid var(--border); padding:12px 22px; display:flex; gap:20px; align-items:baseline; flex-wrap:wrap; z-index:9; }
 nav .brand{ font-weight:700; font-size:1.1rem; } nav .brand .dot{ color:var(--accent); }
 nav a{ color:var(--muted); text-decoration:none; font-size:.95rem; }
 nav a.here{ color:var(--ink); border-bottom:2px solid var(--accent); }
 nav a:hover{ color:var(--accent); } nav .sp{ flex:1; }
 .wrap{ max-width:940px; margin:0 auto; padding:44px 22px 80px; }
 h1{ font-size:2.4rem; margin:0 0 6px; letter-spacing:-.02em; } h1 .dot{ color:var(--accent); }
 .tag{ color:var(--muted); font-size:1.12rem; margin:0 0 8px; }
 h2{ font-size:1.05rem; text-transform:uppercase; letter-spacing:.08em; color:var(--teal); margin:38px 0 14px; }
 code,pre{ font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace; }
 pre{ background:var(--paper); border:1px solid var(--border); border-left:3px solid var(--accent);
   border-radius:6px; padding:14px 16px; overflow-x:auto; font-size:.9rem; }
 .cards{ display:grid; grid-template-columns:1fr 1fr; gap:16px; } @media(max-width:680px){ .cards{ grid-template-columns:1fr; } }
 .card{ background:var(--paper); border:1px solid var(--border); border-radius:8px; padding:18px; text-decoration:none; color:inherit; display:block; }
 .card:hover{ border-color:var(--accent); } .card b{ font-family:"IBM Plex Mono",monospace; color:var(--accent); font-size:1.05rem; }
 .card p{ color:var(--muted); font-size:.92rem; margin:8px 0 10px; } .card .go{ color:var(--teal); font-size:.9rem; }
 .gallery img{ width:100%; height:auto; background:var(--paper); border:1px solid var(--border);
   border-radius:8px; margin:14px 0; box-shadow:0 1px 3px rgba(35,55,59,.06); }
 a{ color:var(--teal); } a:hover{ color:var(--accent); }
 footer{ margin-top:48px; padding-top:20px; border-top:1px solid var(--border); color:var(--muted); font-size:.9rem; }
</style>'

nav() {  # $1 = current page key (index|tensor-grid|ml-plot|ml-theme)
  local c="$1"; here() { [ "$1" = "$c" ] && echo ' class="here"'; }
  cat <<NAV
<nav><span class="brand"><a href="index.html" style="color:inherit;text-decoration:none">chalkdust<span class="dot">.</span></a></span>
<a href="tensor-grid.html"$(here tensor-grid)>tensor-grid</a>
<a href="ml-plot.html"$(here ml-plot)>ml-plot</a>
<a href="ml-data.html"$(here ml-data)>ml-data</a>
<a href="ml-dist.html"$(here ml-dist)>ml-dist</a>
<a href="ml-theme.html"$(here ml-theme)>ml-theme</a>
<span class="sp"></span>
<a href="https://github.com/nipunbatra/chalkdust">GitHub ↗</a></nav>
NAV
}

FOOT='<footer>MIT-licensed · native Typst on <a href="https://cetz-package.github.io/">CeTZ</a> ·
 built for <a href="https://nipunbatra.github.io/dl-teaching">ES 667 Deep Learning</a> ·
 <a href="https://github.com/nipunbatra/chalkdust">source</a></footer></div></body></html>'

# ── landing ──
{
  echo "$HEAD<title>chalkdust — native ML/DL teaching figures in Typst</title></head><body>"
  nav index
  echo '<div class="wrap"><h1>chalkdust<span class="dot">.</span></h1>
  <p class="tag">Native ML/DL teaching figures in Typst — vector, palette-themeable, and <em>computed in Typst</em>,
   so a figure can never disagree with the math on the slide.</p>
  <h2>Packages</h2><div class="cards">
   <a class="card" href="tensor-grid.html"><b>tensor-grid</b><p>Convolution arithmetic, grids, pooling, receptive fields, patchify, attention heatmaps.</p><span class="go">View gallery →</span></a>
   <a class="card" href="ml-plot.html"><b>ml-plot</b><p>Bar & line plots from a function, columns, or points — distributions, gradients, loss curves.</p><span class="go">View gallery →</span></a>
   <a class="card" href="ml-data.html"><b>ml-data</b><p>A tiny data-frame — load CSV/arrays, pick columns by name, filter/mutate, plot. Data, not guesses.</p><span class="go">View gallery →</span></a>
   <a class="card" href="ml-dist.html"><b>ml-dist</b><p>Standard distributions with exact pdf / log-pdf / nll — so a loss curve is the true negative log-likelihood, not a fudged coefficient.</p><span class="go">View gallery →</span></a>
   <a class="card" href="ml-theme.html"><b>ml-theme</b><p>Shared semantic design tokens — colours, ramps, stroke weights — one override restyles all.</p><span class="go">View gallery →</span></a>
  </div>
  <h2>Use it</h2>
  <pre>just install            <span style="color:#6e7f82"># symlink packages into Typst @local</span></pre>
  <pre>#import "@local/ml-plot:0.1.0": *
#bars((3.0, 1.0, 0.2), labels: ("cat", "dog", "cow"), softmax: true)</pre>'
  echo "$FOOT"
} > "$OUT/index.html"

# ── one page per package ──
pkg_page() {  # $1=key  $2=title  $3=desc  $4=usage-snippet
  {
    echo "$HEAD<title>chalkdust · $1</title></head><body>"
    nav "$1"
    echo "<div class=\"wrap\"><h1>$1</h1><p class=\"tag\">$3</p>"
    echo "<h2>Use it</h2><pre>$4</pre>"
    echo '<h2>Gallery</h2><div class="gallery">'
    collect "$1"
    echo '</div>'
    echo "$FOOT"
  } > "$OUT/$1.html"
}

pkg_page tensor-grid "tensor-grid" \
  "Convolution arithmetic (animated multiply-add), annotated grids, pooling, receptive-field growth, patchify (with masking), and attention heatmaps (masks, boxed cells) — all computed in Typst." \
  '#import "@local/tensor-grid:0.1.0": *
#conv-op(input: X, kernel: K, step: 4, show-expr: true)'

pkg_page ml-plot "ml-plot" \
  "General bar & line plots — from a function+domain, x/y columns, or explicit points. Distributions (softmax/temperature), attention weights, signed gradients, loss curves; legends, reference lines, read-off points, area fills." \
  '#import "@local/ml-plot:0.1.0": *
#lines(fn: r => 1.0 - 0.5*r*r, domain: (0,1), fill-under: 0)   // the curve is the maths'

pkg_page ml-data "ml-data" \
  "A tiny data-frame for Typst — build one from csv()/json()/arrays, pick columns by name, select / filter / mutate / group, and hand columns straight to ml-plot. So a figure plots the data, not a hand-typed guess." \
  '#import "@local/ml-data:0.1.0" as md
#let f = md.frame(csv("runs.csv"))
#mp.lines(md.xy(f, "epoch", ("adam", "sgd")), labels: ("Adam", "SGD"))'

pkg_page ml-dist "ml-dist" \
  "Standard probability distributions with exact pdf / log-pdf / nll — Normal, Laplace, Student-t, Uniform, Exponential, Bernoulli, Categorical. A loss curve becomes the true negative log-likelihood of a parameterised distribution, computed in Typst (Student-t via a Lanczos log-Gamma)." \
  '#import "@local/ml-dist:0.1.0" as dist
#let g = dist.normal(sigma: 1.0)
#lines(fn: r => dist.nll0(g, r), domain: (-3, 3))   // the true NLL loss shape'

pkg_page ml-theme "ml-theme" \
  "Shared semantic design tokens — colour roles, a diverging value ramp, a multi-series cycle, and stroke weights. Every sibling package takes a theme dict, so one override restyles every figure." \
  '#import "@local/ml-theme:0.1.0": theme
#let mine = theme(ink: rgb("#23373b"), accent: rgb("#eb811b"))'

echo "built $OUT/ (index + 3 package pages; $(ls "$OUT"/*.svg 2>/dev/null | wc -l | tr -d ' ') gallery SVGs)"
