//
//  FriendProfileView.swift
//  remi
//
//  Created by Pratham S on 12/28/25.
//

import SwiftUI

struct FriendProfileView: View {
    let person: Person
    @State private var showUpdateSheet = false
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. Hero Section
                ProfileHero(
                    image: UIImage(data: person.photoData),
                    name: person.name,
                    relation: person.relation
                )
                
                // 2. AI Suggestion Section
                VStack(alignment: .leading) {
                    SuggestionCard(person: person)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // 4. Memories Section
                MemoriesList(memories: person.memories)
                    .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color("AppBackground"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Update") {
                    showUpdateSheet = true
                    print(person.faceEmbedding)
                }
                .fontWeight(.semibold)
            }
        }
        // .sheet(isPresented: $showUpdateSheet) {
        //     UpdateOptionsSheet(person: person)
        //         .presentationDetents([.height(320)])
        //         .presentationDragIndicator(.visible)
        // }
        .sheet(isPresented: $showUpdateSheet) {
                UpdateOptionsSheet(person: person)
                    .presentationDetents([.medium])
            }
    }
}

#Preview {
    FriendProfileView(person: PreviewHelper.samplePerson)
}

// Helper for Preview Data
private struct PreviewHelper {
    static var samplePerson: Person {
        let image = UIImage(named: "sample_image_2") ?? UIImage(systemName: "person.fill")
        let data = image?.jpegData(compressionQuality: 0.8) ?? Data()
        
        return Person(
            name: "LeVar Burton",
            relation: "Mentor",
            photoData: data
        )
    }
}
