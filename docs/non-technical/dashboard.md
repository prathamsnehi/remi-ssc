# 🚀 Remi Dashboard

### Last Updated: 2026-01-21 01:58:10

## 🚀 Time to Lift Off
> **15 days, 22 hours, 2 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 14 of 30
`[█████████░░░░░░░░░░░] 46.9%`

## 💾 Project Diet
**Total Size**: 12.13 MB / 25 MB
`[█████████░░░░░░░░░░░] 48.5%`

## 🧠 AI Captain's Orders
- [ ] Refine AR Face Overlay & Recognition Card UI: Update the `ARFaceView` to replace the "glass card" next to the head with a dynamic, FaceID-style bounding box around the detected face. Simultaneously, redesign the recognition details to appear in a card anchored at the bottom of the AR view, as per the latest design decisions.
- [ ] Integrate "Your Memories" & Milestones on Homepage: Develop the new "Your Memories" section for the homepage. Populate it with placeholder content for upcoming milestones (e.g., birthdays) and a selection of random memories from `SwiftData`'s `Memory` store, ensuring visual hierarchy consistent with the "Recent Interactions" section on iPad.
- [ ] Complete Robust MobileFaceNet Integration & Concurrency: Fully implement the `Vision` -> `CoreML` (MobileFaceNet) -> Cosine Similarity pipeline for face recognition. Critically, ensure proper `CVPixelBuffer.copy()` for thread-safe processing and verify `MobileFaceNet.mlmodelc` is correctly bundled and loaded.
- [ ] Refactor `FaceRecognitionService` to an Actor: Convert `FaceRecognitionService` into a Swift `actor` to enforce strict concurrency. Modify data transfer to use `Sendable` types like `[(PersistentIdentifier, [Double])]` for candidate embeddings, ensuring all `SwiftData` operations remain on the `MainActor` to prevent crashes.
- [ ] Implement iPadOS Horizontal Side Navigation & Hero Layout: Build the collapsible side navigation for iPadOS horizontal mode, including "Home", "Friends", "Quick Items" (Favorites, New Memory), "Quick Register" (From Photos, From Camera), and "Preferences". Adjust the homepage hero section to accommodate two distinct "Scan" buttons and proper vertical spacing when the side navigation is open/collapsed.

## ✨ Daily Fuel
> "It always seems impossible until it's done. - Nelson Mandela"
