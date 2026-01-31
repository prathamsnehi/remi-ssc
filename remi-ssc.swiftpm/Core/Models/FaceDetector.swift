//
//  FaceDetector.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//
import SwiftUI
import SwiftData

class FaceDetector: ObservableObject {
    // If we see a face on the ARView, this object holds the bounding box of the face
    // The rect is in the ARView's coordinate space
    @Published var faceRect: CGRect? = nil
    
    // Identification Results
    @Published var identifiedPerson: Person? = nil
    @Published var isUnknown: Bool = false
    @Published var confidence: Double = 0.0
    
    // Store the last valid frame (used for registration)
    @Published var lastCapturedImage: UIImage? = nil
    
    // Store the last generated embedding (used for Multi-Vector Registration)
    @Published var lastEmbedding: [Double]? = nil
    
    // Scan Mode: If true, we throttle faster (0.1s)
    // Scan Mode: If true, we throttle faster (0.1s)
    @Published var isScanning: Bool = false
    
    // UI Feedback (e.g. "Low Quality", "Look at Camera")
    @Published var statusMessage: String? = nil
    
    // published to update SwiftUI whenever this updates
    // so that we can keep updating the position of the card based on if the person's face moves on camera
}
