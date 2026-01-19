//
//  ARPersonCard.swift
//  Remi
//
//  Created by Pratham S on 1/18/26.
//

import SwiftUI

struct ARPersonCard: View {
    @ObservedObject var detector: FaceDetector
    var onAddFriend: () -> Void
    var onViewProfile: (Person?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            if let person = detector.identifiedPerson {
                // Match State
                HStack(spacing: 12) {
                    if let uiImage = UIImage(data: person.photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(person.relation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Confidence: \(Int(detector.confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Button(action: { onViewProfile(person) }) {
                    Text("View Profile")
                        .font(.caption)
                        .bold()
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                }
                
                
            } else if detector.isUnknown {
                // Unknown State
                HStack {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading) {
                        Text("Unknown Person")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Not in your memories")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Button(action: onAddFriend) {
                    Text("Add Friend")
                        .font(.caption)
                        .bold()
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                
            } else {
                // Scanning State (Face Detected but not yet processed/identified)
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Identifying...")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 8)
        .frame(width: 200)
        .offset(x: 100, y: -50) // Adjust offset to roughly nice position relative to face center
    }
}

