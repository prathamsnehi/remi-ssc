import SwiftUI

struct ARFooterCard: View {
    @ObservedObject var detector: FaceDetector
    @State private var showCheckmark = false
    @State private var showRegisterSheet = false
    @State private var capturedImage: UIImage?
    @State private var capturedEmbeddings: [[Float]]?
    
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
                            
                            // 1. Capture the data collected in detector.registrationImage/Embeddings before resetting
                            if let data = detector.registrationImage {
                                self.capturedImage = UIImage(data: data)
                            }
                            self.capturedEmbeddings = detector.registrationEmbeddings
                            
                            // 2. Open the registration flow
                            showRegisterSheet = true
                            
                            // 3. Reset the UI state of the footer
                            detector.isScanModeOn = false
                            showCheckmark = false
                            
                            // finally, clearing the state so that it we get a clean slate immediately for the next registration
                            detector.resetFaceScanState()
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
        .sheet(isPresented: $showRegisterSheet) {
            RegisterView(
                preCapturedImage: capturedImage,
                preCapturedEmbeddings: capturedEmbeddings
            )
        }
    }
}
