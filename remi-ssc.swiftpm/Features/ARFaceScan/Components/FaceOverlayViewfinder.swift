import SwiftUI

struct FaceOverlayViewfinder: View {
    @ObservedObject var detector: FaceDetector
    
    var body: some View {
        GeometryReader { geometry in
            if let faceRect = detector.faceRect {
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Convert Vision coordinates (bottom-left) to SwiftUI coordinates (top-left)
                let rect = CGRect(
                    x: faceRect.origin.x * width,
                    y: (1.0 - faceRect.origin.y - faceRect.height) * height,
                    width: faceRect.width * width,
                    height: faceRect.height * height
                )
                
                ZStack {
                    if detector.isScanningFace {
                        // Circular scan progress ring
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 4)
                            .frame(width: rect.width * 1.2, height: rect.height * 1.2)
                        
                        Circle()
                            .trim(from: 0, to: detector.scanProgress)
                            .stroke(
                                Color.white.mix(with: .green, by: detector.scanProgress),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: rect.width * 1.2, height: rect.height * 1.2)
                            .rotationEffect(.degrees(-90))
                    } else {
                        // Standard viewfinder
                        Image(systemName: "viewfinder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: rect.width, height: rect.height)
                            .foregroundStyle(detector.identifiedPerson == nil ? Color.blue : Color.green)
                    }
                }
                .position(x: rect.midX, y: rect.midY)
                // transition for smooth box moving when faceRect updates
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 0.8))
                ))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: detector.faceRect)
    }
}