//
//  FriendMemoryView.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI

struct FriendMemoryView: View {
    let person: Person
    let image: UIImage? // The photo we just took (optional to show)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1. Header Image
                // We prioritize showing the photo they JUST took,
                // but fall back to their stored profile photo.
                if let recentPhoto = image {
                    Image(uiImage: recentPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .padding(.top, 40)
                } else if let profilePhoto = UIImage(data: person.photoData) {
                    Image(uiImage: profilePhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .padding(.top, 40)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 150))
                        .foregroundColor(Color("AppSecondaryText"))
                        .shadow(radius: 10)
                        .padding(.top, 40)
                }
                
                // 2. Info Card
                VStack(spacing: 8) {
                    Text("This is")
                        .font(.title3)
                        .foregroundColor(Color("AppSecondaryText"))
                    
                    Text(person.name)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    
                    Text(person.relation)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AppPrimaryText"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                
                Divider().padding(.horizontal)
                
                // 3. Memories
                VStack(alignment: .leading, spacing: 16) {
                    Text("Things you remember:")
                        .font(.headline)
                        .foregroundColor(Color("AppSecondaryText"))
                        .padding(.leading)
                    
                    if person.memories.isEmpty {
                        ContentUnavailableView("No memories yet", systemImage: "note.text", description: Text("Add memories in the Register view."))
                    } else {
                        ForEach(person.memories) { memory in
                            MemoryRow(memory: memory)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
    }
}

// Subview for Memory List Item
struct MemoryRow: View {
    let memory: Memory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(memory.content)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color("AppPrimaryText"))
                
                Text(memory.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(Color("AppSecondaryText"))
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
