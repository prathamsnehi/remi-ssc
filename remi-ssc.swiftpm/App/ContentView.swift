import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        TabView {
            // 1. Main Tabs
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Friends", systemImage: "person.2.fill") {
                SavedFriendsView()
            }
            
            if sizeClass == .regular {
                if sizeClass == .regular {
                // 2. Quick Items Section (Sidebar Only)
                TabSection("Quick Items") {
                    Tab("Favorites", systemImage: "star.fill") {
                        StubView(title: "Favorites", iconName: "star.fill")
                    }
                    
                    Tab("New Memory", systemImage: "plus.circle.fill") {
                        StubView(title: "New Memory", iconName: "plus.circle.fill")
                    }
                }
                // 3. Quick Register Section (Sidebar Only)
                TabSection("Quick Register") {
                    Tab("From Photos", systemImage: "photo.on.rectangle") {
                        StubView(title: "From Photos", iconName: "photo.on.rectangle")
                    }
                    
                    Tab("From Camera", systemImage: "camera") {
                        StubView(title: "From Camera", iconName: "camera")
                    }
                }
                
                // 4. Preferences (Bottom)
                Tab("Preferences", systemImage: "gear", role: .none) {
                    StubView(title: "Preferences", iconName: "gear")
                }
            }    }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSwiftData.container())
}
