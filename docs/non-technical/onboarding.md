By using **psychological anchoring** and **narrative arc**, we can build a 5-screen flow that creates an emotional "investment" before the user even reaches the home screen.

---

### The "Remi" Emotional Onboarding Flow

**Screen 0: Hero (Step A) - The Gateway**

- **Visual:** A minimalist, elegant entry. Large, rounded app logo centered with "Remi" in bold typography.
- **Interaction:** Subtitles cycle slowly below: "Your Face-Based Memory Bank To..." -> "build stronger relationships," "having confidence," "never letting someone be a stranger."
- **Psychology:** **Priming.** Sets a calm, premium tone and clearly states the value proposition before asking for anything.
- **Action:** "Begin Journey" button leads to the Loss.

**Screen 1: The Loss (Step B) - The Personal Anchor**

- **Visual:** A photo of an elderly person (Grandmother) that starts clear, then slowly blurs.
- **Psychology:** **Loss Aversion.** The gradual blurring mimics the fading of memory, creating an emotional urgency to solve the problem.
- **Content:** _"A face you’ve known for years... suddenly feels like a stranger."_
- **Action:** "I've seen it happen" button leads to the Struggle.

**Screen 2: The Struggle (Step C) - Validating the Pain**

- **Visual:** Thoughts bubble up from the bottom: "Who is that?", "I know them...", "Name?".
- **Psychology:** **Empathy Mapping.** Acknowledging the internal monologue of social anxiety or memory lapses makes the user feel understood.
- **Content:** _"Ever had these thoughts before talking to one of your loved ones?"_
- **Action:** "Yes, but want to overcome them" button leads to the Face Scan Intro.

**Screen 3: The Solution (Step D) - Reassurance & Action**

- **Visual:** Minimalist design featuring the "Scan Face" button from the Home Screen.
- **Psychology:** **Trust & Empowerment.** Reassures the user that the app is the tool to solve their problem, using a familiar actionable element.
- **Content:** _"Your Memories, Unlocked by a Face. Remi helps you store and recall details about your loved ones just by seeing them."_
- **Action:** "Scan Face" button leads to Mock Scan.

**Screen 4: The Experience (Step E) - Proof of Value**

- **Visual:** "Granddaughter" photo starts blurred, then clears up. A camera overlay scans and identifies her as "Granddaughter".
- **Psychology:** **Instant Gratification & Education.** Shows _exactly_ how the app works and the emotional payoff (recognition) without asking for permissions yet.
- **Content:** "Scanning..." -> "Identified: Granddaughter".
- **Action:** "Continue" button finishes onboarding.

---

### Visual Layout Strategy

To keep this from feeling like a "wall of text," use these UI tricks:

- **Micro-Animations:** Use SwiftUI's `.phaseAnimator` to make the text drift in slowly, mimicking the way memories resurface.
- **Voiceover-Ready:** Ensure every emotional beat has an `accessibilityLabel` so the judge sees you've designed for **inclusivity**.
- **The "Skip" Mannerism:** Keep the "Skip" button in the top right, but make it lower contrast (e.g., secondary foreground color) so the eye is naturally drawn to the emotional content first.
