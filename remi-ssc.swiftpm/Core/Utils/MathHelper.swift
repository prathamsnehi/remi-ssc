//
//  MathHelper.swift
//  Remi
//
//  Created by Pratham S on 1/17/26.
//

import Accelerate

struct MathHelper {
    static func cosineSimilarity(_ vectorA: [Double], _ vectorB: [Double]) -> Double {
        guard vectorA.count == vectorB.count else { return 0.0 }
        
        let dotProduct = zip(vectorA, vectorB).map(*).reduce(0, +)
        let magnitudeA = sqrt(vectorA.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(vectorB.map { $0 * $0 }.reduce(0, +))
        
        if magnitudeA == 0 || magnitudeB == 0 { return 0.0 }
        
        return dotProduct / (magnitudeA * magnitudeB)
    }
}

