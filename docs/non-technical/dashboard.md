# 🚀 Remi Dashboard

### Last Updated: 2026-01-22 04:49:16

## 🚀 Time to Lift Off
> **14 days, 19 hours, 10 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 15 of 30
`[██████████░░░░░░░░░░] 50.7%`

## 💾 Project Diet
**Total Size**: 12.13 MB / 25 MB
`[█████████░░░░░░░░░░░] 48.5%`

## 🧠 AI Captain's Orders
- [ ] Implement the updated AR UI for face detection: cover the detected face with a Face ID-style bounding box and display the recognition card at the bottom of the screen, as outlined in recent daily accomplishments.
- [ ] Refine the `ARView` to correctly attach RealityKit entities (the Face ID-style box and recognition card) to the detected `ARFaceAnchor`, ensuring they track the face's position and orientation accurately.
- [ ] Develop a robust helper function to crop a `CGImage` based on a `VNFaceObservation` bounding box and resize it to the `MobileFaceNet` model's expected 112x112 `CVPixelBuffer` format.
- [ ] Fully integrate the `ARSessionDelegate`'s camera feed output with the `FaceRecognitionService` (which uses Vision for face detection and CoreML for embeddings), leveraging the established actor-isolated concurrency pattern to update the AR scene with real-time recognition results.
- [ ] Implement the `NLTagger`-based conversation starter generation for pre-Apple Intelligence devices, and set up the logic to dynamically switch to `FoundationModels` or `TF-IDF/TextRank` for more advanced devices, ensuring graceful fallback for offline and older devices.

## ✨ Daily Fuel
> "We do not remember days, we remember moments."
