import SwiftUI

struct ARFooterCard: View {
    @ObservedObject var detector: FaceDetector
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            if detector.isScanModeOn {
                ScanModeFooter(
                    detector: detector,
                    showCheckmark: $showCheckmark,
                    onFinish: {
                        Task {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            detector.isScanModeOn = false
                            showCheckmark = false
                            
                            // passing the data collected in detector.registrationEmbeddings:
                            
                            
                            // finally, clearing the state so that it we get a clean slate immediately for the next registration
                        }
                    }
                )
            } else {
                IdentifyModeFooter(detector: detector)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .glassEffect()
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.isScanModeOn)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.isScanning)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.uiError != nil)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.isPersonOnCamera)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.identifiedPerson == nil)
    }
}
