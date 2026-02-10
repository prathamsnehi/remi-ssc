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
    
    @State private var showRegisterSheet = false
    @State private var showARView = false
    
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
                                showARView = true
                            },
                            onPhotosTap: {
                                print("get up on me, so get up on dat dihh")
                            }
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
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
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
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            }
                        }
                        
                    } else {
                        // iOS Layout
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    Text("Your Recent Memories")
                                        .font(.system(.title2, design: .rounded)) // Matches the card/button curves
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("AppPrimaryText"))
                                        .padding(.top, 12)
                                        .padding(.leading, 20)
                                    
                                    MemoryStoryCardsView(height: proxy.size.height * 0.32)
                                    // because rest of the content takes about 68% of the space (see calculations below)
                                }
                            }
                            .padding(.top, 10)
                        }
                          
                    
                    Spacer()
                }
            }
            .ignoresSafeArea() // place HomeHero right against the safe area (padding accounted for, i.e. ipad tab bar & iphone dynamic island)
        }
        .fullScreenCover(isPresented: $showRegisterSheet) {
            RegisterView()
        }
        .fullScreenCover(isPresented: $showARView) {
            ARFaceScanView()
        }
        
    }
}



#Preview {
    HomeView()
        .modelContainer(for: Person.self, inMemory: true)
}

// ios, let's assume we have 874 px for iphone 17 pro

// 42% of that taken by the hero header, ~ 367.08
// remaining: 506.92

// taken by button: 40 px (was 120, but pulled up by 80 because of niceau layout
// remaining: 466.92 -> total taken 42 + 4.57 = 46.57%

// padding between the recent memories and button + the text iself:
// like 50? ->
// remaining: 416.92 -> total taken up like 50-51%

// tab bar generous assumption prolly takes like 15% of screen height

// remaining: 100 - 65 = 35%
// but being a bit more generous, let's go 32%
// cuz it's always best to go under than over
