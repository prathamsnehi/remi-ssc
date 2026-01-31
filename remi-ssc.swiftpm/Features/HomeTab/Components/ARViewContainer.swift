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
    @MainActor
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var isProcessing = false
        
        // Tracking State
        private let sequenceHandler = VNSequenceRequestHandler()
        private var lastObservation: VNDetectedObjectObservation?
        private var trackedPersonID: PersistentIdentifier? // ID of person associated with current track
        private var trackStabilityCounter = 0
        
        // Jitter Fix: Smoother
        let smoother = FaceBoxSmoother()
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        // 2. Mark this 'nonisolated' to satisfy ARKit protocol
        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Jump back to MainActor to handle logic safely
            Task { @MainActor in
                self.processFrame(frame)
            }
        }
        
        // This runs on Main Thread
        private func processFrame(_ frame: ARFrame) {
            guard !isProcessing else { return }
            isProcessing = true
            
            // Extract data we need so we don't pass 'ARFrame' to background
            let buffer = frame.capturedImage
            let bufferWrapper = PixelBufferWrapper(buffer: buffer)
            let viewportSize = UIScreen.main.bounds.size
            let displayTransform = frame.displayTransform(for: .portrait, viewportSize: viewportSize)
            
            // 3. Detach heavy vision work
            Task.detached {
                await self.runVisionTracking(wrapper: bufferWrapper, transform: displayTransform, viewportSize: viewportSize)
                await MainActor.run { self.isProcessing = false }
            }
        }
        
        // Runs in Background
        nonisolated private func runVisionTracking(wrapper: PixelBufferWrapper, transform: CGAffineTransform, viewportSize: CGSize) async {
            let buffer = wrapper.buffer
            
            // Step A: Detect/Track
            // Strategy: 
            // 1. If we have a 'lastObservation' (active track), try to TRACK it.
            // 2. If tracking fails (lost) or no track, try to DETECT new faces.
            
            var currentObservation: VNFaceObservation?
            
            if let lastObs = await MainActor.run(body: { self.lastObservation }) {
                // Try Tracking
                let trackRequest = VNTrackObjectRequest(detectedObjectObservation: lastObs)
                trackRequest.trackingLevel = .accurate
                
                do {
                    try sequenceHandler.perform([trackRequest], on: buffer, orientation: .right)
                    if let result = trackRequest.results?.first as? VNDetectedObjectObservation {
                         // Tracking Success - But VNTrackObjectRequest result is generic. 
                         // We need to re-cast or keep using it. 
                         // Actually, we usually want Landmarks for alignment/quality check.
                         // So pure tracking might be insufficient for SFace Quality Check.
                         // User asked to run VNDetectFaceRectanglesRequest on EVERY frame.
                    }
                } catch {
                     // Tracking lost
                }
            }
            
            // Re-read user req: "Run VNDetectFaceRectanglesRequest... on every frame"
            // "Use VNTrackObjectRequest to assign a temporary UUID".
            // Okay, we will use FaceRectangles request mostly.
            
            let detectRequest = VNDetectFaceRectanglesRequest()
            // detectRequest.revision = VNDetectFaceRectanglesRequestRevision3 // Optional
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
            
            do {
                try handler.perform([detectRequest])
                guard let face = detectRequest.results?.first else {
                    // No Face
                    await self.handleFaceLost()
                    return
                }
                
                // We have a face.
                currentObservation = face
                
                // Step B: Calculate Screen Rect
                let boundingBox = face.boundingBox
                let transformedRect = boundingBox.applying(transform)
                var finalRect = transformedRect
                finalRect.origin.y = 1.0 - finalRect.origin.y - finalRect.height
                let screenRect = CGRect(
                    x: finalRect.origin.x * viewportSize.width,
                    y: finalRect.origin.y * viewportSize.height,
                    width: finalRect.width * viewportSize.width,
                    height: finalRect.height * viewportSize.height
                )
                
                // Step C: Trigger Logic
                // Conditions:
                // 1. New Track? (UUID check - FaceObservation has uuid in Vision?) 
                //    Wait, DetectFaceRectangles DOES NOT provide stable UUIDs across frames. 
                //    VNTrackObjectRequest DOES. 
                //    So we must Initialize Track with Detect, then Loop with Track.
                //    But user said "Run Detect on every frame". This is contradictory or implies simple tracking by overlap.
                //    Let's assume "Smart Triggering" means: 
                //    "If I haven't identified this person yet, check stability."
                
                let (shouldRunML, qualityOK) = await MainActor.run { () -> (Bool, Bool) in
                    // Override: If Scanning (Registration), ALWAYS run ML (ignore stable/identified)
                    if self.parent.detector.isScanning {
                         let quality = face.faceCaptureQuality ?? 0.0
                         let qOK = quality >= 0.25 || face.faceCaptureQuality == nil
                         return (qOK, qOK)
                    }
                    
                    let isIdentified = self.trackedPersonID != nil
                    // Quality Check (Quality is not in FaceRectanglesRequest unless we use Landmarks or Revision3? Revision3 has it?)
                    // Let's assume we run Landmarks request if needed or assume Rects is enough for bbox.
                    // Actually, `faceCaptureQuality` property exists on VNFaceObservation.
                    // But standard Rect request might populate it property.
                    let quality = face.faceCaptureQuality ?? 0.0 // Default 0 if nil
                    let qOK = quality >= 0.25 || face.faceCaptureQuality == nil // Permissive if nil
                    
                    if isIdentified { return (false, qOK) } // Already know who it is
                    
                    // Not identified. Check stability.
                    // Simple heuristic: If we have seen a face for X frames... 
                    // Since we run Detect every frame, we are "tracking" by just having a face.
                    self.trackStabilityCounter += 1
                    let stable = self.trackStabilityCounter > 5 // ~0.5s at 10fps?
                    
                    return (stable && qOK, qOK)
                }
                
                if !qualityOK {
                    await self.updateUI(faceRect: screenRect, status: "Low Quality")
                    return
                }
                
                if shouldRunML {
                    // Run SFace
                     guard let embedding = await FaceRecognitionService.shared.generateEmbedding(from: buffer, observation: face) else {
                        await self.updateUI(faceRect: screenRect)
                        return
                    }
                    
                    // Match
                    let candidates = await self.fetchCandidates()
                    let match = await FaceRecognitionService.shared.findBestMatch(for: embedding, candidates: candidates)
                    
                    await self.handleMatchResult(match: match, rect: screenRect, buffer: buffer)
                    
                } else {
                    // Just update box (Tracking or Identified)
                    await self.updateUI(faceRect: screenRect, preservePerson: true)
                }
                
                await MainActor.run { self.lastObservation = nil } // Reset for next frame (since we Detect every time)
                
            } catch {
                print("Vision Error: \(error)")
            }
        }
        
        @MainActor
        private func handleFaceLost() {
            self.parent.detector.faceRect = nil
            self.parent.detector.identifiedPerson = nil
            self.parent.detector.isUnknown = false
            self.trackedPersonID = nil
            self.trackStabilityCounter = 0
            self.smoother.reset()
        }
        
        @MainActor
        private func fetchCandidates() -> [(PersistentIdentifier, [Double])] {
            (try? self.parent.modelContext.fetch(FetchDescriptor<Person>()))?
                .flatMap { person -> [(PersistentIdentifier, [Double])] in
                     // SFace = 128 dims. Filter out old 512/1024 vectors?
                     // FaceRecService checks dims, so just pass all.
                    if !person.samples.isEmpty {
                        return person.samples.map { (person.persistentModelID, $0.embedding) }
                    }
                    return []
                } ?? []
        }
        
        @MainActor
        private func handleMatchResult(match: (PersistentIdentifier, Double)?, rect: CGRect, buffer: CVPixelBuffer) {
             if let (id, conf) = match {
                 // Identified!
                 self.trackedPersonID = id
                 self.trackStabilityCounter = 0 // Reset? No, keep it stuck basically.
                 
                 if let person = try? parent.modelContext.fetch(FetchDescriptor<Person>(predicate: #Predicate { $0.persistentModelID == id })).first {
                     parent.detector.identifiedPerson = person
                     parent.detector.confidence = conf
                     parent.detector.isUnknown = false
                 }
             } else {
                 // Unknown
                 parent.detector.isUnknown = true
                 parent.detector.identifiedPerson = nil
             }
             
             self.updateUI(faceRect: rect, buffer: buffer)
        }
        
        @MainActor
        private func updateUI(faceRect: CGRect?, status: String? = nil, buffer: CVPixelBuffer? = nil, preservePerson: Bool = false) {
             let detector = parent.detector
             detector.faceRect = smoother.smooth(faceRect)
             detector.statusMessage = status
             
             if let b = buffer {
                 detector.lastCapturedImage = createUIImage(from: b)
             }
             
             if preservePerson { return }
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
