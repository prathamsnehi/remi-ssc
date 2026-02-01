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
                
                Image(systemName: "viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: rect.width, height: rect.height)
                    .foregroundStyle(detector.identifiedPerson == nil ? Color.blue : Color.green)
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