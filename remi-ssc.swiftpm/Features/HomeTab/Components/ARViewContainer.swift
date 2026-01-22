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

//struct ARViewContainer: UIViewRepresentable { // Setting up the camera feed for AR
//    typealias UIViewType = RealityKit.ARView
//    @Environment(\.modelContext) var modelContext
//
//    var detector: FaceDetector // contains info of the location of the face and related info
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(detector: detector, modelContext: modelContext)
//    }
//
//    func makeUIView(context: Context) -> RealityKit.ARView {
//        let arView = RealityKit.ARView(frame: .zero)
//
//        // use standard world tracking, aka rear camera:
//        let config = ARWorldTrackingConfiguration()
//        config.userFaceTrackingEnabled = false // Ensure we are using world tracking, not face tracking config
//        // as face tracking config pulls up the front camera, but we want the rear camera
//        arView.session.run(config)
//
//        context.coordinator.arView = arView
//        arView.session.delegate = context.coordinator
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: RealityKit.ARView, context: Context) {
//        // update if needed
//    }
//
//    // Coordinator to listen to frame updates (60 times a second)
//    class Coordinator: NSObject, ARSessionDelegate {
//        weak var arView: RealityKit.ARView?
//        var detector: FaceDetector
//        var modelContext: ModelContext
//
//        // State
//        var isProcessing = false
//        var lastScanTime: Date = Date.distantPast
//        var currentWrapper: SendablePixelBuffer?
//
//        init(detector: FaceDetector, modelContext: ModelContext) {
//            self.detector = detector
//            self.modelContext = modelContext
//            super.init()
//        }
//
//        // request: looking for faces:
//        lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
//            return VNDetectFaceRectanglesRequest { [weak self] request, error in
//                guard let self = self else { return }
//
//                if let results = request.results as? [VNFaceObservation], let result = results.first {
//                    self.processFaceObservation(result)
//                } else {
//                    self.clearFaceData()
//                }
//            }
//        }()
//
//        func session(_ session: ARSession, didUpdate frame: ARFrame) {
//            // High frequency UI update for bounding box (every frame)
//
//            // 1. Throttle Detection
//            guard !isProcessing, Date().timeIntervalSince(lastScanTime) > 0.5 else { return }
//            isProcessing = true
//            lastScanTime = Date()
//
//            guard let copiedBuffer = frame.capturedImage.copy() else {
//                 self.isProcessing = false
//                 return
//            }
//
//            let pixelBufferWrapper = SendablePixelBuffer(buffer: copiedBuffer)
//            self.currentWrapper = pixelBufferWrapper
//
//            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//                guard let self = self else { return }
//
//                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBufferWrapper.buffer, orientation: .right)
//
//                do {
//                    try handler.perform([self.faceDetectionRequest])
//                } catch {
//                    print("Vision Request Failed")
//                    DispatchQueue.main.async { self.isProcessing = false }
//                }
//            }
//        }
//
//        func processFaceObservation(_ observation: VNFaceObservation) {
//            // 1. Update UI Location (Main Thread)
//            // Extract value type (CGRect) to avoid capturing non-sendable VNFaceObservation
//            let boundingBox = observation.boundingBox
//            DispatchQueue.main.async {
//                self.updateFaceRect(boundingBox: boundingBox)
//            }
//
//            // 2. Perform Recognition (Background) if needed
//            // Use the sendable wrapper if available to ensure safety when passing to Task
//            if let wrapper = self.currentWrapper {
//                 self.performRecognition(wrapper: wrapper, faceRect: boundingBox)
//            }
//        }
//
//        // We will call this from within the session dispatch block after perform returns
//        func performRecognition(wrapper: SendablePixelBuffer, faceRect: CGRect) {
//             Task {
//                // 1. Generate Embedding
//                // We pass .right orientation because ARKit buffers (on iPhone Portrait) are landscape (Sensor orientation),
//                // but the faceRect is in relation to the "Upright" (Portrait) orientation.
//                // Our new resizeForMobileFaceNet(..., orientation: .right) handles this:
//                // It treats the buffer as if it is rotated 90deg CW, and applies the crop rect in that space.
//                if let embedding = await FaceRecognitionService.shared.generateEmbedding(from: wrapper.buffer, faceRect: faceRect, orientation: .right) {
//
//                    // 2. Fetch Candidates (Directly from Context, no cache)
//                    // We must do this on MainActor because ModelContext is main-thread bound usually, or we use a background context.
//                    // Assuming safe to fetch on MainActor for now as per original design.
//                    let candidates = await MainActor.run {
//                        let descriptor = FetchDescriptor<Person>()
//                        if let allPersons = try? self.modelContext.fetch(descriptor) {
//                             return allPersons.map { ($0.persistentModelID, $0.faceEmbedding) }
//                        }
//                        return []
//                    }
//
//                    let matchResult = await FaceRecognitionService.shared.findBestMatch(for: embedding, candidates: candidates)
//
//                    await MainActor.run {
//                        if let (matchedID, confidence) = matchResult {
//                            // Fetch object only when needed for display properties
//                            if let person = try? self.modelContext.fetch(FetchDescriptor<Person>(predicate: #Predicate { $0.persistentModelID == matchedID })).first {
//                                self.detector.identifiedPerson = person
//                                self.detector.confidence = confidence
//                                self.detector.isUnknown = false
//                            }
//                        } else {
//                            self.detector.identifiedPerson = nil
//                            self.detector.confidence = 0.0
//                            self.detector.isUnknown = true
//                        }
//
//                         // Capture snapshot for registration
//                        let ciImage = CIImage(cvPixelBuffer: wrapper.buffer)
//                        let context = CIContext()
//                        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
//                            self.detector.lastCapturedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
//                        }
//                    }
//                }
//             }
//        }
//
//        func updateFaceRect(boundingBox: CGRect) {
//             guard let arView = self.arView, let frame = arView.session.currentFrame else { return }
//
//             let viewSize = arView.bounds.size
//
//             // Coordinate Transformation
//             // 1. Vision Rect is Normalized (0,0 bottom-left).
//             // 2. `displayTransform` expects Normalized Image Coordinates (0,0 top-left).
//             // Therefore, we flip Y.
//             var normalizedImageRect = boundingBox
//             normalizedImageRect.origin.y = 1.0 - normalizedImageRect.maxY // Flip origin to top-left
//
//             // 3. Apply ARKit Display Transform (handles Aspect Fill cropping & rotation)
//             let transform = frame.displayTransform(for: .portrait, viewportSize: viewSize)
//             let screenRectNormalized = normalizedImageRect.applying(transform)
//
//             // 4. Scale to View Size
//             let x = screenRectNormalized.origin.x * viewSize.width
//             let y = screenRectNormalized.origin.y * viewSize.height
//             let w = screenRectNormalized.width * viewSize.width
//             let h = screenRectNormalized.height * viewSize.height
//
//             self.detector.faceRect = CGRect(x: x, y: y, width: w, height: h)
//
//             // Unlock processing
//             self.isProcessing = false
//        }
//
//        func clearFaceData() {
//            DispatchQueue.main.async {
//                self.detector.faceRect = nil
//                self.detector.isUnknown = false
//                self.isProcessing = false
//            }
//        }
//    }
//}
//
//
//
//extension ARViewContainer.Coordinator: @unchecked Sendable {}
//struct SendablePixelBuffer: @unchecked Sendable {
//    let buffer: CVPixelBuffer
//}
//
//extension CVPixelBuffer {
//    func copy() -> CVPixelBuffer? {
//        let width = CVPixelBufferGetWidth(self)
//        let height = CVPixelBufferGetHeight(self)
//        let format = CVPixelBufferGetPixelFormatType(self)
//        var newBuffer: CVPixelBuffer?
//
//        // Create new buffer with same attributes
//        let status = CVPixelBufferCreate(nil, width, height, format, nil, &newBuffer)
//        guard status == kCVReturnSuccess, let destination = newBuffer else { return nil }
//
//        CVPixelBufferLockBaseAddress(self, .readOnly)
//        CVPixelBufferLockBaseAddress(destination, [])
//        defer {
//            CVPixelBufferUnlockBaseAddress(self, .readOnly)
//            CVPixelBufferUnlockBaseAddress(destination, [])
//        }
//
//        if CVPixelBufferIsPlanar(self) {
//            let planeCount = CVPixelBufferGetPlaneCount(self)
//            for plane in 0..<planeCount {
//                guard let srcAddr = CVPixelBufferGetBaseAddressOfPlane(self, plane),
//                      let dstAddr = CVPixelBufferGetBaseAddressOfPlane(destination, plane) else { continue }
//
//                let height = CVPixelBufferGetHeightOfPlane(self, plane)
//                let bytesPerRowSrc = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
//                let bytesPerRowDst = CVPixelBufferGetBytesPerRowOfPlane(destination, plane)
//
//                if bytesPerRowSrc == bytesPerRowDst {
//                    // Optimized: Copy full plane if strides match
//                    let planeSize = height * bytesPerRowSrc
//                    memcpy(dstAddr, srcAddr, planeSize)
//                } else {
//                    // Safe: Copy row by row
//                    let rowBytes = min(bytesPerRowSrc, bytesPerRowDst) // Copy min width (should be same logical width)
//                    for line in 0..<height {
//                        let srcPtr = srcAddr.advanced(by: line * bytesPerRowSrc)
//                        let dstPtr = dstAddr.advanced(by: line * bytesPerRowDst)
//                        memcpy(dstPtr, srcPtr, rowBytes)
//                    }
//                }
//            }
//        } else {
//            // Non-Planar (e.g. BGRA)
//            guard let srcAddr = CVPixelBufferGetBaseAddress(self),
//                  let dstAddr = CVPixelBufferGetBaseAddress(destination) else { return nil }
//
//            let bytesPerRowSrc = CVPixelBufferGetBytesPerRow(self)
//            let bytesPerRowDst = CVPixelBufferGetBytesPerRow(destination)
//
//            if bytesPerRowSrc == bytesPerRowDst {
//                let size = CVPixelBufferGetDataSize(destination) // Or height * stride
//                memcpy(dstAddr, srcAddr, size)
//            } else {
//                let rowBytes = min(bytesPerRowSrc, bytesPerRowDst)
//                for line in 0..<height {
//                    let srcPtr = srcAddr.advanced(by: line * bytesPerRowSrc)
//                    let dstPtr = dstAddr.advanced(by: line * bytesPerRowDst)
//                    memcpy(dstPtr, srcPtr, rowBytes)
//                }
//            }
//        }
//
//        return destination
//    }
//}

struct ARViewContainer: UIViewRepresentable {
    
    // initialized coordinator:
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        // building the actual AR View that the user sees:
        let arView = ARView(frame: .zero) // frame zero doesn't matter, SwiftUI will handle placement on screen
        
        let config = ARWorldTrackingConfiguration() // World means use rear camera
        
        arView.session.run(config)
        
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // code if need be
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        var isProcessing = false // because updates are sent 60 times a second, and need to handle instances where the handler is busy with the previous frame processing request
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // triggered automatically by ARKit 60 times a second
            // frame: ARFrame contains everything we need from that second (we are concerned about the image camera captured during that time)
            
            guard !isProcessing else { return } // busy safeguard
            
            isProcessing = true
            
            // creating request to Vision framework to detect faces in frame:
            let faceRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in // use weak self to make sure memory freed in edge cases
                
                guard let self = self else { return } // because we used weak self
                
                // TASKS TO PERFORM WHEN FACE FOUND ON-SCREEN:
                if let results = request.results as? [VNFaceObservation], let firstFace = results.first {
                    
                    print("Face detection in progress")
                    
                    if let croppedBuffer = frame.capturedImage.resizeForMobileFaceNet(cropRect: firstFace.boundingBox) {
                        
                        // async task to interact with ML Model:
                        Task {
                            
                            
                        }
                    }
                    
                    self.isProcessing = false // making sure we end the processing at the end
                }
            }
            
            // firing off the face request we defined above:
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: .right) // .right because camera sensors store in landscape left by default for some reason
            
            do {
                try imageRequestHandler.perform([faceRequest])
            } catch {
                print("Failed to perform vision request: \(error)")
                self.isProcessing = false // ending processing forcefully
            }
        }
        
        
        
        
    }
    
    
    
}
