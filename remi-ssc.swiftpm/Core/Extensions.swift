//
//  Extensions.swift
//  remi-ssc
//
//  Created by Pratham S on 1/19/26.
//

import UIKit
import CoreVideo
import VideoToolbox
import CoreImage
import Vision

extension UIImage {
    /// converting UIImage to CVPixelBuffer for MobileFaceNet ML Model, respecting orientation
    func toCVPixelBuffer(pixelFormat: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
        // Use CIImage to handle orientation and conversion easily
        guard let ciImage = CIImage(image: self) else { return nil }
        
        // If UIImage has orientation metadata, apply it so the buffer is UPRIGHT
        // CIImage(image:) usually preserves the orientation property derived from UIImage
        // But we want to 'bake' it into the pixels.
        // We can just render the CIImage as is (CIContext handles flexible input) to a new buffer
        
        // However, CIImage(image: self) creates a CIImage with the orientation applied (virtual).
        // Standardizing to a new buffer:
        
        let context = CIContext()
        
        var buffer: CVPixelBuffer?
        // Create buffer with swapped dims if needed? 
        // CIImage.extent gives us the oriented dimensions.
        let width = Int(ciImage.extent.width)
        let height = Int(ciImage.extent.height)
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as [String : Any]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attrs as CFDictionary, &buffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = buffer else { return nil }
        
        context.render(ciImage, to: pixelBuffer)
        return pixelBuffer
    }
}
