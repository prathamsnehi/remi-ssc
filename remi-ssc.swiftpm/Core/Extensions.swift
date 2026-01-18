//
//  Extensions.swift
//  Remi
//
//  Created by Pratham S on 1/17/26.
//

import CoreML
import UIKit

extension MLMultiArray {
    func toArray() -> [Double] {
        let count = self.count
        var array = [Double](repeating: 0.0, count: count)
        
        // Pointer access is faster
        let pointer = self.dataPointer.bindMemory(to: Double.self, capacity: count)
        for i in 0..<count {
            array[i] = pointer[i]
        }
        return array
    }
}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         nil,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let data = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
