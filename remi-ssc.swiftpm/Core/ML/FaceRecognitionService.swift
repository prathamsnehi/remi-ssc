import CoreML
import Vision

actor FaceRecognitionService {
    
    // keep the model loaded in memory
    private var model: SFace?
    private var detector: FaceDetector
    
    init(detector: FaceDetector) {
        self.detector = detector
        
        do {
            // Load the model with default configuration
            // Make sure SFace.mlmodelc is in your "Copy Bundle Resources"
            self.model = try SFace(configuration: MLModelConfiguration())
        } catch {
            print("❌ Failed to load SFace model: \(error)")
        }
    }
    
    /// Generates a normalized 128-dimensional vector from a face crop
    /// - Parameter pixelBuffer: A 112x112 BGRA CVPixelBuffer
    /// - Returns: Normalized [Float] vector or nil if failed
    func generateEmbedding(from pixelBuffer: CVPixelBuffer) async -> [Float]? {
        guard let model = self.model else {
            print("⚠️ Model not loaded")
            return nil
        }
        
        do {
            // predict
            // The auto-generated class handles the input wrapper for us
            let output = try model.prediction(data: pixelBuffer)
            
            // convert (Float16 -> Float32)
            // SFace outputs "var_811" as a 1x128 matrix of Float16
            let rawVector = try convertToFloatArray(output.var_811)
            
            // normalize (Crucial!)
            // SFace vectors are not normalized by default.
            // Cosine similarity requires unit vectors (length = 1.0).
            let normalizedVector = l2Normalize(rawVector)
            
            return normalizedVector
            
        } catch {
            print("❌ Prediction error: \(error)")
            return nil
        }
    }
    
    /// Compares the probe vector against all samples of all people in SwiftData
    /// - Parameters:
    ///   - probeVector: The normalized vector from the live camera (128 floats)
    ///   - candidates: The list of Person objects fetched from SwiftData
    ///   - threshold: Minimum similarity score (0.0 - 1.0) to declare a match. Default 0.50 is standard for SFace.
    func identify(
        probeVector: [Float],
        candidateMap: [UUID : [[Float]]],
        threshold: Float = 0.50 // Default threshold
    ) -> (UUID, Float)? {
        
        print("\n---------------------------------------------------")
        print("🔍 [FaceRec] STARTING IDENTIFICATION")
        print("   👥 Candidates Loaded: \(candidateMap.count) people")
        print("   🎯 Match Threshold: \(String(format: "%.2f", threshold))")
        
        var bestMatchId: UUID? = nil
        var bestScore: Float = -1.0
        
        // Loop 1: Iterate through every person in the database
        for (personId, embeddings) in candidateMap {
            
            // We track the best score just for this specific person for debugging
            var highestScoreForThisPerson: Float = -1.0
            
            // Loop 2: Iterate through every embedding sample (20-30 per person)
            for storedVector in embeddings {
                
                // calculate Similarity
                let score = cosineSimilarity(probeVector, storedVector)
                
                // Update local tracking (just for logs)
                if score > highestScoreForThisPerson {
                    highestScoreForThisPerson = score
                }
                
                // Update Global Winner logic
                if score > bestScore {
                    print("      📈 NEW GLOBAL BEST: \(String(format: "%.4f", score)) (ID: \(personId.uuidString.prefix(4))...)")
                    bestScore = score
                    bestMatchId = personId
                }
            }
            
            // Log the summary for this person so you can compare them
            // Prints: "👤 Checked 8A2F... | Max Score: 0.7231"
            print("   👤 Checked \(personId.uuidString.prefix(4))... | Max Score: \(String(format: "%.4f", highestScoreForThisPerson))")
        }
        
        print("   ---------------------------------------------")
        
        // Final Decision: Did the winner beat the threshold?
        if bestScore >= threshold, let matchPersonId = bestMatchId {
            print("✅ MATCH FOUND! 🎉")
            print("   🆔 ID: \(matchPersonId)")
            print("   💯 Score: \(String(format: "%.4f", bestScore)) (Threshold passed)")
            print("---------------------------------------------------\n")
            return (matchPersonId, bestScore)
        }
        
        // Failure Logging
        print("❌ NO MATCH FOUND")
        if let bestId = bestMatchId {
            print("   ⚠️ Closest match was \(bestId.uuidString.prefix(4))...")
            print("   ⚠️ Score: \(String(format: "%.4f", bestScore)) (Failed to beat \(threshold))")
        } else {
            print("   ⚠️ No scores calculated (Candidate map might be empty).")
        }
        print("---------------------------------------------------\n")
        
        return nil
    }
}
