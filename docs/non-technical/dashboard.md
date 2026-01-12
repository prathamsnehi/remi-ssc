# 🚀 Remi Dashboard

### Last Updated: 2026-01-12 22:51:40

## 🚀 Time to Lift Off
> **24 days, 1 hours, 8 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 5 of 30
`[███░░░░░░░░░░░░░░░░░] 19.8%`

## 💾 Project Diet
**Total Size**: 0.01 MB / 25 MB
`[░░░░░░░░░░░░░░░░░░░░] 0.0%`

## 🧠 AI Captain's Orders
- [ ] Integrate ARKit's `ARSessionDelegate` to detect `ARFaceAnchor` updates. When a face is detected, dynamically attach a `ModelEntity` (like the generated text card) to the face anchor's transform in RealityKit, providing real-time visual feedback.
- [ ] Complete the face recognition pipeline by creating helper functions to crop `CGImage` to the detected face's bounding box and convert it to a `CVPixelBuffer` for CoreML. Then, implement the `MLMultiArray` to `[Double]` conversion to get the face embedding for cosine similarity comparison.
- [ ] Set up your SwiftData `ModelContainer` and implement basic CRUD (Create, Read, Update, Delete) operations for `Friend` and `Memory` objects. Focus on saving new `Friend` profiles (including their face embedding) and associating new `Memory` entries, ensuring `mergeProfiles` can be used later.
- [ ] Develop the initial SwiftUI `HomeView` with the "Scan Face" button. Implement the navigation flow to transition to your `ARFaceView` and design how identified person data (name, relation) will be passed back or displayed within the AR experience.
- [ ] As you build the `HomeView` and `ARFaceView`, proactively incorporate accessibility features like `.accessibilityLabel` and `.accessibilityHint` for interactive elements. Also, ensure your basic layouts are responsive and consider how they will adapt for an iPad-first experience using views like `NavigationStack` or `NavigationSplitView`.

## ✨ Daily Fuel
> "Great things are not done by impulse, but by a series of small things brought together."
