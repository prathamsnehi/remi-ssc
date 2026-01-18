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
                .foregroundColor(.primary)
            
            if people.isEmpty {
                emptyState
            } else {
                if sizeClass == .regular {
                    // iPad: Adaptive Grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 20) {
                        contentList
                    }
                } else {
                    // iPhone: Horizontal Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            contentList
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
                .foregroundColor(.secondary)
            
            Text("No recent interactions found")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    var contentList: some View {
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
}

#Preview {
    RecentInteractions()
        .modelContainer(for: Person.self, inMemory: true)
}
