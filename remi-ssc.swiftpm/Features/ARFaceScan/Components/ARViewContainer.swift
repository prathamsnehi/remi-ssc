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
                    
                    self.handleDetectedFace(face, pixelBuffer: pixelBuffer)
                    
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
        private func handleDetectedFace(_ observation: VNFaceObservation, pixelBuffer: CVPixelBuffer) {
            
            // throttling face detection to every 0.5 seconds
            guard Date().timeIntervalSince(lastSaveTime) > 0.5 else { return }
            lastSaveTime = Date()
            
            // applying square padding logic:
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            let expandedRect = getSquareFaceRect(observation.boundingBox, bufferSize: bufferSize)
            
            // saving in detector (it will cause the face scan rectangle to move on the screen)
            let detector = self.detector
            Task { @MainActor in
                detector.faceRect = expandedRect
            }
            
            self.debugFaceScan(pixelBuffer: pixelBuffer, cropRect: expandedRect)
        }
        
        private func debugFaceScan(pixelBuffer: CVPixelBuffer, cropRect: CGRect) {
            // Check throttle (e.g., save only once every 1 second)
            guard Date().timeIntervalSince(lastDebugTime) > 1.0 else { return }
            lastDebugTime = Date()

            // Using CIImage to rotate and crop (can't do these operations on pixel buffer)
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
            let context = CIContext()
            
            // Map normalized cropRect to pixel coordinates
            let cropX = cropRect.origin.x * ciImage.extent.width
            let cropY = cropRect.origin.y * ciImage.extent.height
            let cropW = cropRect.width * ciImage.extent.width
            let cropH = cropRect.height * ciImage.extent.height
            
            let ciCropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
            let croppedCiImage = ciImage.cropped(to: ciCropRect)
            
            guard let cgImageResult = context.createCGImage(croppedCiImage, from: croppedCiImage.extent) else { return }
            let finalImage = UIImage(cgImage: cgImageResult)
            
            guard let data = finalImage.jpegData(compressionQuality: 0.8) else {
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

private func getSquareFaceRect(_ rect: CGRect, bufferSize: CGSize) -> CGRect {
    // 1. Calculate the oriented size (ARKit buffers are landscape, we use .right orientation)
    // Buffer is [W: 1920, H: 1080], oriented portrait it becomes [W: 1080, H: 1920]
    let orientedWidth = bufferSize.height
    let orientedHeight = bufferSize.width
    
    // 2. Map normalized center and dimensions to pixels
    let centerX = rect.midX * orientedWidth
    let centerY = rect.midY * orientedHeight
    let faceWidthPx = rect.width * orientedWidth
    let faceHeightPx = rect.height * orientedHeight
    
    // 3. Size our square based on the larger dimension (usually height)
    // Using 1.6x padding to ensure we get the whole head + context
    let sidePx = max(faceWidthPx, faceHeightPx) * 1.6
    
    // 4. Create the square in pixel space
    var squarePx = CGRect(
        x: centerX - sidePx / 2,
        y: centerY - sidePx / 2,
        width: sidePx,
        height: sidePx
    )
    
    // 5. Shift UP in pixels to capture hairline (Vision 0 is bottom, so += moves up)
    squarePx.origin.y += sidePx * 0.12
    
    // 6. Convert BACK to normalized coordinates [0, 1] for the detector
    return CGRect(
        x: squarePx.origin.x / orientedWidth,
        y: squarePx.origin.y / orientedHeight,
        width: squarePx.width / orientedWidth,
        height: squarePx.height / orientedHeight
    )
}
