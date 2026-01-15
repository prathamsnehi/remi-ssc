import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SavedFriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSwiftData.container())
}
