//
//  FaceDetector.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//
import SwiftUI
import SwiftData

@MainActor
class FaceDetector: ObservableObject {
    // If we see a face on the ARView, this object holds the bounding box of the face
    // The rect is in the ARView's coordinate space
    @Published var faceRect: CGRect? = nil
    
    // Identification Results
    @Published var identifiedPerson: Person? = nil
    @Published var confidence: Double = 0.0
    
    // published to update SwiftUI whenever this updates
    // so that we can keep updating the position of the card based on if the person's face moves on camera
}
