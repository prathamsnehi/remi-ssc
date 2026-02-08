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
                    case "struggle":
                        // Step B: Struggle View (Pass path to allow navigation to Loss)
                        OnboardingStruggleView(path: $path)
                            .navigationBarBackButtonHidden()
                    case "loss":
                        // Step C: Loss View (Pass isFinished to end onboarding)
                        OnboardingLossView(isFinished: $isFinished)
                            .navigationBarBackButtonHidden()
                    default:
                        EmptyView()
                    }
                }
        }
    }
}
