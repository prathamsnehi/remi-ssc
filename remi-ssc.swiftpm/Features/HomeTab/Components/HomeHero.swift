//
//  HomeHero.swift
//  remi
//
//  Created by Pratham S on 12/24/25.
//

import SwiftUI

struct HomeHero: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        
        // Hero Gradient:
        let topColor = colorScheme == .dark ? Color("AppSurface") : Color(red: 0.90, green: 0.90, blue: 0.90)
        let bottomColor = Color("AppBackground")
        
        ZStack(alignment: .top) {
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
            
            // Hero Content
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
                // custom padding, avoids dynamic island in iOS
                // and avoids the top padding in iPadOS
                .padding(.top, sizeClass == .compact ? 70 : 100)
                
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
