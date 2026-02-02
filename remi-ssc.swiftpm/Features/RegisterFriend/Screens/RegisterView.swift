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
    @State private var personID: String? // Stored after API success
    
    // Navigation State
    @State private var currentStep = 1
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    // Voice Mode State
    @State private var showCamera = false
    @State private var showLibrary = false
    
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
            // Voice Mode Camera Handling
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(selectedImage: $inputImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showLibrary) {
                ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
        }
    }
    
    
    func registerFace() {
        guard let image = inputImage else { return }
        isSubmitting = true
        
    }
    
    func finishRegistration() {
        guard let id = personID, let image = inputImage else { return }
        
        // Resize and convert image to Data
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to process image for saving")
            return
        }
        
        // Detect Face Center (Pre-calculate to avoid runtime stutter)
        let faceCenter = image.detectFaceCenter()
        
        // Create the Person
        let newPerson = Person(
            name: name,
            relation: relation.isEmpty ? "Friend" : relation,
            photoData: data,
            embeddingSamples: []
        )
        
        // Create the Memory (if they typed one)
        if !firstMemory.isEmpty {
            let memory = Memory(content: firstMemory, type: .general)
            newPerson.memories.append(memory)
        }
        
        // Save to Database
        modelContext.insert(newPerson)
        print("Saved \(name) to local database with ID: \(id)")
        
        dismiss()
    }
}
