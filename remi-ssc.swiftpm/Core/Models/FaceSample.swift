//
//  FaceSample.swift
//  remi
//
//  Created by Pratham S on 1/28/26.
//

import Foundation
import SwiftData

@Model
class FaceSample {
    var embedding: [Double]
    var source: String // e.g. "scan", "gallery"
    var timestamp: Date
    var qualityScore: Double // Optional: Place to store alignment confidence etc.
    
    // Reverse relationship to Person
    var person: Person?
    
    init(embedding: [Double], source: String = "scan", qualityScore: Double = 1.0) {
        self.embedding = embedding
        self.source = source
        self.timestamp = Date()
        self.qualityScore = qualityScore
    }
}
