# 🚀 Remi Dashboard

### Last Updated: 2026-02-03 23:57:37

## 🚀 Time to Lift Off

> **2 days, 0 hours, 2 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 27 of 30
`[██████████████████░░] 93.3%`

## 💾 Project Diet

**Total Size**: 20.36 MB / 25 MB
`[████████████████░░░░] 81.4%`

## 🧠 AI Captain's Orders

- Refine Core Face Processing with Provided Helper: Integrate the `cropSquareAndResize` helper function (from `sface-must-have-optimizations.md`) into your `detectAndCropFace` logic. This is crucial for correctly handling `BGRA` pixel format, Vision coordinate inversion, square cropping, and resizing to 112x112 for your MobileNetV3 model.
- Implement Robust AR Concurrency & Stability: Prevent crashes by using `CVPixelBuffer.copy()` for camera frames passed to background tasks. Refactor your `FaceRecognitionService` into an `actor` to ensure thread-safe access to your ML model, adhering to Swift 6 Strict Concurrency as detailed in `arkit-implementation-with-coreml.md`.
- Finalize Multi-Embedding Registration Flow: Complete the registration process by capturing multiple embeddings (e.g., 50 over 5 seconds) during the scan. Implement Test Time Augmentation (horizontal flip) and average these L2-normalized embeddings to create a robust "faceprint" for new `Friend` profiles in `SwiftData`.
- Tune MobileNetV3 Similarity & Hysteresis: Apply L2 normalization to *all* embeddings (both stored and newly generated) before comparison. Implement cosine similarity with MobileNetV3's recommended threshold (0.30-0.40) and add "Hysteresis" (e.g., requiring 4 consecutive non-matches to drop an identified face) for stable real-time recognition, as outlined in `face-recognition-accuracy-implementations.md`.
- Polish iPadOS Homepage Adaptive Layout: Implement the adaptive layout for the iPadOS homepage. This includes the expanding/collapsing side navigation for horizontal orientation and adjusting the hero section's vertical positioning. Ensure the "Scan" buttons dynamically adapt their layout (two distinct buttons horizontally, two full-width vertically) to match the specifications in `homepage.md`.

## ✨ Daily Fuel

> "Every meticulous line of code you write in Remi builds a bridge to forgotten memories, transforming complex challenges into moments of profound connection."
