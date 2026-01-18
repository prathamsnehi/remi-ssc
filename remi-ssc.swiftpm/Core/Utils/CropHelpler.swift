//
//  CropHelpler.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import UIKit
import Vision

class CropHelper {
    static func cropFace(from buffer: CVPixelBuffer, boundingBox: CGRect) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        
        // 1. Convert Vision 'normalized' coordinates (0.0 - 1.0) to pixels
        // Note: Vision coordinates originate at Bottom-Left, but CVPixelBuffer/CoreGraphics is Top-Left.
        // We often need to flip Y, but for simple cropping, VNImageRectForNormalizedRect usually handles the mapping if context is standard.
        // However, face rects from Vision are often Bottom-Left.
        
        let faceRect = VNImageRectForNormalizedRect(boundingBox, width, height)
        
        // 2. Convert to CIImage for easier processing
        let ciImage = CIImage(cvPixelBuffer: buffer)
        
        // 3. Crop
        let cropped = ciImage.cropped(to: faceRect)
        
        // 4. Resize to 112x112 (Model Requirement)
        // Calculate scale needed to get to 112
        let scaleX = 112.0 / faceRect.width
        let scaleY = 112.0 / faceRect.height
        
        let resized = cropped.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // 5. Render back to CVPixelBuffer
        // MobileFaceNet expects a specific format (usually BGRA or ARGB)
        var newPixelBuffer: CVPixelBuffer?
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            112,
                            112,
                            kCVPixelFormatType_32BGRA,
                            nil,
                            &newPixelBuffer)
        
        guard let resultBuffer = newPixelBuffer else { return nil }
        
        let context = CIContext()
        context.render(resized, to: resultBuffer)
        
        return resultBuffer
    }
}
