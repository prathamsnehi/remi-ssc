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
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppSecondaryText"))
                
                Text(message)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color("AppPrimaryText"))
            }
            
            Spacer()
        }
    }
}

private struct ScanPromptView: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "face.dashed")
                .font(.title3)
                .foregroundStyle(.blue.opacity(0.8))
            
            Text("Point camera towards a face")
                .font(.callout.weight(.semibold))
                .foregroundStyle(Color("AppPrimaryText"))
            
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
                    .font(.body.weight(.bold))
                    .foregroundStyle(Color("AppPrimaryText"))
                
                Text("Register them to save memories")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppSecondaryText"))
            }
            
            Spacer()
            
            Button {
                detector.isScanModeOn = true
            } label: {
                Text("Register")
                    .font(.footnote.weight(.bold))
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
    let confidence: Float
    
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
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color("AppPrimaryText"))
                    
                    Text("\(Int(confidence * 100))% Match")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.green.opacity(0.1)))
                }
                
                Text(person.relation)
                    .font(.footnote)
                    .foregroundStyle(Color("AppSecondaryText"))
            }
            
            Spacer()
            
            NavigationLink(destination: FriendProfileView(person: person)) {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppPrimaryText").opacity(0.5))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white.opacity(0.1)))
            }
        }
    }
}
