//
//  ARView.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import SwiftUI
import RealityKit
import ARKit
import Vision
import UIKit
import SwiftData

struct ARViewContainer: UIViewRepresentable { // Setting up the camera feed for AR
    typealias UIViewType = RealityKit.ARView
    @Environment(\.modelContext) var modelContext

    var detector: FaceDetector // contains info of the location of the face and related info
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(detector: detector, modelContext: modelContext)
    }
    
    func makeUIView(context: Context) -> RealityKit.ARView {
        let arView = RealityKit.ARView(frame: .zero)
        
        // use standard world tracking, aka rear camera:
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: RealityKit.ARView, context: Context) {
        // update if needed
    }
    
    // Coordinator to listen to frame updates (60 times a second)
    class Coordinator: NSObject, ARSessionDelegate {
        var arView: RealityKit.ARView?
        var detector: FaceDetector
        var modelContext: ModelContext
        var isProcesing = false
        var lastScanTime: Date = Date.distantPast
        
        init(detector: FaceDetector, modelContext: ModelContext) {
            self.detector = detector
            self.modelContext = modelContext
        }
        
        // request: looking for faces:
        lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
            return VNDetectFaceRectanglesRequest { [weak self] request, error in
                guard let self = self else { return }
                
                if let results = request.results as? [VNFaceObservation], let result = results.first {
                    self.updateFaceLocation(boundingBox: result.boundingBox)
                } else {
                    // no face found, clear the location on the main thread:
                    DispatchQueue.main.async {
                        self.detector.faceLocation = nil
                        self.isProcesing = false
                    }
                }
            }
        }()
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Throttling: only scan every 0.5 seconds to prevent flickering
            guard !isProcesing, Date().timeIntervalSince(lastScanTime) > 0.5 else { return }
            isProcesing = true
            lastScanTime = Date()
            
            guard let copiedBuffer = frame.capturedImage.copy() else { return }
            let pixelBufferWrapper = SendablePixelBuffer(buffer: copiedBuffer)
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBufferWrapper.buffer, orientation: .right)
                
                do {
                    try handler.perform([self.faceDetectionRequest])
                    
                    if let results = self.faceDetectionRequest.results, !results.isEmpty {
                        
                        Task {
                            // 1. Generate Embedding (Background Actor)
                            if let embedding = await FaceRecognitionService.shared.generateEmbedding(from: pixelBufferWrapper.buffer) {
                                
                                await MainActor.run {
                                    // 2. Fetch Candidates (Main Actor)
                                    // We fetch here to ensure thread safety with SwiftData
                                    let descriptor = FetchDescriptor<Person>()
                                    if let allPersons = try? self.modelContext.fetch(descriptor) {
                                        
                                        // Prepare Sendable data for the actor
                                        let candidates = allPersons.map { ($0.persistentModelID, $0.faceEmbedding) }
                                        
                                        Task {
                                            // 3. Find Match (Background Actor) - purely mathematical
                                            let matchStart = Date()
                                            let matchResult = await FaceRecognitionService.shared.findBestMatch(for: embedding, candidates: candidates)
                                            
                                            // 4. Update UI (Main Actor)
                                            await MainActor.run {
                                                // Create a snapshot for registration if needed
                                                let ciImage = CIImage(cvPixelBuffer: pixelBufferWrapper.buffer)
                                                let context = CIContext() // Re-using context is better but creating one here is acceptable for now
                                                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                                                    // Fix orientation: AR capturedImage is usually .right (landscape)
                                                    // We rotate it to .up for the UI
                                                    self.detector.lastCapturedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
                                                }
                                                
                                                if let (matchedID, confidence) = matchResult,
                                                   let person = allPersons.first(where: { $0.persistentModelID == matchedID }) {
                                                    
                                                    self.detector.identifiedPerson = person
                                                    self.detector.confidence = confidence
                                                    self.detector.isUnknown = false
                                                } else {
                                                    self.detector.identifiedPerson = nil
                                                    self.detector.confidence = 0.0
                                                    self.detector.isUnknown = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Clear if no face (though updateFaceLocation also handles clearing location)
                        // This ensures ID is cleared too
                        Task {
                             await MainActor.run {
                                  self.detector.identifiedPerson = nil
                                  self.detector.isUnknown = false
                             }
                        }
                    }
                } catch {
                    print("Vision Request Failed")
                    // resetting processing status if it fails:
                    
                    DispatchQueue.main.async {
                        self.isProcesing = false
                    }
                }
            }
        }
        
        func updateFaceLocation(boundingBox: CGRect) {
            DispatchQueue.main.async {
                defer { self.isProcesing = false }
                
                guard let arView = self.arView else { return }
                
                // getting view dimensions:
                let viewSize = arView.bounds.size
                
                // convert vision coords to screen coords:
                let x = boundingBox.midX * viewSize.width
                let y = (1 - boundingBox.midY) * viewSize.height
                
                // updating publisher to add location of face:
                self.detector.faceLocation = CGPoint(x: x, y: y)
            }
        }
    }
}

extension ARViewContainer.Coordinator: @unchecked Sendable {}
struct SendablePixelBuffer: @unchecked Sendable {
    let buffer: CVPixelBuffer
}

extension CVPixelBuffer {
    func copy() -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let format = CVPixelBufferGetPixelFormatType(self)
        var newBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, width, height, format, nil, &newBuffer)
        guard status == kCVReturnSuccess, let destination = newBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(destination, [])
        defer {
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
            CVPixelBufferUnlockBaseAddress(destination, [])
        }
        
        if let srcAddr = CVPixelBufferGetBaseAddress(self), let dstAddr = CVPixelBufferGetBaseAddress(destination) {
            let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
            // Copy line by line if bytesPerRow mismatch, or just memcpy if same
            // For simplicity in ARKit (same format), assuming memcpy works for plane 0 (Y) and 1 (UV) if biplanar
            // Or just use CoreImage to render
            
            // Safer: Use CoreImage to copy? Or Memcpy.
            // Memcpy is fastest for identical buffers.
            let srcSize = CVPixelBufferGetDataSize(self)
            memcpy(dstAddr, srcAddr, srcSize)
        }
        return destination
    }
}
