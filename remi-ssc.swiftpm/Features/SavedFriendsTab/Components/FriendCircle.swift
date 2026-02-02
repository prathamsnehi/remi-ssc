//
//  FriendCircle.swift
//  remi
//
//  Created by Pratham S on 12/25/25.
//

import SwiftUI
import UIKit

struct FriendCircle: View {
    let person: Person
    
    var body: some View {
        VStack(spacing: 12) {
            // 1. Profile Photo
            if let uiImage = UIImage(data: person.photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            // 2. Name
            Text(person.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FriendCircle(person: PreviewHelper.samplePerson)
        .padding()
        .background(Color("AppBackground"))
}

// Helper to keep the Preview clean and avoid compiler ambiguity
private struct PreviewHelper {
    static var samplePerson: Person {
        let image = UIImage(named: "sample_image_1") ?? UIImage(systemName: "person.fill")
        let data = image?.jpegData(compressionQuality: 0.8) ?? Data()
        
        let person = Person(
            name: "Ishowspeed",
            relation: "Streamer and sensational personality",
            photoData: data,
            embeddingSamples: []
        )
        
        let memory = Memory(content: "We went hiking last weekend and saw a deer.", type: .general)
        person.memories.append(memory)
        
        return person
    }
}
