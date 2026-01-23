//
//  FaceRecognitionService.swift
//  remi
//
//  Created by Pratham S on 1/19/26.
//

import UIKit
import Vision
import CoreML
import SwiftData
import Accelerate

//
//  FaceRecognitionService.swift
//  remi
//
//  Created by Pratham S on 1/19/26.
//

import UIKit
import Vision
import CoreML
import SwiftData
import Accelerate

/// Helper service to identify and register faces using the new FaceRec_MobileNetV3
actor FaceRecognitionService {
    static let shared = FaceRecognitionService()
    
    // The new wrapper class
    private let embedder = FaceEmbedder()
    
    // Internal conversion helper
    private let ciContext = CIContext()
    
    private init() {}
    
    // MARK: - Integration Points
    
    /// Generates an embedding from UIImage (for Normal Registration Flow)
    func generateEmbedding(from image: UIImage) async -> [Double]? {
        // Rule A: 5-Point Alignment is Mandatory.
        // We cannot just pass the raw image. We must Detect -> Align -> Embed.
        
        guard let buffer = image.toCVPixelBuffer() else { return nil }
        
        // 1. Detect Landmarks (Required for Alignment)
        let request = VNDetectFaceLandmarksRequest()
        // Determine orientation - UIImage usually has it baked or in tag. 
        // .toCVPixelBuffer usually normalizes to Up, but let's be safe.
        // The previous code assumed .up for toCVPixelBuffer results.
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
        
        do {
            try handler.perform([request])
            
            // Get largest face
            if let result = request.results?.sorted(by: { $0.boundingBox.width > $1.boundingBox.width }).first {
                
                // 2. Align (Rule A)
                guard let landmarks = result.landmarks,
                      let alignedBuffer = buffer.alignToRefPoints(landmarks: landmarks, faceBoundingBox: result.boundingBox, orientation: .up)
                else {
                    print("❌ [FaceRec] Alignment failed (missing landmarks?)")
                    return nil
                }
                
                // 3. Convert Aligned Buffer -> UIImage (Rule: Embedder takes UIImage)
                guard let alignedImage = createUIImage(from: alignedBuffer) else { return nil }
                
                // 4. Generate Embedding
                // Rule D: Embedder returns [Float]. We convert to [Double] for app storage.
                if let floatEmbedding = embedder.generateEmbedding(from: alignedImage) {
                    return floatEmbedding.map { Double($0) }
                }
            }
        } catch {
            print("❌ Registration face detection failed: \(error)")
        }
        return nil
    }
    
    /// Generates an embedding from a wrapped pixel buffer (for AR flow)
    func generateEmbedding(from wrapper: PixelBufferWrapper, faceRect: CGRect) async -> [Double]? {
        let buffer = wrapper.buffer
        
        // Rule A: Validation.
        // ARViewContainer gives us a rect, but we NEED landmarks for alignment.
        // We must run a local landmark detection on this buffer to get the points.
        
        // 1. Detect Landmarks on the valid buffer
        // Note: AR camera buffers are typically .right oriented relative to the device?
        // Let's assume .right as per previous code.
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
        
        do {
            try handler.perform([request])
            
            // Find the face that matches the input `faceRect` (from simple detection)
            // Match by IoU or Center Distance
            guard let bestMatch = request.results?.min(by: { a, b in
                let centerA = CGPoint(x: a.boundingBox.midX, y: a.boundingBox.midY)
                let centerB = CGPoint(x: b.boundingBox.midX, y: b.boundingBox.midY)
                let target = CGPoint(x: faceRect.midX, y: faceRect.midY)
                return hypot(centerA.x - target.x, centerA.y - target.y) < hypot(centerB.x - target.x, centerB.y - target.y)
            }) else {
                return nil
            }
            
            // 2. Align (Rule A)
            guard let landmarks = bestMatch.landmarks,
                  let alignedBuffer = buffer.alignToRefPoints(landmarks: landmarks, faceBoundingBox: bestMatch.boundingBox, orientation: .right)
            else {
                return nil
            }
            
            // 3. Convert to UIImage
            guard let alignedImage = createUIImage(from: alignedBuffer) else { return nil }
            
            // 4. Generate Embedding
            if let floatEmbedding = embedder.generateEmbedding(from: alignedImage) {
                return floatEmbedding.map { Double($0) }
            }
            
        } catch {
            print("❌ AR Vision failed: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Matching Logic (Rule E)
    
    /// Finds the best match using Cosine Similarity > 0.4
    func findBestMatch(for embedding: [Double], candidates: [(PersistentIdentifier, [Double])]) -> (PersistentIdentifier, Double)? {
        // Rule D: Convert to Float for Math
        let floatProbe = embedding.map { Float($0) }
        
        var bestMatchID: PersistentIdentifier?
        // For Cosine Similarity, Higher is Better.
        var maxSimilarity: Float = -1.0
        
        // Rule E: Threshold 0.4
        let threshold: Float = 0.40
        
        for (id, knownVector) in candidates {
            guard knownVector.count == embedding.count else { continue }
            
            let floatCandidate = knownVector.map { Float($0) }
            
            // Rule 11: Cosine Similarity
            let similarity = embedder.cosineSimilarity(floatProbe, floatCandidate)
            
            // Debug Log
            // print("🔍 Candidate: \(similarity)")
            
            if similarity > threshold {
                if similarity > maxSimilarity {
                    maxSimilarity = similarity
                    bestMatchID = id
                }
            }
        }
        
        if let id = bestMatchID {
            // Return confidence (just the similarity score)
            return (id, Double(maxSimilarity))
        }
        
        return nil
    }
    
    // MARK: - Helpers
    
    private func createUIImage(from buffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        // Note: buffer from alignToRefPoints is already 112x112 BGRA and upright.
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

