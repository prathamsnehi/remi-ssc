//
//  ARPersonCard.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import SwiftUI

struct ARPersonCard: View {
    var body: some View {
        VStack (spacing: 4) {
            Text("Person Detected")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("I don't know about their name tho")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(Color.blue.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
        .offset(x: 50) // so that the card doesn't cover the person's face
    }
}

