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
    
    // AR Pre-captured Data
    private let preCapturedImage: UIImage?
    private let preCapturedEmbeddings: [[Float]]?
    
    init(preCapturedImage: UIImage? = nil, preCapturedEmbeddings: [[Float]]? = nil) {
        self.preCapturedImage = preCapturedImage
        self.preCapturedEmbeddings = preCapturedEmbeddings
    }
    
    // Navigation State
    @State private var currentStep = 1
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    // Voice Mode State
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
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
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
            .sheet(isPresented: $showLibrary) {
                ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
            .onAppear {
                if let preImage = preCapturedImage {
                    self.inputImage = preImage
                    self.currentStep = 2 // Skip photo selection
                }
            }
        }
    }
    
    
    func registerFace() {
        // Validation could go here
        withAnimation {
            currentStep = 3
        }
    }
    
    func finishRegistration() {
        guard let image = inputImage else { return }
        
        // Resize and convert image to Data
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to process image for saving")
            return
        }
        
        // Create the Person
        let newPerson = Person(
            name: name,
            relation: relation.isEmpty ? "Friend" : relation,
            photoData: data,
            embeddingSamples: preCapturedEmbeddings ?? []
        )
        
        // Create the Memory (if they typed one)
        if !firstMemory.isEmpty {
            let memory = Memory(content: firstMemory, type: .general)
            newPerson.memories.append(memory)
        }
        
        // Save to Database
        modelContext.insert(newPerson)
        print("Saved \(name) to local database")
        
        dismiss()
    }
}
