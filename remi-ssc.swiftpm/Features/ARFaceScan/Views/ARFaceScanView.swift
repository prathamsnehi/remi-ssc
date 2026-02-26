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
    @State private var showPhotoScanner = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isiPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                    ARViewContainer(detector: detector, savedPersons: savedPersons)
                        .ignoresSafeArea()
                    
                    FaceOverlayViewfinder(detector: detector)
                        .ignoresSafeArea()
                    
                    HStack {
                        HeaderCapsule(
                            title: detector.isScanModeOn ? "Registering Person" : "AR Scan",
                            isScanning: detector.isScanModeOn,
                            onPhotosTap: {
                                showPhotoScanner = true
                            }
                        )
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font((isiPad ? Font.title2 : Font.caption).weight(.bold))
                                .foregroundStyle(Color("AppPrimaryText"))
                                .frame(width: isiPad ? 54 : 36, height: isiPad ? 54 : 36)
                        }
                        .background(.ultraThinMaterial, in: Capsule())

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    VStack {
                        Spacer()
                        
                        ARFooterCard(detector: detector)
                            .padding(.bottom, 20)
                    }
                    .ignoresSafeArea()
                }
                .photoScanner(isPresented: $showPhotoScanner)
        }
    }
}

#Preview {
    ARFaceScanView()
}
