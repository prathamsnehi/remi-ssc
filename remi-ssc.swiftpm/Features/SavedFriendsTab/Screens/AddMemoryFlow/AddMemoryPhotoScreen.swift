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
    
    enum PickerType: String, Identifiable {
        case camera, photoLibrary
        var id: String { rawValue }
    }
    
    @State private var activePicker: PickerType? = nil
    
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
                        activePicker = .camera
                    }
                )
                
                SelectionButton(
                    title: "Photos",
                    icon: "photo.on.rectangle",
                    backgroundColor: Color(.systemGray5),
                    foregroundColor: Color("AppPrimaryText"),
                    action: {
                        activePicker = .photoLibrary
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
        .fullScreenCover(item: $activePicker) { picker in
            ImagePicker(
                selectedImage: $inputImage, 
                sourceType: picker == .camera ? .camera : .photoLibrary
            )
            .ignoresSafeArea()
        }
    }
}
