//
//  RegisterPhotoScreen.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct RegisterPhotoScreen: View {
    @Binding var inputImage: UIImage?
    var onNext: () -> Void
    
    @State private var showCamera = false
    @State private var showLibrary = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("First, let's see who it is.")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Spacer()
            
            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 220)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                    .shadow(radius: 10)
            } else {
                Image(systemName: "person.fill.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .foregroundColor(Color("AppSecondaryText").opacity(0.8))
            }
            
            Spacer()
            
            // Selection Buttons
            HStack(spacing: 15) {
                SelectionButton(
                    title: "Camera",
                    icon: "camera.fill",
                    backgroundColor: .blue,
                    foregroundColor: Color("AppPrimaryText"),
                    action: {
                        showCamera = true
                    }
                )
                
                SelectionButton(
                    title: "Photos",
                    icon: "photo.on.rectangle",
                    backgroundColor: Color(.systemGray5),
                    foregroundColor: Color("AppPrimaryText"),
                    action: {
                        showLibrary = true
                    }
                )
            }
            
            // Next Button (Only visible if image is selected)
            if inputImage != nil {
                Button(action: onNext) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(Color("AppPrimaryText"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.black) // Distinct from the blue buttons
                        .cornerRadius(16)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $inputImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showLibrary) {
            ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
    }
}
