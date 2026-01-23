### The Rules for YOUR MobileNetV3

While you find that code, here is the breakdown of your checklist specifically for the **Yakhyo MobileNetV3** model we just converted.

#### ✅ Rule 1 & 2: Detection & Alignment (CRITICAL)

- **Status:** **MANDATORY.**
- **Why:** MobileNetV3 (like ArcFace/GhostNet) is trained on **aligned** faces.
- **The Trap:** If you just "crop the face" with a bounding box, your accuracy will drop by \~10-15%.
- **The Fix:** You must use **5-point landmark alignment** (eyes, nose, mouth corners) to warp the face into the target 112x112 square. If you skip this, the model will struggle to recognize the same person if their head is tilted even slightly.

#### ✅ Rule 5: Input Size

- **Status:** **112 x 112**
- **Specifics:** Your model expects exactly `112x112` pixels.
- **Good News:** If you use the standard `VNCoreMLModel` (Vision) or the manual Swift helper, Core ML will automatically resize larger images down to 112x112 for you. You just need to ensure the aspect ratio is correct (square crop) before feeding it in.

#### ✅ Rule 6: Normalization (Pixel Values)

- **Status:** **DO NOT DO THIS MANUALLY.** (We baked it in!)
- **Explanation:** In our Python script, we added `scale=1/127.5` and `bias=[-1, -1, -1]`.
- **What this means for you:** You should feed the model a standard **UIImage** or **CVPixelBuffer** (RGB 0-255). The Core ML layer will automatically convert that to the `[-1, 1]` range the model needs.
- **Warning:** If you manually normalize the pixels in Swift (dividing by 255, etc.) and _then_ feed it to the model, you will "double normalize" and destroy the accuracy.

#### ✅ Rule 10: Embedding Post-Processing

- **Status:** **MANDATORY.**
- **Why:** The raw output from the model (the array of 512 floats) is **not** normalized.
- **Action:** You **must** L2-normalize the vector in Swift before comparing it.
- - _Formula:_ `vector / sqrt(sum(vector^2))`
  - If you don't do this, the Cosine Similarity math will be wrong.

#### ✅ Rule 11: Similarity Metric

- **Status:** **Cosine Similarity.**
- **Threshold:** For MobileNetV3 trained on MS1MV2, the threshold is usually around **0.30 - 0.40** for "Same Person" (it is strictly lower than FaceNet's 0.75).
- - _Note:_ Start testing with `0.4` as your cutoff. If it's too strict, lower it to `0.35`.
