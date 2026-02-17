import SwiftUI

struct OnboardingLossView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var path: NavigationPath // Changed to path for navigation to Step C
    
    @State private var blurAmount: CGFloat = 0
    @State private var imageOpacity: Double = 1.0
    
    // Animation States
    @State private var showFirstText: Bool = false
    @State private var showSecondText: Bool = false
    @State private var showButton: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppBackground") // Background base
                    .ignoresSafeArea()
                
                // Main Content Stack
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Push content down to center between header and button
                    Color.clear.frame(height: sizeClass == .regular ? geometry.size.height * 0.1 : 40)
                    
                    // Anchored Image (Stays in place)
                    Image("onboarding-grandmother")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: sizeClass == .regular ? geometry.size.height * 0.4 : 280,
                            height: sizeClass == .regular ? geometry.size.height * 0.4 : 280
                        )
                        .clipShape(Circle())
                        .blur(radius: blurAmount)
                        .opacity(imageOpacity)
                    
                    Spacer() // Flexible space above text
                    
                    // Text Container
                    VStack(spacing: sizeClass == .regular ? 16 : 8) {
                        // First Text
                        if showFirstText {
                            Text("A Face You Have Known For Years...")
                                .font(.system(sizeClass == .regular ? .largeTitle : .title, design: .rounded).weight(.semibold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color("AppPrimaryText"))
                                .transition(.opacity)
                        }
                        
                        // Second Text
                        if showSecondText {
                            Text("Suddenly Feels Like A Stranger.")
                                .font(.system(sizeClass == .regular ? .title : .title2, design: .rounded).weight(.medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color("AppSecondaryText"))
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .frame(minHeight: sizeClass == .regular ? 160 : 120) // Keep minimum height to prevent jump
                    .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.15 : 32)
                    
                    Spacer() // Flexible space below text
                    
                    // Button
                    if showButton {
                        Button(action: {
                            path.append("struggle") // Go to Step C
                        }) {
                            Text("I've seen it happen")
                                .font(sizeClass == .regular ? .title3.bold() : .headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity) // Fill available space
                                .frame(height: sizeClass == .regular ? 64 : 56) // Taller on iPad
                                .background(Color("AppPrimary"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.15 : 20)
                                .padding(.bottom, sizeClass == .regular ? 40 : 20)
                        }
                        .transition(.opacity.animation(.easeIn(duration: 1.0)))
                    } else {
                        Color.clear.frame(height: sizeClass == .regular ? 104 : 76)
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
        // Step 1: Show First Text (0.5s)
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            showFirstText = true
        }
        
        // Step 2: Wait 2.5s, then start gradual blur and show second text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 2.0)) {
                blurAmount = 10
                imageOpacity = 0.8
            }
            
            // Show second text while blur is happening
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                showSecondText = true
            }
        }
        
        // Step 3: Show Button after blur completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                showButton = true
            }
        }
    }
}
