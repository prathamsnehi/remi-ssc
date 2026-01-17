//
//  HomeHero.swift
//  remi
//
//  Created by Pratham S on 12/24/25.
//

import SwiftUI

struct HomeHero: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Allow pushing content down without moving the background
    var contentOffset: CGFloat = 0
    
    var body: some View {
        // Recommendation: A very subtle tint of your Primary Green.
        // This adds "life" to the header without being dark like gray, and separates it from the plain white/gray background.
        let topColor = colorScheme == .dark ? Color("AppSurface") : Color(red: 0.90, green: 0.90, blue: 0.90)
        let bottomColor = Color("AppBackground")
        
        ZStack(alignment: .top) {
            // Background Gradient
            LinearGradient(
                stops: [
                    .init(color: topColor, location: 0.0),
                    .init(color: topColor, location: 0.85),
                    .init(color: bottomColor, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Top Logo Area
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill") // Placeholder logo
                        .foregroundColor(.primary)
                    Text("remi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 70 + contentOffset)
                
                // Fixed spacing to keep content positioning stable regardless of hero height
                Spacer()
                    .frame(height: 30)
                
                // Greeting Area
                VStack(spacing: 10) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    
                    Text("Hi User,")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Who is with you?")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(0)
                
                Spacer() // Pushes content to the top
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

#Preview {
    HomeHero()
        .frame(height: 400)
        .ignoresSafeArea()
}
