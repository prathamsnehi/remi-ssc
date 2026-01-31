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
    var id = UUID()
    var name: String
    var relation: String
    @Attribute(.externalStorage) var photoData: Data // Store the photo
    var lastInteracted: Date // For "Frequently Met" sorting
    
    
    @Relationship(deleteRule: .cascade) var memories: [Memory] = []
    
    // New: Multi-Vector Registry
    init(name: String, relation: String = "Friend", photoData: Data) {
        self.name = name
        self.relation = relation
        self.photoData = photoData
        self.lastInteracted = Date()
    }
}
