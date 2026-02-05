import SwiftUI
import SwiftData

@main
struct remiApp: App {
    var sharedModelContainer: ModelContainer = {
        // CHANGE HERE: We replaced [Item.self] with your actual models
        let schema = Schema([
            Person.self,
            Memory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // ---------------------------------------------------------
            // DEBUG: Uncomment these lines to wipe data on launch
//             try? container.mainContext.delete(model: Person.self)
//             try? container.mainContext.delete(model: Memory.self)
            // ---------------------------------------------------------
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color("AppPrimary"))
        }
        .modelContainer(sharedModelContainer)
    }
}
