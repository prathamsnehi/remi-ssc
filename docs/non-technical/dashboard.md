# 🚀 Remi Dashboard

### Last Updated: 2026-02-01 08:39:01

## 🚀 Time to Lift Off

> **4 days, 15 hours, 21 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 25 of 30
`[████████████████░░░░] 84.5%`

## 💾 Project Diet

**Total Size**: 20.35 MB / 25 MB
`[████████████████░░░░] 81.4%`

## 🧠 AI Captain's Orders

- Prioritize implementing the 5-point landmark alignment for face warping to 112x112, ensuring direct CVPixelBuffer pass to the MobileNetV3 model, and performing L2 normalization on the output embeddings, as these steps are critical for face recognition accuracy and are repeatedly emphasized in the technical documentation.
- Implement the AR face detection and recognition, displaying a 'Face ID' style bounding box around detected faces and a recognition card at the bottom of the screen, in line with the UI/UX update planned for 01-19.
- Apply the concurrency fixes outlined in 'arkit-implementation-with-coreml.md': actor-isolate `FaceRecognitionService`, implement `CVPixelBuffer.copy()` for safe data transfer, and integrate global throttling (2 FPS) with aggressive box smoothing and hysteresis for stable real-time AR recognition.
- Continue refining the iPadOS homepage layout, specifically implementing the horizontal side navigation with 'Quick Items' and 'Quick Register' sections, and adjusting button layouts ('scan from camera', 'scan from photos') for both horizontal and vertical orientations as detailed in 'homepage.md'.
- Integrate the SwiftData `Friend` and `Memory` models, including the `mergeProfiles` logic to handle duplicate entries, and populate the 'Your Memories' section on the homepage with placeholder or actual memory content, linking the data layer to the UI.

## ✨ Daily Fuel

> "The greatest creations begin with a dedicated step. Keep building, keep refining, and let your passion shine through every detail, creating unforgettable stories."
