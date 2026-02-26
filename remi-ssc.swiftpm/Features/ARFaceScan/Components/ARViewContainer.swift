import SwiftUI
import ARKit
@preconcurrency import Vision

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var detector: FaceDetector
    var savedPersons: [Person] // synced with SwiftData (source of truth)
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        // Configure the AR session
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // syncing SwiftData data to fetch latest People data
        // and store it in the detector
        if detector.savedPersons != savedPersons {
            DispatchQueue.main.async {
                detector.savedPersons = savedPersons
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(detector: detector)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, ARSessionDelegate {
        
        // creating ciContext once (less hardware intensive rather than creating multiple times a second in helper methods)
        private let ciContext = CIContext() // used for cropping the buffer for each face observation
        
        // face recognition services:
        private let recognizer: FaceRecognitionService
        
        // face detector:
        let detector: FaceDetector
        init(detector: FaceDetector) {
            self.detector = detector
            self.recognizer = FaceRecognitionService(detector: detector)
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
                
                let detector = self.detector
                
                if let results = request.results as? [VNFaceObservation], let face = results.first {
                    
                    // when the person is found on-screen:
                    Task { await detector.setPersonOnCamera(true)}
                    self.handleDetectedFace(face, pixelBuffer: pixelBuffer)
                    
                } else {
                    // when no faces are found on the screen:
                    Task { await detector.resetFaceDetector()}
                }
                
                self.isProcessing = false
            }
            
            // perform the request
            // portrait AR usually requires .right orientation
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
        
        // MARK: Session Methods:
        private func handleDetectedFace(_ observation: VNFaceObservation, pixelBuffer: CVPixelBuffer) {
            let detector = self.detector
            
            // checking to make sure observation quality is upto the mark:
            if checkFaceObservationQuality(observation: observation) != true { return } // checks for basic face scan killers (face tilt, blurry, etc. If this is case, give UI error and don't generate embedding
            
            
            // throttling face detection to every 0.5 seconds
            guard Date().timeIntervalSince(lastSaveTime) > 0.5 else { return }
            lastSaveTime = Date()
            
            // proceed if no problems detected with the scan:
            Task { await detector.resetDetectorErrorStatus() }
            
            
            // separate bounding boxes depending on UI or ML Calculations:
            let uiRect = observation.boundingBox // narrower bounding box for tight UI
            
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            let mlRect = getSquareFaceRect(observation.boundingBox, bufferSize: bufferSize) // normalized CGRect for ml prediction on image
            
            // saving in detector (it will cause the face scan rectangle to move on the screen)
            Task {
                await detector.setUIFaceRect(uiRect) // <- uiRect because it only impacts the UI
            }
            
            // this croppedFaceBuffer is the perfectly cropped buffer needed to feed into the ml model
            guard let croppedFaceBuffer: CVPixelBuffer = extractCroppedFacePixelBuffer(from: pixelBuffer, normalizedRect: mlRect, context: self.ciContext) else {
                print("Error bro, couldn't crop pixel buffer")
                return
            }
            
            let modelInput = UnsafeTransfer(value: croppedFaceBuffer) // to safely pass to a Task block
            let originalInput = UnsafeTransfer(value: pixelBuffer)
            
            // face recognition pipeline flow:
            Task { [recognizer = self.recognizer, modelInput] in // because ml model interactions is async
                let inputBuffer = modelInput.value
                let originalBuffer = originalInput.value // for converting to jpeg and save as user's registration photo
                
                
                // 1. get embedding
                guard let faceEmbedding = await recognizer.generateEmbedding(from: inputBuffer) else {
                    print("Couldn't generate embedding")
                    return
                }
                
                // REGISTRATION SCAN FLOW
                // based on the flow, this is the perfect place to put that logic
                if (await detector.isScanning) {
                    await detector.addRegistrationEmbedding(faceEmbedding)
                    
                    if await detector.registrationImage == nil {
                        // only one time save the person's photo when clicked on the scan button on frontend
                        if let uiImage = originalBuffer.toUIImage(orientation: .right),
                           let jpegData = uiImage.jpegData(compressionQuality: 1.0) {
                            await detector.saveRegistrationPhoto(jpegData)
                        }
                    }
                    return // because the stuff ahead of this is the logic of detecting match: we're not finding a match when scanning and storing embeddings for a person
                }
                
                // FACE DETECTION FLOW:
                let candidateMap: [UUID: [[Float]]] = await detector.personLookupMap
                
                // find if there is a match
                guard let (bestMatchId, confidence) = await recognizer.identify(probeVector: faceEmbedding, candidateMap: candidateMap) else {
                    // no match logic, try going to the registration screen
                    await detector.setUnidentifiedFace() // sets identifiedPerson to nil for the frontend logic
                    return
                }
                
                // find the person who matches with that Id, adding this info + confidence in the detector
                
                // yes match, update detector to include the detected person for UI:
                await detector.setIdentifiedFace(id: bestMatchId, confidence: confidence)
                
                print("VECTOR GENERATED: \(faceEmbedding)")
                print("VECTOR SIZE: \(faceEmbedding.count)")
            }
            
            self.debugFaceScan(pixelBuffer: croppedFaceBuffer)
        }
        
        // MARK: Detector Helper Methods:
        private func checkFaceObservationQuality(observation: VNFaceObservation) -> Bool {
            let detector = self.detector
            
            // scanning for face tilt (yaw):
            if let yaw = observation.yaw?.doubleValue, abs(yaw) > 0.5 {
                Task { await detector.showUIError(errorType: .headTilted) }
                return false
            }
            
            // if made it through, observation quality is good, so:
            return true
        }
        
        
        // MARK: Debug Methods:
        private func debugFaceScan(pixelBuffer: CVPixelBuffer) {
            // Check throttle (e.g., save only once every 1 second)
            guard Date().timeIntervalSince(lastDebugTime) > 1.0 else { return }
            lastDebugTime = Date()
            
            // Using CIImage to rotate and crop (can't do these operations on pixel buffer)
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            
            guard let cgImageResult = context.createCGImage(ciImage, from: ciImage.extent) else { return }
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

// MARK: Buffer Cropping Helpers:
private func getSquareFaceRect(_ rect: CGRect, bufferSize: CGSize) -> CGRect {
    // golder cropping ratio crop (perfectly includes the whole face, and gives coordinates of a square
    // job: give squares of the perfect crop, and pass to the function extractCroppedFacePixelBuffer
    
    // calculate the oriented size (ARKit buffers are landscape, we use .right orientation)
    // buffer is [W: 1920, H: 1080], oriented portrait it becomes [W: 1080, H: 1920]
    let orientedWidth = bufferSize.height
    let orientedHeight = bufferSize.width
    
    // map normalized center and dimensions to pixels
    let centerX = rect.midX * orientedWidth
    let centerY = rect.midY * orientedHeight
    let faceWidthPx = rect.width * orientedWidth
    let faceHeightPx = rect.height * orientedHeight
    
    // size our square based on the larger dimension (usually height)
    // using 1.6x padding to ensure we get the whole head + context
    let sidePx = max(faceWidthPx, faceHeightPx) * 1.6
    
    // create the square in pixel space
    var squarePx = CGRect(
        x: centerX - sidePx / 2,
        y: centerY - sidePx / 2,
        width: sidePx,
        height: sidePx
    )
    
    // shift UP in pixels to capture hairline (Vision 0 is bottom, so += moves up)
    squarePx.origin.y += sidePx * 0.12
    
    // convert BACK to normalized coordinates [0, 1] for the detector
    return CGRect(
        x: squarePx.origin.x / orientedWidth,
        y: squarePx.origin.y / orientedHeight,
        width: squarePx.width / orientedWidth,
        height: squarePx.height / orientedHeight
    )
}

private func extractCroppedFacePixelBuffer(from uncroppedBuffer: CVPixelBuffer, normalizedRect: CGRect, context: CIContext) -> CVPixelBuffer? {
    // job: take the crop from getSquareFaceRect, and turn it into a CVPixelBuffer
    // create the CIImage and orient it properly
    let ciImage = CIImage(cvPixelBuffer: uncroppedBuffer).oriented(.right)
    
    let cropX = normalizedRect.origin.x * ciImage.extent.width
    let cropY = normalizedRect.origin.y * ciImage.extent.height
    let cropW = normalizedRect.width * ciImage.extent.width
    let cropH = normalizedRect.height * ciImage.extent.height
    
    let pixelCropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
    let croppedImage = ciImage.cropped(to: pixelCropRect)
    
    // move to origin and scale
    // problem: 'croppedImage' is still floating at (x: 500, y: 500).
    // fix: we must move it to (0,0) and scale it to 112x112.
    
    // move to (0,0)
    let translation = CGAffineTransform(translationX: -pixelCropRect.origin.x,
                                        y: -pixelCropRect.origin.y)
    
    // B. Scale to 112x112
    // We calculate how much we need to shrink/grow to hit exactly 112px.
    let targetSize = CGSize(width: 112, height: 112)
    let scaleX = targetSize.width / pixelCropRect.width
    let scaleY = targetSize.height / pixelCropRect.height
    let scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
    
    // combine transforms: move first, then scale
    let finalTransform = translation.concatenating(scale)
    let finalImage = croppedImage.transformed(by: finalTransform)
    
    // render to pixel buffer (efficiently)
    // reuse the logic from the extension I gave you, or inline it here.
    // ideally, make sure 'self.ciContext' is a property of Coordinator so we reuse it.
    
    var newPixelBuffer: CVPixelBuffer?
    let attrs = [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
        kCVPixelBufferWidthKey: Int(targetSize.width),
        kCVPixelBufferHeightKey: Int(targetSize.height),
        kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA // SFace Requirement
    ] as CFDictionary
    
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     Int(targetSize.width),
                                     Int(targetSize.height),
                                     kCVPixelFormatType_32BGRA,
                                     attrs,
                                     &newPixelBuffer)
    
    guard status == kCVReturnSuccess, let buffer = newPixelBuffer else {
        print("Failed to create pixel buffer")
        return nil
    }
    
    context.render(finalImage, to: buffer)
    
    return buffer
}

/// A generic wrapper to safely pass non-Sendable types (like CVPixelBuffer)
struct UnsafeTransfer<T>: @unchecked Sendable {
    let value: T
}

