//
//  RegisterView.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI
import SwiftData

struct RegisterView: View {
    // Access to the database
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Data State
    @State private var name: String = ""
    @State private var relation: String = ""
    @State private var firstMemory: String = ""
    @State private var inputImage: UIImage?
    @State private var personID: String? // Unused in local ML logic
    @State private var currentEmbedding: [Double]? // Store the calculated vector
    
    // Navigation State
    @State private var currentStep = 1
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Progress Bar (Optional, but nice for wizards)
                ProgressView(value: Double(currentStep), total: 4)
                    .padding(.horizontal)
                    .tint(.blue)
                
                // Step Views
                switch currentStep {
                case 1:
                    RegisterPhotoScreen(inputImage: $inputImage, onNext: {
                        withAnimation { currentStep = 2 }
                    })
                case 2:
                    RegisterNameScreen(
                        name: $name,
                        image: inputImage,
                        onNext: registerFace,
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
            // Error Alert for API Failure
            .alert("Registration Failed", isPresented: $showErrorAlert) {
                Button("Retake Photo") {
                    // Go back to step 1 to fix the photo
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
    
    // --- LOGIC ---
    
    func registerFace() {
        guard let image = inputImage else { return }
        isSubmitting = true
        
        Task {
            // Generate embedding using local ML
            if let embedding = await FaceRecognitionService.shared.generateEmbedding(from: image) {
                await MainActor.run {
                    self.currentEmbedding = embedding
                    self.isSubmitting = false
                    withAnimation { currentStep = 3 }
                }
            } else {
                await MainActor.run {
                    self.isSubmitting = false
                    self.errorMessage = "Could not detect a face. Please try a clearer photo."
                    self.showErrorAlert = true
                }
            }
        }
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
