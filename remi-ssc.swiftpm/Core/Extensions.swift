//
//  Extensions.swift
//  remi-ssc
//
//  Created by Pratham S on 1/19/26.
//

import UIKit
import CoreVideo
import VideoToolbox

extension UIImage {
    /// converting UIImage to CVPixelBuffer for MobileFaceNet ML Model:
    func toCVPixelBuffer(pixelFormat: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
        // getting CGImage (contains pixel data & dimension info) from the UIImage:
        guard let cgImage = self.cgImage else {
            print("Conversion Failed")
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // defining buffer attributes in memory (because CVPixelBuffer only exists in memory):
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        // allocating the buffer:
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attributes as CFDictionary, &pixelBuffer) // & means passing the address of the pixelbuffer
        
        // confirmation check of cvpixelbuffer was successfully allocated in memory:
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Conversion failed, \(status)")
            return nil
        }
        
        // locking the memory location to prevent overwriting on it by sth else:
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        defer {
            // to prevent deadlock, memory is always freed up at the end of the process
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        // drawing the pixelbuffer from the ui image:
        guard let contextData = CVPixelBufferGetBaseAddress(buffer) else {
            print("Conversion failed")
            return nil
        }
        
        
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        guard let context = CGContext(
            data: contextData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            print("Conversion Failed")
            return nil
        }
        
        context.draw(cgImage, in:CGRect(x: 0, y: 0, width: width, height: height))
        
        return buffer
        
    }
}

extension CVPixelBuffer {
    /// resizes CVPixelBuffer to 112x112 for MobileFaceNet ML Model:
    func resizeForMobileFaceNet() -> CVPixelBuffer? {
        // creating CGImage from CVPixelBuffer (so that we can deal with dimensions)
        var cgImage: CGImage?
        let status = VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        
        guard status == noErr, let sourceImage = cgImage else {
            print("Rsize failed")
            return nil
        }
        
        // defining attributes for the updated CVPixelBuffer:
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        // create new cvpixelbuffer with 112x112:
        var buffer: CVPixelBuffer?
        let createStatus = CVPixelBufferCreate(kCFAllocatorDefault, 112, 112, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &buffer)
        
        guard createStatus == kCVReturnSuccess, let newBuffer = buffer else {
            print("Resize failed")
            return nil
        }
        
        // locking new buffer so that we can write to it:
        CVPixelBufferLockBaseAddress(newBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        defer {
            // prevent deadlock, free memory in the end
            CVPixelBufferUnlockBaseAddress(newBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        // create context for new buffer:
        guard let contextData = CVPixelBufferGetBaseAddress(newBuffer) else { return nil }
        
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        
        guard let context = CGContext(
            data: contextData,
            width: 112,
            height: 112,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(newBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        
        // drawing image:
        context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: 112, height: 112))
        
        return newBuffer
        
    }
}
