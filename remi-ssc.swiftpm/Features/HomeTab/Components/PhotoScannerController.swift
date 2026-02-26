//
//  PhotoScannerController.swift
//  remi-ssc
//
//  Created by Pratham S on 2/25/26.
//

import SwiftUI
import SwiftData

/// State wrapper handling the pipeline from Image Picker -> ML Processor -> Result Modals
struct PhotoScannerModifier: ViewModifier {
    @Query var savedPersons: [Person]
    
    // Binding required so the parent view can trigger the Photo Library
    @Binding var isPresented: Bool
    
    // ML State
    @StateObject private var detector = FaceDetector()
    @StateObject private var processor: PhotoMLProcessor
    
    // UI State
    @State private var inputImage: UIImage? = nil
    @State private var personToView: Person? = nil
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        
        // Initialize state objects
        let tempDetector = FaceDetector()
        self._detector = StateObject(wrappedValue: tempDetector)
        self._processor = StateObject(wrappedValue: PhotoMLProcessor(detector: tempDetector))
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isiPad: Bool { horizontalSizeClass == .regular }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Initial sync
                detector.savedPersons = savedPersons
            }
            .onChange(of: savedPersons) { _, newPersons in
                // Keep the detector synced with the DB so identity matching works
                detector.savedPersons = newPersons
            }
            .onChange(of: inputImage) { _, newImage in
                guard let image = newImage else { return }
                // Begin processing the image silently in the background
                Task {
                    await processor.processSelectedImage(image)
                }
            }
            // 1. The Photo Library Picker
            .sheet(isPresented: $isPresented) {
                ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
            // 2. The Loading State
            .overlay {
                if processor.isProcessing {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text("Scanning Face...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(30)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
            // 3. Result: Match Found (Shows bottom card)
            .sheet(isPresented: Binding(
                get: { processor.finalMatchingResult != nil },
                set: { if !$0 { processor.finalMatchingResult = nil; inputImage = nil } }
            )) {
                if let (person, confidence) = processor.finalMatchingResult {
                    VStack(spacing: 24) {
                            if let uiImage = UIImage(data: person.photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                                    .shadow(radius: 10)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Person Identified")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppSecondaryText"))
                                
                                Text(person.name)
                                    .font(.system(.title, design: .rounded).weight(.bold))
                                    .foregroundStyle(Color("AppPrimaryText"))
                                
                                Text("\(Int(confidence * 100))% Match • \(person.relation)")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                            }
                            
                            Button {
                                let targetPerson = person
                                // Dismiss current sheet
                                processor.finalMatchingResult = nil
                                inputImage = nil
                                
                                // Give the sheet time to dismiss, then trigger navigation on the parent stack
                                Task {
                                    try? await Task.sleep(nanoseconds: 200_000_000)
                                    await MainActor.run {
                                        self.personToView = targetPerson
                                    }
                                }
                            } label: {
                                Text("View Profile")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color("AppPrimary"), in: Capsule())
                            }
                            .padding(.top, 10)
                            
                            Button("Dismiss") {
                                processor.finalMatchingResult = nil
                                inputImage = nil
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppSecondaryText"))
                        }
                        .padding(32)
                        .presentationDetents([.height(isiPad ? 450 : 380)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(36)
                }
            }
            // 4. Result: No Match / Pre-filled Registration
            .fullScreenCover(isPresented: Binding(
                get: { processor.processedImageForRegistration != nil },
                set: { if !$0 { processor.processedImageForRegistration = nil; inputImage = nil } }
            )) {
                if let image = processor.processedImageForRegistration,
                   let embeddings = processor.generatedEmbeddingsForRegistration {
                    
                    RegisterView(
                        preCapturedImage: image,
                        preCapturedEmbeddings: embeddings
                    )
                }
            }
            // 5. Parent Navigation (Triggered after sheet dismisses)
            .navigationDestination(item: $personToView) { person in
                FriendProfileView(person: person)
            }
    }
}

extension View {
    func photoScanner(isPresented: Binding<Bool>) -> some View {
        self.modifier(PhotoScannerModifier(isPresented: isPresented))
    }
}
