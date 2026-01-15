//
//  RecentInteractions.swift
//  remi
//
//  Created by Pratham S on 12/24/25.
//

import SwiftUI
import SwiftData

struct RecentInteractions: View {
    @Query(sort: \Person.lastInteracted, order: .reverse) private var people: [Person]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Interactions")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
                .foregroundColor(.primary)
            
            if people.isEmpty {
                // Empty State - Left Aligned & Minimal
                HStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No recent interactions found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(people.prefix(5)) { person in
                            NavigationLink(destination: FriendProfileView(person: person)) {
                                VStack(spacing: 8) {
                                    // Profile "Image"
                                    if let uiImage = UIImage(data: person.photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 90, height: 90)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
                                    } else {
                                        Circle()
                                            .fill(Color(.systemGray6))
                                            .frame(width: 90, height: 90)
                                    }
                                    // Removed shadow for a flatter, cleaner look
                                    
                                    // Name
                                    Text(person.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 90)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    RecentInteractions()
        .modelContainer(for: Person.self, inMemory: true)
}
