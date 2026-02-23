# 🚀 Remi Dashboard

### Last Updated: 2026-02-23 18:53:41

## 🚀 Time to Lift Off
> **Submission Closed! 🏁** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 47 of 30
`[████████████████████] 100.0%`

## 💾 Project Diet
**Total Size**: 21.91 MB / 25 MB
`[█████████████████░░░] 87.6%`

## 🧠 AI Captain's Orders
- [ ] Integrate the provided `cropSquareAndResize` helper function into your `detectAndCropFace` pipeline. This is crucial for correctly handling `kCVPixelFormatType_32BGRA`, coordinate flipping, and squaring/padding the face crop to 112x112, directly resolving critical issues identified in `sface-must-have-optimizations.md`.
- [ ] Upgrade your face pre-processing to include 5-point landmark alignment. Use Vision's `VNFaceLandmarkRegion2D` to extract eye, nose, and mouth corner points, then apply a `CGAffineTransform` (similarity transform) to warp the face into a canonical, upright frontal view before feeding it to the MobileNetV3 model. This is critical for robust recognition, as outlined in `face-recognition-accuracy-implementations.md`.
- [ ] Iterate on the iPadOS onboarding flow (`onboarding.md`), focusing on specific feedback for Steps C, D, and E (e.g., thought appearance rate, content for D, image overlap in E). Ensure relative sizings, alignments, and the 'smiley' size are consistent across vertical and horizontal orientations to provide a seamless user experience.
- [ ] Re-haul the iPadOS homepage and Friends tab to align with the design system and iPad-first principles. For the homepage, implement the dual scan buttons and adjust hero spacing based on side navigation state. For both, ensure visual hierarchy for 'Your Memories'/'Recent Interactions' cards, uniform spacing, and legible typography as per `design-system.md`.
- [ ] Implement crucial fail-safes during the face scanning process. Detect and provide immediate feedback to the user if a face is not visible, unclear, or has excessive yaw/pitch (e.g., 'Face Not Detected', 'Keep Still'). Simultaneously, refine the scan UI to clearly communicate these states and the 'Person Identified' card status, as noted in `2026-02-03.md` and `todo.md`.

## ✨ Daily Fuel
> "Every line of code you write is a step towards bringing comfort and connection to someone's life."
