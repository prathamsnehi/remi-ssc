# 🚀 Remi Dashboard

### Last Updated: 2026-01-16 05:45:52

## 🚀 Time to Lift Off
> **20 days, 18 hours, 14 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 9 of 30
`[██████░░░░░░░░░░░░░░] 30.8%`

## 💾 Project Diet
**Total Size**: 0.03 MB / 25 MB
`[░░░░░░░░░░░░░░░░░░░░] 0.1%`

## 🧠 AI Captain's Orders
- [ ] Refactor the homepage layout to be iPad-first, specifically implementing the `NavigationSplitView` for horizontal iPadOS mode and adapting the hero section and button placements as detailed in `homepage.md`. Ensure the top tab bar offset is correctly handled for both orientations.
- [ ] Build the foundational AR Face Scanning View by integrating `ARKit` and `RealityKit`. Focus on setting up `ARFaceView` to detect faces and render a dynamic 'glass card' next to them using `MeshResource.generateText`, laying the groundwork for displaying recognition results.
- [ ] Implement the `Vision` framework for robust face detection and cropping. Prioritize creating the helper function mentioned in `implementations.md` to precisely crop the detected face to a `CVPixelBuffer` of 112x112, preparing the input for your `MobileFaceNet` model.
- [ ] Integrate `SwiftData` to establish the `Friend` and `Memory` models, and crucially, implement the `mergeProfiles` function. This will allow Remi to intelligently consolidate duplicate person entries and their associated memories, demonstrating sophisticated data management.
- [ ] Develop the `NaturalLanguage` based conversation starter logic. Implement the `generateStarter` function to extract key topics from `Memory` content and embed them into templates, providing personalized prompts even on devices without Apple Intelligence.

## ✨ Daily Fuel
> "The journey of building 'Remi' is not just about writing code; it's about crafting a bridge to cherished memories. Every line you write strengthens that connection, making the 'unforgettable' truly permanent."
