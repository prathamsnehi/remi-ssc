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
        threshold: Float = 0.50
    ) -> (UUID, Float)? {
        
        var bestMatchId: UUID? = nil
        var bestScore: Float = -1.0
        
        // Loop 1: Iterate through every person in the database
        for (personId, embeddings) in candidateMap {
            
            // Loop 2: Iterate through every embedding sample (20-30 per person)
            for storedVector in embeddings {
                
                // calculate Similarity
                let score = cosineSimilarity(probeVector, storedVector)
                
                // keeping the winner
                if score > bestScore {
                    bestScore = score
                    bestMatchId = personId
                }
            }
        }
        
        // final Decision: Did the winner beat the threshold?
        if bestScore >= threshold, let matchPersonId = bestMatchId {
            return (matchPersonId, bestScore)
        }
        
        // if best score was 0.3, we return nil (Unknown Person)
        return nil
    }
    
    
}
