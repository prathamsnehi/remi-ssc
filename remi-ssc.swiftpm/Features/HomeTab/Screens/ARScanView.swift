//
//  ARScanView.swift
//  Remi
//
//  Created by Pratham S on 1/17/26.
//

import SwiftUI
import RealityKit
import ARKit
import SwiftData

struct ARScanView: UIViewRepresentable {
    @Binding var scannedFaceName: String?
    var modelContext: ModelContext
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return arView
        }
        
        let config = ARFaceTrackingConfiguration()
        config.maximumNumberOfTrackedFaces = 1
        
        arView.session.delegate = context.coordinator
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // 1. FIX: Add '@unchecked Sendable' to silence the "Sending self" error
    class Coordinator: NSObject, ARSessionDelegate, @unchecked Sendable {
        var parent: ARScanView
        var isProcessingFrame = false
        
        var currentFaceAnchorEntity: AnchorEntity?
        let faceMatcher = FaceMatchingService()

        init(parent: ARScanView) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard !isProcessingFrame else { return }
            isProcessingFrame = true
            
            // Capture image locally
            let pixelBuffer = frame.capturedImage
            
            // 2. FIX: Use [weak self] to safely handle 'self' inside the Task
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                defer { self.isProcessingFrame = false }
                
                // Identify the face
                if let result = self.faceMatcher.identifyFace(in: pixelBuffer,
                                                            modelContext: self.parent.modelContext) {
                    
                    let personName = result.person.name
                    
                    // Update UI only if changed
                    if self.parent.scannedFaceName != personName {
                        self.parent.scannedFaceName = personName
                        self.updateARCard(text: personName)
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.first as? ARFaceAnchor,
                  let arView = session.delegate as? ARView else { return }
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                let anchorEntity = AnchorEntity(anchor: faceAnchor)
                let cardEntity = GlassCard.createCard(text: "Scanning...")
                
                anchorEntity.addChild(cardEntity)
                arView.scene.addAnchor(anchorEntity)
                
                self.currentFaceAnchorEntity = anchorEntity
            }
        }
        
        @MainActor
        func updateARCard(text: String) {
            guard let anchorEntity = currentFaceAnchorEntity else { return }
            
            anchorEntity.children.removeAll()
            let newCard = GlassCard.createCard(text: text)
            anchorEntity.addChild(newCard)
        }
    }
}
