//
//  PreviewSwiftData.swift
//  remi
//
//  Created by Pratham S on 12/25/25.
//

import SwiftUI
import SwiftData

struct PreviewSwiftData {
    @MainActor
    static func container() -> ModelContainer {
        let schema = Schema([
            Person.self,
            Memory.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            
            // Mock Data
            let image1 = UIImage(named: "sample_image_1")
            let image2 = UIImage(named: "sample_image_2")
            
            // Fallback to a system image if assets are missing
            let fallbackData = UIImage(systemName: "person.fill")?.pngData() ?? Data()
            
            let data1 = image1?.jpegData(compressionQuality: 0.8) ?? fallbackData
            let data2 = image2?.jpegData(compressionQuality: 0.8) ?? fallbackData
            
            // Person 1
            let person1 = Person(
                name: "Ishowspeed",
                relation: "Streamer of the year",
                photoData: data1
            )
            let memory1 = Memory(content: "Please speed I need this. My mom is kinda homeless. I live w my dad", type: .general)
            person1.memories.append(memory1)
            
            // Person 2
            let person2 = Person(
                name: "Kai Cenat",
                relation: "Just a normal streamer",
                photoData: data2
            )
            let memory2 = Memory(content: "Idk just stream to a bunch of people I guess", type: .general)
            person2.memories.append(memory2)
            
            container.mainContext.insert(person1)
            container.mainContext.insert(person2)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
