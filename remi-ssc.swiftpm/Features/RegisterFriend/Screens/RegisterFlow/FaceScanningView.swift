//
//  FaceScanningView.swift
//  remi
//
//  Created by Pratham S on 1/28/26.
//

import SwiftUI

struct FaceScanningView: View {
    var onScanned: (UIImage, [[Double]]) -> Void
    var onCancel: () -> Void
    
    @StateObject private var detector = FaceDetector()
    
    // Scan State
    enum ScanState {
        case idle
        case scanning
        case complete
    }
    @State private var scanState: ScanState = .idle
    @State private var collectedSamples: [[Double]] = []
    
    // Timer State
    @State private var timeRemaining: Double = 3.0
    @State private var timer: Timer?
    let scanDuration: Double = 3.0
    
    // Gallery State
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            // 1. Camera Feed (AR)
            ARViewContainer(detector: detector)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(scanState == .complete ? 0.5 : 0))
            
            // 2. Overlays
            VStack {
                // Top Bar
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .background(Circle().fill(.black.opacity(0.3)))
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Center Feedback
                if scanState == .scanning {
                    ZStack {
                        // Countdown Ring
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat((scanDuration - timeRemaining) / scanDuration))
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: timeRemaining)
                        
                        // Face Guide
                        if let rect = detector.faceRect {
                            // In a real AR view, the face is moving. 
                            // We can overlay a static guide or track the face. 
                            // For simplicity, we just show the countdown/ring CENTERED on screen 
                            // as a "Look Here" target.
                        }
                        
                        Text("\(Int(ceil(timeRemaining)))")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 10)
                    }
                } else if scanState == .idle {
                    // Face Prompt
                    if detector.faceRect == nil {
                        Text("Point camera at face")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.5))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Bottom Controls
                if scanState == .idle {
                    HStack(spacing: 30) {
                        // Gallery Button
                        Button(action: { showImagePicker = true }) {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                Text("Gallery")
                                    .font(.caption)
                            }
                            .foregroundStyle(.white)
                        }
                        
                        // Start Scan Button
                        Button(action: startScan) {
                            Text("Start Scan")
                                .font(.title3.bold())
                                .foregroundStyle(.black)
                                .frame(width: 160, height: 55)
                                .background(Color.white)
                                .cornerRadius(30)
                        }
                        .disabled(detector.faceRect == nil)
                        .opacity(detector.faceRect == nil ? 0.5 : 1)
                    }
                    .padding(.bottom, 50)
                } else if scanState == .scanning {
                    Text("Hold Still...")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.bottom, 50)
                }
            }
        }
        // Sample Collection Logic
        .onChange(of: detector.lastEmbedding) { oldValue, newEmbedding in
            guard scanState == .scanning, let embedding = newEmbedding else { return }
            // Filter: basic check? (Assuming detector only outputs if face is detected)
            collectedSamples.append(embedding)
        }
        // Gallery Picker Sheet
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { _, image in
            if let img = image {
                processGalleryImage(img)
            }
        }
    }
    
    // MARK: - Actions
    
    func startScan() {
        scanState = .scanning
        detector.isScanning = true // Enable fast capture
        collectedSamples = []
        timeRemaining = 3.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                finishScan()
            }
        }
    }
    
    func finishScan() {
        detector.isScanning = false // Disable fast capture
        timer?.invalidate()
        timer = nil
        scanState = .complete
        
        // Use the last captured image as the profile photo
        guard let bestImage = detector.lastCapturedImage else {
            // Fallback? reset
            scanState = .idle
            return
        }
        
        // Pass data back
        onScanned(bestImage, collectedSamples)
    }
    
    func processGalleryImage(_ image: UIImage) {
        // For Gallery, we generate 1 sample.
        // We need to call usage FaceRecognitionService (async)
        Task {
            if let embedding = await FaceRecognitionService.shared.generateEmbedding(from: image) {
                // Success
                await MainActor.run {
                    onScanned(image, [embedding])
                }
            }
        }
    }
}
