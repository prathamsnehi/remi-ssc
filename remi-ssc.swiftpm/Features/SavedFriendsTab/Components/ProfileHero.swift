//
//  ProfileHero.swift
//  remi
//
//  Created by Pratham S on 12/28/25.
//

import SwiftUI

struct ProfileHero: View {
    let image: UIImage?
    let name: String
    let relation: String

    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Background Image with Fade
            GeometryReader { geometry in
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                        .clipped()
                    .overlay(
                        ZStack {
                            // Bottom Fade (Existing)
                                LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0.4),
                                        .init(color: Color("AppBackground").opacity(0.8), location: 0.95),
                                        .init(color: Color("AppBackground"), location: 1.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                
                                // Top Scrim (New) - Darkens the status bar area
                                LinearGradient(
                                    colors: [.black.opacity(0.6), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 140) // Only covers the top portion
                                .frame(maxHeight: .infinity, alignment: .top)
                            }
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // 2. Text Content (Name & Relation)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 34, weight: .bold)) // Serif font like reference
                    .foregroundColor(.primary)
                
                Text(relation)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Push up slightly from the very bottom edge
        }
        .frame(height: 400) // Fixed height for the hero section
    }
}

#Preview {
    ProfileHero(
        image: UIImage(named: "sample_image_1"),
        name: "LeVar Burton",
        relation: "Book Club Moderator",
    )
    .background(Color("AppBackground"))
}
