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
    
    @State private var showARScanner = false
    
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
                            return proxy.size.height * 0.41
                        }
                    } else {
                        // fixed 0.42 for iphones (as always portrait):
                        return proxy.size.height * 0.42
                    }
                }
                
                VStack(spacing: 0) {
                    VStack {
                        HomeHero()
                            .frame(height: heroFrameHeight)
                        
                        HomeActionButtons(
                            mode: isiPad ? .ipad : .ios,
                            onScanFaceTap: {
                                showARScanner = true
                            },
                            onCameraTap: { print("Camera Tapped") },
                            onPhotosTap: { print("Photos Tapped") }
                        )
                        // pulling the button by ~66% of it's height (80px)
                        // so that it sits intersecting the HomeHero's gradient
                        .offset(y: -80)
                        .padding(.bottom, -80)
                        
                    }
                    .ignoresSafeArea()
                    

                    
                    if isiPad {
                        ScrollView {
                            if isLandscape {
                                // iPad Landscape: Side-by-Side
                                HStack(alignment: .top, spacing: 30) {
                                    MyMemoriesView()
                                        .frame(maxWidth: .infinity)
                                    
                                    RecentInteractions()
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.leading, 30)
                                .padding(.trailing, 30)
                                .padding(.top, 30)
                            } else {
                                // iPad Portrait: Vertical Stack
                                VStack(spacing: 30) {
                                    MyMemoriesView()
                                        .frame(maxWidth: .infinity)
                                    
                                    RecentInteractions()
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 30)
                                .padding(.leading, 35)
                                .padding(.trailing, 35)
                            }
                        }
                        
                    } else {
                        // iOS Layout
                        ScrollView() {
                            MyMemoriesView()
                            RecentInteractions()
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .ignoresSafeArea() // place HomeHero right against the safe area (padding accounted for, i.e. ipad tab bar & iphone dynamic island)
            .fullScreenCover(isPresented: $showARScanner) { // show AR Scanner when clicked
                ARCameraView(isPresented: $showARScanner)
            }
            
        }
    }
}


#Preview {
    HomeView()
        .modelContainer(for: Person.self, inMemory: true)
}

