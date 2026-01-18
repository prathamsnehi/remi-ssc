# 🚀 Remi Dashboard

### Last Updated: 2026-01-18 01:13:22

## 🚀 Time to Lift Off
> **18 days, 22 hours, 46 minutes** until Feb 6, 2026.

**30-Day Sprint Progress**:
Day 11 of 30
`[███████░░░░░░░░░░░░░] 36.8%`

## 💾 Project Diet
**Total Size**: 0.04 MB / 25 MB
`[░░░░░░░░░░░░░░░░░░░░] 0.1%`

## 🧠 AI Captain's Orders
- [ ] For the iPad vertical layout, enrich the 'Your Memories' section with more diverse content, like visual 'memory snippets' or prompts, to fill the 'blank' space. Ensure 'Recent Interactions' also transition to a card-based layout to align with this aesthetic, creating a cohesive design.
- [ ] Implement the ARKit `ARFaceAnchor` delegate methods to precisely attach the `textEntity` (e.g., 'Hi, Grandpa!') to the detected face's anchor. Experiment with offsets to position the 'glass card' naturally next to the person's head.
- [ ] Develop the `detectAndCropFace` helper function to accurately crop the `CGImage` to the detected `boundingBox`, resize it to 112x112, and convert it into a `CVPixelBuffer` suitable for the MobileFaceNet model's input.
- [ ] Begin implementing the iPadOS sidebar using `UITabGroup` and `UITab` classes as described in `docs/technical/ipados-sidebar.md`. Focus on structuring the 'Quick Items' and 'Quick Register' groups, and setting `tabBarController.mode = .tabSidebar` for a robust navigation experience.
- [ ] Refine the 'Scan from Camera' and 'Scan from Photos' buttons in the iPad horizontal layout. Instead of full width, constrain them to a suitable maximum width (e.g., using a fixed-width `HStack` with padding or `Spacer`s) to create 'ample breathing room' as specified in the homepage requirements.

## ✨ Daily Fuel
> "The journey of a thousand miles begins with a single step."
