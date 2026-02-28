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
    let availableWidth: CGFloat
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Background Image with Fade
            GeometryReader { geometry in
                if let image = image {
                    // WIDESCREEN CINEMATIC MODE
                    if availableWidth > 800 {
                        ZStack {
                            // 1. Blurred Background
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .blur(radius: 60)
                                .scaleEffect(1.4) // Push the blurry edges outside the frame
                                .overlay(Color.black.opacity(0.4)) // Darken overall ambient light
                                .overlay( // aggressively fade the bottom of the blur into the app background
                                    LinearGradient(
                                        stops: [
                                            .init(color: .clear, location: 0.3),
                                            .init(color: Color("AppBackground"), location: 0.9)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                
                            // 2. Crisp, Constrained Foreground
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                // Constrain width based on the height to preserve the portrait aspect safely
                                // Using 1.25 ratio (4:5) which fits faces nicely without stretching horizontally
                                .frame(width: min(geometry.size.height * 1.25, 600), height: geometry.size.height, alignment: .top)
                                .clipped()
                                // Add a subtle horizontal fade mask so the edge blends gracefully into the blur
                                .mask(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .clear, location: 0.0),
                                            .init(color: .black, location: 0.1),
                                            .init(color: .black, location: 0.9),
                                            .init(color: .clear, location: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .overlay(gradientOverlays)
                        .clipped() // Prevent the scaled-up blur from bleeding vertically outside the hero bounds
                    } else {
                        // STANDARD PORTRAIT/MOBILE MODE
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                            .clipped()
                            .overlay(gradientOverlays)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color("AppSecondaryText"))
                        )
                }
            }
            
            // 2. Text Content (Name & Relation)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.largeTitle.weight(.bold)) // Serif font like reference
                    .foregroundColor(Color("AppPrimaryText"))
                
                Text(relation)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("AppSecondaryText"))
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Push up slightly from the very bottom edge
        }
        // The frame height is controlled externally by the parent view (FriendProfileView)
    }
    
    // Extracted the gradient overlays to avoid massive code duplication
    private var gradientOverlays: some View {
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
    }
}

#Preview {
    ProfileHero(
        image: UIImage(named: "sample_image_1"),
        name: "LeVar Burton",
        relation: "Book Club Moderator",
        availableWidth: 400
    )
    .background(Color("AppBackground"))
}
