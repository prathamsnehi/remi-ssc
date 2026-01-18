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
            GeometryReader { proxy in
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
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Greeting Area
                    VStack(spacing: 12) {
                        // ipad, the have wave is with the text
                        // to accomodate larger font
                        if (sizeClass == .regular) {
                            HStack (spacing: 20) {
                                Image(systemName: "hand.wave.fill")
                                    .font(.system(size: sizeClass == .compact ? 24 : 32))
                                    .foregroundColor(.yellow)
                                
                                Text("Hi User,")
                                    .font(.system(size: sizeClass == .compact ? 36 : 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                        } else {
                            // normal separated wave and text for iphone
                            Image(systemName: "hand.wave.fill")
                                .font(.system(size: sizeClass == .compact ? 24 : 32))
                                .foregroundColor(.yellow)
                            
                            Text("Hi User,")
                                .font(.system(size: sizeClass == .compact ? 36 : 48, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        
                        Text("Who is with you?")
                            .font(sizeClass == .compact ? .title3 : .title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(0)
                    
                    Spacer() // Pushes content to the center of the remaining space
                    
                    // Visual Offset: 
                    // Push the center "Up" by 15% to account for the gradient ending at 0.85
                    Spacer()
                        .frame(height: proxy.size.height * 0.15)
                }
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
