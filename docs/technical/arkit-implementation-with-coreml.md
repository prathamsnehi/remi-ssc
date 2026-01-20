# AR Face Recognition & Concurrency Fixes

We have successfully implemented the AR Face Recognition feature, resolving critical concurrency warnings, runtime crashes, and resource loading issues.

## Key Accomplishments

### 1. Actor-Isolated Face Recognition

To adhere to Swift 6 Strict Concurrency, we refactored `FaceRecognitionService` into an `actor`.

- **Thread Safety**: All state (the ML model) is isolated.
- **Safe Data Transfer**: We stopped passing non-Sendable `Person` objects across actor boundaries. Instead, we pass `Sendable` types: `([(PersistentIdentifier, [Double])])`.
- **Main Actor Fetching**: SwiftData operations are explicitly performed on the `MainActor` in `ARViewContainer` before handing off data to the service.

### 2. Runtime Crash Resolution

We identified and fixed a crash caused by memory access conflicts in `ARSessionDelegate`.

- **Deep Copy**: Implemented `CVPixelBuffer.copy()` to create a deep copy of the camera frame.
- **Why**: ARKit recycles buffers. If our background task processed the buffer after ARKit reclaimed it, the app would crash. The deep copy ensures our background actor owns its data.

### 3. MobileFaceNet Integration

We solved the "Model Not Found" error specific to Swift Playgrounds.

- **Resource Loading**: Updated MobileFaceNet.swift to robustly search for the `.mlmodelc` folder (both as a directory and a bundle resource).
- **Package.swift Config**: Explicitly added `.copy("Resources/MobileFaceNet.mlmodelc")` to Package.swift to ensure the model assets are actually bundled in the built app.

## Code Highlights

### Deep Copying Pixel Buffer

```javascript
extension CVPixelBuffer {
    func copy() -> CVPixelBuffer? {
        // Creates a new CVPixelBuffer and uses memcpy/CoreImage to copy pixel data
        // ...
    }
}
```

### Safe Concurrency Pattern

```javascript
// 1. Generate Embedding (Background Actor)
if let embedding = await FaceRecognitionService.shared.generateEmbedding(from: buffer) {

    await MainActor.run {
        // 2. Fetch Candidates (Main Actor - Thread Safe)
        let allPersons = try? modelContext.fetch(FetchDescriptor<Person>())
        let candidates = allPersons.map { ($0.persistentModelID, $0.faceEmbedding) }

        Task {
            // 3. Find Match (Background Actor - Fast & Safe)
            let match = await FaceRecognitionService.shared.findBestMatch(for: embedding, candidates: candidates)

            // 4. Update UI (Main Actor)
            await MainActor.run { ... }
        }
    }
}
```
