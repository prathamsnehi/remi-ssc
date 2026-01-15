//
//  Models.swift
//  remi
//
//  Created by Pratham S on 12/21/25.
//

import Foundation
import SwiftData

enum MemoryType: String, Codable {
    case general
    case preference
    case milestone
}

enum MemorySentiment: String, Codable {
    case positive
    case neutral
    case negative // make the ai cautious about suggesting a negative memory
    // aka, double check before assigning this
}

enum MemoryImportance: String, Codable {
    case low
    case medium
    case high
}


@Model
class Memory {
    // Core Memory:
    var content: String
    @Attribute(.externalStorage) var photoData: Data? // Optional photo for the memory
    
    
    // Time-Related Metadata:
    var dateAdded: Date
    var dateOccurred: Date? // when did this memory occur
    var isRecurring: Bool // birthdays, anniversaries, all that stuff
    
    // Other Metadata:
    var type: MemoryType
    var sentiment: MemorySentiment
    var importance: MemoryImportance
    
    
    init(content: String, photoData: Data? = nil, type: MemoryType, dateOccurred: Date? = nil, isRecurring: Bool = false, sentiment: MemorySentiment = .neutral, importance: MemoryImportance = .low) {
        self.content = content
        self.photoData = photoData
        
        self.dateAdded = Date()
        self.dateOccurred = dateOccurred
        self.isRecurring = isRecurring
        
        self.type = type
        self.sentiment = sentiment
        self.importance = importance
    }
    
    /// Formats the memory and its metadata into a string suitable for AI context.
    func getFormattedMetadata() -> String {
        let dateAddedStr = dateAdded.formatted(date: .abbreviated, time: .omitted)
        let dateOccurredStr = dateOccurred?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
        
        return """
        Content: \(content)
        - Date Added: \(dateAddedStr)
        - Date Occurred: \(dateOccurredStr)
        - Type: \(type.rawValue)
        - Importance: \(importance.rawValue)
        - Sentiment: \(sentiment.rawValue)
        - Recurring: \(isRecurring)
        """
    }
}
