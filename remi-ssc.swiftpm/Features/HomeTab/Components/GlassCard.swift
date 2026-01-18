//
//  GlassCardFactory.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import RealityKit
import UIKit

@MainActor // 1. Fixes "Call to main actor-isolated..." warnings
struct GlassCard { // 2. Renamed from GlassCardFactory
    
    static func createCard(text: String) -> ModelEntity {
        // 1. Create the Glass Background (Plane)
        let cardMesh = MeshResource.generatePlane(width: 0.2, height: 0.1, cornerRadius: 0.02)
        
        // "Glass" Material
        var glassMaterial = SimpleMaterial(color: .white.withAlphaComponent(0.4), isMetallic: false)
        glassMaterial.roughness = 0.2
        
        // 3. Fix: 'tintColor' is deprecated. Use 'color' with a tint initializer.
        glassMaterial.color = .init(tint: .blue.withAlphaComponent(0.2))
        
        let cardEntity = ModelEntity(mesh: cardMesh, materials: [glassMaterial])
        
        // 2. Create the 3D Text
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.005,
            font: .systemFont(ofSize: 0.02, weight: .bold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byCharWrapping
        )
        
        let textMaterial = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        // Center the text on the card
        textEntity.position = SIMD3<Float>(-0.08, -0.01, 0.01) // Adjust manually based on size
        
        cardEntity.addChild(textEntity)
        
        // Position card above head
        cardEntity.position = SIMD3<Float>(0, 0.25, 0)
        
        return cardEntity
    }
}
