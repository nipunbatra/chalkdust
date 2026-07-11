// theme — the numeric token helpers.
#import "@local/theme:0.1.0": default-theme, theme, clamp, norm, ramp-color, contrast-text
#import "asserts.typ": approx, eq, ok, passed
#set page(width: auto, height: auto, margin: 10pt)

#approx(clamp(5, 0, 1), 1.0, msg: "clamp above")
#approx(clamp(-3, 0, 1), 0.0, msg: "clamp below")
#approx(clamp(0.4, 0, 1), 0.4, msg: "clamp inside")

#approx(norm(5, 0, 10), 0.5, msg: "norm midpoint")
#approx(norm(0, 0, 10), 0.0, msg: "norm min")
#approx(norm(3, 3, 3), 0.5, msg: "norm safe when vmin == vmax")
#approx(norm(20, 0, 10), 1.0, msg: "norm clamps above")

#ok(type(ramp-color(0.5, default-theme.ramp)) == color, msg: "ramp-color returns a color")

// theme() override merges without touching the rest
#let t2 = theme(accent: rgb("#123456"))
#eq(t2.accent, rgb("#123456"), msg: "theme override applies")
#eq(t2.ink, default-theme.ink, msg: "theme override leaves other tokens")

#passed("theme")
