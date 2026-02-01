import SwiftUI

struct FaceScanWarning: View {
    @ObservedObject var detector: FaceDetector
    
    var body: some View {
        Group {
            if let error = detector.uiError {
                HStack(spacing: 8) {
                    Text(error.uiMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassEffect()
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(0.1), lineWidth: 0.5)
                        }
                }
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: detector.uiError == nil)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FaceScanWarning(detector: FaceDetector())
            .onAppear {
                // For preview testing, we'd need to mock the detector state
                // Since FaceDetector is @MainActor, we'd do this in a task
            }
    }
}
