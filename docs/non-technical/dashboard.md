# 🚀 Remi Dashboard

### Last Updated: 2026-01-22 03:25:08

## 🚀 Time to Lift Off
> **14 days, 20 hours, 35 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 15 of 30
`[██████████░░░░░░░░░░] 50.5%`

## 💾 Project Diet
**Total Size**: 12.13 MB / 25 MB
`[█████████░░░░░░░░░░░] 48.5%`

## 🧠 AI Captain's Orders
- [ ] Implement Dynamic AR UI for Face Recognition: Refine the AR experience by replacing the floating "glass card" with a FaceID-style bounding box around detected faces and displaying the recognition details card prominently at the bottom of the screen, as outlined in your latest daily goal.
- [ ] Connect ARKit Camera Feed to Face Recognition Logic: Integrate the `detectAndCropFace`, `getFaceEmbedding`, and `isMatch` functions from `implementations.md` directly into your `ARFaceView`'s `ARSessionDelegate`. Ensure you're leveraging the `CVPixelBuffer.copy()` and actor-isolated `FaceRecognitionService` patterns for thread-safe and crash-free performance as detailed in `arkit-implementation-with-coreml.md`.
- [ ] Develop the Post-Recognition Registration Flow: When an unfamiliar face is detected in AR, implement the UI flow to guide the user through registering a new person. This includes collecting their name, relation, and saving the generated face embedding to SwiftData, leading into the "merge profiles" functionality if a duplicate is later found.
- [ ] Enhance iPad Homepage Vertical Layout: Address the "blank" feeling on the iPad vertical homepage by strategically adding more engaging content, perhaps a larger "Your Memories" section with more prominent cards or integrating a subtle "onboarding" hint for new users, building on your recent UI fixes.
- [ ] Begin Implementing Conversation Starters with NLTagger Fallback: Start coding the `generateStarter(from:)` function using `NaturalLanguage`'s `NLTagger` to extract topics from memories for pre-Apple Intelligence devices. Prepare the groundwork for `FoundationModels` as a more advanced option, ensuring graceful degradation.

## ✨ Daily Fuel
> "Remember, every great app starts with a spark of empathy and grows with relentless dedication to the user."
