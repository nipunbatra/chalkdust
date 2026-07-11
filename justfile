# chalkdust — dev tasks

local-pkgs := home_directory() / "Library/Application Support/typst/packages/local"

# symlink all packages into the @local namespace
install:
    mkdir -p "{{local-pkgs}}/ml-theme" "{{local-pkgs}}/tensor-grid" "{{local-pkgs}}/ml-plot" "{{local-pkgs}}/ml-data" "{{local-pkgs}}/ml-dist"
    ln -sfn "{{justfile_directory()}}/packages/ml-theme" "{{local-pkgs}}/ml-theme/0.1.0"
    ln -sfn "{{justfile_directory()}}/packages/tensor-grid" "{{local-pkgs}}/tensor-grid/0.1.0"
    ln -sfn "{{justfile_directory()}}/packages/ml-plot" "{{local-pkgs}}/ml-plot/0.1.0"
    ln -sfn "{{justfile_directory()}}/packages/ml-data" "{{local-pkgs}}/ml-data/0.1.0"
    ln -sfn "{{justfile_directory()}}/packages/ml-dist" "{{local-pkgs}}/ml-dist/0.1.0"

# compile every package gallery (the de-facto test suite)
gallery:
    typst compile packages/ml-theme/docs/gallery.typ
    typst compile packages/tensor-grid/docs/gallery.typ
    typst compile packages/ml-plot/docs/gallery.typ
    typst compile packages/ml-data/docs/gallery.typ
    typst compile packages/ml-dist/docs/gallery.typ

# render galleries to PNG for visual inspection
gallery-png:
    typst compile --format png --ppi 150 packages/tensor-grid/docs/gallery.typ \
        packages/tensor-grid/docs/gallery-{p}.png

# compile the dl-teaching demo deck (needs ~/git/dl-teaching)
demo:
    cd ~/git/dl-teaching && typst compile --root . tensor-grid-demo.typ /tmp/tg-demo.pdf

# at publish time: swap @local imports for @preview in package sources
publish-prep:
    grep -rl '@local/' packages/*/src packages/*/lib.typ 2>/dev/null | \
        xargs sed -i '' 's/@local\//@preview\//g'
