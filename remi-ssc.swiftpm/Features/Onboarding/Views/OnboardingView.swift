import SwiftUI

struct OnboardingView: View {
    @Binding var isFinished: Bool
    // Path for navigation
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            OnboardingHeroView(path: $path)
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                    case "loss":
                        // Step B: Loss View (Pass path to allow navigation to Struggle)
                        OnboardingLossView(path: $path)
                            .navigationBarBackButtonHidden()
                    case "struggle":
                        // Step C: Struggle View (Pass path for Step D)
                        OnboardingStruggleView(path: $path)
                            .navigationBarBackButtonHidden()
                    case "facescan":
                        // Step D: Face Scan Intro (Pass isFinished to end onboarding)
                        OnboardingFaceScanIntroView(isFinished: $isFinished)
                            .navigationBarBackButtonHidden()
                    default:
                        EmptyView()
                    }
                    
                    }
                }
        }
    }
