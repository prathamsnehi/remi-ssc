import SwiftUI

struct OnboardingLossView: View {
    @Binding var isFinished: Bool // Changed from path to isFinished
    
    @State private var blurAmount: CGFloat = 0
    @State private var imageOpacity: Double = 1.0
    
    // Animation States
    @State private var showFirstText: Bool = false
    @State private var showSecondText: Bool = false
    @State private var showButton: Bool = false
    
    var body: some View {
        ZStack {
            Color("AppBackground") // Background base
                .ignoresSafeArea()
            
            // Main Content Stack
            VStack(spacing: 0) {
                Spacer()
                
                // Anchored Image (Stays in place)
                Image("onboarding-grandmother")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 280, height: 280)
                    .clipShape(Circle())
                    .blur(radius: blurAmount)
                    .opacity(imageOpacity)
                    // Removed saturation modifier to keep color
                    // Animation is handled by the state changes in withAnimation block
                
                // Text Container (Fixed height to prevent jumping, or flexible)
                VStack(spacing: 8) { // Reduced spacing between lines
                    // First Text (Always visible after delay)
                    if showFirstText {
                        Text("A face you’ve known for years...")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("AppPrimaryText"))
                            .transition(.opacity) // Fade in only, no movement
                    }
                    
                    // Second Text (Appears below first)
                    if showSecondText {
                        Text("...suddenly feels like a stranger.")
                            .font(.system(.title2, design: .rounded, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("AppSecondaryText"))
                            .transition(.opacity.combined(with: .move(edge: .bottom))) // Moves up from bottom
                    }
                }
                .frame(minHeight: 120) // Reduced height
                .padding(.top, 20) // Reduced padding from image
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Button
                if showButton {
                    Button(action: {
                        withAnimation {
                            isFinished = true
                        }
                    }) {
                        Text("I've seen it happen")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("AppPrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    .transition(.opacity.animation(.easeIn(duration: 1.0)))
                } else {
                    Color.clear.frame(height: 76)
                }
            }
        }
        .onAppear {
            runAnimationSequence()
        }
    }
    
    private func runAnimationSequence() {
        // Step 1: Show First Text (0.5s)
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            showFirstText = true
        }
        
        // Step 2: Wait 3.5s, then start gradual blur and show second text
        // Blur takes 3 seconds (was 6s, user requested faster)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 3.0)) { // Changed to easeInOut for smoother start/end
                blurAmount = 10 
                imageOpacity = 0.8
            }
            
            // Show second text while blur is happening
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                showSecondText = true
            }
        }
        
        // Step 3: Show Button after blur completes + reading time
        // 2.5s start + 3.0s duration + .5s reading buffer = ~6.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation {
                showButton = true
            }
        }
    }
}
