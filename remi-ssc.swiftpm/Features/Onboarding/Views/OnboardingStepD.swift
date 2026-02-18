import SwiftUI

struct OnboardingFaceScanIntroView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var path: NavigationPath
    
    // Animation States
    @State private var showContent = false
    @State private var showSteps = false // Animated steps
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: sizeClass == .regular ? 40 : 30) {
                    Spacer()
                    // Push content lower on iPhone
                    if sizeClass != .regular {
                        Spacer()
                    }
                    
                    // Icon / Illustration
                    if showContent {
                        // iPad Fix: Cap icon size to 100pt max, otherwise proportional. iPhone stays 80.
                        let iconSize: CGFloat = sizeClass == .regular ? min(geometry.size.width * 0.15, 100) : 80
                        
                        Image(systemName: "face.dashed") // Using SF Symbol as minimal representation
                            .font(.system(size: iconSize, weight: .light))
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
                            
                            Text("Instantly Recall Details About\nYour Loved Ones Just By\nSeeing Them.")
                                .font(.system(sizeClass == .regular ? .title2 : .body, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color("AppSecondaryText"))
                                .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.2 : 40)
                            
                            // Responsive "How it Works" Summary (iPhone & iPad Portrait)
                            // Show if vertical space allows (basically always except extreme landscape)
                            if geometry.size.height > geometry.size.width {
                                let contentSpacing: CGFloat = sizeClass == .regular ? 32 : 20
                                let rowSpacing: CGFloat = sizeClass == .regular ? 24 : 16
                                let iconSize: CGFloat = sizeClass == .regular ? 40 : 28
                                let textSize: Font = sizeClass == .regular ? .title3.weight(.medium) : .subheadline.weight(.medium)
                                let iconFrame: CGFloat = sizeClass == .regular ? 50 : 32
                                let sidePadding: CGFloat = sizeClass == .regular ? 60 : 20
                                let topPadding: CGFloat = sizeClass == .regular ? 40 : 20
                                
                                VStack(alignment: .leading, spacing: contentSpacing) {
                                    // Row 1: Camera (Left) -> Text (Right)
                                    HStack(spacing: rowSpacing) {
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: iconSize))
                                            .foregroundStyle(Color("AppPrimary"))
                                            .frame(width: iconFrame)
                                        
                                        Text("Simply point your camera")
                                            .font(textSize)
                                            .foregroundStyle(Color("AppSecondaryText"))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    // Row 2: Text (Left) -> Face (Right)
                                    HStack(spacing: rowSpacing) {
                                        Image(systemName: "face.dashed")
                                            .font(.system(size: iconSize))
                                            .foregroundStyle(Color("AppPrimary"))
                                            .frame(width: iconFrame)
                                        
                                        Text("Remi recognizes who they are")
                                            .font(textSize)
                                            .foregroundStyle(Color("AppSecondaryText"))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    // Row 3: Sparkles (Left) -> Text (Right)
                                    HStack(spacing: rowSpacing) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: iconSize))
                                            .foregroundStyle(Color("AppPrimary"))
                                            .frame(width: iconFrame)
                                        
                                        Text("Instantly see shared memories")
                                            .font(textSize)
                                            .foregroundStyle(Color("AppSecondaryText"))
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .padding(.horizontal, sidePadding) // Constraint width
                                .fixedSize(horizontal: true, vertical: false) // Hug content width so it centers
                                .frame(maxWidth: .infinity) // Center the hugging VStack in the screen space
                                .padding(.top, topPadding)
                                .opacity(showSteps ? 1 : 0) // Fade in
                            }
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
        
        // Step 2: Show "How it Works" Steps
        // Delay slightly after main text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                showSteps = true
            }
        }
        
        // Step 3: Button Appears (Wait for user to read everything)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
