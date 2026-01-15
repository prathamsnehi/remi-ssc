//
//  HomeView.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Base Background
                Color(colorScheme == .dark ? .black : UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0))
                    .ignoresSafeArea()
                
                // 1. Hero Section (Background Layer)
                HomeHero()
                    .containerRelativeFrame(.vertical) { length, _ in length * 0.45 }
                    .ignoresSafeArea(edges: .top)
                
                // 2. Content Layer (Buttons & Recent Interactions)
                VStack(spacing: 0) {
                    // Spacer to position buttons relative to the screen height
                    // We want buttons to start at (0.40 * Height) - 30 (overlap)
                    Spacer()
                        .containerRelativeFrame(.vertical) { length, _ in (length * 0.40) - 30}
                    
                    HomeActionButtons(
                        onRegisterTap: { }, // No-op as requested
                        onIdentifyTap: { }  // No-op as requested
                    )
                    // Shadow to give depth like the reference card
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    
                    // 3. Recent Interactions Section
                    RecentInteractions()
                        .padding(.top, 40)
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
            
            // --- Destinations (Placeholders for now) ---
        }
        }
    }


#Preview {
    HomeView()
        .modelContainer(for: Person.self, inMemory: true)
}

