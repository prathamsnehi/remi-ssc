# 🚀 Remi Dashboard

### Last Updated: 2026-02-11 15:37:53

## 🚀 Time to Lift Off
> **Submission Closed! 🏁** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 35 of 30
`[████████████████████] 100.0%`

## 💾 Project Diet
**Total Size**: 21.85 MB / 25 MB
`[█████████████████░░░] 87.4%`

## 🧠 AI Captain's Orders
- [ ] Integrate 5-Point Landmark Alignment for Face Input: While the `cropSquareAndResize` helper from `sface-must-have-optimizations.md` correctly handles BGRA pixel format, coordinate flipping, and initial squaring/padding, it *does not* include 5-point landmark alignment. This is **critical** for MobileNetV3 (as per `mobilenetv3-specific-instructions.md` and `face-recognition-accuracy-implementations.md`). Enhance your face input pipeline to use the 5 detected landmarks (eyes, nose, mouth corners) to perform a `CGAffineTransform` (similarity transform) to warp the face into a canonical, upright frontal view *before* resizing to 112x112.
- [ ] Fortify AR Face Recognition with Strict Concurrency & Deep Copies: As you build out the AR face scanning feature, ensure `FaceRecognitionService` is refactored into an `actor` to isolate state and prevent runtime crashes. Implement `CVPixelBuffer.copy()` (as shown in `arkit-implementation-with-coreml.md`) to create deep copies of ARKit's camera frames before processing in the background, as ARKit recycles buffers, which can lead to memory access conflicts. Explicitly perform SwiftData operations (`FetchDescriptor<Person>()`) on the `MainActor` before passing Sendable candidate data to the background actor.
- [ ] Apply MobileNetV3-Specific Embedding Post-Processing and Thresholds: After generating the face embeddings, you **must** L2-normalize the 512-float vector before comparison (`vector / sqrt(sum(vector^2))`). When performing cosine similarity, use the threshold of `0.30 - 0.40` for "Same Person" for your MobileNetV3 model, testing with `0.4` first and adjusting if too strict (`mobilenetv3-specific-instructions.md`). Remember that the pixel value normalization (0-255 RGB to [-1, 1]) is already baked into your Core ML model, so do *not* double normalize manually.
- [ ] Craft the 5-Screen Emotional Onboarding Flow: Design and implement the "Remi" Emotional Onboarding Flow outlined in `onboarding.md`. Focus on the "Gateway", "Loss", "Struggle", "Solution", and "Experience" screens to build user investment. Incorporate micro-animations with `.phaseAnimator` for text, ensure `accessibilityLabel` for every emotional beat, and include a lower-contrast "Skip" button. Center content and buttons as noted in your daily accomplishments.
- [ ] Implement Comprehensive iPadOS Homepage Adaptations: Continue refining the homepage for iPadOS by implementing the specific layouts described in `homepage.md`. This includes a side navigation that expands/collapses (containing "Quick Items" and "Quick Register" groups), two distinct "Scan from Camera" and "Scan from Photos" buttons (with ample breathing room in horizontal mode, full width in vertical), and adjusting the hero content position by ~100px downwards to accommodate the top tab bar. Ensure consistency in spacing and typefaces across all new and existing components, referencing `design-system.md`.

## ✨ Daily Fuel
> "Remember, the 'Golden Rule' of development: If it's not working, one of these critical rules is broken."
