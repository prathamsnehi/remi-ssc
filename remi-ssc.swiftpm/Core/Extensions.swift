import UIKit
import Vision
import SwiftUI
import ImageIO // Required for CGImagePropertyOrientation
import VideoToolbox


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
}
