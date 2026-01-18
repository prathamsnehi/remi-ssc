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
                SelectionButton(
                    title: "Camera\nAR Scan", // Preserving "form" typo if intent is strictly follow, but assuming "from" is correct.
                    // Correcting to "from" for quality.
                    icon: "camera.fill",
                    backgroundColor: Color("AppPrimary"),
                    foregroundColor: .white,
                    height: 120,
                    titleFont: .headline,
                    iconFont: .largeTitle,
                    action: onCameraTap
                )
                .padding(.leading, 20)
                
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
                .padding(.trailing, 20)
            }
        }
        .padding(.horizontal)
    }
}

// Internal helper just for this file
// Removed ActionButton struct as we are now using SelectionButton

