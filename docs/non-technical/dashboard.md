# 🚀 Remi Dashboard

### Last Updated: 2026-02-01 06:30:18

## 🚀 Time to Lift Off

> **4 days, 17 hours, 29 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 25 of 30
`[████████████████░░░░] 84.2%`

## 💾 Project Diet

**Total Size**: 20.35 MB / 25 MB
`[████████████████░░░░] 81.4%`

## 🧠 AI Captain's Orders

- [ ] Set up the foundational ARKit `ARView` by integrating the camera feed and implementing initial face detection using `ARFaceTrackingConfiguration` to begin the AR scanning feature.
- [ ] Implement `Vision` framework to perform detailed face analysis on `CVPixelBuffer`s, specifically extracting 5-point landmarks (eyes, nose, mouth corners) required for precise face alignment with `MobileNetV3`.
- [ ] Integrate the `MobileNetV3.mlmodel` into the project, ensuring the input pipeline strictly adheres to its requirements: perform 5-point landmark alignment to warp faces to 112x112 pixels, and feed `RGB 0-255` `CVPixelBuffer`s directly, avoiding manual pixel normalization.
- [ ] Refactor face embedding generation and comparison logic into a `FaceRecognitionService` `actor` to guarantee thread safety. Ensure deep copies of `CVPixelBuffer` are made and L2 normalization is applied to embeddings before cosine similarity comparison.
- [ ] Design and implement the AR recognition user interface to display a 'FaceID logo style box' over the detected face and position the recognition card (with name, relation, and conversation starter) at the bottom of the screen, as per the latest UX refinement.

## ✨ Daily Fuel

> "Every challenge in code is an opportunity to craft a truly unforgettable experience, for yourself and for those you touch."
