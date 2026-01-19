//
//  ARView.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import SwiftUI
import RealityKit
import ARKit
import Vision
import UIKit

struct ARViewContainer: UIViewRepresentable { // Setting up the camera feed for AR
    typealias UIViewType = RealityKit.ARView

    var detector: FaceDetector // contains info of the location of the face
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(detector: detector)
    }
    
    func makeUIView(context: Context) -> RealityKit.ARView {
        let arView = RealityKit.ARView(frame: .zero)
        
        // use standard world tracking, aka rear camera:
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: RealityKit.ARView, context: Context) {
        // update if needed
    }
    
    // Coordinator to listen to frame updates (60 times a second)
    class Coordinator: NSObject, ARSessionDelegate {
        var arView: RealityKit.ARView?
        var detector: FaceDetector
        var isProcesing = false
        
        init(detector: FaceDetector) {
            self.detector = detector
        }
        
        // request: looking for faces:
        lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
            return VNDetectFaceRectanglesRequest { [weak self] request, error in
                guard let self = self else { return }
                
                if let results = request.results as? [VNFaceObservation], let result = results.first {
                    self.updateFaceLocation(boundingBox: result.boundingBox)
                } else {
                    // no face found, clear the location on the main thread:
                    DispatchQueue.main.async {
                        self.detector.faceLocation = nil
                        self.isProcesing = false
                    }
                }
            }
        }()
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard !isProcesing else { return }
            isProcesing = true
            
            let pixelBufferWrapper = SendablePixelBuffer(buffer: frame.capturedImage)
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBufferWrapper.buffer, orientation: .right)
                
                do {
                    try handler.perform([self.faceDetectionRequest])
                } catch {
                    print("Vision Request Failed")
                    // resetting processing status if it fails:
                    
                    DispatchQueue.main.async {
                        self.isProcesing = false
                    }
                }
            }
        }
        
        func updateFaceLocation(boundingBox: CGRect) {
            DispatchQueue.main.async {
                defer { self.isProcesing = false }
                
                guard let arView = self.arView else { return }
                
                // getting view dimensions:
                let viewSize = arView.bounds.size
                
                // convert vision coords to screen coords:
                let x = boundingBox.midX * viewSize.width
                let y = (1 - boundingBox.midY) * viewSize.height
                
                // updating publisher to add location of face:
                self.detector.faceLocation = CGPoint(x: x, y: y)
            }
        }
    }
}

extension ARViewContainer.Coordinator: @unchecked Sendable {}
struct SendablePixelBuffer: @unchecked Sendable {
    let buffer: CVPixelBuffer
}
