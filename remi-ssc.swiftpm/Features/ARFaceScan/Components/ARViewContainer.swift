import SwiftUI
import ARKit
import Vision

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var detector: FaceDetector
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        // Configure the AR session
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(detector: detector)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, ARSessionDelegate {
        
        // face detector:
        let detector: FaceDetector
        init(detector: FaceDetector) {
            self.detector = detector
        }
        
        // Flag to prevent clogging the thread
        private var isProcessing = false
        private var lastSaveTime = Date.distantPast
        private var lastDebugTime = Date.distantPast
        
        // MARK: - ARSessionDelegate
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard !isProcessing else { return }
            isProcessing = true
            
            // capture the pixel buffer
            let pixelBuffer = frame.capturedImage
            
            let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
                guard let self = self else { return }
                
                if let results = request.results as? [VNFaceObservation], let face = results.first {
                    
                    self.handleDetectedFace(face)
                    
                    self.debugFaceScan(pixelBuffer: pixelBuffer)
                } else {
                    let detector = self.detector
                    Task { @MainActor in
                        detector.faceRect = nil
                    }
                }
                
                self.isProcessing = false
            }
            
            // 4. Perform the request
            // Portrait AR usually requires .right orientation
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try imageRequestHandler.perform([request])
                } catch {
                    print("Failed to perform Vision request: \(error)")
                    self.isProcessing = false
                }
            }
        }
        
        // MARK: - Helper Methods
        private func handleDetectedFace(_ observation: VNFaceObservation) {
            
            // throttling face detection to every 0.5 seconds
            guard Date().timeIntervalSince(lastSaveTime) > 0.5 else { return }
            lastSaveTime = Date()
            
            // applying 15% increase in both dir as padding (for ml model):
            let boundingBox = observation.boundingBox
            let scaleTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
            // saving in detector (it will cause the face scan rectangle to move on the screen)
            let detector = self.detector
            Task { @MainActor in
                detector.faceRect = boundingBox.applying(scaleTransform)
            }
        }
        
        private func debugFaceScan(pixelBuffer: CVPixelBuffer) {
            // Check throttle (e.g., save only once every 2 seconds)
            guard Date().timeIntervalSince(lastDebugTime) > 2.0 else { return }
            lastDebugTime = Date()

            // Convert to UIImage (ensure you have the extension I provided earlier)
            // We use .right because ARKit buffers are usually rotated 90 degrees
            guard let image = pixelBuffer.toUIImage(orientation: .right),
                  let data = image.jpegData(compressionQuality: 0.8) else {
                print("Error converting pixel buffer")
                return
            }
            
            let filename = "face_capture_\(Int(Date().timeIntervalSince1970)).jpg"
            
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                
                do {
                    try data.write(to: fileURL)
                    print("💾 Image Saved: \(fileURL.path)")
                } catch {
                    print("❌ Error saving image: \(error)")
                }
            }
        }
    }
}
