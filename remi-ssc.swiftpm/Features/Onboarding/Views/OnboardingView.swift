import SwiftUI

struct OnboardingView: View {
    @Binding var isFinished: Bool
    // Path for navigation
    @State private var path = NavigationPath()
    @Namespace private var animation
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var introStep = 0 // 0: Start, 1: Reveal, 2: Final
    
    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                OnboardingHeroView(path: $path)
                    .navigationDestination(for: String.self) { destination in
                        switch destination {
                        case "loss":
                            OnboardingLossView(path: $path)
                                .navigationBarBackButtonHidden()
                        case "struggle":
                            OnboardingStruggleView(path: $path)
                                .navigationBarBackButtonHidden()
                        case "facescan":
                            OnboardingFaceScanIntroView(path: $path)
                                .navigationBarBackButtonHidden()
                        case "mockscan":
                            OnboardingMockScanView(isFinished: $isFinished)
                                .navigationBarBackButtonHidden()
                        default:
                            EmptyView()
                        }
                    }
            }
            
            // Persistent Logo Overlay
            // We use a GeometryReader or matched geometry to transition, but since it's an overlay on top of NavigationStack,
            // we can just toggle the frame/position based on path state.
            VStack {
                // Single Identity Header
                // We use one view structure and animate its modifiers to ensure smooth resizing
                // rather than cross-fading between two different views.
                VStack {
                    if path.isEmpty {
                        Spacer()
                    }
                    
                    HStack(spacing: path.isEmpty ? 16 : 8) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            // Step 0: 120 (Large), Step 1+: 80 (Hero Normal), Step B: 24
                            .frame(width: path.isEmpty ? (introStep == 0 ? 120 : 80) : 24, 
                                   height: path.isEmpty ? (introStep == 0 ? 120 : 80) : 24)
                            .clipShape(RoundedRectangle(cornerRadius: path.isEmpty ? (introStep == 0 ? 30 : 22) : 6)) // Animated corner radius too
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        // Text reveals in Step 1
                        if !path.isEmpty || introStep > 0 {
                            Text("remi")
                                .font(.system(size: path.isEmpty ? 60 : 21, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppPrimaryText"))
                                .fixedSize()
                                .transition(.scale.combined(with: .opacity)) // Smooth reveal
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Explicitly center
                    .offset(x: (path.isEmpty && introStep > 0) ? -20 : 0) // Visual correction only when text is visible
                    .padding(.top, path.isEmpty ? 0 : 25) // Animate top padding
                    .padding(.bottom, path.isEmpty ? 40 : 0) // Nudge logo up in Step A
                    
                    if path.isEmpty {
                        Spacer()
                        // In Step 0/1 (Center), we want equal spacers. 
                        // In Step 2 (Final), we want extra spacer to push it up (approx 1/3 down)
                        if introStep == 2 {
                            Spacer()
                        }
                    } else {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity) // Ensure the container fills the width
            }
            .allowsHitTesting(false) // Let touches pass through to buttons
            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: path.isEmpty) // Smooth transition
            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: introStep) // Intro animation
            .onAppear {
                // Intro Animation Sequence
                // Phase 1: Reveal Text
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        introStep = 1
                    }
                }
                // Phase 2: Move Up
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        introStep = 2
                    }
                }
            }
            
            // Skip Button Overlay (Hidden on Step A / Hero)
            if !path.isEmpty {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isFinished = true
                            }
                        }) {
                            Text("Skip")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                        .glassEffect()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .allowsHitTesting(true)
            }
        }
    }
}
