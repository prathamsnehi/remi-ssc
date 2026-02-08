//
//  MemoriesList.swift
//  remi
//
//  Created by Pratham S on 12/28/25.
//

import SwiftUI

struct MemoriesList: View {
    let memories: [Memory]
    
    var sortedMemories: [Memory] {
        memories.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Memories")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // List
            if sortedMemories.isEmpty {
                ContentUnavailableView(
                    "No Memories Found",
                    systemImage: "note.text",
                    description: Text("Add a new memory to see it here.")
                )
                .padding(.top, 20)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedMemories.enumerated()), id: \.element.id) { index, memory in
                        HStack(alignment: .top, spacing: 12) {
                            // Date
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
                            .padding(.top, 2) // Align with dot
                            
                            // Timeline
                            ZStack(alignment: .top) {
                                // Line
                                if index < sortedMemories.count - 1 {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 2)
                                        .padding(.top, 12)
                                        .frame(maxHeight: .infinity)
                                }
                                
                                // Dot
                                Circle()
                                    .fill(Color("AppPrimary"))
                                    .frame(width: 10, height: 10)
                                    .padding(.top, 8)
                                    .background(
                                        Circle()
                                            .fill(Color("AppBackground"))
                                            .frame(width: 16, height: 16)
                                            .padding(.top, 8)
                                    )
                            }
                            .frame(width: 16)
                            
                            // Card
                            MemoryCard(memory: memory)
                                .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

#Preview {
    MemoriesList(memories: [])
        .background(Color("AppBackground"))
}
