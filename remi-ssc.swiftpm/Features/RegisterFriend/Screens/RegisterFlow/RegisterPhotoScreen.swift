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
            SelectionButton(
                title: "Choose from Photos",
                icon: "photo.on.rectangle",
                backgroundColor: Color(.systemGray5),
                foregroundColor: Color("AppPrimaryText"),
                action: {
                    showLibrary = true
                }
            )
            
            // Next Button (Always visible, but disabled if no image)
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(inputImage != nil ? Color("AppPrimary") : Color.gray.opacity(0.3)) 
                    .cornerRadius(16)
            }
            .disabled(inputImage == nil)
            .padding(.top, 10)
        }
        .padding()
        .fullScreenCover(isPresented: $showLibrary) {
            ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
    }
}

func dummy () -> Void {
    print("Don't you know")
}

#Preview {
    @State var selectedImage = UIImage(named: "sample_image_1")
    RegisterPhotoScreen(inputImage: $selectedImage, onNext: dummy)
}
