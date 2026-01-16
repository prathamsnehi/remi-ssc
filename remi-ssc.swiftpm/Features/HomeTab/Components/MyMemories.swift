//
//  YourMemoriesView.swift
//  remi
//
//  Created by Pratham S on 1/15/26.
//

import SwiftUI

struct MyMemoriesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Your Memories")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            // Content (Horizontal Scroll)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Item 1: Upcoming Milestone
                    DashboardCard(
                        title: "Dad's Birthday",
                        subtitle: "In 3 days",
                        icon: "gift.fill",
                        color: .orange
                    )
                    
                    // Item 2: Random Memory
                    DashboardCard(
                        title: "Disneyland Trip",
                        subtitle: "Remembering this day",
                        icon: "photo.fill",
                        color: .blue
                    )
                    
                    // Item 3: Recurring Event
                    DashboardCard(
                        title: "Weekly Hiking",
                        subtitle: "Every Sunday",
                        icon: "figure.hiking",
                        color: .green
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// Internal Helper Component - Renamed to avoid conflict with SavedFriendsTab/Components/MemoryCard
private struct DashboardCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 160, height: 140, alignment: .topLeading)
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
    ZStack {
        Color("AppBackground").ignoresSafeArea()
        MyMemoriesView()
    }
}
