//
//  EditPersonView.swift
//  remi-ssc
//
//  Created by Pratham S on 2/27/26.
//

import SwiftUI
import SwiftData

struct EditPersonView: View {
    @Bindable var person: Person
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPhotoUpdater = false
    @State private var showDeleteAlert = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo
                    VStack {
                        if let image = UIImage(data: person.photoData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button("Use new photo") {
                            showPhotoUpdater = true
                        }
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    }
                    .padding(.top, 32)
                    
                    // Fields
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("NAME")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Name", text: $person.name)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("RELATION")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Relation (e.g. Best Friend)", text: $person.relation)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Delete Button
                    Button(action: { showDeleteAlert = true }) {
                        Text("Remove Person")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Edit Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showPhotoUpdater) {
                UpdatePhotoFlow(person: person)
            }
            .alert("Remove \(person.name)?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deletePerson()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete this person and all associated memories.")
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func deletePerson() {
        modelContext.delete(person)
        dismiss()
    }
}
