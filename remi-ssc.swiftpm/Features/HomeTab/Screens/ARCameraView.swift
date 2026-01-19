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

    var body: some View {
        ZStack {
            // Camera Feed:
            ARViewContainer(detector: detector)
                .edgesIgnoringSafeArea(.all)
            
            // Card Overlay:
            if let location = detector.faceLocation {
                // if location is not nil (means face on-screen)
                ARPersonCard()
                    .position(x: location.x, y: location.y)
                    .animation(.spring(), value: location)
            }
            
            // Dismiss Button:
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
                }
                .padding(.leading, 20)
                .padding(.top, 50)
                
                Spacer()

            }
            
            Spacer()
        }
    }
}
