//
//  FaceEmbedder.swift
//  remi-ssc
//
//  Created by Pratham S on 1/23/26.
//

import Vision
import CoreML
import UIKit

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
    
    /// Generates a 512-float embedding from a cropped face image
    func generateEmbedding(from faceImage: UIImage) -> [Float]? {
        do {
            // 1. Resize and Convert to CVPixelBuffer
            // We use the generated input class's convenience initializer which handles
            // the 112x112 resizing and format conversion (BGRA) automatically.
            guard let cgImage = faceImage.cgImage else { return nil }
            
            // This 'try' handles the 112x112 resize and pixel format check (Rule 4 & 5)
            let input = try FaceRec_MobileNetV3Input(input_imageWith: cgImage)
            
            // 2. Run Prediction
            let output = try model.prediction(input: input)
            
            // 3. Extract and L2 Normalize (Rule 10)
            // The output is a raw 512 vector. We must normalize it so its magnitude is 1.0.
            let rawVector = self.convertMultiArrayToFloat(output.embedding)
            let normalizedVector = self.l2Normalize(rawVector)
            
            return normalizedVector
            
        } catch {
            print("⚠️ Prediction failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Math Helpers (Rule 10 & 11)
    
    private func l2Normalize(_ vector: [Float]) -> [Float] {
        // Calculate magnitude (sqrt of sum of squares)
        let sumOfSquares = vector.reduce(0) { $0 + ($1 * $1) }
        let magnitude = sqrt(sumOfSquares)
        
        // Avoid division by zero
        let epsilon: Float = 1e-9
        let divisor = max(magnitude, epsilon)
        
        return vector.map { $0 / divisor }
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
    
    /// Calculates Cosine Similarity between two embeddings (Rule 11)
    /// Returns a value between -1.0 and 1.0.
    /// > 0.4 usually means "Same Person" for this model.
    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return 0 }
        
        // Since vectors are already L2 normalized, Cosine Similarity is just the Dot Product
        let dotProduct = zip(a, b).map(*).reduce(0, +)
        return dotProduct
    }
}
