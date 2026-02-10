import SwiftUI

struct OnboardingHeroView: View {
    @Binding var path: NavigationPath
    
    @State private var opacity = 0.0 // Text opacity
    @State private var buttonOpacity = 0.0 // Button opacity
    @State private var subtitleIndex = 0
    @State private var showSubtitle = false
    
    private let subtitles = [
        "Recall Every Face",
        "Connect Without Fear",
        "Deepen Every Bond"
    ]
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Reserve space for the logo overlay
                Spacer()
                    .frame(height: 240)
                
                Spacer()
                
                // Subtitles
                VStack(spacing: 32) {
                    Text("Your Face-Based Memory Bank")
                        .font(.system(.title2, design: .rounded).weight(.heavy)) // Extra bold for emphasis
                        .foregroundStyle(Color("AppPrimaryText"))
                        .multilineTextAlignment(.center)
                    
                    Text(subtitles[subtitleIndex])
                        .font(.system(.title3, design: .rounded).weight(.medium)) // Distinctly lighter than headline
                        .foregroundStyle(Color("AppSecondaryText"))
                        .multilineTextAlignment(.center)
                        .id("subtitle-\(subtitleIndex)")
                        .opacity(showSubtitle ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8), value: showSubtitle)
                }
                .padding(.horizontal, 35) // Constrain to approx 70% width for narrower look
                .opacity(opacity) // Sync fade-in with button
                
                Spacer()
                
                // Button
                Button(action: {
                    path.append("loss") // Go to Step B (Loss)
                }) {
                    Text("Tap to Begin Journey")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("AppPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .opacity(buttonOpacity)
            }
        }
        .onAppear {
            // Intro - Wait for Logo Animation to finish (approx 2.8s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 1.0
                }
            }
            
            // Button appears 1s later (3.8s total)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                withAnimation(.easeOut(duration: 1.0)) {
                    buttonOpacity = 1.0
                }
            }
            
            // Start Subtitle Cycle
            startSubtitleCycle()
        }
    }
    
    private func startSubtitleCycle() {
        // Initial show
        withAnimation {
            showSubtitle = true
        }
        
        // Total cycle time: 2.5 seconds (gives ~1.5s reading time + 1s transitions)
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            // Fade out (0.4s)
            withAnimation(.easeInOut(duration: 0.4)) {
                showSubtitle = false
            }
            
            // Wait 0.4s, then switch text & Fade in (0.4s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                subtitleIndex = (subtitleIndex + 1) % subtitles.count
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSubtitle = true
                }
            }
        }
    }
}

#Preview {
    @State var path = NavigationPath()
    OnboardingHeroView(path: $path)
}
