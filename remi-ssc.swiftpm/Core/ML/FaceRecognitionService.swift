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
        guard let buffer = image.pixelBuffer() else { return nil }
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
        guard let croppedFace = cropFace(from: buffer) else { return nil }
        
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
    func findBestMatch(for embedding: [Double], candidates: [(PersistentIdentifier, [Double])]) -> (PersistentIdentifier, Double)? {
        var bestMatchID: PersistentIdentifier?
        var maxSimilarity: Double = -1.0
        let threshold = 0.6
        
        for (id, knownVector) in candidates {
            guard !knownVector.isEmpty else { continue }
            
            let similarity = cosineSimilarity(embedding, knownVector)
            if similarity > maxSimilarity {
                maxSimilarity = similarity
                bestMatchID = id
            }
        }
        
        if let id = bestMatchID, maxSimilarity > threshold {
            return (id, maxSimilarity)
        }
        
        return nil
    }
    
    private func cosineSimilarity(_ v1: [Double], _ v2: [Double]) -> Double {
        guard v1.count == v2.count else { return 0.0 }
        
        var dotProduct = 0.0
        var normA = 0.0
        var normB = 0.0
        
        for i in 0..<v1.count {
            dotProduct += v1[i] * v2[i]
            normA += v1[i] * v1[i]
            normB += v2[i] * v2[i]
        }
        
        if normA == 0 || normB == 0 { return 0.0 }
        return dotProduct / (sqrt(normA) * sqrt(normB))
    }
    
    // MARK: - Vision Helpers
    
    private func cropFace(from buffer: CVPixelBuffer) -> CVPixelBuffer? {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
        // Note: For ARFrame capturedImage (landscapeRight sensor), '.up' might be wrong relative to image coordinates if not adjusted.
        // However, standard VNImageRequestHandler usually works well if we just want *some* face.
        // If detection fails in AR, we might need to adjust orientation.
        
        try? handler.perform([request])
        
        guard let results = request.results as? [VNFaceObservation],
              let face = results.first else { return nil }
        
        // Determine crop rect in buffer coordinates
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        
        let boundingBox = face.boundingBox
        
        let w = boundingBox.width * CGFloat(width)
        let h = boundingBox.height * CGFloat(height)
        let x = boundingBox.minX * CGFloat(width)
        let y = (1 - boundingBox.maxY) * CGFloat(height) // Vision origin is bottom-left
        
        let cropRect = CGRect(x: x, y: y, width: w, height: h)
        
        // Crop and Resize to 112x112 (MobileFaceNet input size)
        return buffer.cropAndResize(to: cropRect, targetSize: CGSize(width: 112, height: 112))
    }
}

// MARK: - Extensions

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

extension CVPixelBuffer {
    func cropAndResize(to rect: CGRect, targetSize: CGSize) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let cropped = ciImage.cropped(to: rect)
        
        // Scale to target size
        let scaleX = targetSize.width / rect.width
        let scaleY = targetSize.height / rect.height
        let scaled = cropped.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Render back to CVPixelBuffer
        let context = CIContext()
        var newBuffer: CVPixelBuffer?
        // Create formatted buffer (32BGRA is standard for ML inputs usually)
        CVPixelBufferCreate(nil, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32BGRA, nil, &newBuffer)
        
        if let newBuffer = newBuffer {
            context.render(scaled, to: newBuffer)
            return newBuffer
        }
        return nil
    }
}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        // Fix Orientation
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
