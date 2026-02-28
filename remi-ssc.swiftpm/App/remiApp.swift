import SwiftUI
import SwiftData

@main
struct remiApp: App {
    var sharedModelContainer: ModelContainer = {
        // CHANGE HERE: We replaced [Item.self] with your actual models
        let schema = Schema([
            Person.self,
            Memory.self,
            Metadata.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // PRELOAD DATA FOR JUDGES
            Task { @MainActor in
                let descriptor = FetchDescriptor<Person>()
                let existingCount = (try? container.mainContext.fetchCount(descriptor)) ?? 0
                
                if existingCount == 0 {
                    // Only preload if the database is completely empty on first launch
                    let fallbackData = UIImage(systemName: "person.fill")?.pngData() ?? Data()
                    let data1 = UIImage(named: "sample_image_1")?.jpegData(compressionQuality: 0.8) ?? fallbackData
                    let data2 = UIImage(named: "sample_image_2")?.jpegData(compressionQuality: 0.8) ?? fallbackData
                    let beachData = UIImage(named: "beach_sample_image")?.jpegData(compressionQuality: 0.8)
                    
                    let person1 = Person(
                        name: "Sarah Jenkins",
                        relation: "Stock Photo Model (Sample)",
                        photoData: data1,
                        embeddingSamples: []
                    )
                    
                    let person2 = Person(
                        name: "David Chen",
                        relation: "Stock Photo Model (Sample)",
                        photoData: data2,
                        embeddingSamples: []
                    )
                    
                    // Add memories for Sarah
                    let mem1 = Memory(content: "We just went to the beach today and it was super windy but we found some amazing shells.", photoData: beachData, type: .general)
                    let mem2 = Memory(content: "Sarah's favorite food is sushi. Make sure to take her to that new place downtown for her birthday next month.", type: .preference)
                    let mem3 = Memory(content: "I've known Sarah since freshman year of college in the dorms.", type: .general)
                    mem1.dateAdded = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                    mem2.dateAdded = Calendar.current.date(byAdding: .day, value: -15, to: Date())!
                    mem3.dateAdded = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
                    
                    person1.memories.append(contentsOf: [mem1, mem2, mem3])
                    
                    // Add memories for David
                    let davidMem1 = Memory(content: "David helped me move into my new apartment. Such a lifesaver.", type: .general)
                    let davidMem2 = Memory(content: "He's allergic to peanuts - definitely need to remember this when cooking.", type: .general)
                    let davidMem3 = Memory(content: "We took this awesome trip to the coast last summer.", photoData: beachData, type: .general)
                    davidMem1.dateAdded = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
                    davidMem2.dateAdded = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                    davidMem3.dateAdded = Calendar.current.date(byAdding: .month, value: -8, to: Date())!
                    
                    person2.memories.append(contentsOf: [davidMem1, davidMem2, davidMem3])
                    
                    container.mainContext.insert(person1)
                    container.mainContext.insert(person2)
                    
                    try? container.mainContext.save()
                    print("Successfully preloaded sample data for judges.")
                }
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
