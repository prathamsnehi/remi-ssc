import SwiftUI

struct OnboardingHeroView: View {
    @Binding var path: NavigationPath
    
    @State private var opacity = 0.0
    @State private var subtitleIndex = 0
    @State private var showSubtitle = false
    
    private let subtitles = [
        "build stronger relationships with those you love",
        "have confidence talking to those you love",
        "never let someone familiar be a stranger again"
    ]
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo & App Name
                VStack(spacing: 24) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180) // Much bigger
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Text("Remi")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppPrimaryText"))
                }
                
                Spacer()
                
                // Subtitles
                VStack(spacing: 20) {
                    Text("Your Face Based\nMemory Bank To:")
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppPrimaryText"))
                    
                    Text(subtitles[subtitleIndex])
                        .font(.title3)
                        .foregroundStyle(Color("AppSecondaryText"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .id("subtitle-\(subtitleIndex)")
                        .opacity(showSubtitle ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8), value: showSubtitle)
                }
                
                Spacer()
                
                // Button
                Button(action: {
                    path.append("struggle") // Go to Step B (Struggle)
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
                .opacity(opacity)
            }
        }
        .onAppear {
            // Intro
            withAnimation(.easeOut(duration: 1.5)) {
                opacity = 1.0
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
