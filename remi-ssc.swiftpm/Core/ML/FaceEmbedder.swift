//
//  FaceEmbedder.swift
//  remi-ssc
//
//  Created by Pratham S on 1/23/26.
//

import Vision
import CoreML
import UIKit
import Accelerate

class FaceEmbedder {
    // Keep a single instance to avoid reloading the heavy model every time
    let model: FaceRec_MobileNetV3
    
    init() {
        do {
            self.model = try FaceRec_MobileNetV3(configuration: MLModelConfiguration())
            print("✅ MobileNetV3 Loaded Successfully")
        } catch {
            fatalError("❌ Failed to load model. Did you put the .mlmodelc folder in Resources? Error: \(error)")
        }
    }
    
    /// Generates a 512-float embedding from a cropped face image (UIImage)
    func generateEmbedding(from faceImage: UIImage) -> [Float]? {
        // Fallback: Convert to CVPixelBuffer if needed, but prefer passing buffer directly
        guard let cvBuffer = faceImage.toCVPixelBuffer() else { return nil }
        return generateEmbedding(from: cvBuffer)
    }
    
    /// Generates a 512-float embedding from a CVPixelBuffer (Standard Entry Point)
    /// **Important**: Expects 112x112 size. Ideally BGRA/BGR.
    func generateEmbedding(from buffer: CVPixelBuffer) -> [Float]? {
        do {
            // 1. Direct Input (Avoids extra ARGB conversion if using convenience init)
            // The model input expects a CVPixelBuffer.
            let input = FaceRec_MobileNetV3Input(input_image: buffer)
            
            // 2. Run Prediction
            let output = try model.prediction(input: input)
            
            // 3. Extract and L2 Normalize (Rule 10)
            let rawVector = self.convertMultiArrayToFloat(output.embedding)
            let normalizedVector = self.l2Normalize(rawVector)
            
            return normalizedVector
            
        } catch {
            print("⚠️ Prediction failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Math Helpers (Rule 10 & 11)
    
    /// L2 Normalize a vector using Apple's Accelerate framework (Super Fast)
    private func l2Normalize(_ vector: [Float]) -> [Float] {
        // 1. Calculate the squared sum
        var squaredSum: Float = 0
        vDSP_svesq(vector, 1, &squaredSum, vDSP_Length(vector.count))
        
        // 2. Calculate magnitude (sqrt)
        let magnitude = sqrt(squaredSum)
        
        // 3. Avoid division by zero
        let epsilon: Float = 1e-9
        if magnitude < epsilon { return vector }
        
        // 4. Divide vector by magnitude
        var normalizedVector = [Float](repeating: 0, count: vector.count)
        var scale = 1.0 / magnitude
        vDSP_vsmul(vector, 1, &scale, &normalizedVector, 1, vDSP_Length(vector.count))
        
        return normalizedVector
    }
    
    private func convertMultiArrayToFloat(_ array: MLMultiArray) -> [Float] {
        var floatArray = [Float](repeating: 0, count: array.count)
        // Fast pointer access
        let pointer = UnsafeMutablePointer<Float>(OpaquePointer(array.dataPointer))
        for i in 0..<array.count {
            floatArray[i] = pointer[i]
        }
        return floatArray
    }
    
    /// Averages multiple vectors and L2 normalizes the result.
    /// Useful for TTA (Test Time Augmentation).
    func averageAndNormalize(_ vectors: [[Float]]) -> [Float]? {
        guard !vectors.isEmpty else { return nil }
        let dim = vectors[0].count
        var sumVector = [Float](repeating: 0, count: dim)
        
        for vec in vectors {
            guard vec.count == dim else { continue }
            vDSP_vadd(sumVector, 1, vec, 1, &sumVector, 1, vDSP_Length(dim))
        }
        
        return l2Normalize(sumVector)
    }

    /// Calculates Cosine Similarity between two embeddings (Rule 11)
    /// Returns a value between -1.0 and 1.0.
    /// > 0.4 usually means "Same Person" for this model.
    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return 0 }
        
        // Since vectors are already L2 normalized, Cosine Similarity == Dot Product
        var dotProduct: Float = 0
        vDSP_dotpr(a, 1, b, 1, &dotProduct, vDSP_Length(a.count))
        
        return dotProduct
    }
}
