//
//  AddMemoryTextScreen.swift
//  remi
//
//  Created by Pratham S on 12/30/25.
//

import SwiftUI

struct AddMemoryTextScreen: View {
    @Binding var text: String
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What's the memory?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            VStack(alignment: .leading) {
                TextField("Type your memory here...", text: $text, axis: .vertical)
                    .font(.system(.title2, design: .rounded, weight: .medium)) // Smaller than 40pt, but still prominent
                    .multilineTextAlignment(.leading)
                    .lineLimit(4...10)
                    .padding()
                    .background(Color("AppSurface"))
                    .cornerRadius(16)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(Color("AppPrimaryText"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(text.isEmpty ? Color.gray : Color("AppPrimary"))
                    .cornerRadius(16)
            }
            .disabled(text.isEmpty)
        }
        .padding()
    }
}
