import SwiftUI

struct OnboardingLossView: View {
    @Binding var path: NavigationPath // Changed to path for navigation to Step C
    
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
                
                // Text Container
                VStack(spacing: 8) {
                    // First Text
                    if showFirstText {
                        Text("A face you’ve known for years...")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("AppPrimaryText"))
                            .transition(.opacity)
                    }
                    
                    // Second Text
                    if showSecondText {
                        Text("...suddenly feels like a stranger.")
                            .font(.system(.title2, design: .rounded, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("AppSecondaryText"))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .frame(minHeight: 120)
                .padding(.top, 20)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Button
                if showButton {
                    Button(action: {
                        path.append("struggle") // Go to Step C
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
        .navigationBarBackButtonHidden()
    }
    
    private func runAnimationSequence() {
        // Step 1: Show First Text (0.5s)
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            showFirstText = true
        }
        
        // Step 2: Wait 2.5s, then start gradual blur and show second text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 3.0)) {
                blurAmount = 10 
                imageOpacity = 0.8
            }
            
            // Show second text while blur is happening
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                showSecondText = true
            }
        }
        
        // Step 3: Show Button after blur completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation {
                showButton = true
            }
        }
    }
}
