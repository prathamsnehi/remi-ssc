//
//  RegisterMemoryScreen.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct RegisterMemoryScreen: View {
    @Binding var memory: String
    let image: UIImage?
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            PhotoHeader(image: image)
            
            Spacer()
            
            Text("Add a first memory (Optional)")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            StyledTextField(placeholder: "Memory...", text: $memory)
            
            Spacer()
            
            Button(action: onFinish) {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
        }
        .padding()
    }
}
