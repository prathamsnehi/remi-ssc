//
//  UpdatePhotoFlow.swift
//  remi-ssc
//
//  Created by Pratham S on 2/27/26.
//

import SwiftUI
import SwiftData

struct UpdatePhotoFlow: View {
    @Bindable var person: Person
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var detector: FaceDetector
    @StateObject private var processor: PhotoMLProcessor
    
    @State private var inputImage: UIImage? = nil
    @State private var showPhotoScanner = false
    @State private var showCheckmark = false
    
    private var isiPad: Bool { horizontalSizeClass == .regular }
    
    init(person: Person) {
        self.person = person
        let tempDetector = FaceDetector()
        // Empty savedPersons ensures PhotoMLProcessor forces a registration extraction rather than a match
        self._detector = StateObject(wrappedValue: tempDetector)
        self._processor = StateObject(wrappedValue: PhotoMLProcessor(detector: tempDetector))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ARViewContainer(detector: detector, savedPersons: [])
                    .ignoresSafeArea()
                
                FaceOverlayViewfinder(detector: detector)
                    .ignoresSafeArea()
                
                HStack {
                    HeaderCapsule(
                        title: "Update Photo",
                        isScanning: detector.isScanModeOn,
                        onPhotosTap: {
                            showPhotoScanner = true
                        }
                    )
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font((isiPad ? Font.title2 : Font.caption).weight(.bold))
                            .foregroundStyle(Color("AppPrimaryText"))
                            .frame(width: isiPad ? 54 : 36, height: isiPad ? 54 : 36)
                    }
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                VStack {
                    Spacer()
                    
                    ScanModeFooter(
                        detector: detector,
                        showCheckmark: $showCheckmark,
                        onFinish: {
                            Task {
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                if let data = detector.registrationImage, !detector.registrationEmbeddings.isEmpty {
                                    applyNewPhotoData(jpegData: data, embeddings: detector.registrationEmbeddings)
                                }
                            }
                        }
                    )
                    .padding(.horizontal, isiPad ? 36 : 24)
                    .padding(.bottom, 20)
                }
                .ignoresSafeArea()
                
                // Photo Processor loading overlay
                if processor.isProcessing {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Processing Photo...")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            Text("Face recognition is powered by AI and can make mistakes.")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(30)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
            .onAppear {
                detector.isScanModeOn = true // start in scan mode instantly to hide standard find mode
            }
            .onChange(of: inputImage) { _, newImage in
                guard let image = newImage else { return }
                Task {
                    await processor.processSelectedImage(image)
                }
            }
            // Triggered if the Photo library flow provides a new high quality crop
            .onChange(of: processor.processedImageForRegistration) { _, newImage in
                if let newImage = newImage, let firstEmbedding = processor.generatedEmbeddingsForRegistration?.first {
                    if let data = newImage.jpegData(compressionQuality: 0.75) {
                        applyNewPhotoData(jpegData: data, embeddings: [firstEmbedding])
                    }
                }
            }
            .fullScreenCover(isPresented: $showPhotoScanner) {
                ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func applyNewPhotoData(jpegData: Data, embeddings: [[Float]]) {
        person.photoData = jpegData
        person.embeddingSamples.append(contentsOf: embeddings)
        print("Updated person photo and appended \(embeddings.count) embeddings")
        dismiss()
    }
}
