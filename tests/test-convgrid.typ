// convgrid — the computed helpers (conv arithmetic, output size, row softmax).
#import "@local/convgrid:0.1.0" as tg
#import "asserts.typ": approx, eq, approx-arr, passed
#set page(width: auto, height: auto, margin: 10pt)

// ── conv-out-size:  o = floor((n + 2p - d(k-1) - 1)/s) + 1 ──
#eq(tg.conv-out-size(5, 3), 3, msg: "5,k3 -> 3")
#eq(tg.conv-out-size(5, 3, stride: 2), 2, msg: "5,k3,s2 -> 2")
#eq(tg.conv-out-size(5, 3, padding: 1), 5, msg: "5,k3,p1 -> same")
#eq(tg.conv-out-size(7, 3, dilation: 2), 3, msg: "7,k3,d2 -> 3")

// ── conv2d: valid cross-correlation ──
#let X = ((1, 2, 3), (4, 5, 6), (7, 8, 9))
#let K = ((1, 0), (0, 1))
// out[i][j] = sum X[i+a][j+b] K[a][b]
#let Y = tg.conv2d(X, K)
#eq(Y.len(), 2, msg: "conv2d rows")
#eq(Y.at(0).len(), 2, msg: "conv2d cols")
#approx-arr(Y.at(0), (6.0, 8.0), msg: "conv2d row 0")   // 1*1+5*1=6 ; 2*1+6*1=8
#approx-arr(Y.at(1), (12.0, 14.0), msg: "conv2d row 1") // 4*1+8*1=12; 5*1+9*1=14

// an edge kernel on a constant patch gives 0
#let flat = ((2, 2, 2), (2, 2, 2), (2, 2, 2))
#let edge = ((1, 1), (-1, -1))
#approx(tg.conv2d(flat, edge).at(0).at(0), 0.0, msg: "edge kernel on flat = 0")

// ── softmax-rows: each row sums to 1 ──
#let S = tg.softmax-rows(((0, 0), (1, 0)))
#approx-arr(S.at(0), (0.5, 0.5), msg: "softmax-rows equal logits")
#approx(S.at(1).sum(), 1.0, msg: "softmax-rows sums to 1")
#approx(S.at(1).at(0), 0.7310585786300049, msg: "softmax-rows(1,0)[0] = sigmoid(1)")

#passed("convgrid")
