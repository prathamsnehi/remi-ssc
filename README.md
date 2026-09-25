# Remi

<img src="remi-ssc.swiftpm/Assets.xcassets/Logo.imageset/remi-icon.png" alt="Remi bookmark logo" width="96">

**A face-based memory bank for the people who matter.**

**2026 Apple Swift Student Challenge winner**

Remi helps someone reconnect a familiar face with the stories and details behind it. Point the camera at a person or choose a photo, and Remi can bring up their name, relationship, and saved memories. Remi is made for people with early memory loss who may struggle to recall personal details, while remaining useful for anyone who wants to preserve moments with loved ones.

This repository contains the Swift Playgrounds app submitted for the 2026 Swift Student Challenge. It is an iPhone and iPad prototype built with SwiftUI, ARKit, Vision, Core ML, and SwiftData. Face recognition and data storage run on the device; the app has no backend or network dependency.

## Explore the app

1. **Recognize a face:** Scan with the camera or select an image from the photo library. A match opens the person's profile and memories.
2. **Remember someone new:** If Remi does not recognize a face, register the person with a name, relationship, photo, and optional first memory. Camera registration collects multiple face samples during a short scan; photo registration uses the selected image.
3. **Build their story:** Add text and optional photos to a person's timeline. Edit their details and memories later, or find them in the searchable Friends tab.
4. **Revisit recent memories:** The Home tab presents people and their photos as story cards. The app includes two sample profiles and memories on first launch so the interface can be explored immediately.

## How face recognition works

```text
Camera frame or selected photo
    → Vision detects a face
    → Face is cropped to a 112 × 112 pixel image
    → Bundled SFace Core ML model produces a 128-value embedding
    → Embedding is normalized and compared with saved samples
    → Best match above the similarity threshold resolves to a Person
    → SwiftData loads that person's profile and memories
```

The camera flow uses ARKit for the live view and Vision for face detection. It processes a face about every 0.5 seconds to keep recognition responsive without running the model on every frame. A dedicated actor owns the Core ML model, while SwiftUI observes scan state and presents the result. Identification compares cosine similarity against all saved embeddings and currently uses a `0.50` match threshold. A single photo provides one embedding; the live registration flow can collect multiple samples.

The model runs locally, and `Person` and `Memory` records are persisted with SwiftData. Profile and memory images use SwiftData's external storage support. No account or server is required.

## Project structure

| Path | What it contains |
| --- | --- |
| [`App/`](remi-ssc.swiftpm/App) | App entry point, onboarding handoff, and tab navigation |
| [`Features/ARFaceScan/`](remi-ssc.swiftpm/Features/ARFaceScan) | Live camera experience, face overlay, and registration scan |
| [`Features/HomeTab/`](remi-ssc.swiftpm/Features/HomeTab) | Home screen, story cards, and photo library scanning |
| [`Features/RegisterFriend/`](remi-ssc.swiftpm/Features/RegisterFriend) | New person registration flow |
| [`Features/SavedFriendsTab/`](remi-ssc.swiftpm/Features/SavedFriendsTab) | Searchable people grid, profiles, and memory editing |
| [`Core/ML/`](remi-ssc.swiftpm/Core/ML) | Face embedding, photo processing, and similarity matching |
| [`Core/Models/`](remi-ssc.swiftpm/Core/Models) | SwiftData models and observable scanner state |
| [`docs/`](docs) | Design notes, technical experiments, and development journal |

The [design system](docs/non-technical/design-system.md) explains Remi's visual choices. The [technical notes](docs/technical) document experiments and earlier approaches; the Swift source above reflects the current implementation.

## Run it

- **Requirements:** A Mac with Xcode 26 or later, or Swift Playgrounds 4.6 or later. The package targets iOS 18 and supports iPhone and iPad.
- **Open:** Open [`remi-ssc.swiftpm`](remi-ssc.swiftpm) in Xcode or Swift Playgrounds, then select the **Remi** app target and run it.
- **Try recognition:** Use a physical device that supports ARKit world tracking, allow Camera and Photos access when prompted, and register a new person before testing a live match. The preloaded sample profiles have no face embeddings and therefore cannot be recognized by a scan.

The interface and saved profiles can be explored in Simulator, but the live AR camera scan requires supported device hardware. The Core ML model is included in the package.

## Prototype notes

Remi is a memory aid, not a medical device. Face matches are estimates and can be wrong; users should verify an identity before relying on it. The current build also saves cropped face images to the app's local Documents directory for debugging during camera and photo scans. That diagnostic behavior should be removed before a production release.

Built by **Pratham Snehi** for the 2026 Apple Swift Student Challenge.
