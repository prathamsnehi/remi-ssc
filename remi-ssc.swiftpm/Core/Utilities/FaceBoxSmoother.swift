//
//  FaceBoxSmoother.swift
//  remi-ssc
//
//  Created by Pratham S on 1/23/26.
//

import CoreGraphics
import Foundation

/// Utility to smooth jittery bounding boxes using Exponential Moving Average (EMA)
class FaceBoxSmoother {
    private var smoothedRect: CGRect?
    
    // Tuning parameter:
    // 0.0 = Infinite smoothing (no movement)
    // 1.0 = No smoothing (raw value)
    // 0.12 = Heavy smoothing (very stable, slight lag)
    private let alpha: CGFloat
    
    // Threshold to snap to new position if valid moves too far (to recover from drift)
    private let snapThreshold: CGFloat = 0.15
    
    init(alpha: CGFloat = 0.12) {
        self.alpha = alpha
    }
    
    func smooth(_ newRect: CGRect?) -> CGRect? {
        guard let newRect = newRect else {
            // Lost tracking: reset
            self.smoothedRect = nil
            return nil
        }
        
        guard let prev = smoothedRect else {
            // First frame: initialize
            self.smoothedRect = newRect
            return newRect
        }
        
        // Check for massive jump (re-initialization or bad detection)
        // If the box jumps more than 20% of screen width, snap immediately
        // to avoid "trailing" effect on rapid head turns.
        let deltaX = abs(newRect.origin.x - prev.origin.x)
        let deltaY = abs(newRect.origin.y - prev.origin.y)
        
        if deltaX > snapThreshold || deltaY > snapThreshold {
            self.smoothedRect = newRect
            return newRect
        }
        
        // Exponential Moving Average
        // avg = alpha * new + (1 - alpha) * old
        let x = alpha * newRect.origin.x + (1 - alpha) * prev.origin.x
        let y = alpha * newRect.origin.y + (1 - alpha) * prev.origin.y
        let w = alpha * newRect.width + (1 - alpha) * prev.width
        let h = alpha * newRect.height + (1 - alpha) * prev.height
        
        let result = CGRect(x: x, y: y, width: w, height: h)
        self.smoothedRect = result
        return result
    }
    
    func reset() {
        smoothedRect = nil
    }
}
