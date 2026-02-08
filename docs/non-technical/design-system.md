# Remi Design System

This document serves as the single source of truth for the Remi design language. It outlines the typography, color palette, and component patterns that define the application's look and feel. When introducing new features or screens, adhere strictly to these guidelines to maintain a cohesive, premium, and friendly user experience.

> \[!NOTE]
> Remi is a "Face-Based Memory Bank." The design should feel**personal**, **calm**, and **trustworthy**. It balances modern glassmorphism with soft, rounded aesthetics to appear approachable yet sophisticated.

---

## 1. Typography

Remi exclusively uses Apple's system fonts (`San Francisco`) but applies specific designs (`.rounded`, `.serif`) to create hierarchy and emotion.

### Type Scale

| Style             | SwiftUI Font   | Weight               | Design     | Usage                                                                       |
| ----------------- | -------------- | -------------------- | ---------- | --------------------------------------------------------------------------- |
| **Hero Title**    | `.largeTitle`  | `.bold`              | `.rounded` | Main screen greetings ("Hi User"), major profile names.                     |
| **Section Title** | `.title2`      | `.bold`              | `.rounded` | Onboarding headers, major section dividers ("Your Face-Based Memory Bank"). |
| **Card Title**    | `.title3`      | `.bold`              | `.default` | Names on cards, secondary headers in lists.                                 |
| **Headline**      | `.headline`    | `.semibold`          | `.rounded` | Interactive elements, buttons, important short text.                        |
| **Body**          | `.body`        | `.regular`           | `.default` | Standard reading text, descriptions, memories.                              |
| **Callout**       | `.callout`     | `.medium`            | `.rounded` | Prompts, instructional text ("Point camera..."), subtitles.                 |
| **Subheadline**   | `.subheadline` | `.medium`            | `.default` | Secondary information, list item details.                                   |
| **Caption**       | `.caption`     | `.bold` / `.regular` | `.rounded` | Metadata tags, timestamps, small labels.                                    |
| **Footnote**      | `.footnote`    | `.medium`            | `.default` | Disclaimers, very small instructional text.                                 |

### Design Nuances

- **Rounded (design: .rounded)**: Use for **Headings**, **Greetings**, **Buttons**, and **"Human"** elements. This softens the UI and makes it feel friendlier.
- **Serif (design: .serif)**: Use _sparingly_ for **Emotional** or **Storytelling** moments (e.g., "A face you’ve known for thirty years...").
- **Default**: Use for standard body text and information density where readability is paramount.

---

## 2. Color Palette

Colors are semantic. Avoid hardcoding hex values; use the named assets in the asset catalog.

### Core Semantic Colors

| Name               | Role                   | Visual Description                                                              |
| ------------------ | ---------------------- | ------------------------------------------------------------------------------- |
| `AppPrimary`       | **Brand Accent**       | A vibrant blue/purple. Used for primary buttons, active states, and highlights. |
| `AppPrimaryText`   | **Main Content**       | High-contrast text (Near-black in Light Mode, White in Dark Mode).              |
| `AppSecondaryText` | **Supporting Content** | Lower-contrast text (Gray). Used for subtitles, captions, and placeholders.     |
| `AppBackground`    | **Canvas**             | The base background of the application.                                         |
| `AppSurface`       | **Containers**         | Slightly elevated background for cards, sheets, and modals.                     |

### Functional Colors

- **Success**: `Color.green` (Used for "Match %", Checkmarks).
- **Warning**: `Color.orange` (Used for "Scanning Problem").
- **Magic/AI**: `Color.yellow` (Used for "Sparkles", AI suggestions).
- **Destructive**: `Color.red` (Used for "Delete", "Remove").

---

## 3. Component Patterns

### Buttons

- **Primary Action**:
  - **Shape**: Capsule.
  - **Background**: `AppPrimary`.
  - **Text**: `.white`, `.headline`.
  - **Usage**: "Continue", "Add Memory", "Scan".
- **Secondary Action**:
  - **Shape**: Capsule.
  - **Background**: `.ultraThinMaterial` or `AppSurface` with a subtle stroke.
  - **Text**: `AppPrimaryText`, `.subheadline`.
  - **Usage**: "Cancel", "Edit", "View Options".

### Cards

Cards are the primary container for information in Remi.

- **Corner Radius**: `16px` to `24px` (Continuous curvature).
- **Background**: `AppSurface` or `.ultraThinMaterial` (for glass effects).
- **Shadow**: `radius: 10, y: 5, color: black.opacity(0.05)` (Soft, diffuse shadow).
- **Border**: Subtle stroke `Color.white.opacity(0.2)` or `Color.black.opacity(0.05)` to define edges on low-contrast backgrounds.

### Inputs

- **Styled Text Field**:
  - **Font**: `.largeTitle`, `.bold`, `.rounded`.
  - **Alignment**: Centered.
  - **Decoration**: Bottom underline (`Rectangle` height 2), `AppSecondaryText` opacity 0.3.
  - **Interaction**: No background, focused on the text content itself.

### Imagery

- **Avatars**: Circular.
  - **Border**: 1px stroke (white or gray) to separate from background.
  - **Shadow**: Medium shadow for depth.
- **Hero Images**: Full bleed or top-gradient fade.
  - **Overlay**: Gradient from transparent to `AppBackground` at the bottom for text readability.

---

## 4. Layout & Spacing

- **Safe Areas**: Always respect safe areas. Use `ignoresSafeArea` only for background gradients or full-screen camera views.
- **Padding**:
  - **Standard Edge**: `20px` (Horizontal).
  - **Section Spacing**: `24px` to `32px` (Vertical).
  - **Internal Card Padding**: `16px`.
  - **Element Spacing**: `8px` to `12px` (Stacks).
- **Glassmorphism**: When overlaying content on camera or complex backgrounds (like AR View), use `.background(.ultraThinMaterial)` with `.glassEffect()` modifier (if available) or standard material with a white opacity stroke.

---

## 5. AR & HUD Elements

- **Status Capsules**:
  - **Background**: `.ultraThinMaterial`.
  - **Shape**: Capsule.
  - **Content**: `.caption` bold text.
- **Overlays**:
  - Use `.white.opacity(0.2)` for stroke outlines on face bounding boxes.
  - Use clear, high-contrast text (`.white` with shadow or `.black` on light blur) for HUD labels.
