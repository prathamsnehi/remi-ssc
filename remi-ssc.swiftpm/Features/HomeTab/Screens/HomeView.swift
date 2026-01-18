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
            GeometryReader { proxy in // for different layout multipliers for vertical / horizontal ipad layouts
                
                // Finding orientation (applicable to ipad only)
                let isLandscape = proxy.size.width > proxy.size.height
                
                // finding the "feels right" proportion for HomeHero:
                var heroFrameHeight: CGFloat {
                    if isiPad {
                        if isLandscape {
                            return proxy.size.height * 0.50
                        } else {
                            return proxy.size.height * 0.42
                        }
                    } else {
                        // fixed 0.47 for iphones (as always portrait):
                        return proxy.size.height * 0.47
                    }
                }
                
                VStack(spacing: 0) {
                    VStack {
                        HomeHero()
                            .frame(height: heroFrameHeight)
                        
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
                        
                    }
                    .ignoresSafeArea()
                    
                    // Memories and Recent Interactions:
                    // ipad: HStack
                    // iphone: VStack
                    
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
            }
            .ignoresSafeArea() // place HomeHero right against the safe area (padding accounted for, i.e. ipad tab bar & iphone dynamic island)
            
        }
    }
}


#Preview {
    HomeView()
        .modelContainer(for: Person.self, inMemory: true)
}

