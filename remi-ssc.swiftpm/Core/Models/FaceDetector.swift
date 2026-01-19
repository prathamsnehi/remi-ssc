//
//  FaceDetector.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//
import SwiftUI

class FaceDetector: ObservableObject {
    // if we see a face on the ARView, this object holds the location of the face
    // and nil if no face
    @Published var faceLocation: CGPoint? = nil
    
    // published to update SwiftUI whenever this updates
    // so that we can keep updating the position of the card based on if the person's face moves on camera
}
