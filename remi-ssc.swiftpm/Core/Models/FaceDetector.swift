//
//  FaceDetector.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//
import SwiftUI
import SwiftData

enum UIErrors {
    case headTilted
    
    var uiMessage: String {
        switch self {
        case .headTilted: return "head is tilted, please face the camera"
        }
    }
}

@MainActor
class FaceDetector: ObservableObject {
    // If we see a face on the ARView, this object holds the bounding box of the face
    // The rect is in the ARView's coordinate space
    @Published var faceRect: CGRect? = nil
    
    // ui errors:
    @Published var uiError: UIErrors? = nil
    
    // Identification Results
    @Published var identifiedPerson: Person? = nil
    @Published var confidence: Double = 0.0
    
    // published to update SwiftUI whenever this updates
    // so that we can keep updating the position of the card based on if the person's face moves on camera
}
