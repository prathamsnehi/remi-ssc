import SwiftUI

struct IdentifyModeFooter: View {
    @ObservedObject var detector: FaceDetector
    
    var body: some View {
        Group {
            if let error = detector.uiError {
                ScanErrorView(message: error.uiMessage)
            } else if !detector.isPersonOnCamera {
                ScanPromptView()
            } else if let person = detector.identifiedPerson {
                IdentifiedPersonView(person: person, confidence: detector.confidence)
            } else {
                UnregisteredPersonView(detector: detector)
            }
        }
    }
}

private struct ScanErrorView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Scanning Problem")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(message)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            Spacer()
        }
    }
}

private struct ScanPromptView: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "face.dashed")
                .font(.system(size: 24))
                .foregroundStyle(.blue.opacity(0.8))
            
            Text("Point camera towards a face")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

private struct UnregisteredPersonView: View {
    @ObservedObject var detector: FaceDetector
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Person Not Recognized")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Register them to save memories")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button {
                detector.isScanModeOn = true
            } label: {
                Text("Register")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white))
            }
        }
    }
}

private struct IdentifiedPersonView: View {
    let person: Person
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 16) {
            if let uiImage = UIImage(data: person.photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(person.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("\(Int(confidence * 100))% Match")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.green.opacity(0.1)))
                }
                
                Text(person.relation)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            NavigationLink(destination: FriendProfileView(person: person)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white.opacity(0.1)))
            }
        }
    }
}
