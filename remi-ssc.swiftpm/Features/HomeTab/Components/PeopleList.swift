//
//  PeopleList.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI
import SwiftData

struct PeopleList: View {
    let searchText: String
    
    // We sort by lastInteracted to show "Frequently Met" people first
    @Query(sort: \Person.lastInteracted, order: .reverse) private var people: [Person]
    
    var body: some View {
        List {
            // Section Header logic
            if people.isEmpty {
                ContentUnavailableView("No friends added yet", systemImage: "person.2.slash")
            } else {
                Section(header: Text(searchText.isEmpty ? "Frequently Met" : "Search Results")) {
                    ForEach(filteredPeople) { person in
                        HStack(spacing: 15) {
                            // Profile Photo
                            if let uiImage = UIImage(data: person.photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 55, height: 55)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(person.name)
                                    .font(.headline)
                                Text(person.relation)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped) // Modern iOS look
        .scrollContentBackground(.hidden) // Removes default gray background
        .background(Color(.systemGroupedBackground))
    }
    
    // Logic to filter the query based on search text
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        } else {
            return people.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
