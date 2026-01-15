//
//  ShimmerEffect.swift
//  remi
//
//  Created by Pratham S on 12/30/25.
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -200

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.6), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2) // Make gradient wider than view
                    .offset(x: phase)
                    .blendMode(.overlay)
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            phase = geometry.size.width + 200
                        }
                    }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}
