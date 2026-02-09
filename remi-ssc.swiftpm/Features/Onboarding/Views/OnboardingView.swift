import SwiftUI

struct OnboardingView: View {
    @Binding var isFinished: Bool
    // Path for navigation
    @State private var path = NavigationPath()
    @Namespace private var animation
    @Environment(\.horizontalSizeClass) var sizeClass
    
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
                            .frame(width: path.isEmpty ? 80 : 24, height: path.isEmpty ? 80 : 24)
                            .clipShape(RoundedRectangle(cornerRadius: path.isEmpty ? 22 : 6)) // Animated corner radius too
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Text("remi")
                            .font(.system(size: path.isEmpty ? 60 : 21, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppPrimaryText"))
                            .fixedSize()
                    }
                    .frame(maxWidth: .infinity) // Always centered horizontally
                    .padding(.top, path.isEmpty ? 0 : 25) // Animate top padding
                    
                    if path.isEmpty {
                        Spacer()
                        Spacer()
                    } else {
                        Spacer()
                    }
                }
            }
            .allowsHitTesting(false) // Let touches pass through to buttons
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: path.isEmpty) // Smooth transition
            
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
