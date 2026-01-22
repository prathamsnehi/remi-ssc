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
import SwiftData

struct ARViewContainer: UIViewRepresentable {
    
    @Environment(\.modelContext) var modelContext
    @ObservedObject var detector: FaceDetector
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.userFaceTrackingEnabled = false
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    // 1. Mark the whole class as MainActor.
    // Now everything inside here is safe for UI/SwiftData by default.
    @MainActor
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var isProcessing = false
        var lastRecognitionTime: Date = .distantPast
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        // 2. Mark this 'nonisolated' to satisfy ARKit protocol
        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Jump back to MainActor immediately to use our safe variables
            Task { @MainActor in
                self.processFrame(frame)
            }
        }
        
        // This runs on Main Thread (because the class is @MainActor)
        private func processFrame(_ frame: ARFrame) {
            guard !isProcessing else { return }
            isProcessing = true
            
            // Extract data we need so we don't pass 'ARFrame' to background
            let buffer = frame.capturedImage
            let bufferWrapper = PixelBufferWrapper(buffer: buffer) // Safe wrapper
            let viewportSize = UIScreen.main.bounds.size
            let displayTransform = frame.displayTransform(for: .portrait, viewportSize: viewportSize)
            
            // 3. Detach heavy work to background
            Task.detached {
                await self.runVisionAndML(wrapper: bufferWrapper, transform: displayTransform, viewportSize: viewportSize)
                
                // Reset flag when done
                await MainActor.run { self.isProcessing = false }
            }
        }
        
        // This runs in Background
        nonisolated private func runVisionAndML(wrapper: PixelBufferWrapper, transform: CGAffineTransform, viewportSize: CGSize) async {
            let buffer = wrapper.buffer
            
            // A. Vision Detection
            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
            
            do {
                try handler.perform([request])
                guard let face = request.results?.first else {
                    await self.updateUI(faceRect: nil, person: nil) // Clear UI
                    return
                }
                
                // B. Calculate Screen Rect
                let boundingBox = face.boundingBox
                let transformedRect = boundingBox.applying(transform)
                var finalRect = transformedRect
                finalRect.origin.y = 1.0 - finalRect.origin.y - finalRect.height // Flip Y
                let screenRect = CGRect(
                    x: finalRect.origin.x * viewportSize.width,
                    y: finalRect.origin.y * viewportSize.height,
                    width: finalRect.width * viewportSize.width,
                    height: finalRect.height * viewportSize.height
                )
                
                // C. Recognition (Throttled Check)
                // We ask MainActor: "Is it time yet?"
                let shouldRecognize = await MainActor.run {
                    if Date().timeIntervalSince(self.lastRecognitionTime) > 0.5 {
                        self.lastRecognitionTime = Date()
                        return true
                    }
                    // Just update box, skip ML
                    self.parent.detector.faceRect = screenRect
                    return false
                }
                
                guard shouldRecognize else { return }
                
                // D. Run ML (Heavy work, still in background)
                guard let embedding = await FaceRecognitionService.shared.generateEmbedding(from: wrapper, faceRect: boundingBox) else { return }
                
                // E. Fetch Candidates (Must hop to MainActor for SwiftData)
                let candidates = await MainActor.run {
                    (try? self.parent.modelContext.fetch(FetchDescriptor<Person>()))?
                        .map { ($0.persistentModelID, $0.faceEmbedding) } ?? []
                }
                
                // F. Match
                let match = await FaceRecognitionService.shared.findBestMatch(for: embedding, candidates: candidates)
                
                // G. Final UI Update
                await self.updateUI(faceRect: screenRect, match: match, buffer: buffer)
                
            } catch {
                print("Vision error: \(error)")
            }
        }
        
        // Helper to cleanly update UI state on MainActor
        @MainActor
        private func updateUI(faceRect: CGRect?, match: (PersistentIdentifier, Double)? = nil, buffer: CVPixelBuffer? = nil, person: Person? = nil) {
            let detector = parent.detector
            detector.faceRect = faceRect
            
            if let buffer = buffer {
                detector.lastCapturedImage = createUIImage(from: buffer)
            }
            
            guard let (id, confidence) = match else {
                if faceRect == nil { // Clear everything
                    detector.identifiedPerson = nil
                    detector.isUnknown = false
                } else { // Face found but no match yet
                    detector.identifiedPerson = nil
                    detector.isUnknown = true
                }
                return
            }
            
            // Fetch Person object
            if let person = try? parent.modelContext.fetch(FetchDescriptor<Person>(predicate: #Predicate { $0.persistentModelID == id })).first {
                detector.identifiedPerson = person
                detector.confidence = confidence
                detector.isUnknown = false
            }
        }
        
        nonisolated private func createUIImage(from buffer: CVPixelBuffer) -> UIImage? {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
            return UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        }
    }
}

// Helper needed for passing buffer safely
struct PixelBufferWrapper: @unchecked Sendable {
    let buffer: CVPixelBuffer
}
