//
//  PhotoLibraryButton.swift
//  remi-ssc
//
//  Created by Pratham S on 1/31/26.
//

import SwiftUI

struct HeaderCapsule: View {
    // contains switcher to photos, as well as an indicator of the current mode (AR Scan)
    
    var body: some View {
        HStack(spacing: 0) {
            Text("AR Scan")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
            
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(width: 1, height: 16)
            
            HStack(spacing: 8) {
                Text("or scan with")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)
                
                Button(action: {
                    // Placeholder action
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("Photos")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
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
        .padding(.vertical, 6)
        .glassEffect()
        .foregroundStyle(.white)
    }
}
