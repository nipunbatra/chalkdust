// dist gallery — exact densities and the losses they imply.
// Compile:  typst compile docs/gallery.typ
#import "@local/dist:0.1.0" as dist
#import "@local/plot:0.1.0": lines

#set page(width: 20cm, height: auto, margin: 1.4cm)
#set text(size: 11pt)

= dist

Exact `pdf` / `log-pdf` / `nll` for standard distributions — so a loss curve is
the *true* negative log-likelihood of a parameterised distribution, not a
coefficient tuned to look right.

#let g = dist.normal(sigma: 1.0)
#let l = dist.laplace(b: 0.8)
#let s = dist.student-t(nu: 2.0)

== the densities
#lines(fn: (x => dist.pdf(g, x), x => dist.pdf(l, x), x => dist.pdf(s, x)),
  domain: (-4, 4), labels: ("Normal", "Laplace", "Student-t"), legend: "tr",
  markers: false, x-label: [x], y-label: [p(x)])

== the loss each density implies — $-log p$, shifted so the minimum is 0
Gaussian → squared error, Laplace → absolute error, Student-t → a robust,
tail-flattening loss. Same maths, one function each.
#lines(fn: (r => dist.nll0(g, r), r => dist.nll0(l, r), r => dist.nll0(s, r)),
  domain: (-3, 3), labels: ("Normal", "Laplace", "Student-t"), legend: "tr",
  markers: false, x-label: [residual r], y-label: [$-log p(r)$])
