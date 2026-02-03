import SwiftUI

struct ScanModeFooter: View {
    @ObservedObject var detector: FaceDetector
    @Binding var showCheckmark: Bool
    var onFinish: () -> Void
    
    var body: some View {
        RegistrationButtonView(
            detector: detector,
            showCheckmark: $showCheckmark,
            onFinish: onFinish
        )
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
                            .font(.system(size: 24))
                            .foregroundStyle(.green)
                        
                        Text("Scan Complete")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    HStack(spacing: 16) {
                        Image(systemName: detector.isScanning ? "faceid" : "viewfinder")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        
                        VStack(alignment: detector.isScanning ? .center : .leading, spacing: 2) {
                            Text(detector.isScanning ? "Scanning Face..." : "Start Face Scan")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Hold Still")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
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
