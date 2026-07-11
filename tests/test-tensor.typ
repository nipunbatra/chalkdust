// tensor — assert shape ops, broadcasting, reductions, and the linalg/rand bridges.
#import "@local/tensor:0.1.0" as nd
#import "asserts.typ": passed, ok, eq, approx, approx-arr

#let A = nd.arr(((1, 2, 3), (4, 5, 6)))          // shape (2, 3)

// shape / construction
#eq(A.shape, (2, 3), msg: "arr infers shape from nesting")
#eq(nd.size(A), 6, msg: "size")
#eq(nd.arange(4).data, (0.0, 1.0, 2.0, 3.0), msg: "arange")
#approx-arr(nd.eye(3).data, (1, 0, 0, 0, 1, 0, 0, 0, 1), msg: "eye")

// reshape / transpose / index
#eq(nd.reshape(A, (3, 2)).shape, (3, 2), msg: "reshape keeps data, changes shape")
#eq(nd.transpose(A).shape, (3, 2), msg: "transpose shape")
#approx-arr(nd.transpose(A).data, (1, 4, 2, 5, 3, 6), msg: "transpose data")
#approx(nd.at(A, 1, 2), 6, msg: "multi-index at(1,2)")
#approx-arr(nd.row(A, 1).data, (4, 5, 6), msg: "row")

// broadcasting: scalar, row vector, column vector
#approx-arr(nd.add(A, 10).data, (11, 12, 13, 14, 15, 16), msg: "scalar broadcast")
#approx-arr(nd.add(A, nd.arr((10, 20, 30))).data, (11, 22, 33, 14, 25, 36), msg: "row-vector broadcast")
#approx-arr(nd.add(A, nd.arr(((10,), (100,)))).data, (11, 12, 13, 104, 105, 106), msg: "column-vector broadcast")
#approx-arr(nd.mul(A, A).data, (1, 4, 9, 16, 25, 36), msg: "elementwise (Hadamard) product")

// reductions (whole tensor and along an axis)
#approx(nd.sum(A), 21, msg: "sum all")
#approx(nd.mean(A), 3.5, msg: "mean all")
#approx(nd.amax(A), 6, msg: "max all")
#approx-arr(nd.sum-axis(A, 0).data, (5, 7, 9), msg: "sum along axis 0 (columns)")
#approx-arr(nd.sum-axis(A, 1).data, (6, 15), msg: "sum along axis 1 (rows)")
#eq(nd.sum-axis(A, 1).shape, (2,), msg: "axis reduction drops the axis")

// 2-D matmul routed through linalg
#approx-arr(nd.matmul(A, nd.transpose(A)).data, (14, 32, 32, 77), msg: "matmul A·Aᵀ (via linalg)")

// random tensors from rand: right shape, ~standard-normal
#eq(nd.randn((3, 4), 1).shape, (3, 4), msg: "randn shape")
#approx(nd.mean(nd.randn((800,), 5)), 0.0, eps: 0.12, msg: "randn ≈ mean 0 (via rand)")

#passed("tensor")
