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
    /// crops the given pixel buffer to a given bouding rectangle, resize to 112x112
    /// using RefAlignment (Similarity Transform)
    /// crops the given pixel buffer to a given bouding rectangle, resize to 112x112
    /// using RefAlignment (Similarity Transform)
    /// **UPDATED**: Uses CIImage physics (Bottom-Left Origin) to avoid Context flipping issues.
    func alignToRefPoints(landmarks: VNFaceLandmarks2D, faceBoundingBox: CGRect, orientation: CGImagePropertyOrientation = .right) -> CVPixelBuffer? {
        
        // 1. Setup Image (CIImage is conceptually infinite, origin at 0,0)
        let ciImage = CIImage(cvPixelBuffer: self).oriented(orientation)
        let width = CGFloat(ciImage.extent.width)
        let height = CGFloat(ciImage.extent.height)
        
        // 2. Extract Landmarks (5 points)
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye,
              let nose = landmarks.nose,
              let outerLips = landmarks.outerLips
        else {
            print("❌ [Align] Missing necessary landmarks for alignment")
            return nil
        }
        
        // Helper to get center of a region in BOTTOM-LEFT (Core Image) Coordinates
        let leftEyePt = getRegionCenterBL(leftEye, in: faceBoundingBox, imageW: width, imageH: height)
        let rightEyePt = getRegionCenterBL(rightEye, in: faceBoundingBox, imageW: width, imageH: height)
        let nosePt = getRegionCenterBL(nose, in: faceBoundingBox, imageW: width, imageH: height)
        let mouthPts = getMouthCornersBL(outerLips, in: faceBoundingBox, imageW: width, imageH: height)
        
        let leftMouthPt = mouthPts.0
        let rightMouthPt = mouthPts.1
        
        let sourcePoints = [
            leftEyePt,
            rightEyePt,
            nosePt,
            leftMouthPt,
            rightMouthPt
        ]
        
        // 3. Solve for Transform (Source BL -> Dest BL)
        // We map our source image points to the 112x112 box, respecting BL origin.
        let transform = RefAlignment.estimateSimilarityTransform(from: sourcePoints, to: RefAlignment.referencePointsBottomLeft)
        
        // 4. Apply Transform
        // Warps the image so the face lands at the correct coordinates in global space.
        let outputImage = ciImage.transformed(by: transform)
        
        // 5. Crop & Render
        // We want the 112x112 box at (0,0) of the transformed space.
        // Since we mapped Source -> Dest(0..112, 0..112), the face is now at (0,0) in the output.
        // CVPixelBuffer creation
        var newPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 112, 112, kCVPixelFormatType_32BGRA, nil, &newPixelBuffer)
        guard status == kCVReturnSuccess, let destBuffer = newPixelBuffer else { return nil }
        
        // Render using CIContext (Handles texturing and coords correctly)
        // We render the region (0,0) -> (112,112) of the outputImage to the buffer.
        let ciContext = CIContext()
        let destRect = CGRect(x: 0, y: 0, width: 112, height: 112)
        
        ciContext.render(outputImage, to: destBuffer, bounds: destRect, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        return destBuffer
    }
    
    // ... (resizeForMobileFaceNet omitted or kept? I'll leave it as you requested replace up to line 171)
    
    // Fallback: Simple Square Crop (Only if strictly needed, but Rule A says Alignment Mandatory)
    func resizeForMobileFaceNet(normRect: CGRect, targetSize: CGSize = CGSize(width: 112, height: 112), orientation: CGImagePropertyOrientation = .right) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: self).oriented(orientation)
        let rotatedExtent = ciImage.extent
        let cropRect = VNImageRectForNormalizedRect(normRect, Int(rotatedExtent.width), Int(rotatedExtent.height))
        let croppedImage = ciImage.cropped(to: cropRect)
        let scaleX = targetSize.width / cropRect.width
        let scaleY = targetSize.height / cropRect.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = croppedImage.transformed(by: transform).transformed(by: CGAffineTransform(translationX: -cropRect.origin.x * scaleX, y: -cropRect.origin.y * scaleY))
        let context = CIContext()
        var newPixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32BGRA, nil, &newPixelBuffer)
        if let resultBuffer = newPixelBuffer {
            context.render(scaledImage, to: resultBuffer)
            return resultBuffer
        }
        return nil
    }
    
    // Helper to get center of landmark region in Image BOTTOM-LEFT Coords
    private func getRegionCenterBL(_ region: VNFaceLandmarkRegion2D, in normBox: CGRect, imageW: CGFloat, imageH: CGFloat) -> CGPoint {
        let boxX = normBox.origin.x * imageW
        let boxY = normBox.origin.y * imageH
        let boxW = normBox.size.width * imageW
        let boxH = normBox.size.height * imageH
        
        let points = region.normalizedPoints
        var sumX: CGFloat = 0
        var sumY: CGFloat = 0
        for pt in points {
            sumX += pt.x
            sumY += pt.y
        }
        let avgX = sumX / CGFloat(points.count)
        let avgY = sumY / CGFloat(points.count)
        
        // Vision (Bottom-Left) -> Image Bottom-Left (Direct map, just denormalize)
        let imageX_bl = boxX + avgX * boxW
        let imageY_bl = boxY + avgY * boxH
        
        return CGPoint(x: imageX_bl, y: imageY_bl)
    }
    
    // Helper for mouth corners in BOTTOM-LEFT
    private func getMouthCornersBL(_ region: VNFaceLandmarkRegion2D?, in normBox: CGRect, imageW: CGFloat, imageH: CGFloat) -> (CGPoint, CGPoint) {
        guard let region = region else { return (.zero, .zero) }
        let points = region.normalizedPoints
        guard let leftNorm = points.min(by: { $0.x < $1.x }),
              let rightNorm = points.max(by: { $0.x < $1.x }) else { return (.zero, .zero) }
        
        let boxX = normBox.origin.x * imageW
        let boxY = normBox.origin.y * imageH
        let boxW = normBox.size.width * imageW
        let boxH = normBox.size.height * imageH
        
        let leftX_bl = boxX + leftNorm.x * boxW
        let leftY_bl = boxY + leftNorm.y * boxH
        let rightX_bl = boxX + rightNorm.x * boxW
        let rightY_bl = boxY + rightNorm.y * boxH
        
        return (CGPoint(x: leftX_bl, y: leftY_bl),
                CGPoint(x: rightX_bl, y: rightY_bl))
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
