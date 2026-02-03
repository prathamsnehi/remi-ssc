import UIKit
import Vision
import SwiftUI
import ImageIO // Required for CGImagePropertyOrientation
import VideoToolbox
import CoreImage
import CoreVideo


extension UIImage {
    
    // 1. Helper to convert UIImage.Orientation to CGImagePropertyOrientation
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
    
    /// Detects the center of the first face found in the image.
    /// Returns a UnitPoint where (0,0) is top-left and (1,1) is bottom-right.
    /// Returns nil if no face is found.
    func detectFaceCenter() -> UnitPoint? {
        guard let cgImage = self.cgImage else { return nil }
        
        let request = VNDetectFaceRectanglesRequest()
        
        // 2. Use the new helper property here
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: self.cgImagePropertyOrientation, options: [:])
        
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else { return nil }
            
            // Vision coordinates: Origin is bottom-left, normalized 0...1
            let boundingBox = observation.boundingBox
            
            // Calculate center
            let x = boundingBox.midX
            let y = 1.0 - boundingBox.midY // Flip Y for SwiftUI coordinate system (top-left origin)
            
            return UnitPoint(x: x, y: y)
        } catch {
            print("Face detection failed: \(error)")
            return nil
        }
    }
}


extension CVPixelBuffer {
    func toUIImage(orientation: UIImage.Orientation = .up) -> UIImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        
        guard let createdCGImage = cgImage else { return nil }
        return UIImage(cgImage: createdCGImage, scale: 1.0, orientation: orientation)
    }
    
    /// Returns a cropped JPEG from the pixel buffer, oriented to `.right`.
    /// - Parameters:
    ///   - normalizedRect: The rect in normalized coordinates (0-1)
    ///   - quality: JPEG compression quality
    /// - Returns: JPEG Data or nil if failed
    func jpegData(croppedTo normalizedRect: CGRect, quality: CGFloat = 0.8) -> Data? {
        // Create CIImage
        let ciImage = CIImage(cvPixelBuffer: self).oriented(.right)
        
        // Convert normalized rect to pixel rect
        let pixelRect = CGRect(
            x: normalizedRect.origin.x * ciImage.extent.width,
            y: normalizedRect.origin.y * ciImage.extent.height,
            width: normalizedRect.width * ciImage.extent.width,
            height: normalizedRect.height * ciImage.extent.height
        )
        
        // Crop
        let cropped = ciImage.cropped(to: pixelRect)
        
        // Convert to UIImage and encode JPEG
        let uiImage = UIImage(ciImage: cropped)
        return uiImage.jpegData(compressionQuality: quality)
    }
}

extension CIImage {
    
    /// Renders the CIImage into a new CVPixelBuffer with SFace-compatible settings (BGRA).
    /// - Parameters:
    ///   - context: The shared CIContext (Passed in to avoid performance drops).
    ///   - size: The target size (e.g., 112x112).
    /// - Returns: A ready-to-use CVPixelBuffer or nil if allocation fails.
    func toCVPixelBuffer(using context: CIContext, size: CGSize) -> CVPixelBuffer? {
        
        // 1. Define Attributes: We force BGRA here for your model
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferWidthKey: Int(size.width),
            kCVPixelBufferHeightKey: Int(size.height),
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA // <--- CRITICAL for our ML Model
        ] as CFDictionary
        
        // 2. Allocate the Buffer
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("❌ Extension Error: Could not allocate PixelBuffer. Status: \(status)")
            return nil
        }
        
        // 3. Render
        // Note: This renders the CIImage *into* the buffer's bounds.
        // Ensure your CIImage is already transformed/cropped correctly before calling this.
        context.render(self, to: buffer)
        
        return buffer
    }
}
