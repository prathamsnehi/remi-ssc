//
//  SuggestionCard.swift
//  remi
//
//  Created by Pratham S on 12/28/25.
//

import SwiftUI

struct SuggestionCard: View {
    let person: Person
    
    @State private var summary: String? = nil
    @State private var isLoading = true

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .symbolRenderingMode(.multicolor) // Makes the sparkles look nice if supported, or falls back
                    .foregroundStyle(.yellow)
                
                Text("REMI SUGGESTS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .tracking(1.2) // Adds spacing for a premium feel
            }
            
            // Body Text
            Group {
                if isLoading {
                    // Loading State (Shimmering Placeholders)
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                            .frame(maxWidth: .infinity)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                            .frame(width: 200)
                    }
                    .shimmer()

                } else if let summary = summary {
                    // Success State
                    Text(summary)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                // Base Surface
                Color("AppSurface")
                
                // Subtle Gradient Tint for "Magic" feel
                LinearGradient(
                    colors: [
                        Color("AppPrimary").opacity(0.15),
                        Color("AppPrimary").opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color("AppPrimary").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .onAppear(perform: generateSummary)
    }
    
    func generateSummary() {
        // Static placeholder as requested
        self.summary = "Remi's AI suggestions are currently disabled."
        self.isLoading = false
    }
}

#Preview {
    ZStack {
        Color("AppBackground")
            .ignoresSafeArea()
        SuggestionCard(person: Person(name: "Test", relation: "Friend", photoData: Data(), embeddingSamples: []))
            .padding()
    }
}
