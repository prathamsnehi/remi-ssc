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
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Interactions")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, sizeClass == .regular ? 0 : 20)
                .foregroundColor(Color("AppPrimaryText"))
            
            if people.isEmpty {
                emptyState
            } else {
                if sizeClass == .regular {
                    // iPad: Card Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(people.prefix(4)) { person in
                            NavigationLink(destination: FriendProfileView(person: person)) {
                                InteractionCard(person: person)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 0)
                } else {
                    // iPhone: Horizontal Scroll (Circles)
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
                                        
                                        // Name
                                        Text(person.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color("AppPrimaryText"))
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
    
    @ViewBuilder
    var emptyState: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
                .foregroundColor(Color("AppSecondaryText"))
            
            Text("No recent interactions found")
                .font(.subheadline)
                .foregroundColor(Color("AppSecondaryText"))
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }
}

// iPad Card Component
private struct InteractionCard: View {
    let person: Person
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Larger Profile Image
                if let uiImage = UIImage(data: person.photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black.opacity(0.05), lineWidth: 1))
                } else {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 60, height: 60)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(Color("AppPrimary"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AppPrimaryText"))
                    .lineLimit(1)
                
                Text(person.relation)
                    .font(.body)
                    .foregroundColor(Color("AppSecondaryText"))
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RecentInteractions()
        .modelContainer(for: Person.self, inMemory: true)
}
