import SwiftUI
import ARKit
import Vision

struct ARViewContainer: UIViewRepresentable {
    
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
        Coordinator()
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, ARSessionDelegate {
        
        // Flag to prevent clogging the thread
        private var isProcessing = false
        private var lastSaveTime = Date.distantPast
        
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
                    
                    // debugger function call:
                    self.debugFaceScan(pixelBuffer: pixelBuffer)
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
            let boundingBox = observation.boundingBox
            let x = String(format: "%.2f", boundingBox.origin.x)
            let y = String(format: "%.2f", boundingBox.origin.y)
            let w = String(format: "%.2f", boundingBox.width)
            let h = String(format: "%.2f", boundingBox.height)
            
            print("👤 Face Detected! [x: \(x), y: \(y), w: \(w), h: \(h)]")
        }
        
        private func debugFaceScan(pixelBuffer: CVPixelBuffer) {
            // Check throttle (e.g., save only once every 2 seconds)
            guard Date().timeIntervalSince(lastSaveTime) > 2.0 else { return }
            lastSaveTime = Date()

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
