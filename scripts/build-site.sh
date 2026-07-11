#!/usr/bin/env bash
# Build the GitHub Pages site for chalkdust: a landing page + one page per
# package (theme, convgrid, plot), each showing that package's gallery.
# Assumes the packages are installed on Typst's @local namespace (`just install`).
# Usage: bash scripts/build-site.sh [out-dir]   (default: _site)
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-_site}"
rm -rf "$OUT"; mkdir -p "$OUT"

# Render each gallery to crisp vector SVGs (one per page).
for p in theme bits rand autodiff convgrid plot frame linalg dist optim field learn; do
  typst compile --format svg "packages/$p/docs/gallery.typ" "$OUT/$p-{p}.svg"
done

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

nav() {  # $1 = current page key (index|convgrid|plot|theme)
  local c="$1"; here() { [ "$1" = "$c" ] && echo ' class="here"'; }
  cat <<NAV
<nav><span class="brand"><a href="index.html" style="color:inherit;text-decoration:none">chalkdust<span class="dot">.</span></a></span>
<a href="rand.html"$(here rand)>rand</a>
<a href="bits.html"$(here bits)>bits</a>
<a href="autodiff.html"$(here autodiff)>autodiff</a>
<a href="optim.html"$(here optim)>optim</a>
<a href="dist.html"$(here dist)>dist</a>
<a href="frame.html"$(here frame)>frame</a>
<a href="linalg.html"$(here linalg)>linalg</a>
<a href="convgrid.html"$(here convgrid)>convgrid</a>
<a href="plot.html"$(here plot)>plot</a>
<a href="field.html"$(here field)>field</a>
<a href="learn.html"$(here learn)>learn</a>
<a href="theme.html"$(here theme)>theme</a>
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
   <a class="card" href="rand.html"><b>rand</b><p>A tiny seeded PRNG — pure uniform / normal / integer draws, random vectors, sampling &amp; shuffle. Reproducible, no hidden state.</p><span class="go">View gallery →</span></a>
   <a class="card" href="bits.html"><b>bits</b><p>32-bit bitwise ops (shift, rotate, and/or/xor, mul-high) built from integer arithmetic — enough to implement RNGs, hashes &amp; checksums.</p><span class="go">View gallery →</span></a>
   <a class="card" href="autodiff.html"><b>autodiff</b><p>Reverse-mode automatic differentiation — micrograd in miniature. Build a scalar expression, get the exact gradient in one backward pass. Drives optim.</p><span class="go">View gallery →</span></a>
   <a class="card" href="optim.html"><b>optim</b><p>Gradient descent, momentum, Nesterov, RMSProp &amp; Adam that return the real descent trajectory — plus finite-difference &amp; autodiff gradients. N-dimensional.</p><span class="go">View gallery →</span></a>
   <a class="card" href="dist.html"><b>dist</b><p>Standard distributions with exact pdf / log-pdf / nll — so a loss curve is the true negative log-likelihood, not a fudged coefficient.</p><span class="go">View gallery →</span></a>
   <a class="card" href="frame.html"><b>frame</b><p>A tiny data-frame — load CSV/arrays, pick columns by name, filter/mutate, plot. Data, not guesses.</p><span class="go">View gallery →</span></a>
   <a class="card" href="linalg.html"><b>linalg</b><p>Small dense linear algebra — transpose, matmul, solve / inverse / determinant, and a Jacobi symmetric eigendecomposition. Fit a regression or run PCA.</p><span class="go">View gallery →</span></a>
   <a class="card" href="convgrid.html"><b>convgrid</b><p>Convolution arithmetic, grids, pooling, receptive fields, patchify, attention heatmaps.</p><span class="go">View gallery →</span></a>
   <a class="card" href="plot.html"><b>plot</b><p>Bar & line plots from a function, columns, or points — distributions, gradients, loss curves.</p><span class="go">View gallery →</span></a>
   <a class="card" href="field.html"><b>field</b><p>2-D & 3-D fields of f(x,y) — heatmaps, iso-contours (with descent paths + marked minima), and surfaces.</p><span class="go">View gallery →</span></a>
   <a class="card" href="learn.html"><b>learn</b><p>Classic ML fit in Typst — linear/logistic regression, k-means, k-NN, PCA. The capstone: built on linalg/optim/rand/dist, drawn through plot/field.</p><span class="go">View gallery →</span></a>
   <a class="card" href="theme.html"><b>theme</b><p>Shared semantic design tokens — colours, ramps, stroke weights — one override restyles all.</p><span class="go">View gallery →</span></a>
  </div>
  <h2>Use it</h2>
  <pre>just install            <span style="color:#6e7f82"># symlink packages into Typst @local</span></pre>
  <pre>#import "@local/plot:0.1.0": *
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

pkg_page bits "bits" \
  "32-bit bitwise operations for Typst, built from integer arithmetic (Typst has no native bit ops): shifts and rotates via powers of two, and / or / xor via 4-bit lookup tables, one's complement, modular add/sub, and an overflow-safe 32-bit multiply plus multiply-high. Enough to implement counter RNGs, hashes and checksums (Threefry, PCG, Murmur) — rand is built on it." \
  '#import "@local/bits:0.1.0" as bits
#bits.bxor(0xF0F0, 0x00FF)      // 0xF00F
#bits.rotl(0x80000001, 1)       // 0x00000003'

pkg_page rand "rand" \
  "A tiny seeded PRNG for Typst — pure, index-based uniform / normal / integer / Bernoulli draws, random vectors, element sampling and Fisher–Yates shuffle. Every draw is a pure function of (seed, index), so figures are reproducible and hold no hidden state." \
  '#import "@local/rand:0.1.0" as rnd
#let cloud = range(400).map(i => rnd.randnvec(7, i, 2))   // 400 gaussian 2-D points'

pkg_page autodiff "autodiff" \
  "Reverse-mode automatic differentiation in Typst — micrograd in miniature. Build a scalar expression from differentiable primitives (add / mul / exp / tanh / relu / …); one backward pass gives the EXACT gradient — no finite differences. Purely functional (immutable graph), so it plugs straight into optim to drive a descent from a loss written once." \
  '#import "@local/autodiff:0.1.0" as ad
#let f(v) = ad.add(ad.sq(v.at(0)), ad.mul(100, ad.sq(v.at(1))))  // x² + 100y²
#ad.grad(f, (-2.3, 0.45))   // (-4.6, 90.0) exactly — feed to optim'

pkg_page optim "optim" \
  "Small numerical optimization in Typst — gradient descent, momentum, Nesterov, RMSProp and Adam that return the full descent trajectory (N-dimensional, pure, with seeded SGD noise). Gradients come from finite differences (numgrad / grad2d) or exact autodiff. The path is the real iteration, so a loss-landscape figure and the optimizer never disagree." \
  '#import "@local/optim:0.1.0" as opt
#let path = opt.adam(opt.grad2d(loss), (-2, 2), lr: 0.2, steps: 60)   // loss written once
#contour(loss, paths: (path,))   // feed straight to field.contour'

pkg_page convgrid "convgrid" \
  "Convolution arithmetic (animated multiply-add), annotated grids, pooling, receptive-field growth, patchify (with masking), and attention heatmaps (masks, boxed cells) — all computed in Typst." \
  '#import "@local/convgrid:0.1.0": *
#conv-op(input: X, kernel: K, step: 4, show-expr: true)'

pkg_page plot "plot" \
  "General bar & line plots — from a function+domain, x/y columns, or explicit points. Distributions (softmax/temperature), attention weights, signed gradients, loss curves; legends, reference lines, read-off points, area fills." \
  '#import "@local/plot:0.1.0": *
#lines(fn: r => 1.0 - 0.5*r*r, domain: (0,1), fill-under: 0)   // the curve is the maths'

pkg_page frame "frame" \
  "A tiny data-frame for Typst — build one from csv()/json()/arrays, pick columns by name, select / filter / mutate / group, and hand columns straight to plot. So a figure plots the data, not a hand-typed guess." \
  '#import "@local/frame:0.1.0" as md
#let f = md.frame(csv("runs.csv"))
#mp.lines(md.xy(f, "epoch", ("adam", "sgd")), labels: ("Adam", "SGD"))'

pkg_page linalg "linalg" \
  "Small dense linear algebra for Typst — vectors and matrices with transpose, matmul, matrix-vector product, Gaussian-elimination solve / inverse / determinant, norms, and a Jacobi symmetric eigendecomposition. A matrix is a list of rows; enough to fit a regression by the normal equations or run PCA on a covariance in a slide." \
  '#import "@local/linalg:0.1.0" as la
#la.solve(((2, 1), (1, 3)), (3, 5))     // (0.8, 1.4)
#la.eig-sym(((2, 1), (1, 2)))           // ((3, 1), eigenvectors)'

pkg_page dist "dist" \
  "Standard probability distributions with exact pdf / log-pdf / nll — Normal, Laplace, Student-t, Uniform, Exponential, Bernoulli, Categorical. A loss curve becomes the true negative log-likelihood of a parameterised distribution, computed in Typst (Student-t via a Lanczos log-Gamma)." \
  '#import "@local/dist:0.1.0" as dist
#let g = dist.normal(sigma: 1.0)
#lines(fn: r => dist.nll0(g, r), domain: (-3, 3))   // the true NLL loss shape'

pkg_page field "field" \
  "2-D and 3-D plots of a function f(x,y): heatmaps, iso-contours (marching squares) with overlaid gradient-descent paths and marked points, and back-to-front shaded 3-D surfaces. Loss landscapes and posteriors become the real field, not a drawing." \
  '#import "@local/field:0.1.0": *
#contour((x, y) => x*x + 3*y*y, xlim: (-3,3), ylim: (-3,3), marks: ((0,0,[min]),))'

pkg_page learn "learn" \
  "Classic ML algorithms fit in Typst — linear regression (normal equations), logistic regression (gradient descent), k-means, k-nearest-neighbours, and PCA. The capstone of the stack: it builds on linalg, optim, rand and dist, and its results (a fitted line, a decision boundary, a clustering, a principal axis) draw straight through plot and field. Everything is computed, not drawn." \
  '#import "@local/learn:0.1.0" as ml
#ml.linreg-fit((0, 1, 2, 3), (1, 3, 5, 7))   // (intercept, slope) = (1, 2)
#ml.kmeans(points, 3)                          // (centroids, assignments)
#ml.pca(data, k: 2)                            // principal axes + variances'

pkg_page theme "theme" \
  "Shared semantic design tokens — colour roles, a diverging value ramp, a multi-series cycle, and stroke weights. Every sibling package takes a theme dict, so one override restyles every figure." \
  '#import "@local/theme:0.1.0": theme
#let mine = theme(ink: rgb("#23373b"), accent: rgb("#eb811b"))'

echo "built $OUT/ (index + 12 package pages; $(ls "$OUT"/*.svg 2>/dev/null | wc -l | tr -d ' ') gallery SVGs)"
