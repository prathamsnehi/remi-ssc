# Swift Student Challenge App Ideation

## Application Requirements

- App playground app (.swiftpm) in .zip
- No network connection; local resources only
- Max 25 MB .zip file
- Individual work only (third-party open source allowed with credit)
- Built with Swift Playground 4.6 or Xcode 26+
- English content only

## Phases

### **1. Ideation Phase: The "Apple-fication" Pivot**

- Research about target audience
- Enumerate all of the features that you are going to use in the app. There should be a "why" behind all of those features (Remember, less is more. Focus more on the less)
- **Define the "Why" (Impact Statement):** Clearly articulate the problem your app solves and the positive impact it has on the user's life. This should be a single, compelling sentence.
- **Review Apple's Human Interface Guidelines (HIG):** Ensure your core concept aligns perfectly with Apple's design philosophy (Clarity, Deference, Depth).
- **Identify a Unique iOS/iPadOS Feature:** Beyond the basics, choose one or two advanced, platform-specific features (e.g., PencilKit, Live Activities, Widgets, App Intents, or a new iOS 26 API) to integrate and showcase mastery.
- Research all that they look for while judging these swift student challenges + what apple’s ideals are type beat
- Think about all of the conversion pathways and documentation to go from Azure Backend to all working offline using Apple’s libraries
- Emphasize the privacy angle
- Think of methods for re-iteration
- Think about marketing of the application (plan to release as an App Store app as well, no backend cost because everything works offline)

### **2. Prototyping Phase: The "Playground" Experience**

- Think about the entire flow of the onboarding
- Walking the user through the problem in the onboarding (tell a story)
- Somehow showing the user the demo of the app without them having to scan anyone’s faces, but have all the options available to them to scan their own or someone else’s faces and see the app running in action
- Learn strategies to make your design iPad-first (things like `NavigationSplitView`, etc. This requires a learning curve)
- Place accessibility at the forefront (be sure to integrate it in each part of the app, ensure you are in compliance with screen accessibility WCAG, etc.) (things like `.accessibilityLabel("")`, dynamic type (text scales based off of system settings))
- **Create a Polished README/Documentation:** Write a clear, engaging, and error-free document that explains your app's purpose, how to use it, and the technical decisions you made. This is crucial for the judges.
- **Develop a "Wow" Moment:** Design a specific interaction or visual effect that is delightful, memorable, and demonstrates high-quality craftsmanship.
- **Implement Haptics and Sound:** Use subtle haptic feedback and system sounds to enhance the user experience and provide tactile confirmation for key actions.

### **3. Coding Phase: The Tech Stack Migration**

- You need to swap your Microsoft dependencies for Apple equivalents to show off your Swift skills.

| Current Tech (Microsoft) | New Tech (Apple SSC)          | Why?                                                                                                                           |
| ------------------------ | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **Azure Face API**       | **Vision Framework**          | Shows you know how to use Core Image and Vision for on-device ML.                                                              |
| **Azure OpenAI**         | **NaturalLanguage Framework** | Use `NLEmbedding` or simple logic for "conversation starters." If you _must_ use GenAI, ensure it fails gracefully if offline. |
| **Azure Web App**        | **SwiftData / Core Data**     | Shows mastery of persistent local storage.                                                                                     |
| **React/Native Code**    | **SwiftUI**                   | Mandatory. Use the latest SwiftUI features (e.g., iOS 17/18 APIs) to impress judges.                                           |

- **Code Quality and Style:** Review your code for clean, idiomatic Swift. Ensure consistent naming conventions and clear commenting, especially for complex logic.
- **Error Handling and Graceful Failure:** Implement robust error handling, particularly around permissions (e.g., Camera, Photos) and resource loading, to ensure the app never crashes.
- **Testing and Debugging:** Include a note in your documentation about how you tested the app and confirm that all features work flawlessly on the target platform (iPad).
