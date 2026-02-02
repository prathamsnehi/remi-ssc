//
//  MLHelper.swift
//  remi-ssc
//
//  Created by Pratham S on 2/1/26.
//

import CoreML

// MARK: - Math Helpers

/// converts MLMultiArray (Float16 or Float32) to a standard Swift [Float] array
func convertToFloatArray(_ multiArray: MLMultiArray) throws -> [Float] {
    // prepare array container
    let count = multiArray.count
    var array = [Float](repeating: 0, count: count)
    
    // fast pointer access
    // SFace is Float16, but CoreML handles the casting if we ask for Float32 pointer,
    // OR we can iterate safely. The safest generic way that handles both types:
    for i in 0..<count {
        array[i] = multiArray[i].floatValue
    }
    
    return array
}

/// l2 normalization: v = v / ||v||
/// scales the vector so its length is exactly 1.0
func l2Normalize(_ vector: [Float]) -> [Float] {
    // calculate the magnitude (Square Root of sum of squares)
    let sumOfSquares = vector.reduce(0) { $0 + ($1 * $1) }
    let magnitude = sqrt(sumOfSquares)
    
    // avoid division by zero
    let epsilon: Float = 1e-6
    let lowerBound = max(magnitude, epsilon)
    
    // divide each element by the magnitude
    return vector.map { $0 / lowerBound }
}

func cosineSimilarity(_ v1: [Float], _ v2: [Float]) -> Float {
        // Safety check for vector length mismatch
        guard v1.count == v2.count else { return 0.0 }
        
        var dotProduct: Float = 0.0
        
        // Fast loop
        for i in 0..<v1.count {
            dotProduct += v1[i] * v2[i]
        }
        
        return dotProduct
    }
