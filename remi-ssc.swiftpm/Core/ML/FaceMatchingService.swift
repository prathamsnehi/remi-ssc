//
//  FaceMatchingService.swift
//  Remi
//
//  Created by Pratham S on 1/17/26.
//

import Vision
import CoreML
import SwiftData
import UIKit

class FaceMatchingService {
    
    // 1. Load the CoreML Model
    private let model: MobileFaceNet? = {
        // We use the standard init() from the generated Swift file
        try? MobileFaceNet(configuration: MLModelConfiguration())
    }()
    
    // 2. The Main Function called by your AR View
    // Returns the matching Person object if found
    @MainActor
    func identifyFace(in buffer: CVPixelBuffer, modelContext: ModelContext) -> (person: Person, confidence: Double)? {
        guard let model = model else { return nil }

        // A. Vision Request: Detect Face Rect
        // Note: ARKit camera buffers are usually .right oriented
        let faceRequest = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right, options: [:])
        
        try? handler.perform([faceRequest])
        
        // If no face, return nil
        guard let faceObservation = faceRequest.results?.first else { return nil }
        
        // B. Crop & Resize to 112x112
        // Uses your CropHelper from the Utils folder
        guard let croppedFace = CropHelper.cropFace(from: buffer, boundingBox: faceObservation.boundingBox) else { return nil }

        // C. Generate Embedding (The Vector)
        // FIXED: Uses 'input_1' (as found in your previous error logs)
        guard let input = try? MobileFaceNetInput(input_1: croppedFace),
              let output = try? model.prediction(input: input) else { return nil }
        
        // FIXED: Robustly find the output vector regardless of its name (Identity, output_1, etc.)
        guard let firstFeatureName = output.featureNames.first,
              let multiArray = output.featureValue(for: firstFeatureName)?.multiArrayValue else { return nil }
        
        let scannedVector = multiArray.toArray() // Uses your MLMultiArray extension
        
        // D. Compare against SwiftData
        let descriptor = FetchDescriptor<Person>()
        guard let knownPeople = try? modelContext.fetch(descriptor) else { return nil }
        
        var bestMatch: Person? = nil
        var bestScore: Double = -1.0
        
        // Iterate and Compare Cosine Similarity
        for person in knownPeople {
            let score = MathHelper.cosineSimilarity(scannedVector, person.faceEmbedding)
            
            if score > bestScore {
                bestScore = score
                bestMatch = person
            }
        }
        
        // Threshold Check (MobileFaceNet is strict, 0.75 is a good baseline)
        if bestScore > 0.75, let match = bestMatch {
            return (match, bestScore)
        }
        
        return nil
    }
    
    // 3. Registration Helper (Now Fully Implemented)
    // Call this when the user clicks "Save Person"
    func generateEmbedding(from image: UIImage) -> [Double]? {
        guard let model = model,
              let buffer = image.pixelBuffer() else { return nil } // Requires your UIImage+Extension
        
        // A. Detect Face
        let faceRequest = VNDetectFaceRectanglesRequest()
        // Standard UIImages are typically .up, but we let Vision handle default
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        
        try? handler.perform([faceRequest])
        
        // If no face detected in the photo, fail
        guard let faceObservation = faceRequest.results?.first else { return nil }
        
        // B. Crop & Resize
        guard let croppedFace = CropHelper.cropFace(from: buffer, boundingBox: faceObservation.boundingBox) else { return nil }
        
        // C. Generate Embedding
        do {
            let input = try MobileFaceNetInput(input_1: croppedFace)
            let output = try model.prediction(input: input)
            
            // Robust Output Extraction
            if let firstFeatureName = output.featureNames.first,
               let multiArray = output.featureValue(for: firstFeatureName)?.multiArrayValue {
                return multiArray.toArray()
            }
        } catch {
            print("Error generating embedding: \(error)")
        }
        
        return nil
    }
}
