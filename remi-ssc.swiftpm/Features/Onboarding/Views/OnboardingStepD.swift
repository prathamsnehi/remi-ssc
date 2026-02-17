import SwiftUI

struct OnboardingFaceScanIntroView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var path: NavigationPath
    
    // Animation States
    @State private var showContent = false
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: sizeClass == .regular ? 40 : 30) {
                    Spacer()
                    
                    // Icon / Illustration
                    if showContent {
                        Image(systemName: "face.dashed") // Using SF Symbol as minimal representation
                            .font(.system(size: sizeClass == .regular ? geometry.size.width * 0.15 : 80, weight: .light))
                            .foregroundStyle(Color("AppPrimary"))
                            .padding(.bottom, sizeClass == .regular ? 40 : 20)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Text Content
                    if showContent {
                        VStack(spacing: sizeClass == .regular ? 24 : 16) {
                            Text("Your Memories,\nUnlocked By A Face")
                                .font(.system(sizeClass == .regular ? .largeTitle : .title, design: .rounded).weight(.heavy))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color("AppPrimaryText"))
                            
                            Text("Instantly Recall Details About Your Loved Ones, Just By Seeing Them.")
                                .font(.system(sizeClass == .regular ? .title2 : .body, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color("AppSecondaryText"))
                                .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.2 : 40)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer()
                    
                    // The Selection Button (Simulating HomeView placement/component)
                    if showButton {
                        SelectionButton(
                            title: "Scan Face",
                            icon: "faceid",
                            backgroundColor: Color("AppPrimary"),
                            foregroundColor: .white,
                            height: sizeClass == .regular ? 140 : 110, // Taller on iPad
                            titleFont: sizeClass == .regular ? .title.bold() : .title2,
                            iconFont: sizeClass == .regular ? .system(size: 50) : .largeTitle,
                            action: {
                                path.append("mockscan") // Navigate to Step E
                            }
                        )
                        .frame(width: sizeClass == .regular ? geometry.size.width * 0.7 : nil) // 70% width on iPad
                        .frame(maxWidth: .infinity) // Center the button relative to screen
                        .padding(.horizontal, 30) // Matches HomeView padding (mainly for iPhone)
                        .padding(.bottom, sizeClass == .regular ? 50 : 50)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            }
        }
        .onAppear {
            runAnimationSequence()
        }
        .navigationBarBackButtonHidden()
    }
    
    private func runAnimationSequence() {
        // Step 1: Content Fade In
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            showContent = true
        }
        
        // Step 2: Button Appears (Wait for user to read)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showButton = true
            }
        }
    }
}

#Preview {
    @State var path = NavigationPath()
    OnboardingFaceScanIntroView(path: $path)
}
