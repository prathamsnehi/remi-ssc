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
    var personLookupMap: [UUID: [[Float]]] = [:]
    @Published  var savedPersons: [Person] = [] {
        didSet {
            // when Person in SwiftData changes
            // because auto-updates the savedPerson because of ARViewContainer's updateView method
            self.personLookupMap = Dictionary(uniqueKeysWithValues: savedPersons.map { ($0.id, $0.embeddingSamples) })
        }
    }
    // If we see a face on the ARView, this object holds the bounding box of the face
    // The rect is in the ARView's coordinate space
    @Published var faceRect: CGRect? = nil
    
    // ui errors:
    @Published var uiError: UIErrors? = nil
    
    // Identification Results
    @Published var isPersonOnCamera: Bool = false
    @Published var identifiedPerson: Person? = nil
    @Published var confidence: Double = 0.0
    
    // published to update SwiftUI whenever this updates
    // so that we can keep updating the position of the card based on if the person's face moves on camera
    
    func resetDetectorErrorStatus() {
        // resets the ui instructions that are set in the detector
        self.uiError = nil
    }
    
    func showUIError(errorType: UIErrors) {
        self.uiError = errorType
    }
    
    func setPersonOnCamera(_ status: Bool) {
        self.isPersonOnCamera = status
        if !status {
            self.faceRect = nil
        }
    }
    
    func setUIFaceRect(_ rect: CGRect?) {
        self.faceRect = rect
    }
    
    func showNoMatchFound() {
        self.identifiedPerson = nil
    }
    
    func showMatchFound(identifiedPerson: Person, confidence: Double) {
        self.identifiedPerson = identifiedPerson
        self.confidence = confidence
    }
}
