//
//  PersonIdentifyCard.swift
//  remi-ssc
//
//  Created by Pratham S on 2/2/26.
//

import SwiftUI

struct ARFooterCard: View {
    @ObservedObject var detector: FaceDetector
    
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            if detector.isScanningFace {
                // Special Variant: Registration Button / Scan Loop
                RegistrationButtonView(
                    detector: detector,
                    showCheckmark: $showCheckmark,
                    onFinish: {
                        Task {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            detector.isScanningFace = false
                            showCheckmark = false
                            detector.scanProgress = 0
                        }
                    }
                )
            } else if let error = detector.uiError {
                // Priority Variant: Show active scanning error (e.g. head tilt)
                ScanErrorView(message: error.uiMessage)
            } else if !detector.isPersonOnCamera {
                // Variant 1: No person detected
                ScanPromptView()
            } else if let person = detector.identifiedPerson {
                // Variant 3: Identified person
                IdentifiedPersonView(person: person, confidence: detector.confidence)
            } else {
                // Variant 2: Person detected but not registered
                UnregisteredPersonView(detector: detector)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .frame(height: 90) // Fixed height for a consistent, prominent feel
        .glassEffect()
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.isScanningFace)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.isScanning)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.uiError != nil)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.isPersonOnCamera)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: detector.identifiedPerson == nil)
    }
}

// MARK: - Subviews

private struct ScanErrorView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Scanning Problem")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(message)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            Spacer()
        }
    }
}

private struct ScanPromptView: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "face.dashed")
                .font(.system(size: 24))
                .foregroundStyle(.blue.opacity(0.8))
            
            Text("Point camera towards a face")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

private struct UnregisteredPersonView: View {
    @ObservedObject var detector: FaceDetector
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Person Not Recognized")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Register them to save memories")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button {
                detector.isScanningFace = true
            } label: {
                Text("Register")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white))
            }
        }
    }
}

private struct RegistrationButtonView: View {
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
                            
                            if detector.isScanning {
                                Text("Hold Still")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
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

private struct IdentifiedPersonView: View {
    let person: Person
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile thumbnail
            if let uiImage = UIImage(data: person.photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(person.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("\(Int(confidence * 100))% Match")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.green.opacity(0.1)))
                }
                
                Text(person.relation)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            NavigationLink(destination: FriendProfileView(person: person)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white.opacity(0.1)))
            }
        }
    }
}
