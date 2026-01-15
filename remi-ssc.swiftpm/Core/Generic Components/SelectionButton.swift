//
//  SelectionButton.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct SelectionButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let foregroundColor: Color
    var height: CGFloat = 90
    var titleFont: Font = .body
    var iconFont: Font = .title2
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(iconFont)
                Text(title)
                    .font(titleFont)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundColor.gradient)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 5)
        }
    }
}

#Preview {
    HStack {
        SelectionButton(
            title: "Camera",
            icon: "camera.fill",
            backgroundColor: .blue,
            foregroundColor: .white,
            action: {}
        )
        SelectionButton(
            title: "Photos",
            icon: "photo.on.rectangle",
            backgroundColor: Color(.systemGray5),
            foregroundColor: .primary,
            action: {}
        )
    }
    .padding()
}
