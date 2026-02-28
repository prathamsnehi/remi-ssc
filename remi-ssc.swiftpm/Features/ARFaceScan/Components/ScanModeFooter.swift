import SwiftUI

struct ScanModeFooter: View {
    @ObservedObject var detector: FaceDetector
    @Binding var showCheckmark: Bool
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            RegistrationButtonView(
                detector: detector,
                showCheckmark: $showCheckmark,
                onFinish: onFinish
            )
            
            Text("Face recognition is powered by AI and can make mistakes.")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

struct RegistrationButtonView: View {
    @ObservedObject var detector: FaceDetector
    @Binding var showCheckmark: Bool
    var onFinish: () -> Void
    
    var body: some View {
        Button {
            if !detector.isScanning && !showCheckmark {
                startScanning()
            }
        } label: {
            ZStack {
                if showCheckmark {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                        
                        Text("Scan Complete")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color("AppPrimaryText"))
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    HStack(spacing: 16) {
                        Image(systemName: detector.isScanning ? "faceid" : "viewfinder")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color("AppPrimaryText"))
                        
                        VStack(alignment: detector.isScanning ? .center : .leading, spacing: 2) {
                            Text(detector.isScanning ? "Scanning Face..." : "Start Face Scan")
                                .font(.body.weight(.bold))
                                .foregroundStyle(Color("AppPrimaryText"))
                            
                            Text("Hold Still")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color("AppPrimaryText"))
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func startScanning() {
        detector.isScanning = true
        detector.scanProgress = 0
        
        withAnimation(.linear(duration: 3.0)) {
            detector.scanProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring()) {
                detector.isScanning = false
                showCheckmark = true
            }
            onFinish()
        }
    }
}
