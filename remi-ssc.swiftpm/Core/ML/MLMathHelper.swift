//
//  MLMathHelper.swift
//  remi-ssc
//
//  Created by Pratham S on 1/20/26.
//

import Accelerate

func getFaceDistance(_ a: [Double], _ b: [Double]) -> Double {
    precondition(a.count == b.count)

    var diff = [Double](repeating: 0, count: a.count)

    // diff = a - b
    vDSP_vsubD(b, 1, a, 1, &diff, 1, vDSP_Length(a.count))

    var sum: Double = 0

    // sum = Σ(diff²)
    vDSP_svesqD(diff, 1, &sum, vDSP_Length(a.count))

    return sqrt(sum)
}
