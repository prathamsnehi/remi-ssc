//
//  ARView.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import SwiftUI

struct ARCameraView: View {
    @StateObject var detector = FaceDetector() // store location of face on-screen
    @Binding var isPresented: Bool // to be able to dismiss the AR View
    @State private var showRegisterSheet = false

    var body: some View {
        ZStack {
            // Camera Feed:
            ARViewContainer(detector: detector)
                .edgesIgnoringSafeArea(.all)
            
            // Card Overlay:
            // Card Overlay:
            if let rect = detector.faceRect {
                FaceOverlayView(rect: rect, isUnknown: detector.isUnknown)
            }
            
            // UI Layer
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3).clipShape(Circle()))
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 50)
                
                Spacer()
                
                // Bottom Detail Panel
                PersonDetailPanel(
                    person: detector.identifiedPerson,
                    isUnknown: detector.isUnknown,
                    confidence: detector.confidence,
                    onAddFriend: {
                        showRegisterSheet = true
                    },
                    onViewProfile: {
                        // FUTURE: Navigate to Person Detail View
                        print("User tapped view profile for \(detector.identifiedPerson?.name ?? "Unknown")")
                    }
                )
                .animation(.spring, value: detector.identifiedPerson)
                .animation(.spring, value: detector.isUnknown)
            }
            

            
            Spacer()
        }
        .sheet(isPresented: $showRegisterSheet) {
            RegisterView(initialImage: detector.lastCapturedImage)
        }
    }
}
