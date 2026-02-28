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
    var onPhotosTap: (() -> Void)? = nil
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isiPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(size: isiPad ? 18 : 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppPrimaryText"))
                .padding(.horizontal, isiPad ? 24 : 16)
            
            if !isScanning {
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: isiPad ? 1.5 : 1, height: isiPad ? 24 : 16)
                
                HStack(spacing: isiPad ? 12 : 8) {
                    Text("or scan with")
                        .font(.system(size: isiPad ? 16 : 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("AppPrimaryText"))
                        .padding(.leading, isiPad ? 18 : 12)
                    
                    Button(action: {
                        onPhotosTap?()
                    }) {
                        HStack(spacing: isiPad ? 9 : 6) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: isiPad ? 18 : 12))
                            
                            Text("Photos")
                                .font(.system(size: isiPad ? 18 : 12, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, isiPad ? 21 : 14)
                        .padding(.vertical, isiPad ? 12 : 8)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open Photo Library")
                }
                .padding(.trailing, isiPad ? 9 : 6)
            }
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
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
