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

/// Helper service to identify and register faces using MobileFaceNet
/// Helper service to identify and register faces using MobileFaceNet
actor FaceRecognitionService {
    static let shared = FaceRecognitionService()
    
    // The model wrapper (loads pre-compiled model from Bundle)
    private var model: MobileFaceNet?
    
    private init() {
        // Initialize the model on first use
        do {
            self.model = try MobileFaceNet()
        } catch {
            print("Failed to load MobileFaceNet: \(error)")
        }
    }
    
    // MARK: - Integration Points
    
    /// Generates an embedding for the RegisterView flow (from UIImage)
    func generateEmbedding(from image: UIImage) async -> [Double]? {
        guard let buffer = image.toCVPixelBuffer() else { return nil }
        return computeEmbedding(from: buffer)
    }
    
    /// Generates an embedding from a pixel buffer (for AR flow)
    func generateEmbedding(from buffer: CVPixelBuffer) async -> [Double]? {
        return computeEmbedding(from: buffer)
    }
    
    // MARK: - Internal Logic
    
    /// Core function: Buffer -> Embedding
    private func computeEmbedding(from buffer: CVPixelBuffer) -> [Double]? {
        guard let model = model else { return nil }
        
        // 1. Detect and Crop Face (112x112)
        guard let croppedFace = buffer.resizeForMobileFaceNet() else { return nil }
        
        // 2. Run Inference
        do {
            // MobileFaceNetInput init requires 'input_1'
            let input = MobileFaceNetInput(input_1: croppedFace)
            let output = try model.prediction(input: input)
            
            // 3. Extract Vector from 'var_950'
            let multiArray = output.var_950
            return multiArray.toArray()
            
        } catch {
            print("Inference error: \(error)")
            return nil
        }
    }
    
    /// Pure math: finds the best match for an embedding among candidates
    /// Returns (bestMatchId, confidence)
    func findBestMatch(for embedding: [Double], candidates: [(PersistentIdentifier, [Double])]) -> (PersistentIdentifier, Double)? {
        var bestMatchID: PersistentIdentifier?
        var minDistance: Double = 1.0
        let strictThreshold = 0.6
        
        for (id, knownVector) in candidates {
            guard !knownVector.isEmpty else { continue }
            
            var distance = getFaceDistance(embedding, knownVector)
            if distance < strictThreshold {
                if distance < minDistance {
                    minDistance = distance
                    bestMatchID = id
                }
            }
        }
        
        if let id = bestMatchID {
            return (id, (1.0 - minDistance))
        }
        
        return nil
    }
}

extension MLMultiArray {
    func toArray() -> [Double] {
        let count = self.count
        var array = [Double](repeating: 0.0, count: count)
        for i in 0..<count {
            array[i] = self[i].doubleValue
        }
        return array
    }
}
