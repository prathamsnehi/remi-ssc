import SwiftUI

struct OnboardingFaceScanIntroView: View {
    @Binding var path: NavigationPath
    
    // Animation States
    @State private var showContent = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon / Illustration
                if showContent {
                    Image(systemName: "face.dashed") // Using SF Symbol as minimal representation
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(.bottom, 20)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Text Content
                if showContent {
                    VStack(spacing: 16) {
                        Text("Your Memories,\nUnlocked By A Face")
                            .font(.system(.title, design: .rounded).weight(.heavy))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("AppPrimaryText"))
                        
                        Text("Instantly Recall Details About Your Loved Ones, Just By Seeing Them.")
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("AppSecondaryText"))
                            .padding(.horizontal, 40)
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
                        height: 110,
                        titleFont: .title2,
                        iconFont: .largeTitle,
                        action: {
                            path.append("mockscan") // Navigate to Step E
                        }
                    )
                    .padding(.horizontal, 30) // Matches HomeView padding
                    .padding(.bottom, 50)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
