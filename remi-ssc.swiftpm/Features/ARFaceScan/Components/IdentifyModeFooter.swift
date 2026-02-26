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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isiPad: Bool { horizontalSizeClass == .regular }
    
    var body: some View {
        HStack(spacing: isiPad ? 32 : 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: isiPad ? 50 : 32))
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: isiPad ? 4 : 2) {
                Text("Scanning Problem")
                    .font(.system(size: isiPad ? 22 : 14, weight: .bold))
                    .foregroundStyle(Color("AppPrimaryText"))
                
                Text(message)
                    .font(.system(size: isiPad ? 30 : 20, weight: .semibold))
                    .foregroundStyle(Color("AppPrimaryText"))
            }
        }
    }
}

private struct ScanPromptView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isiPad: Bool { horizontalSizeClass == .regular }
    
    var body: some View {
        HStack(spacing: isiPad ? 32 : 20) {
            Image(systemName: "face.dashed")
                .font(.system(size: isiPad ? 44 : 36))
                .foregroundStyle(.blue.opacity(0.8))
            
            Text("Point Camera\nTowards a Face")
                .font(.system(size: isiPad ? 32 : 20, weight: .bold))
                .foregroundStyle(Color("AppPrimaryText"))
        }
    }
}

private struct UnregisteredPersonView: View {
    @ObservedObject var detector: FaceDetector
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isiPad: Bool { horizontalSizeClass == .regular }
    
    var body: some View {
        HStack(spacing: isiPad ? 32 : 20) {
            VStack(alignment: .leading, spacing: isiPad ? 10 : 6) {
                Text("Not Recognized")
                    .font(.system(size: isiPad ? 32 : 20, weight: .bold))
                    .foregroundStyle(Color("AppPrimaryText"))
                
                Text("Register them to save memories")
                    .font(.system(size: isiPad ? 24 : 16))
                    .foregroundStyle(Color("AppPrimaryText"))
            }
            
            Button {
                detector.isScanModeOn = true
            } label: {
                Text("Register")
                    .font(.system(size: isiPad ? 22 : 15, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, isiPad ? 30 : 20)
                    .padding(.vertical, isiPad ? 14 : 10)
                    .background(Capsule().fill(Color.white))
            }
        }
    }
}

private struct IdentifiedPersonView: View {
    let person: Person
    let confidence: Float
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isiPad: Bool { horizontalSizeClass == .regular }
    
    var body: some View {
        HStack(spacing: isiPad ? 28 : 18) {
            if let uiImage = UIImage(data: person.photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isiPad ? 90 : 60, height: isiPad ? 90 : 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: isiPad ? 4 : 2) {
                HStack(alignment: .firstTextBaseline, spacing: isiPad ? 14 : 8) {
                    Text(person.name)
                        .font(.system(size: isiPad ? 34 : 22, weight: .bold))
                        .foregroundStyle(Color("AppPrimaryText"))
                    
                    Text("\(Int(confidence * 100))% Match")
                        .font(.system(size: isiPad ? 18 : 12, weight: .bold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, isiPad ? 12 : 8)
                        .padding(.vertical, isiPad ? 6 : 4)
                        .background(Capsule().fill(.green.opacity(0.1)))
                }
                
                Text(person.relation)
                    .font(.system(size: isiPad ? 24 : 15))
                    .foregroundStyle(Color("AppSecondaryText"))
            }
            
            NavigationLink(destination: FriendProfileView(person: person)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: isiPad ? 22 : 15, weight: .bold))
                    .foregroundStyle(Color("AppPrimaryText").opacity(0.5))
                    .frame(width: isiPad ? 52 : 36, height: isiPad ? 52 : 36)
                    .background(Circle().fill(.white.opacity(0.1)))
            }
        }
    }
}
