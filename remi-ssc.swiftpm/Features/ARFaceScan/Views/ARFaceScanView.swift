//
//  ARFaceScanView.swift
//  remi-ssc
//
//  Created by Pratham S on 1/31/26.
//

import SwiftUI
import SwiftData

struct ARFaceScanView: View {
    @Environment(\.dismiss) private var dismiss
    @Query var savedPersons: [Person]
    @StateObject private var detector = FaceDetector()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ARViewContainer(detector: detector, savedPersons: savedPersons)
                    .ignoresSafeArea()
                
                FaceOverlayViewfinder(detector: detector)
                    .ignoresSafeArea()
                
                HStack {
                    HeaderCapsule(
                        title: detector.isScanningFace ? "Registering Person" : "AR Scan",
                        isScanning: detector.isScanningFace
                    )
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
                
                VStack {
                    Spacer()
                    
                    ARFooterCard(detector: detector)
                        .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    ARFaceScanView()
}
