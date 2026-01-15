//
//  SavedFriendsView.swift
//  remi
//
//  Created by Pratham S on 12/24/25.
//

import SwiftUI
import SwiftData

struct SavedFriendsView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(filteredPeople) { person in
                        NavigationLink(destination: FriendProfileView(person: person)) {
                            FriendCircle(person: person)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
            }
            .navigationTitle("Friends")
            .background(Color("AppBackground"))
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search friends")
            .overlay {
                if filteredPeople.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Friends Yet" : "No Results",
                        systemImage: searchText.isEmpty ? "person.2.fill" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Add friends to see them here." : "Try a different name.")
                    )
                }
            }
        }
    }
    
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        } else {
            return people.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    SavedFriendsView()
        .modelContainer(PreviewSwiftData.container())

}
