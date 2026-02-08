//
//  StyledTextField.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var onCommit: () -> Void = {}
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
            .multilineTextAlignment(.center)
            .submitLabel(.next)
            .onSubmit(onCommit)
            .padding()
            .background(Color.clear) // Transparent background
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color("AppSecondaryText").opacity(0.3))
                    .padding(.top, 50), // Underline effect
                alignment: .bottom
            )
    }
}

#Preview {
    StyledTextField(placeholder: "Enter Name", text: .constant("Alice"))
        .padding()
}
