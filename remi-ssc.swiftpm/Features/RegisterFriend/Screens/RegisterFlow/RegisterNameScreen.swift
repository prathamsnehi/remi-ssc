//
//  RegisterNameScreen.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct RegisterNameScreen: View {
    @Binding var name: String
    let image: UIImage?
    var onNext: () -> Void
    var isSubmitting: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            PhotoHeader(image: image)
            
            Spacer()
            
            Text("What is their name?")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            StyledTextField(placeholder: "Name", text: $name)
            
            Spacer()
            
            if isSubmitting {
                ProgressView("Verifying...")
            } else {
                Button(action: onNext) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(name.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(16)
                }
                .disabled(name.isEmpty)
            }
        }
        .padding()
    }
}
