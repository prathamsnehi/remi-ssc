//
//  Models.swift
//  remi
//
//  Created by Pratham S on 12/25/25.
//

import Foundation
import SwiftData

@Model
class Person {
    var name: String
    var relation: String
    @Attribute(.externalStorage) var photoData: Data // Store the photo
    var lastInteracted: Date // For "Frequently Met" sorting
    
    // Legacy: Single embedding (Deprecated, but kept for migration safety)
    var faceEmbedding: [Double] 
    
    @Relationship(deleteRule: .cascade) var memories: [Memory] = []
    
    // New: Multi-Vector Registry
    @Relationship(deleteRule: .cascade) var samples: [FaceSample] = []
    
    init(name: String, relation: String = "Friend", photoData: Data, faceEmbedding: [Double] = []) {
        self.name = name
        self.relation = relation
        self.photoData = photoData
        self.lastInteracted = Date()
        self.faceEmbedding = faceEmbedding
        self.samples = [] // Initialize empty
    }
}
