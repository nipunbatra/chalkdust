# chalkdust — dev tasks

local-pkgs := home_directory() / "Library/Application Support/typst/packages/local"

# symlink all packages into the @local namespace
install:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in theme bits rand autodiff convgrid plot frame linalg tensor dist optim field learn; do
        mkdir -p "{{local-pkgs}}/$p"
        ln -sfn "{{justfile_directory()}}/packages/$p" "{{local-pkgs}}/$p/0.1.0"
    done

# run the assertion tests — a failed assert is a failed compile
test:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in tests/test-*.typ; do echo "· $f"; typst compile "$f" /tmp/chalkdust-test.png >/dev/null; done
    echo "all tests passed"

# compile every package gallery (a smoke test that each figure still renders)
gallery:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in theme bits rand autodiff convgrid plot frame linalg tensor dist optim field learn; do
        echo "· $p"; typst compile "packages/$p/docs/gallery.typ" >/dev/null
    done
    echo "all galleries compiled"

# render galleries to PNG for visual inspection
gallery-png:
    typst compile --format png --ppi 150 packages/convgrid/docs/gallery.typ \
        packages/convgrid/docs/gallery-{p}.png

# compile the dl-teaching demo deck (needs ~/git/dl-teaching)
demo:
    cd ~/git/dl-teaching && typst compile --root . convgrid-demo.typ /tmp/tg-demo.pdf

# at publish time: swap @local imports for @preview in package sources
publish-prep:
    grep -rl '@local/' packages/*/src packages/*/lib.typ 2>/dev/null | \
        xargs sed -i '' 's/@local\//@preview\//g'
