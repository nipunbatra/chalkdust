// linalg — assert against hand-computed results (solve, det, inverse, eig).
#import "@local/linalg:0.1.0" as la
#import "asserts.typ": passed, ok, approx, approx-arr

// matmul / matvec / transpose
#approx-arr(la.matmul(((1, 2), (3, 4)), ((5, 6), (7, 8))).flatten(), (19, 22, 43, 50), msg: "matmul 2x2")
#approx-arr(la.matvec(((1, 2), (3, 4)), (5, 6)), (17, 39), msg: "matrix-vector")
#approx-arr(la.transpose(((1, 2, 3), (4, 5, 6))).flatten(), (1, 4, 2, 5, 3, 6), msg: "transpose")
#approx(la.dot((1, 2, 3), (4, 5, 6)), 32, msg: "dot")

// solve A x = b  (2 known systems)
#approx-arr(la.solve(((2, 1), (1, 3)), (3, 5)), (0.8, 1.4), eps: 1e-9, msg: "solve 2x2")
#approx-arr(la.solve(((1, 1, 1), (0, 2, 5), (2, 5, -1)), (6, -4, 27)), (5, 3, -2), eps: 1e-9, msg: "solve 3x3")

// determinant
#approx(la.det(((1, 2), (3, 4))), -2, msg: "det 2x2")
#approx(la.det(((6, 1, 1), (4, -2, 5), (2, 8, 7))), -306, msg: "det 3x3")
#approx(la.det(la.identity(4)), 1, msg: "det I = 1")

// inverse: A · A⁻¹ = I
#let A = ((4, 7), (2, 6))
#approx-arr(la.matmul(A, la.inv(A)).flatten(), la.identity(2).flatten(), eps: 1e-9, msg: "A · inv(A) = I")

// symmetric eigendecomposition: values, and A v = λ v for the top pair
#let (vals, vecs) = la.eig-sym(((2, 1), (1, 2)))
#approx-arr(vals, (3, 1), eps: 1e-6, msg: "eig values (sorted desc)")
#approx-arr(la.matvec(((2, 1), (1, 2)), vecs.at(0)), la.scale(vecs.at(0), vals.at(0)), eps: 1e-6, msg: "A v = λ v")
#approx(la.norm(vecs.at(0)), 1.0, msg: "eigenvectors are unit length")
// eigenvalues equal the trace/det invariants
#approx(vals.sum(), 4.0, msg: "sum of eigenvalues = trace")

#passed("linalg")
