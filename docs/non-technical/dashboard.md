:wq!

# 🚀 Remi Dashboard

### Last Updated: 2026-01-18 02:16:01

## 🚀 Time to Lift Off
<<<<<<< HEAD

> **18 days, 22 hours, 46 minutes** until Feb 6, 2026.
=======
> **18 days, 21 hours, 44 minutes** until Feb 6, 2026.
>>>>>>> 57c3f7fa4c28f3085ef0d4cba91f9dde6eec5d30

**30-Day Sprint Progress**:
Day 11 of 30
`[███████░░░░░░░░░░░░░] 37.0%`

## 💾 Project Diet

**Total Size**: 0.04 MB / 25 MB
`[░░░░░░░░░░░░░░░░░░░░] 0.1%`

## 🧠 AI Captain's Orders
<<<<<<< HEAD

- For the iPad vertical layout, enrich the 'Your Memories' section with more diverse content, like visual 'memory snippets' or prompts, to fill the 'blank' space. Ensure 'Recent Interactions' also transition to a card-based layout to align with this aesthetic, creating a cohesive design.
- Implement the ARKit `ARFaceAnchor` delegate methods to precisely attach the `textEntity` (e.g., 'Hi, Grandpa!') to the detected face's anchor. Experiment with offsets to position the 'glass card' naturally next to the person's head.
- Develop the `detectAndCropFace` helper function to accurately crop the `CGImage` to the detected `boundingBox`, resize it to 112x112, and convert it into a `CVPixelBuffer` suitable for the MobileFaceNet model's input.
- Begin implementing the iPadOS sidebar using `UITabGroup` and `UITab` classes as described in `docs/technical/ipados-sidebar.md`. Focus on structuring the 'Quick Items' and 'Quick Register' groups, and setting `tabBarController.mode = .tabSidebar` for a robust navigation experience.
- Refine the 'Scan from Camera' and 'Scan from Photos' buttons in the iPad horizontal layout. Instead of full width, constrain them to a suitable maximum width (e.g., using a fixed-width `HStack` with padding or `Spacer`s) to create 'ample breathing room' as specified in the homepage requirements.

## ✨ Daily Fuel

> "The journey of a thousand miles begins with a single step."
=======
- [ ] Refactor your iPad navigation from the `UITab` and `UITabGroup` (UIKit) snippets to use SwiftUI's `NavigationSplitView` and `TabView` for a modern, adaptive sidebar/tab bar experience. Design the `NavigationSplitView` to present your 'Home' and 'Friends' tabs, with the 'Quick Items' and 'Quick Register' groups nested within the sidebar, making sure to hide/show the sidebar appropriately for different iPad orientations.
- [ ] Implement the adaptive layout for the homepage buttons on iPad: in horizontal orientation, ensure the two buttons ('Scan from camera', 'Scan from photos') have ample breathing room and are not full-width; in vertical orientation, make them full-width (respecting default padding). Adjust the hero content's vertical offset to account for the tab bar being on top in iPadOS, ensuring it's pushed down by ~100px consistently.
- [ ] Integrate the core face recognition logic by connecting your copied `detectAndCropFace`, `getFaceEmbedding`, and `isMatch` functions. When the 'Scan from Camera' button is tapped, initiate the `ARFaceView` to capture a face, process it through the Vision/CoreML pipeline to generate an embedding, and then use `isMatch` against stored embeddings to identify the person or trigger the registration flow.
- [ ] Transform the 'Recent Interactions' section on iPad by converting its items into cards. Ensure these new cards visually match the design and styling of the 'Your Memories' items, providing a consistent and elevated UI experience for iPad users.
- [ ] Begin populating the 'Your Memories' section. Implement the logic to display upcoming milestones (e.g., birthdays) and cherry-pick random memories from your `SwiftData` store. This will address the current blankness on the iPad vertical homepage and add valuable content.

## ✨ Daily Fuel
> "Success is not final, failure is not fatal: it is the courage to continue that counts."
>>>>>>> 57c3f7fa4c28f3085ef0d4cba91f9dde6eec5d30
