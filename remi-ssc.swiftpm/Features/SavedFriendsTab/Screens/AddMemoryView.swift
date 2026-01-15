//
//  AddMemoryView.swift
//  remi
//
//  Created by Pratham S on 12/30/25.
//

import SwiftUI
import SwiftData

struct AddMemoryView: View {
    let person: Person
    var onDone: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var currentStep = 1
    @State private var memoryText = ""
    @State private var inputImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                // Progress
                ProgressView(value: Double(currentStep), total: 2)
                    .padding(.horizontal)
                    .tint(Color("AppPrimary"))
                    .padding(.top, 10)
                
                switch currentStep {
                case 1:
                    AddMemoryTextScreen(text: $memoryText, onNext: {
                        withAnimation { currentStep = 2 }
                    })
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case 2:
                    AddMemoryPhotoScreen(inputImage: $inputImage, onFinish: saveMemory)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut, value: currentStep)
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func saveMemory() {
        var photoData: Data? = nil
        if let image = inputImage {
            // Save directly without resizing (Extensions removed)
            photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        let newMemory = Memory(
            content: memoryText,
            photoData: photoData,
            type: .general
        )
        
        person.memories.append(newMemory)
        dismiss()
        onDone?()
    }
}
