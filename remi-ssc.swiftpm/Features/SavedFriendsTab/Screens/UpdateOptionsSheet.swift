//
//  UpdateOptionsSheet.swift
//  remi
//
//  Created by Pratham S on 12/30/25.
//

import SwiftUI

struct UpdateOptionsSheet: View {
    let person: Person
    @Environment(\.dismiss) var dismiss
    
    // Sheet States
    @State private var showAddMemory = false
    @State private var showEditPerson = false
    @State private var showEditMemories = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Update \(person.name)")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .padding(.top, 24)
            
            // 1. Add Memory (Primary Action)
            Button(action: { showAddMemory = true }) {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                    Text("Add New Memory")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color("AppPrimaryText"))
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color("AppPrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color("AppPrimary").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // 2. Secondary Actions Row
            HStack(spacing: 16) {
                // Edit Person Info
                Button(action: { showEditPerson = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.largeTitle)
                        Text("Edit Info")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color("AppPrimaryText"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                    )
                }
                
                // Edit Memories
                Button(action: { showEditMemories = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.largeTitle)
                        Text("Edit Memories")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color("AppPrimaryText"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color("AppBackground").opacity(0.2))
        // Sheets
        .fullScreenCover(isPresented: $showAddMemory) {
            AddMemoryView(person: person) {
                dismiss()
            }
        }
        .sheet(isPresented: $showEditPerson) { StubView(title: "Edit Person Info", iconName: "smile") }
        .sheet(isPresented: $showEditMemories) { StubView(title: "Edit Memories", iconName: "smile") }
    }
}



#Preview {
    UpdateOptionsSheet(person: Person(name: "Test", relation: "Friend", photoData: Data(), embeddingSamples: []))
}
