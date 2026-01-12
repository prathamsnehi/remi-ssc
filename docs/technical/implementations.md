## Apple APIs Used:

### Face Scanner & AR Interface:

- Frameworks Summary: `ARKit`, `RealityKit`, `SwiftUI`
- ARView to display a camera feed, then render a floating "glass card" next to their head with their name and relation
- Use RealityKit's `MeshResource.generateBox` or `MeshResource.generateText` to create the UI element for the card

```swift
// Snippet: Anchoring text to a face in AR
import RealityKit
import ARKit

struct ARFaceView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARFaceTrackingConfiguration() // Tracks the face geometry
        arView.session.run(config)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // In a real app, you'd use a delegate to detect the specific face anchor
        // and attach a RealityKit entity (the text) to that anchor.

        // Creating a 3D text label programmatically (Saves space!)
        let textMesh = MeshResource.generateText(
            "Hi, Grandpa!",
            extrusionDepth: 0.02,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byCharWrapping
        )
        let material = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])

        // You would attach 'textEntity' to the FaceAnchor here
    }
}
```

### Face Recognition Logic:

- Frameworks Summary: `Vision`, `CoreML`
- using Vision to detect faces, and crop to image to the face region + to the exact size the model expects (112x112 usually):

```swift
import Vision
import CoreML

// 1. Detect Face Logic
func detectAndCropFace(from image: UIImage) -> CVPixelBuffer? {
    let request = VNDetectFaceRectanglesRequest()
    let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])

    try? handler.perform([request])

    guard let observation = request.results?.first else { return nil }

    // Convert normalized rect (0.0-1.0) to image coordinates
    let boundingBox = observation.boundingBox
    let size = CGSize(width: 112, height: 112) // MobileFaceNet input size

    // You need a helper function here to crop the CGImage to 'boundingBox'
    // and resize it to 112x112.
    // Then convert that cropped image to a CVPixelBuffer.
    return croppedBuffer
}
```

- use a pre-trained MobileFaceNet.mlmodel (from github) to generate a vector representation of the face
- this mlmodel is \~4MB, therefore not affecting project diet size that much

```swift
// 2. Generate Embedding Logic
func getFaceEmbedding(from buffer: CVPixelBuffer, model: MobileFaceNet) -> [Double]? {
    // MobileFaceNet is the auto-generated class from your .mlmodel file
    guard let output = try? model.prediction(input: MobileFaceNetInput(data: buffer)) else {
        return nil
    }

    // The model usually outputs a MultiArray (e.g., 128 numbers)
    // Convert MLMultiArray to a Swift [Double] array
    return output.features.toArray()
}
```

- use cosine similarity (math, no need for apis) to compare the new vector (being scanned from ar) against stored vectors:

```swift
// 3. Comparison Logic
func isMatch(embedding1: [Double], embedding2: [Double]) -> Bool {
    // Calculate Dot Product & Magnitude (Cosine Similarity)
    let dotProduct = zip(embedding1, embedding2).map(*).reduce(0, +)
    let magnitude1 = sqrt(embedding1.map { $0 * $0 }.reduce(0, +))
    let magnitude2 = sqrt(embedding2.map { $0 * $0 }.reduce(0, +))

    let similarity = dotProduct / (magnitude1 * magnitude2)

    // Threshold: usually 0.6 to 0.8 for MobileFaceNet
    return similarity > 0.75
}
```

### Memory Bank:

- Frameworks Summary: `SwiftData`
- also should gracefully handle the case where the same people have been registered twice as people with different person_id's (due to inaccuracy in recognizing the same person)

```swift
import SwiftData

@Model
class Friend {
    var name: String
    var relation: String // e.g., "Grandson"
    var facePrintData: Data // The VNFeaturePrint serialized
    @Relationship(deleteRule: .cascade) var memories: [Memory]

    init(name: String, relation: String, facePrintData: Data) {
        self.name = name
        self.relation = relation
        self.facePrintData = facePrintData
        self.memories = []
    }
}

// The Logic for Merging Two Profiles
func mergeProfiles(keep: Friend, discard: Friend, context: ModelContext) {
    // 1. Move all memories from the 'discard' profile to 'keep'
    keep.memories.append(contentsOf: discard.memories)

    // 2. Empty the discard array so they don't get deleted by cascade
    discard.memories.removeAll()

    // 3. Delete the duplicate profile
    context.delete(discard)
}
```

### Conversation Starters of Friends Profiles:

- Frameworks Summary: `NaturalLanguage`, `FoundationModels`
- cleverly makes use of the NLTagger to find the subject of particular memories, and fit them into a pre-generated template (for pre-apple intelligence devices)

```swift
import NaturalLanguage

func generateStarter(from memories: [Memory]) -> String {
    let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])

    for memory in memories {
        tagger.string = memory.content

        // Find nouns or verbs in the memory
        tagger.enumerateTags(in: memory.content.startIndex..<memory.content.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            if tag == .noun {
                let topic = String(memory.content[range])
                // Simple template injection
                return "Ask him about the \(topic) you mentioned earlier."
            }
            return true
        }
    }
    return "Ask how his day is going." // Fallback
}
```

- OR, if the device being used supports apple intelligence, use the FoundationModel to generate conversation starters (this API is not available for pre-apple intelligence devices)

```swift
import FoundationModels

let model = SystemLanguageModel.default
let session = LanguageModelSession(model: model)

let response = try await session.respond {
    Prompt("Write a short story about Mars exploration.")
}
print(response.content)
```

- alternatively, explore the mobile model `TF-IDF / TextRank` to generate conversation starters (bundle size ~5MB)
  - this supports all devices as long as they're running the appropriate ios version when coreml was introduced
  - relies on the cpu / gpu of the device itself to generate the text content
