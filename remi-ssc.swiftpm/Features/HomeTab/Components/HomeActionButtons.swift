//
//  HomeActionButtons.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI

struct HomeActionButtons: View {
    enum DisplayMode {
        case ios
        case ipad
    }
    
    let mode: DisplayMode
    
    // Callbacks
    var onScanFaceTap: () -> Void = {}
    var onCameraTap: () -> Void = {}
    var onPhotosTap: () -> Void = {}
    var onIdentifyTap: () -> Void = {} // Kept for backward compatibility if needed, or reused
    
    var body: some View {
        GeometryReader { geometry in
            // Use max(0, ...) to prevent negative values during initial layout (when width might be 0)
            let availableWidth = max(0, geometry.size.width - 60) 
            
            HStack(spacing: 20) {
                if mode == .ios {
                    // Single Button: "Scan Face"
                    SelectionButton(
                        title: "Scan Face",
                        icon: "faceid",
                        backgroundColor: Color("AppPrimary"),
                        foregroundColor: .white,
                        height: 120,
                        titleFont: .headline,
                        iconFont: .largeTitle,
                        action: onScanFaceTap
                    )
                } else {
                    // Dual Buttons: "Scan from Camera" & "Scan from Photos"
                    // Ratio: 66% vs 33%
                    let spacing: CGFloat = 20
                    let usefulWidth = max(0, availableWidth - spacing)
                    
                    SelectionButton(
                        title: "Camera\nAR Scan",
                        icon: "faceid",
                        backgroundColor: Color("AppPrimary"),
                        foregroundColor: .white,
                        height: 120,
                        titleFont: .headline,
                        iconFont: .largeTitle,
                        action: onCameraTap
                    )
                    .frame(width: usefulWidth * 0.66)
                    
                    SelectionButton(
                        title: "Photos\nScan",
                        icon: "photo.fill.on.rectangle.fill",
                        backgroundColor: Color("AppPrimary"),
                        foregroundColor: .white,
                        height: 120,
                        titleFont: .headline,
                        iconFont: .largeTitle,
                        action: onPhotosTap
                    )
                     .frame(width: usefulWidth * 0.34)
                }
            }
            .padding(.horizontal, 30) // Adjusted from 20 to 30 to match the math (60 total)
            .frame(width: geometry.size.width) // Ensure centered
        }
        .frame(height: 120) // Constrain height to button height
    }
}

// Internal helper just for this file
// Removed ActionButton struct as we are now using SelectionButton

