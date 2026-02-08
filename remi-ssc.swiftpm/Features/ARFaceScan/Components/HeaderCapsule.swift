//
//  PhotoLibraryButton.swift
//  remi-ssc
//
//  Created by Pratham S on 1/31/26.
//

import SwiftUI

struct HeaderCapsule: View {
    let title: String
    let isScanning: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(Color("AppPrimaryText"))
                .padding(.horizontal, 16)
            
            if !isScanning {
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 1, height: 16)
                
                HStack(spacing: 8) {
                    Text("or scan with")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color("AppSecondaryText"))
                        .padding(.leading, 12)
                    
                    Button(action: {
                        // Placeholder action
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.caption)
                            
                            Text("Photos")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 6)
            }
        }
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .glassEffect()
        .foregroundStyle(Color("AppPrimaryText"))
    }
}

#Preview {
    ZStack {
        // Gradient background to make glass effect visible
        LinearGradient(
            colors: [.blue, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            HeaderCapsule(title: "AR Scan", isScanning: false)
            Spacer()
        }
        .padding()
    }
}
