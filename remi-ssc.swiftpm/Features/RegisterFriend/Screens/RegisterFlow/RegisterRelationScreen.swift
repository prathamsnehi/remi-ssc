//
//  RegisterRelationScreen.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct RegisterRelationScreen: View {
    @Binding var relation: String
    let image: UIImage?
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            PhotoHeader(image: image)
            
            Spacer()
            
            Text("How do you know them?")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            StyledTextField(placeholder: "Relation (e.g. Friend)", text: $relation)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(relation.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(16)
            }
            .disabled(relation.isEmpty)
        }
        .padding()
    }
}
