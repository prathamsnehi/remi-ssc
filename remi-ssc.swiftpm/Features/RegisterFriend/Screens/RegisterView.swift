//
//  RegisterView.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI
import SwiftData

struct RegisterView: View {
    // Access to the database of stored vectors and stuff
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.dismiss) private var dismiss
    
    // Inputs from the user about friend registration:
    @State private var name: String = ""
    @State private var relation: String = ""
    @State private var firstMemory: String = ""
    @State private var inputImage: UIImage?
    @State private var personID: String? // identifier of friend
    // Multi-Vector Registry State
    @State private var currentSamples: [[Double]] = []
    @State private var currentEmbedding: [Double]? // Still used for backward compat / profile?
    
    // Navigation State
    @State private var currentStep: Int
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    init(initialImage: UIImage? = nil) {
        if let image = initialImage {
            _inputImage = State(initialValue: image)
            _currentStep = State(initialValue: 2) // Skip to Name step
        } else {
            _currentStep = State(initialValue: 1)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // progress bar
                ProgressView(value: Double(currentStep), total: 4)
                    .padding(.horizontal)
                    .tint(.blue)
                
                // Step Views
                switch currentStep {
                case 1:
                    // Step 1: Scan Face (3s Loop)
                    FaceScanningView(onScanned: { image, samples in
                        self.inputImage = image
                        self.currentSamples = samples
                        // For legacy/display field, we can use the average or first sample
                        self.currentEmbedding = samples.first 
                        
                        withAnimation { currentStep = 2 }
                    }, onCancel: {
                        dismiss()
                    })
                case 2:
                    RegisterNameScreen(
                        name: $name,
                        image: inputImage,
                        onNext: registerFace, // This is now just a pass-through
                        isSubmitting: isSubmitting
                    )
                case 3:
                    RegisterRelationScreen(
                        relation: $relation,
                        image: inputImage,
                        onNext: {
                            withAnimation { currentStep = 4 }
                        }
                    )
                case 4:
                    RegisterMemoryScreen(
                        memory: $firstMemory,
                        image: inputImage,
                        onFinish: finishRegistration
                    )
                default:
                    EmptyView()
                }
            }
            .navigationTitle("New Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            // error message if something failed:
            .alert("Registration Failed", isPresented: $showErrorAlert) {
                Button("Retake Photo") {
                    // go back to step 1 to fix the photo
                    currentStep = 1
                    inputImage = nil
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
        
    func registerFace() {
        // Step 2 Action: Previously generated embedding.
        // Now: We already have samples from Step 1.
        // Just proceed.
        guard inputImage != nil else { return }
        
        if currentSamples.isEmpty && currentEmbedding == nil {
             // Should not happen if Step 1 worked, but guard against "Initial Image" flow logic
             // If initialImage provided (e.g. from Unknown Result), we might not have samples?
             // Ah, CameraScannerView passes initialImage. If so, we have NO SAMPLES.
             // We need to generate one if it's missing.
             
             if let img = inputImage {
                 Task {
                     if let embedding = await FaceRecognitionService.shared.generateEmbedding(from: img) {
                         await MainActor.run {
                             self.currentSamples = [embedding]
                             self.currentEmbedding = embedding
                             withAnimation { currentStep = 3 }
                         }
                     }
                 }
                 return
             }
        }
        
        withAnimation { currentStep = 3 }
    }
    
    func finishRegistration() {
        guard let image = inputImage else { return }
        
        // Resize and convert image to Data
        // Note: We use simpler compression here.
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to process image for saving")
            return
        }
        
        // Create the Person
        let newPerson = Person(
            name: name,
            relation: relation.isEmpty ? "Friend" : relation,
            photoData: data,
            faceEmbedding: currentEmbedding ?? []
        )
        
        // Save Samples
        for sampleVec in currentSamples {
            let sample = FaceSample(embedding: sampleVec, source: "registration")
            newPerson.samples.append(sample)
        }
        
        // Create the Memory (if they typed one)
        if !firstMemory.isEmpty {
            let memory = Memory(content: firstMemory, type: .general)
            newPerson.memories.append(memory)
        }
        
        // Save to Database
        modelContext.insert(newPerson)
        print("Saved \(name) to local database.")
        
        dismiss()
    }
}
