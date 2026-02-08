//
//  YourMemoriesView.swift
//  remi
//
//  Created by Pratham S on 1/15/26.
//

import SwiftUI

struct MyMemoriesView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Your Memories")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("View More")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color("AppPrimary"))
            }
            .padding(.horizontal, sizeClass == .regular ? 0 : 20)
            
            // Unified Grid Layout (2x2)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                memoryContent
            }
            .padding(.horizontal, sizeClass == .regular ? 0 : 20)
        }
    }
    
    @ViewBuilder
    var memoryContent: some View {
        Group {
            DashboardCard(title: "Dad's Birthday", subtitle: "In 3 days", icon: "gift.fill", color: .orange, personImageName: "sample_image_1")
            DashboardCard(title: "Disneyland Trip", subtitle: "Remembering this day", icon: "photo.fill", color: .blue, personImageName: "sample_image_2")
            
            if sizeClass == .regular {
                DashboardCard(title: "Weekly Hiking", subtitle: "Every Sunday", icon: "figure.hiking", color: .green, personImageName: "sample_image_1")
                DashboardCard(title: "Dad's Birthday", subtitle: "In 3 days", icon: "gift.fill", color: .orange, personImageName: "sample_image_2")
            }
        }
    }
    
    
    // Internal Helper Component - Renamed to avoid conflict with SavedFriendsTab/Components/MemoryCard
    private struct DashboardCard: View {
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let personImageName: String?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: -15) {
                // 1. Person Photo Circle (Left, On Top)
                if let imageName = personImageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black.opacity(0.05), lineWidth: 1))
                        // The "Cutout" Effect Biter:
                        .background(
                            Circle()
                                .fill(Color("AppSurface"))
                                .padding(-4)
                        )
                        .zIndex(1) // On Top
                } else {
                    // Fallback
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(Color("AppSecondaryText"))
                        )
                        .background(
                            Circle()
                                .fill(Color("AppSurface"))
                                .padding(-3)
                        )
                        .zIndex(1) // On Top
                }
                
                // 2. Icon Circle (Right, Underneath)
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                    )
            }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color("AppPrimaryText"))
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Color("AppSecondaryText"))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
}
