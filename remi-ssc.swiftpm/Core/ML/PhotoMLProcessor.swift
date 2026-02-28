import SwiftUI
import CoreML
@preconcurrency import Vision
import SwiftData

final class ContinuationWrapper<T: Sendable> {
    private var continuation: CheckedContinuation<T, Never>?
    private let lock = NSLock()
    
    init(_ continuation: CheckedContinuation<T, Never>) {
        self.continuation = continuation
    }
    
    func resume(returning value: T) {
        lock.lock()
        defer { lock.unlock() }
        if let cont = continuation {
            self.continuation = nil
            cont.resume(returning: value)
        }
    }
}

@MainActor
class PhotoMLProcessor: ObservableObject {
    private let ciContext = CIContext()
    private let recognizer: FaceRecognitionService
    var detector: FaceDetector // For logging or fallback reference if needed
    
    @Published var isProcessing = false
    @Published var finalMatchingResult: (Person, Float)? = nil
    @Published var processedImageForRegistration: UIImage? = nil
    @Published var generatedEmbeddingsForRegistration: [[Float]]? = nil
    
    init(detector: FaceDetector) {
        self.detector = detector
        self.recognizer = FaceRecognitionService(detector: detector)
    }
    
    /// Processes a single UIImage.
    /// Returns either a match (Person, Confidence), or sets up the properties for Registration.
    func processSelectedImage(_ image: UIImage) async {
        self.isProcessing = true
        self.finalMatchingResult = nil
        self.processedImageForRegistration = nil
        self.generatedEmbeddingsForRegistration = nil
        
        // 1. Convert UIImage to CVPixelBuffer
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("❌ PhotoMLProcessor: Could not convert UIImage to CVPixelBuffer")
            self.isProcessing = false
            return
        }
        
        // 2. Perform Vision Request securely off the MainActor
        let faceObservation = await self.detectFace(in: pixelBuffer)
        
        if let face = faceObservation {
            print("✅ Face detected in photo!")
            await self.handleDetectedFace(face, pixelBuffer: pixelBuffer, originalImage: image)
            self.isProcessing = false
        } else {
            print("❌ No face detected in photo.")
            self.isProcessing = false
        }
    }
    
    // MARK: - Vision Execution (Safe from MainActor)
    nonisolated private func detectFace(in pixelBuffer: CVPixelBuffer) async -> VNFaceObservation? {
        // UnsafeTransfer to securely pass the CVPixelBuffer across concurrency domains
        let bufferTransfer = UnsafeTransfer(value: pixelBuffer)
        
        return await withCheckedContinuation { continuation in
            let wrapper = ContinuationWrapper(continuation)
            
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let results = request.results as? [VNFaceObservation], let face = results.first {
                    wrapper.resume(returning: face)
                } else {
                    wrapper.resume(returning: nil)
                }
            }
            
            let safeBuffer = bufferTransfer.value
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: safeBuffer, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try imageRequestHandler.perform([request])
                } catch {
                    print("⚠️ Failed to perform Vision request on pixel buffer: \(error)")
                    print("🔄 Falling back to CGImage request (common on Simulators)...")
                    
                    // Fallback for Simulator Architecture (Could not create inference context)
                    do {
                        let ciImage = CIImage(cvPixelBuffer: safeBuffer)
                        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
                            wrapper.resume(returning: nil)
                            return
                        }
                        
                        let fallbackHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                        try fallbackHandler.perform([request])
                    } catch {
                        print("❌ Failed fallback Vision request on photo: \(error)")
                        wrapper.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Direct Copy of ARViewContainer logic
    private func handleDetectedFace(_ observation: VNFaceObservation, pixelBuffer: CVPixelBuffer, originalImage: UIImage) async {
        
        // In AR mode, we check head tilt here. For photos we might be more lenient,
        // but keeping it structural.
        if let yaw = observation.yaw?.doubleValue, abs(yaw) > 0.5 {
            print("⚠️ Face is tilted in photo, ML embeddings might be degraded.")
            // We'll proceed anyway for static photos since they chose this photo
        }
        
        let bufferSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        let mlRect = getSquareFaceRect(observation.boundingBox, bufferSize: bufferSize)
        
        // perfectly cropped buffer
        guard let croppedFaceBuffer = extractCroppedFacePixelBuffer(from: pixelBuffer, normalizedRect: mlRect, context: self.ciContext) else {
            print("❌ PhotoMLProcessor: couldn't crop pixel buffer")
            return
        }
        
        // Debug the face crop just like ARView
        self.debugFaceScan(pixelBuffer: croppedFaceBuffer, suffix: "photo")
        
        let modelInput = UnsafeTransfer(value: croppedFaceBuffer)
        
        Task { [recognizer = self.recognizer, modelInput, originalImage] in
            let inputBuffer = modelInput.value
            
            // GENERATE EMBEDDING
            guard let faceEmbedding = await recognizer.generateEmbedding(from: inputBuffer) else {
                print("❌ PhotoMLProcessor: Couldn't generate embedding")
                return
            }
            
            
            // IDENTIFICATION
            // Since we need detector.personLookupMap, we fetch it asynchronously or pass it in. 
            // In ARViewContainer it does `await detector.personLookupMap`. Let's do that:
            let candidateMap = await self.detector.personLookupMap
            
            if let (bestMatchId, confidence) = await recognizer.identify(probeVector: faceEmbedding, candidateMap: candidateMap) {
                
                // Match Found!
                await MainActor.run {
                    if let match = self.detector.savedPersons.first(where: { $0.id == bestMatchId }) {
                        print("✅ PhotoMLProcessor: Match configured -> \(match.name) (\(confidence))")
                        self.finalMatchingResult = (match, confidence)
                    } else {
                        print("⚠️ PhotoMLProcessor: Match ID found but Person missing.")
                        self.setupForRegistrationFallback(originalImage: originalImage, embedding: faceEmbedding)
                    }
                }
                
            } else {
                // No Match Found -> Prepare Registration payload
                print("❌ PhotoMLProcessor: No match found. Prepping registration payload.")
                await MainActor.run {
                    self.setupForRegistrationFallback(originalImage: originalImage, embedding: faceEmbedding)
                }
            }
        }
    }
    
    private func setupForRegistrationFallback(originalImage: UIImage, embedding: [Float]) {
        self.generatedEmbeddingsForRegistration = [embedding]
        
        // Preserve the exact orientation of the UIImage the user selected
        // We use the raw UIImage instead of converting back from the CVPixelBuffer 
        // because the buffer strips EXIF rotation data.
        self.processedImageForRegistration = originalImage
    }
    
    // MARK: - Duplicated Helpers (As requested by user: DO NOT DRY)
    private func getSquareFaceRect(_ rect: CGRect, bufferSize: CGSize) -> CGRect {
        // ARKit buffers use oriented height/width.
        // For static UIImage, bufferSize is true size
        let orientedWidth = bufferSize.width
        let orientedHeight = bufferSize.height
        
        let centerX = rect.midX * orientedWidth
        let centerY = rect.midY * orientedHeight 
        let faceWidthPx = rect.width * orientedWidth
        let faceHeightPx = rect.height * orientedHeight
        
        let sidePx = max(faceWidthPx, faceHeightPx) * 1.6
        
        var squarePx = CGRect(
            x: centerX - sidePx / 2,
            y: centerY - sidePx / 2,
            width: sidePx,
            height: sidePx
        )
        
        // shift UP in pixels to capture hairline
        squarePx.origin.y += sidePx * 0.12 
        
        return CGRect(
            x: squarePx.origin.x / orientedWidth,
            y: squarePx.origin.y / orientedHeight,
            width: squarePx.width / orientedWidth,
            height: squarePx.height / orientedHeight
        )
    }

    private func extractCroppedFacePixelBuffer(from uncroppedBuffer: CVPixelBuffer, normalizedRect: CGRect, context: CIContext) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: uncroppedBuffer)
        
        let cropX = normalizedRect.origin.x * ciImage.extent.width
        let cropY = normalizedRect.origin.y * ciImage.extent.height
        let cropW = normalizedRect.width * ciImage.extent.width
        let cropH = normalizedRect.height * ciImage.extent.height
        
        let pixelCropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
        let croppedImage = ciImage.cropped(to: pixelCropRect)
        
        let translation = CGAffineTransform(translationX: -pixelCropRect.origin.x,
                                            y: -pixelCropRect.origin.y)
        
        let targetSize = CGSize(width: 112, height: 112)
        let scaleX = targetSize.width / pixelCropRect.width
        let scaleY = targetSize.height / pixelCropRect.height
        let scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let finalTransform = translation.concatenating(scale)
        let finalImage = croppedImage.transformed(by: finalTransform)
        
        var newPixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferWidthKey: Int(targetSize.width),
            kCVPixelBufferHeightKey: Int(targetSize.height),
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(targetSize.width),
                                         Int(targetSize.height),
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &newPixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = newPixelBuffer else {
            return nil
        }
        
        context.render(finalImage, to: buffer)
        
        return buffer
    }
    
    // MARK: Debug Methods
    private func debugFaceScan(pixelBuffer: CVPixelBuffer, suffix: String = "photo") {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImageResult = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let finalImage = UIImage(cgImage: cgImageResult)
        
        guard let data = finalImage.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let filename = "face_capture_\(suffix)_\(Int(Date().timeIntervalSince1970)).jpg"
        
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            do {
                try data.write(to: fileURL)
            } catch {
                print("❌ Error saving debug ML image: \(error)")
            }
        }
    }
}

// MARK: - Extension to Convert UIImage to CVPixelBuffer
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        // Use true pixel dimensions instead of UI points
        let width = Int(self.size.width * self.scale)
        let height = Int(self.size.height * self.scale)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        // CIImage directly handles UIImage EXIF orientation and color space conversions automatically
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        
        // Render flawlessly across Device & Simulator architectures
        let context = CIContext()
        context.render(ciImage, to: buffer)
        
        return buffer
    }
}

// MARK: - Photo Jpeg Helper (No Rotations)
extension CVPixelBuffer {
    func photoJpegData(croppedTo normalizedRect: CGRect, quality: CGFloat = 0.8) -> Data? {
        let ciImage = CIImage(cvPixelBuffer: self) // NO .oriented(.right)
        
        let pixelRect = CGRect(
            x: normalizedRect.origin.x * ciImage.extent.width,
            y: normalizedRect.origin.y * ciImage.extent.height,
            width: normalizedRect.width * ciImage.extent.width,
            height: normalizedRect.height * ciImage.extent.height
        )
        
        let cropped = ciImage.cropped(to: pixelRect)
        let uiImage = UIImage(ciImage: cropped)
        return uiImage.jpegData(compressionQuality: quality)
    }
}
