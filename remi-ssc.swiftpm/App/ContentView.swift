import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Friends", systemImage: "person.2.fill") {
                SavedFriendsView()
            }
        }
        
    }
}



//#Preview (traits: .landscapeLeft) {
#Preview() {
    ContentView()
        .modelContainer(PreviewSwiftData.container())
        .preferredColorScheme(.dark)
}
