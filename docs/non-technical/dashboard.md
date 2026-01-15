# 🚀 Remi Dashboard

### Last Updated: 2026-01-15 00:40:12

## 🚀 Time to Lift Off
> **21 days, 23 hours, 19 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 8 of 30
`[█████░░░░░░░░░░░░░░░] 26.8%`

## 💾 Project Diet
**Total Size**: 0.01 MB / 25 MB
`[░░░░░░░░░░░░░░░░░░░░] 0.0%`

## 🧠 AI Captain's Orders
- [ ] Refine your `ARFaceView` to detect specific `ARFaceAnchor` instances and dynamically attach the `textEntity` (showing name/relation) to the detected face's coordinate system, ensuring it moves naturally with the person's head.
- [ ] Complete the `detectAndCropFace` function by implementing the actual `CGImage` cropping based on the `VNFaceObservation` bounding box and then resizing the result to 112x112, finally converting it into a `CVPixelBuffer` suitable for your `MobileFaceNet` model.
- [ ] Integrate the full face recognition pipeline: when a face is detected in AR, pass the camera frame to `Vision` for face detection, crop the face, generate an embedding using `MobileFaceNet`, and then use cosine similarity to query against existing `Friend` embeddings stored in `SwiftData`.
- [ ] Implement the `SwiftData` CRUD operations for `Friend` and `Memory` objects, focusing on the registration flow where a new face (embedding) is saved as a `Friend` and ensuring the `mergeProfiles` function is available when duplicate profiles are identified or explicitly merged by the user.
- [ ] Enhance your `NaturalLanguage` conversation starter logic (e.g., `generateStarter` function) by iterating through more memory content to extract diverse keywords (nouns, verbs, named entities) and integrate these starters prominently into the `Friends Profile Screen` UI.

## ✨ Daily Fuel
> "The journey of building Remi is not just about code; it's about crafting empathy, one memory at a time. Keep pushing the boundaries of what's possible with Swift and Apple's powerful frameworks."
