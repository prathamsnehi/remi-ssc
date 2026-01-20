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
    @State private var currentEmbedding: [Double]?
    
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
        guard let image = inputImage else { return }
        isSubmitting = true
        
        Task {
            // generate embedding using local ML
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
