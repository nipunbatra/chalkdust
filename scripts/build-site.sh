#!/usr/bin/env bash
# Build the GitHub Pages site for chalkdust: a landing page + one page per package,
# each showing that package's rendered gallery. Modern, responsive, dark-mode aware.
# Assumes the packages are installed on Typst's @local namespace (`just install`).
# Usage: bash scripts/build-site.sh [out-dir]   (default: _site)
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-_site}"
rm -rf "$OUT"; mkdir -p "$OUT"

# Render each gallery to crisp vector SVGs (one per page).
for p in theme bits rand autodiff convgrid plot frame linalg tensor dist optim field learn; do
  typst compile --format svg "packages/$p/docs/gallery.typ" "$OUT/$p-{p}.svg"
done

collect() {  # $1 = prefix → <img> tags for that gallery, in order
  local out=""
  for f in $(ls "$OUT/$1"-*.svg 2>/dev/null | sort -V); do
    out+="        <img src=\"$(basename "$f")\" alt=\"$1 gallery\" loading=\"lazy\" />\n"
  done
  printf "%b" "$out"
}

read -r -d '' HEAD <<'HTML' || true
<!doctype html><html lang="en"><head><meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<style>
 :root{
   --bg:#fbfbf9; --surface:#ffffff; --ink:#17282c; --muted:#5f7377; --faint:#8a9a9d;
   --accent:#2c7a7b; --accent2:#e07b39; --border:#ece9e2; --code:#f6f5f2; --shadow:0 1px 2px rgba(20,40,44,.05),0 6px 22px rgba(20,40,44,.05);
 }
 @media (prefers-color-scheme: dark){ :root{
   --bg:#0d1315; --surface:#141d20; --ink:#e7edee; --muted:#93a6aa; --faint:#6c8286;
   --accent:#4cb6b3; --accent2:#f0965b; --border:#233033; --code:#121b1e; --shadow:0 1px 2px rgba(0,0,0,.3),0 8px 26px rgba(0,0,0,.30);
 }}
 :root[data-theme="light"]{ --bg:#fbfbf9; --surface:#fff; --ink:#17282c; --muted:#5f7377; --faint:#8a9a9d; --accent:#2c7a7b; --accent2:#e07b39; --border:#ece9e2; --code:#f6f5f2; --shadow:0 1px 2px rgba(20,40,44,.05),0 6px 22px rgba(20,40,44,.05); }
 :root[data-theme="dark"]{ --bg:#0d1315; --surface:#141d20; --ink:#e7edee; --muted:#93a6aa; --faint:#6c8286; --accent:#4cb6b3; --accent2:#f0965b; --border:#233033; --code:#121b1e; --shadow:0 1px 2px rgba(0,0,0,.3),0 8px 26px rgba(0,0,0,.30); }
 *{ box-sizing:border-box; } html{ scroll-behavior:smooth; }
 body{ margin:0; background:var(--bg); color:var(--ink); -webkit-font-smoothing:antialiased;
   font:16px/1.65 ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif; }
 code,pre,.mono{ font-family:ui-monospace,"SF Mono","JetBrains Mono","Cascadia Code",Menlo,Consolas,monospace; }
 a{ color:var(--accent); text-decoration:none; } a:hover{ color:var(--accent2); }
 .wrap{ max-width:1000px; margin:0 auto; padding:0 24px; }
 /* nav */
 nav{ position:sticky; top:0; z-index:20; background:color-mix(in srgb,var(--bg) 82%,transparent);
   backdrop-filter:saturate(160%) blur(10px); border-bottom:1px solid var(--border); }
 nav .row{ max-width:1000px; margin:0 auto; padding:11px 24px; display:flex; align-items:center; gap:16px; flex-wrap:wrap; }
 .brand{ font-weight:800; font-size:1.12rem; letter-spacing:-.02em; color:var(--ink); }
 .brand .dot{ color:var(--accent2); }
 .navpk{ display:flex; gap:5px; flex-wrap:wrap; flex:1; }
 .navpk a{ font-size:.8rem; color:var(--muted); padding:3px 8px; border-radius:6px; font-family:ui-monospace,monospace; }
 .navpk a:hover{ background:var(--code); color:var(--ink); }
 .navpk a.here{ background:var(--accent); color:#fff; }
 .ghlink{ font-size:.85rem; color:var(--muted); font-weight:600; white-space:nowrap; }
 .themetoggle{ cursor:pointer; background:none; border:1px solid var(--border); color:var(--muted);
   border-radius:7px; width:30px; height:30px; font-size:.9rem; display:grid; place-items:center; }
 .themetoggle:hover{ color:var(--ink); border-color:var(--accent); }
 /* hero */
 .hero{ padding:72px 0 40px; text-align:center; }
 .hero h1{ font-size:clamp(2.6rem,6vw,4rem); line-height:1.02; letter-spacing:-.035em; margin:0 0 14px; font-weight:850; }
 .hero h1 .dot{ color:var(--accent2); }
 .hero .lede{ font-size:clamp(1.05rem,2.3vw,1.3rem); color:var(--muted); max-width:640px; margin:0 auto 26px; text-wrap:balance; }
 .hero .lede em{ color:var(--ink); font-style:normal; font-weight:600; }
 .stats{ display:flex; gap:10px; justify-content:center; flex-wrap:wrap; margin-bottom:26px; }
 .stat{ background:var(--surface); border:1px solid var(--border); border-radius:10px; padding:9px 16px; box-shadow:var(--shadow); }
 .stat b{ font-size:1.15rem; font-variant-numeric:tabular-nums; } .stat span{ color:var(--muted); font-size:.82rem; margin-left:6px; }
 .install{ display:inline-flex; align-items:center; gap:12px; background:var(--code); border:1px solid var(--border);
   border-radius:10px; padding:11px 16px; font-size:.92rem; color:var(--ink); }
 .install .pfx{ color:var(--accent); } .install .cm{ color:var(--faint); }
 /* section headings */
 h2.sec{ font-size:.82rem; text-transform:uppercase; letter-spacing:.11em; color:var(--accent); font-weight:700;
   margin:52px 0 4px; } .sub{ color:var(--muted); font-size:.95rem; margin:0 0 18px; }
 /* cards */
 .cards{ display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:14px; }
 .card{ background:var(--surface); border:1px solid var(--border); border-radius:13px; padding:18px 18px 16px;
   display:block; box-shadow:var(--shadow); transition:transform .14s ease,border-color .14s ease; }
 .card:hover{ transform:translateY(-3px); border-color:var(--accent); }
 .card .nm{ font-family:ui-monospace,monospace; color:var(--accent); font-weight:700; font-size:1.02rem; }
 .card .uses{ float:right; font-size:.68rem; color:var(--faint); font-family:ui-monospace,monospace; margin-top:3px; }
 .card p{ color:var(--muted); font-size:.9rem; margin:8px 0 0; line-height:1.55; }
 /* code */
 pre{ background:var(--code); border:1px solid var(--border); border-radius:11px; padding:15px 17px; overflow-x:auto; font-size:.86rem; line-height:1.6; margin:14px 0; }
 pre .cm{ color:var(--faint); }
 /* gallery */
 .gallery{ background:var(--surface); border:1px solid var(--border); border-radius:14px; padding:8px; box-shadow:var(--shadow); margin:18px 0; }
 .gallery img{ width:100%; height:auto; display:block; border-radius:8px; }
 .pagehead{ padding:44px 0 8px; } .pageback{ color:var(--muted); font-size:.9rem; }
 .pagehead h1{ font-size:2.5rem; letter-spacing:-.03em; margin:12px 0 6px; font-family:ui-monospace,monospace; }
 .pagehead .tag{ color:var(--muted); font-size:1.08rem; max-width:720px; }
 footer{ margin-top:64px; border-top:1px solid var(--border); }
 footer .row{ max-width:1000px; margin:0 auto; padding:26px 24px 48px; color:var(--muted); font-size:.88rem; display:flex; gap:14px; flex-wrap:wrap; align-items:center; }
 .diagram{ background:var(--code); border:1px solid var(--border); border-radius:11px; padding:16px 18px; overflow-x:auto;
   font-family:ui-monospace,monospace; font-size:.82rem; color:var(--muted); line-height:1.75; white-space:pre; }
 .diagram b{ color:var(--accent); font-weight:600; }
</style>
<script>(function(){var t=localStorage.getItem("cd-theme");if(t)document.documentElement.setAttribute("data-theme",t);})();</script>
HTML

nav() {  # $1 = current page key ("" for index)
  local c="$1"; local links=""
  for p in bits rand autodiff linalg tensor optim dist frame plot field convgrid learn theme; do
    local cls=""; [ "$p" = "$c" ] && cls=" class=\"here\""
    links+="<a href=\"$p.html\"$cls>$p</a>"
  done
  cat <<NAV
<nav><div class="row">
<a href="index.html" class="brand">chalkdust<span class="dot">.</span></a>
<div class="navpk">$links</div>
<a class="ghlink" href="https://github.com/nipunbatra/chalkdust">GitHub&nbsp;↗</a>
<button class="themetoggle" onclick="var d=document.documentElement,n=(d.getAttribute('data-theme')==='dark')?'light':'dark';d.setAttribute('data-theme',n);localStorage.setItem('cd-theme',n);" aria-label="Toggle theme">◑</button>
</div></nav>
NAV
}

read -r -d '' FOOT <<'HTML' || true
<footer><div class="row">
<span>MIT-licensed · native Typst on <a href="https://cetz-package.github.io/">CeTZ</a> + <a href="https://typst.app">Typst</a></span>
<span style="flex:1"></span>
<a href="https://nipunbatra.github.io/dl-teaching">ES 667 Deep Learning</a>
<a href="https://github.com/nipunbatra/chalkdust">source</a>
</div></footer></body></html>
HTML

# card helper: name, "uses" tag, description
card() { printf '   <a class="card" href="%s.html"><span class="uses">%s</span><span class="nm">%s</span><p>%s</p></a>\n' "$1" "$3" "$1" "$2"; }

# ── landing ──
{
  echo "$HEAD<title>chalkdust — a scientific-computing stack for Typst</title></head><body>"
  nav ""
  cat <<'HERO'
<header class="hero"><div class="wrap">
  <h1>chalkdust<span class="dot">.</span></h1>
  <p class="lede">A small <em>scientific-computing stack for Typst</em> — random numbers, autodiff, linear algebra, optimizers, distributions and ML, all <em>computed in Typst</em> so a figure can never disagree with the maths on the slide.</p>
  <div class="stats">
    <div class="stat"><b>13</b><span>packages</span></div>
    <div class="stat"><b>13</b><span>CI-gated tests</span></div>
    <div class="stat"><b>0</b><span>runtime deps</span></div>
    <div class="stat"><b>MIT</b><span>licensed</span></div>
  </div>
  <div class="install"><span class="pfx">just</span> install <span class="cm">&nbsp;# symlink packages into Typst @local</span></div>
</div></header>
<div class="wrap">
HERO
  echo '<h2 class="sec">Foundations</h2><p class="sub">Shared tokens and the bitwise base everything is built on.</p><div class="cards">'
  card theme "Semantic design tokens — colours, a diverging ramp, a series cycle, stroke weights. One override restyles every figure." ""
  card bits "32-bit bitwise ops (shift, rotate, and/or/xor, mul-high) from integer arithmetic — Typst has no native bit ops. The base for RNGs and hashes." ""
  echo '</div>'
  echo '<h2 class="sec">Numerics</h2><p class="sub">The compute core — each pure, seeded and reproducible.</p><div class="cards">'
  card rand "A seeded PRNG — uniform / normal / integer draws, sampling, shuffle. Threefry-2x32 (JAX&#39;s cipher), verified against its known-answer test." "→ bits"
  card autodiff "Reverse-mode automatic differentiation — micrograd in miniature. Write a loss, get the exact gradient in one backward pass. It draws its own graph." "→ theme"
  card linalg "Small dense linear algebra — transpose, matmul, solve / inverse / determinant, and a Jacobi symmetric eigendecomposition. Fit a regression or run PCA." ""
  card tensor "A numpy/torch-lite n-d array — reshape, transpose, elementwise with full broadcasting, axis reductions; matmul via linalg, random via rand." "→ linalg · rand"
  card optim "Gradient descent, momentum, Nesterov, RMSProp &amp; Adam returning the real descent trajectory — gradients by finite differences or exact autodiff." "→ rand"
  card dist "Standard distributions with exact pdf / log-pdf / nll — so a loss curve is the true negative log-likelihood, not a fudged coefficient." ""
  echo '</div>'
  echo '<h2 class="sec">Data &amp; Visualization</h2><p class="sub">Turn the computed numbers into vector figures.</p><div class="cards">'
  card frame "A tiny data-frame — load CSV/arrays, pick columns by name, filter / mutate / group, and hand columns straight to plot." "→ plot"
  card plot "General bar &amp; line plots from a function, columns or points — distributions, gradients, loss curves; legends, reference lines, area fills." "→ theme"
  card field "2-D &amp; 3-D fields of f(x,y) — heatmaps, iso-contours with overlaid descent paths and marked minima, and shaded surfaces." "→ theme"
  card convgrid "Convolution arithmetic, pooling, receptive-field growth, patchify (with masking) and attention heatmaps — all computed in Typst." ""
  echo '</div>'
  echo '<h2 class="sec">Capstone</h2><p class="sub">Classic ML fit in Typst — the stack feeding on itself.</p><div class="cards">'
  card learn "Linear &amp; logistic regression, k-means, k-NN, PCA — fit in a slide. Built on linalg / optim / rand / dist, drawn through plot / field." "→ linalg · optim · rand · dist"
  echo '</div>'
  cat <<'GS'
  <h2 class="sec">Get started</h2><p class="sub">Symlink the packages, then import what you need.</p>
  <pre><span class="cm"># one-time: symlink every package onto Typst's @local namespace</span>
just install

<span class="cm"># then, in any .typ file</span>
#import "@local/learn:0.1.0" as ml
#import "@local/field:0.1.0" as field
#let w = ml.linreg-fit(xs, ys)          <span class="cm">// fit, computed</span>
#field.contour(loss, paths: (path,))    <span class="cm">// draw the real thing</span></pre>
  <h2 class="sec">How the packages fit together</h2><p class="sub">Focused packages that feed on each other.</p>
  <div class="diagram"><b>bits</b> → <b>rand</b> → <b>optim</b> ─┐
<b>linalg</b> ──┬─→ <b>tensor</b>       │
        └────────────────┴─→ <b>learn</b>        (the capstone consumes four)
<b>dist</b> ─────────────────────┘
<b>theme</b> → field · plot · convgrid · autodiff</div>
GS
  echo '</div>'
  echo "$FOOT"
} > "$OUT/index.html"

# ── one page per package ──
pkg_page() {  # $1=key  $2=title  $3=desc  $4=usage-snippet
  {
    echo "$HEAD<title>chalkdust · $1</title></head><body>"
    nav "$1"
    echo "<div class=\"wrap\"><div class=\"pagehead\"><a class=\"pageback\" href=\"index.html\">← all packages</a>"
    echo "<h1>$1</h1><p class=\"tag\">$3</p></div>"
    echo "<h2 class=\"sec\">Use it</h2><pre>$4</pre>"
    echo '<h2 class="sec">Gallery</h2><div class="gallery">'
    collect "$1"
    echo '</div>'
    echo "$FOOT"
  } > "$OUT/$1.html"
}

pkg_page bits "bits" \
  "32-bit bitwise operations for Typst, built from integer arithmetic (Typst has no native bit ops): shifts and rotates via powers of two, and / or / xor via 4-bit lookup tables, one's complement, modular add/sub, and an overflow-safe 32-bit multiply plus multiply-high. Enough to implement counter RNGs, hashes and checksums (Threefry, PCG, Murmur) — rand is built on it." \
  '#import "@local/bits:0.1.0" as bits
#bits.bxor(0xF0F0, 0x00FF)      <span class="cm">// 0xF00F</span>
#bits.rotl(0x80000001, 1)       <span class="cm">// 0x00000003</span>'

pkg_page rand "rand" \
  "A tiny seeded PRNG for Typst — uniform / normal / integer / Bernoulli draws, random vectors, element sampling and Fisher-Yates shuffle. It is Threefry-2x32 (the Random123 cipher that backs JAX's PRNG), implemented exactly against its known-answer test, so every draw is a pure function of (seed, index) and streams are statistically independent." \
  '#import "@local/rand:0.1.0" as rnd
#let cloud = range(400).map(i => rnd.randnvec(7, i, 2))   <span class="cm">// 400 gaussian 2-D points</span>'

pkg_page autodiff "autodiff" \
  "Reverse-mode automatic differentiation in Typst — micrograd in miniature. Build a scalar expression from differentiable primitives (or parse a formula string); one backward pass gives the EXACT gradient — no finite differences. Purely functional, so it plugs straight into optim, and it can draw its own computation graph." \
  '#import "@local/autodiff:0.1.0" as ad
#let f = ad.expr("(w*x + b - y)^2", ("w", "x", "b", "y"))
#ad.grad(f, (2, 3, 1, 10))   <span class="cm">// (-18, -12, -6, 6) exactly</span>'

pkg_page optim "optim" \
  "Small numerical optimization in Typst — gradient descent, momentum, Nesterov, RMSProp and Adam that return the full descent trajectory (N-dimensional, pure, with seeded SGD noise). Gradients come from finite differences (numgrad / grad2d) or exact autodiff. The path is the real iteration, so a loss-landscape figure and the optimizer never disagree." \
  '#import "@local/optim:0.1.0" as opt
#let path = opt.adam(opt.grad2d(loss), (-2, 2), lr: 0.2, steps: 60)
#contour(loss, paths: (path,))   <span class="cm">// feed straight to field.contour</span>'

pkg_page convgrid "convgrid" \
  "Convolution arithmetic (animated multiply-add), annotated grids, pooling, receptive-field growth, patchify (with masking), and attention heatmaps (masks, boxed cells) — all computed in Typst." \
  '#import "@local/convgrid:0.1.0" as cg
#cg.conv-op(input: X, kernel: K, step: 4, show-expr: true)'

pkg_page plot "plot" \
  "General bar &amp; line plots — from a function+domain, x/y columns, or explicit points. Distributions (softmax/temperature), attention weights, signed gradients, loss curves; legends, reference lines, read-off points, area fills." \
  '#import "@local/plot:0.1.0" as plot
#plot.lines(fn: r => 1.0 - 0.5*r*r, domain: (0,1), fill-under: 0)   <span class="cm">// the curve is the maths</span>'

pkg_page frame "frame" \
  "A tiny data-frame for Typst — build one from csv()/json()/arrays, pick columns by name, select / filter / mutate / group, and hand columns straight to plot. So a figure plots the data, not a hand-typed guess." \
  '#import "@local/frame:0.1.0" as fr
#let f = fr.frame(csv("runs.csv"))
#plot.lines(fr.xy(f, "epoch", ("adam", "sgd")), labels: ("Adam", "SGD"))'

pkg_page linalg "linalg" \
  "Small dense linear algebra for Typst — vectors and matrices with transpose, matmul, matrix-vector product, Gaussian-elimination solve / inverse / determinant, norms, and a Jacobi symmetric eigendecomposition. A matrix is a list of rows; enough to fit a regression by the normal equations or run PCA on a covariance in a slide." \
  '#import "@local/linalg:0.1.0" as la
#la.solve(((2, 1), (1, 3)), (3, 5))     <span class="cm">// (0.8, 1.4)</span>
#la.eig-sym(((2, 1), (1, 2)))           <span class="cm">// ((3, 1), eigenvectors)</span>'

pkg_page tensor "tensor" \
  "A numpy / torch-lite n-dimensional array for Typst — a tensor is (data: flat, shape: dims). Reshape, transpose (with an axes permutation), elementwise ops with full numpy broadcasting, whole-tensor and per-axis reductions, multi-index access, 2-D matmul routed through linalg, and random tensors from rand. The shared array primitive." \
  '#import "@local/tensor:0.1.0" as nd
#let A = nd.arr(((1, 2, 3), (4, 5, 6)))       <span class="cm">// shape (2, 3)</span>
#nd.add(A, nd.arr((10, 20, 30)))              <span class="cm">// broadcasts the row vector</span>
#nd.matmul(A, nd.transpose(A))                <span class="cm">// (2,3)·(3,2) via linalg</span>'

pkg_page dist "dist" \
  "Standard probability distributions with exact pdf / log-pdf / nll — Normal, Laplace, Student-t, Uniform, Exponential, Bernoulli, Categorical, plus a bivariate gaussian. A loss curve becomes the true negative log-likelihood of a parameterised distribution, computed in Typst (Student-t via a Lanczos log-Gamma)." \
  '#import "@local/dist:0.1.0" as dist
#let g = dist.normal(sigma: 1.0)
#plot.lines(fn: r => dist.nll0(g, r), domain: (-3, 3))   <span class="cm">// the true NLL loss shape</span>'

pkg_page field "field" \
  "2-D and 3-D plots of a function f(x,y): heatmaps, iso-contours (marching squares) with overlaid gradient-descent paths and marked points, and back-to-front shaded 3-D surfaces. Loss landscapes and posteriors become the real field, not a drawing." \
  '#import "@local/field:0.1.0" as field
#field.contour((x, y) => x*x + 3*y*y, xlim: (-3,3), ylim: (-3,3), marks: ((0,0,[min]),))'

pkg_page learn "learn" \
  "Classic ML algorithms fit in Typst — linear regression (normal equations), logistic regression (gradient descent), k-means, k-nearest-neighbours, and PCA. The capstone of the stack: it builds on linalg, optim, rand and dist, and its results (a fitted line, a decision boundary, a clustering, a principal axis) draw straight through plot and field. Everything is computed, not drawn." \
  '#import "@local/learn:0.1.0" as ml
#ml.linreg-fit((0, 1, 2, 3), (1, 3, 5, 7))   <span class="cm">// (intercept, slope) = (1, 2)</span>
#ml.kmeans(points, 3)                          <span class="cm">// (centroids, assignments)</span>
#ml.pca(data, k: 2)                            <span class="cm">// principal axes + variances</span>'

pkg_page theme "theme" \
  "Shared semantic design tokens — colour roles, a diverging value ramp, a multi-series cycle, and stroke weights. Every sibling package takes a theme dict, so one override restyles every figure." \
  '#import "@local/theme:0.1.0" as th
#let mine = th.theme(ink: rgb("#23373b"), accent: rgb("#eb811b"))'

echo "built $OUT/ (index + 13 package pages; $(ls "$OUT"/*.svg 2>/dev/null | wc -l | tr -d ' ') gallery SVGs)"
