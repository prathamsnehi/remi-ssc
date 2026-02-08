By using **psychological anchoring** and **narrative arc**, we can build a 5-screen flow that creates an emotional "investment" before the user even reaches the home screen.

---

### The "Remi" Emotional Onboarding Flow

### The "Remi" Emotional Onboarding Flow

**Screen 0: Hero (Step A) - The Gateway**

- **Visual:** A minimalist, elegant entry. Large, rounded app logo centered with "Remi" in bold typography.
- **Interaction:** Subtitles cycle slowly below: "Your Face-Based Memory Bank For..." -> "building stronger relationships," "having confidence," "never letting someone be a stranger."
- **Psychology:** **Priming.** Sets a calm, premium tone and clearly states the value proposition before asking for anything.
- **Action:** "Begin Journey" button leads to the Struggle.

**Screen 1: The Struggle (Step B) - Validating the Pain**

- **Visual:** Thoughts bubble up from the bottom: "What was...", "Who is...", "Name...", "Uhh...".
- **Psychology:** **Empathy Mapping.** Acknowledging the internal monologue of social anxiety or memory lapses makes the user feel understood.
- **Content:** _"Ever had these thoughts before talking to one of your loved ones?"_
- **Action:** "Yes, but want to overcome them" button leads to the Loss.

**Screen 2: The Loss (Step C) - The Personal Anchor**

- **Visual:** A photo of an elderly person (Grandmother) that starts clear, then slowly blurs over 5 seconds.
- **Psychology:** **Loss Aversion.** The gradual blurring mimics the fading of memory, creating an emotional urgency to solve the problem.
- **Content:** _"A face you’ve known for thirty years... suddenly feels like a stranger."_
- **Action:** "I've seen it happen" button finishes onboarding.

#### Screen 3: The Solution (Home Screen)

- **Visual:** The user lands on the Home Screen, ready to add their own people.

---

### Visual Layout Strategy

To keep this from feeling like a "wall of text," use these UI tricks:

- **Micro-Animations:** Use SwiftUI's `.phaseAnimator` to make the text drift in slowly, mimicking the way memories resurface.
- **Voiceover-Ready:** Ensure every emotional beat has an `accessibilityLabel` so the judge sees you've designed for **inclusivity**.
- **The "Skip" Mannerism:** Keep the "Skip" button in the top right, but make it lower contrast (e.g., secondary foreground color) so the eye is naturally drawn to the emotional content first.
