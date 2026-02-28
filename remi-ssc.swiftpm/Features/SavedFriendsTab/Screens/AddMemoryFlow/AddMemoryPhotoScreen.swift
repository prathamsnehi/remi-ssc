//
//  AddMemoryPhotoScreen.swift
//  remi
//
//  Created by Pratham S on 12/30/25.
//

import SwiftUI

struct AddMemoryPhotoScreen: View {
    @Binding var inputImage: UIImage?
    var onFinish: () -> Void
    
    @State private var showCamera = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a photo?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Photos help bring memories to life.")
                .font(.body)
                .foregroundColor(Color("AppSecondaryText"))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 280, height: 280) // Square for memory photo
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 10)
                    .overlay(
                        Button(action: { inputImage = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(Color("AppPrimaryText"))
                                .shadow(radius: 2)
                        }
                        .padding(10)
                        .accessibilityLabel("Remove Selected Photo"),
                        alignment: .topTrailing
                    )
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .foregroundColor(Color("AppSecondaryText").opacity(0.5))
            }
            
            Spacer()
            
            // Selection Buttons
            HStack(spacing: 15) {
                SelectionButton(
                    title: "Camera",
                    icon: "camera.fill",
                    backgroundColor: .blue,
                    foregroundColor: .white,
                    action: {
                        pickerSourceType = .camera
                        showCamera = true
                    }
                )
                
                SelectionButton(
                    title: "Photos",
                    icon: "photo.on.rectangle",
                    backgroundColor: Color(.systemGray5),
                    foregroundColor: Color("AppPrimaryText"),
                    action: {
                        pickerSourceType = .photoLibrary
                        showCamera = true
                    }
                )
            }
            
            // Finish Button
            Button(action: onFinish) {
                Text(inputImage == nil ? "Skip & Finish" : "Finish")
                    .font(.headline)
                    .foregroundColor(inputImage == nil ? Color("AppPrimaryText") : Color("AppPrimaryText"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(inputImage == nil ? Color(.systemGray5) : Color("AppPrimary"))
                    .cornerRadius(16)
            }
            .padding(.top, 10)
        }
        .padding()
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $inputImage, sourceType: pickerSourceType)
                .ignoresSafeArea()
                .id(pickerSourceType)
        }
    }
}
