//
//  HomeView.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // Determine if we are effectively on iPad (Regular width)
    var isiPad: Bool {
        sizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Base Background
                Color("AppBackground")
                    .ignoresSafeArea()
                
                // 1. Hero Section (Background Layer)
                HomeHero()
                    .containerRelativeFrame(.vertical) { length, _ in length * 0.45 }
                    // iPad adjustment: Push down by 100px so content is lower
                    .padding(.top, isiPad ? 100 : 0)
                    .ignoresSafeArea(edges: .top)
                
                // 2. Content Layer
                VStack(spacing: 0) {
                    // Responsive Spacer
                    // On iPad, we need more push since we added top padding to hero
                    Spacer()
                        .containerRelativeFrame(.vertical) { length, _ in
                            let baseOffset = (length * 0.40) - 30
                            return isiPad ? baseOffset + 80 : baseOffset
                        }
                    
                    HomeActionButtons(
                        mode: isiPad ? .ipad : .ios,
                        onScanFaceTap: { print("San Face Tapped") },
                        onCameraTap: { print("Camera Tapped") },
                        onPhotosTap: { print("Photos Tapped") }
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    // Limit width on iPad for breathing room
                    .frame(maxWidth: isiPad ? 600 : .infinity)
                    
                    // 3. Additional Content
                    VStack(spacing: 40) {
                        
                        // New: Your Memories (iOS Only as per initial request, or both if fits)
                        // Requirement said "On iOS... a new section Your Memories"
                        // But iPad has "Recent Interactions". Let's show Memories on both for consistency unless space is tight.
                        if !isiPad {
                            MyMemoriesView()
                        }
                        
                        // Recent Interactions Section
                        RecentInteractions()
                    }
                    .padding(.top, 40) // Spacing from buttons
                    
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

