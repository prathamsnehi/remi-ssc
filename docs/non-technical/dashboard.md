# 🚀 Remi Dashboard

### Last Updated: 2026-02-01 09:13:50

## 🚀 Time to Lift Off
> **4 days, 14 hours, 46 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 25 of 30
`[████████████████░░░░] 84.6%`

## 💾 Project Diet
**Total Size**: 20.35 MB / 25 MB
`[████████████████░░░░] 81.4%`

## 🧠 AI Captain's Orders
- [ ] Implement the provided `cropSquareAndResize` helper function from `docs/technical/sface-must-have-optimizations.md` to ensure correct `kCVPixelFormatType_32BGRA` pixel format, proper coordinate flipping (Vision to Core Graphics), and square cropping with padding for the model input.
- [ ] Adopt 5-Point Landmark Alignment: Integrate 5-point landmark detection (eyes, nose, mouth corners) with a `CGAffineTransform` (Similarity Transform) to warp the face into a canonical, upright frontal view *before* feeding it to MobileNetV3 for embedding. This is critical for high accuracy.
- [ ] Refactor with Actor-Isolated Face Recognition & CVPixelBuffer Deep Copy: Convert your `FaceRecognitionService` to an `actor` for thread safety and implement the `CVPixelBuffer.copy()` extension to create deep copies of camera frames, preventing memory access crashes as detailed in `ARKit-implementation-with-coreml.md`.
- [ ] Implement Embedding Post-Processing and Similarity Thresholding: Ensure all generated embeddings are L2-normalized before comparison, and use Cosine Similarity with a refined threshold of `0.30 - 0.40` for MobileNetV3 for "Same Person" detection, as specified in `MobileNetV3-specific-instructions.md`.
- [ ] Enhance AR UI Feedback for Face Recognition: Adapt the AR display to show a FaceID-style box covering the recognized face, and present the recognition card (with the person's name and relation) at the bottom of the screen, instead of floating next to the head.

## ✨ Daily Fuel
> "In the intricate dance of pixels and vectors, remember that your meticulous precision isn't just about code; it's about crafting unforgettable stories for a lifetime."
