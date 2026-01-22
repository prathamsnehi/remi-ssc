//
//  MLExtensions.swift
//  remi-ssc
//
//  Created by Pratham S on 1/21/26.
//

import CoreVideo
import CoreImage
import Vision
import CoreML

extension CVPixelBuffer {
    /// crops the given pixel buffer to a given bouding rectangle, resize to 112x112
    func resizeForMobileFaceNet(normRect: CGRect, targetSize: CGSize = CGSize(width: 112, height: 112)) -> CVPixelBuffer? {
        // note: expects .right orientation of the input buffer
        
        let ciImage = CIImage(cvPixelBuffer: self).oriented(.right)
        
        let rotatedExtent = ciImage.extent
        let cropRect = VNImageRectForNormalizedRect(normRect, Int(rotatedExtent.width), Int(rotatedExtent.height))
        
        // cropping the image based on bounding rectangle:
        let croppedImage = ciImage.cropped(to: cropRect)
        
        // making size to 112x112:
        // Note: We create a transform to scale the image to the target size
        let scaleX = targetSize.width / cropRect.width
        let scaleY = targetSize.height / cropRect.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        // translating image to (0,0) before scaling to avoid coordinate shifts
        let scaledImage = croppedImage
            .transformed(by: transform)
            .transformed(by: CGAffineTransform(translationX: -cropRect.origin.x * scaleX,
                                               y: -cropRect.origin.y * scaleY))
        
        // rendering back to cvPixelBuffer:
        let context = CIContext()
        
        var newPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(targetSize.width),
                                         Int(targetSize.height),
                                         kCVPixelFormatType_32BGRA,
                                         nil,
                                         &newPixelBuffer)
        
        guard status == kCVReturnSuccess, let resultBuffer = newPixelBuffer else {
            return nil
        }
        
        context.render(scaledImage, to: resultBuffer)
        return resultBuffer
    }
}

extension MLMultiArray {
    func toDoubleArray() -> [Double] {
        let count = self.count
        var array: [Double] = []
        array.reserveCapacity(count)
        
        // Handle Float32 (common) or Double
        if self.dataType == .float32 {
            let pointer = self.dataPointer.bindMemory(to: Float.self, capacity: count)
            for i in 0..<count {
                array.append(Double(pointer[i]))
            }
        } else if self.dataType == .double {
            let pointer = self.dataPointer.bindMemory(to: Double.self, capacity: count)
            for i in 0..<count {
                array.append(pointer[i])
            }
        } else {
            // Safe fallback
            for i in 0..<count {
                array.append(self[i].doubleValue)
            }
        }
        return array
    }
}
