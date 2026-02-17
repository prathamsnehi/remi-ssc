import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
        
    
    var body: some View {
        if  hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView(isFinished: $hasCompletedOnboarding)
                .transition(.opacity.combined(with: .scale)) // smooth handoff to non-onboarding content
        }
    }
}


//#Preview (traits: .landscapeLeft) {
#Preview() {
    ContentView()
        .modelContainer(PreviewSwiftData.container())
        .preferredColorScheme(.dark)
        .tint(Color("AppPrimary"))
}
