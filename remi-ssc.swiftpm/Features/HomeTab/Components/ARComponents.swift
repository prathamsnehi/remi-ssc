import SwiftUI
import SwiftData

struct FaceOverlayView: View {
    let rect: CGRect
    let isUnknown: Bool
    
    var body: some View {
        Image(systemName: "viewfinder")
            .resizable()
            .scaledToFit()
            .foregroundStyle(isUnknown ? .white.opacity(0.8) : .green.opacity(0.8))
            .frame(width: rect.width * 1.5, height: rect.height * 1.5) // Slightly larger than the face box
            .position(x: rect.midX, y: rect.midY)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rect)
    }
}

struct PersonDetailPanel: View {
    let person: Person?
    let isUnknown: Bool
    let confidence: Double // New: Pass simple Double, we format it here
    var onAddFriend: () -> Void
    var onViewProfile: () -> Void // New: Action to view details
    
    var body: some View {
        VStack(spacing: 12) {
            if let person = person {
                // Known Person
                HStack(spacing: 16) {
                    if let uiImage = UIImage(data: person.photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 8) {
                            Text(person.relation)
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(.white)
                            
                            // Confidence Display
                            Text("\(Int(confidence * 100))% Match")
                                .font(.caption2)
                                .foregroundStyle(.green.opacity(0.9))
                        }
                    }
                    Spacer()
                    
                    // View Profile Button
                    Button(action: onViewProfile) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            } else if isUnknown {
                // Unknown Person
                HStack {
                    VStack(alignment: .leading) {
                        Text("Unknown Person")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Would you like to register them?")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                    
                    Button(action: onAddFriend) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                            Text("Add Friend")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                }
            } else {
                // No face detected - scanning state
                HStack {
                    Image(systemName: "waveform.and.magnifyingglass")
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Scanning for faces...")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .padding(.horizontal, 20)
        .padding(.bottom, 10) // Lift slightly from bottom edge
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
