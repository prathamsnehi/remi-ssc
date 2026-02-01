//
//  ARFaceScanView.swift
//  remi-ssc
//
//  Created by Pratham S on 1/31/26.
//

import SwiftUI

struct ARFaceScanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var detector = FaceDetector()
    
    var body: some View {
        ZStack(alignment: .top) {
            ARViewContainer(detector: detector)
                .ignoresSafeArea()
            
            FaceOverlayViewfinder(detector: detector)
                .ignoresSafeArea()
            
            HStack {
                HeaderCapsule()
                .padding(.leading, 16)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                }
                .glassEffect()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

#Preview {
    ARFaceScanView()
}
