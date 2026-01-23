//
//  RefAlignment.swift
//  remi-ssc
//
//  Created by Pratham S on 1/23/26.
//

import Foundation
import CoreGraphics
import Accelerate

/// Helper to align faces to the standard ArcFace/MobileFaceNet/MobileNetV3 reference points using a Similarity Transform.
class RefAlignment {
    
    // Standard Reference Points for 112x112 input (InsightFace Standard)
    // Coordinates: [x, y]
    static let referencePoints: [CGPoint] = [
        CGPoint(x: 38.2946, y: 51.6963), // Left Eye
        CGPoint(x: 73.5318, y: 51.5014), // Right Eye
        CGPoint(x: 56.0252, y: 71.7366), // Nose
        CGPoint(x: 41.5493, y: 92.3655), // Left Mouth
        CGPoint(x: 70.7299, y: 92.2041)  // Right Mouth
    ]
    
    /// Computes the similarity transform (scale, rotation, translation) to map detected landmarks to reference landmarks.
    /// Uses Least Squares (Umeyama optimization for 2D).
    static func estimateSimilarityTransform(from source: [CGPoint]) -> CGAffineTransform {
        guard source.count == 5 else {
            print("❌ [RefAlignment] Need exactly 5 source points")
            return .identity
        }
        
        let dest = referencePoints
        
        // Compute Means
        var srcMean = CGPoint.zero
        var dstMean = CGPoint.zero
        for i in 0..<5 {
            srcMean.x += source[i].x
            srcMean.y += source[i].y
            dstMean.x += dest[i].x
            dstMean.y += dest[i].y
        }
        srcMean.x /= 5.0; srcMean.y /= 5.0
        dstMean.x /= 5.0; dstMean.y /= 5.0
        
        // Compute variance and covariance
        var srcVar: Double = 0
        var matrix: [Double] = [0, 0, 0, 0] // 2x2 Accumulator
        
        for i in 0..<5 {
            let srcX = Double(source[i].x - srcMean.x)
            let srcY = Double(source[i].y - srcMean.y)
            let dstX = Double(dest[i].x - dstMean.x)
            let dstY = Double(dest[i].y - dstMean.y)
            
            srcVar += srcX * srcX + srcY * srcY
            
            // Accumulate for Rotation Matrix
            matrix[0] += srcX * dstX + srcY * dstY // a term
            matrix[1] += srcX * dstY - srcY * dstX // b term
            matrix[2] += srcX * srcX + srcY * srcY // norm term (denom)
        }
        
        if matrix[2] == 0 { return .identity }
        
        // a = s * cos(theta), b = s * sin(theta)
        let a = matrix[0] / matrix[2]
        let b = matrix[1] / matrix[2]
        
        // Translation
        let val_a = Double(a)
        let val_b = Double(b)
        
        // t = dstMean - (s * R * srcMean)
        // tx = dstMean.x - (a * srcMean.x - b * srcMean.y)
        // ty = dstMean.y - (b * srcMean.x + a * srcMean.y)
        let tx = Double(dstMean.x) - (val_a * Double(srcMean.x) - val_b * Double(srcMean.y))
        let ty = Double(dstMean.y) - (val_b * Double(srcMean.x) + val_a * Double(srcMean.y))
        
        // CGAffineTransform definition:
        // x' = ax + cy + tx
        // y' = bx + dy + ty
        //
        // Our Similarity EQ (for standard axes):
        // x' = ax - by + tx
        // y' = bx + ay + ty
        //
        // Mapping:
        // CoreGraphics a = val_a
        // CoreGraphics b = val_b (coeff of x in y')
        // CoreGraphics c = -val_b (coeff of y in x')
        // CoreGraphics d = val_a
        
        return CGAffineTransform(a: CGFloat(val_a), b: CGFloat(val_b), c: CGFloat(-val_b), d: CGFloat(val_a), tx: CGFloat(tx), ty: CGFloat(ty))
    }
}
