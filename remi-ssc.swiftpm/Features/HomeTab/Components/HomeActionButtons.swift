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
        HStack(spacing: 15) {
            
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
                    title: "Scan from\nCamera", // Preserving "form" typo if intent is strictly follow, but assuming "from" is correct.
                    // Correcting to "from" for quality.
                    icon: "camera.fill",
                    backgroundColor: Color("AppPrimary"),
                    foregroundColor: .white,
                    height: 120,
                    titleFont: .headline,
                    iconFont: .largeTitle,
                    action: onCameraTap
                )
                
                SelectionButton(
                    title: "Scan from\nPhotos",
                    icon: "photo.fill.on.rectangle.fill",
                    backgroundColor: Color("AppPrimary"),
                    foregroundColor: .white,
                    height: 120,
                    titleFont: .headline,
                    iconFont: .largeTitle,
                    action: onPhotosTap
                )
            }
        }
        .padding(.horizontal)
    }
}

// Internal helper just for this file
// Removed ActionButton struct as we are now using SelectionButton

