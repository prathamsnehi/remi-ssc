//
//  MemoryCard.swift
//  remi
//
//  Created by Pratham S on 12/28/25.
//

import SwiftUI

struct MemoryCard: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. Photo (if exists)
            if let data = memory.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 2. Content
            if !memory.content.isEmpty {
                Text(memory.content)
                    .font(.subheadline)
                    .foregroundColor(Color("AppPrimaryText"))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 3. Metadata Footer
            HStack(spacing: 8) {
                // Type
                Text(memory.type.rawValue.capitalized)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AppSecondaryText"))
                
                // Importance
                if memory.importance == .high {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(Color("AppPrimaryText"))
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
        .contextMenu {
            // Save Photo Option (Only if photo exists)
            if let data = memory.photoData, let uiImage = UIImage(data: data) {
                Button {
                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                } label: {
                    Label("Save Photo", systemImage: "square.and.arrow.down")
                }
            }
            
            // Copy Text Option
            Button {
                UIPasteboard.general.string = memory.content
            } label: {
                Label("Copy Text", systemImage: "doc.on.doc")
            }
        }
    }
}

#Preview {
    let memory = Memory(
        content: "We went to the beach and had a great time watching the sunset.",
        type: .general,
        importance: .high
    )
    return MemoryCard(memory: memory)
        .padding()
        .background(Color("AppBackground"))
}
