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
            VStack {
                    HomeHero()
                    .containerRelativeFrame(.vertical) {
                        length, axis in
                        // checking if is ipad or iphone:
                        if isiPad {
                            // ipad, screen height * 0.5
                            return length * 0.5
                            
                        } else {
                            // iphone, simply screen height * 0.45:
                            return length * 0.45
                        }
                        
                    }
                    
                    HomeActionButtons(
                        mode: isiPad ? .ipad : .ios,
                        onScanFaceTap: { print("San Face Tapped") },
                        onCameraTap: { print("Camera Tapped") },
                        onPhotosTap: { print("Photos Tapped") }
                    )
                    // pulling the button by ~66% of it's height (80px)
                    // so that it sits intersecting the HomeHero's gradient
                    .offset(y: -80)
                    .padding(.bottom, -80)
                    
                
                if isiPad {
                    HStack(alignment: .top, spacing: 30) {
                        MyMemoriesView()
                            .frame(maxWidth: .infinity)
                
                        RecentInteractions()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(30)
                } else {
                    // iOS Layout
                    VStack(spacing: 40) {
                        MyMemoriesView()
                        RecentInteractions()
                    }
                    .padding(.top, 40)
                }
                
                
                
                Spacer()
            }
            .ignoresSafeArea()

            
            
            // Memories and Recent Interactions
            // HStack -> iPadOS
            // VStack -> iOS
            
            
            
            
            //            ZStack(alignment: .top) {
            //                // Base Background
            //                Color("AppBackground")
            //                    .ignoresSafeArea()
            //
            //                // 1. Hero Section (Background Layer)
            //                HomeHero()
            //                    .containerRelativeFrame(.vertical) { length, _ in length * 0.48 }
            //                    .ignoresSafeArea(edges: .top)
            //
            //                // 2. Content Layer
            //                VStack(spacing: 0) {
            //                    // Responsive Spacer
            //                    // On iPad, we need more push since we added top padding to hero
            //                    Spacer()
            //                        .containerRelativeFrame(.vertical) { length, _ in
            //                            let baseOffset = (length * 0.40) - 30
            //                            return baseOffset
            //                        }
            //
            //                    HomeActionButtons(
            //                        mode: isiPad ? .ipad : .ios,
            //                        onScanFaceTap: { print("San Face Tapped") },
            //                        onCameraTap: { print("Camera Tapped") },
            //                        onPhotosTap: { print("Photos Tapped") }
            //                    )
            //                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            //                    // Limit width on iPad for breathing room
            //                    .frame(maxWidth: .infinity)
            //
            //                    if isiPad {
            //                        HStack(alignment: .top, spacing: 30) {
            //                            MyMemoriesView()
            //                                .frame(maxWidth: .infinity)
            //
            //                            RecentInteractions()
            //                                .frame(maxWidth: .infinity)
            //                        }
            //                        .padding(30)
            //                    } else {
            //                        // iOS Layout
            //                        VStack(spacing: 40) {
            //                            MyMemoriesView()
            //                            RecentInteractions()
            //                        }
            //                        .padding(.top, 40) // Spacing from buttons
            //                    }
            //
            //
            //                    Spacer()
            //                }
            //                .ignoresSafeArea(edges: .top)
            //
            //            }
            //            .navigationTitle("Home")
            //            .navigationBarHidden(true)
            
            // --- Destinations (Placeholders for now) ---
        }
    }
}


#Preview {
    HomeView()
        .modelContainer(for: Person.self, inMemory: true)
}

