//
//  EditMemoriesView.swift
//  remi-ssc
//
//  Created by Pratham S on 2/27/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditableMemoryCard: View {
    @Bindable var memory: Memory
    var onDelete: () -> Void
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Photo Section
            ZStack(alignment: .topTrailing) {
                if let data = memory.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Remove photo button
                    Button(action: {
                        withAnimation {
                            memory.photoData = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white, .black.opacity(0.6))
                            .font(.title)
                    }
                    .padding(8)
                } else {
                    // Add photo button
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add Photo")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color("AppPrimaryText"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(style: StrokeStyle(dash: [6])).foregroundStyle(Color.secondary.opacity(0.3)))
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.8) {
                        await MainActor.run {
                            withAnimation {
                                memory.photoData = compressed
                            }
                        }
                    }
                }
            }
            
            // Content Editing
            TextField("Memory text...", text: $memory.content, axis: .vertical)
                .lineLimit(1...8)
                .font(.body)
                .foregroundStyle(Color("AppPrimaryText"))
                .padding(8)
                .background(Color.secondary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Footer & Delete
            HStack(spacing: 8) {
                Text(memory.type.rawValue.capitalized)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AppSecondaryText"))
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 2,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 16
            )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


struct EditMemoriesView: View {
    @Bindable var person: Person
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var sortedMemories: [Memory] {
        person.memories.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if sortedMemories.isEmpty {
                    ContentUnavailableView(
                        "No Memories",
                        systemImage: "note.text",
                        description: Text("Return to the profile to add memories.")
                    )
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(sortedMemories.enumerated()), id: \.element.id) { index, memory in
                            HStack(alignment: .top, spacing: 12) {
                                // Date Component
                                VStack(alignment: .trailing) {
                                    Text(memory.dateAdded.formatted(.dateTime.month(.abbreviated)))
                                        .font(.caption2)
                                        .textCase(.uppercase)
                                        .foregroundColor(Color("AppSecondaryText"))
                                    Text(memory.dateAdded.formatted(.dateTime.day()))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("AppPrimaryText"))
                                    
                                    if Calendar.current.component(.year, from: memory.dateAdded) != Calendar.current.component(.year, from: Date()) {
                                        Text(memory.dateAdded.formatted(.dateTime.year(.defaultDigits)))
                                            .font(.caption2)
                                            .foregroundColor(Color("AppSecondaryText"))
                                    }
                                }
                                .frame(width: 40, alignment: .trailing)
                                .padding(.top, 2)
                                
                                // Timeline Visuals
                                ZStack(alignment: .top) {
                                    if index < sortedMemories.count - 1 {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 2)
                                            .padding(.top, 12)
                                            .frame(maxHeight: .infinity)
                                    }
                                    
                                    Circle()
                                        .fill(Color("AppPrimary"))
                                        .frame(width: 10, height: 10)
                                        .padding(.top, 8)
                                        .background(
                                            Circle()
                                                .fill(Color(UIColor.systemBackground))
                                                .frame(width: 16, height: 16)
                                                .padding(.top, 8)
                                        )
                                }
                                .frame(width: 16)
                                
                                // Modifiable Card
                                EditableMemoryCard(memory: memory) {
                                    deleteMemory(memory)
                                }
                                .padding(.bottom, 24)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Edit Memories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func deleteMemory(_ memory: Memory) {
        withAnimation {
            if let index = person.memories.firstIndex(where: { $0.id == memory.id }) {
                person.memories.remove(at: index)
                // Delete explicitly from SwiftData Context just in case relationships don't cascade cleanly depending on the schema
                modelContext.delete(memory)
            }
        }
    }
}
