#!/usr/bin/env bash
# Build the GitHub Pages site: render the tensor-grid gallery (the de-facto test
# suite) to SVG and wrap it in a self-contained landing page.
# Assumes the packages are installed on Typst's @local namespace (`just install`).
# Usage: bash scripts/build-site.sh [out-dir]   (default: _site)
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-_site}"
rm -rf "$OUT"; mkdir -p "$OUT"

# Render every gallery page to a crisp vector SVG (gallery-1.svg, gallery-2.svg, …).
typst compile --format svg packages/tensor-grid/docs/gallery.typ "$OUT/gallery-{p}.svg"

# Collect the rendered pages, in numeric order.
imgs=""
for f in $(ls "$OUT"/gallery-*.svg | sort -V); do
  imgs+="      <img src=\"$(basename "$f")\" alt=\"tensor-grid gallery page\" />\n"
done

cat > "$OUT/index.html" <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>typst-ml-diagrams — native ML/DL teaching figures in Typst</title>
<style>
  :root{ --bg:#fdfcf9; --paper:#fff; --ink:#23373b; --muted:#6e7f82;
         --accent:#eb811b; --teal:#2c7a7b; --border:#e6e1d6; }
  *{ box-sizing:border-box; }
  body{ margin:0; background:var(--bg); color:var(--ink);
        font:16px/1.6 "Iowan Old Style","Palatino Linotype",Georgia,serif; }
  .wrap{ max-width:940px; margin:0 auto; padding:56px 22px 80px; }
  header{ border-bottom:2px solid var(--border); padding-bottom:26px; margin-bottom:34px; }
  h1{ font-size:2.5rem; margin:0 0 6px; letter-spacing:-.02em; }
  h1 .dot{ color:var(--accent); }
  .tag{ color:var(--muted); font-size:1.15rem; margin:0; }
  h2{ font-size:1.15rem; text-transform:uppercase; letter-spacing:.08em;
      color:var(--teal); margin:40px 0 14px; }
  ul{ padding-left:1.1em; } li{ margin:.35em 0; }
  code,pre{ font-family:"IBM Plex Mono",ui-monospace,SFMono-Regular,Menlo,monospace; }
  pre{ background:var(--paper); border:1px solid var(--border); border-left:3px solid var(--accent);
       border-radius:6px; padding:14px 16px; overflow-x:auto; font-size:.9rem; }
  .pkgs{ display:grid; grid-template-columns:1fr 1fr; gap:16px; }
  @media(max-width:640px){ .pkgs{ grid-template-columns:1fr; } }
  .pkg{ background:var(--paper); border:1px solid var(--border); border-radius:8px; padding:16px 18px; }
  .pkg b{ font-family:"IBM Plex Mono",monospace; color:var(--accent); }
  .gallery img{ width:100%; height:auto; background:var(--paper); border:1px solid var(--border);
       border-radius:8px; margin:14px 0; box-shadow:0 1px 3px rgba(35,55,59,.06); }
  a{ color:var(--teal); } a:hover{ color:var(--accent); }
  footer{ margin-top:48px; padding-top:20px; border-top:1px solid var(--border);
          color:var(--muted); font-size:.9rem; }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <h1>typst-ml-diagrams<span class="dot">.</span></h1>
    <p class="tag">Native ML/DL teaching figures in Typst — vector, palette-themeable, and
      <em>computed in Typst</em>, so a figure can never disagree with the math on the slide.</p>
  </header>

  <h2>Packages</h2>
  <div class="pkgs">
    <div class="pkg"><b>ml-theme</b><br/>Shared design tokens: semantic colours, diverging ramps, stroke weights.</div>
    <div class="pkg"><b>tensor-grid</b><br/>Convolution arithmetic (animated multiply-add), annotated grids, pooling, receptive-field growth, patchify, and causal / softmaxed attention heatmaps.</div>
  </div>

  <h2>Use it</h2>
  <pre>just install            <span style="color:#6e7f82"># symlink packages into Typst @local</span>
just gallery            <span style="color:#6e7f82"># compile the gallery (the test suite)</span></pre>
  <pre>#import "@local/ml-theme:0.1.0": theme
#import "@local/tensor-grid:0.1.0" as tg
#let mine = tg.conv-op.with(theme: theme(accent: rgb("#eb811b")))
#mine(input: X, kernel: K, step: 4, show-expr: true)</pre>

  <h2>Gallery</h2>
  <div class="gallery">
$(printf "%b" "$imgs")  </div>

  <footer>
    MIT-licensed · built on <a href="https://cetz-package.github.io/">CeTZ</a> ·
    developed alongside <a href="https://github.com/nipunbatra/dl-teaching">ES 667 Deep Learning</a> ·
    <a href="https://github.com/nipunbatra/typst-ml-diagrams">source on GitHub</a>
  </footer>
</div>
</body>
</html>
HTML

echo "built $OUT/ ($(ls "$OUT"/gallery-*.svg | wc -l | tr -d ' ') gallery page(s) + index.html)"
