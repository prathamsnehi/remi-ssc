# Face Recognition Accuracy Implementations

**Date:** January 26, 2026

This document outlines the technical improvements and architectural decisions implemented to achieve high-accuracy, stable, and robust face recognition in the Remi app.

## 1. Core Model & Algorithm

The foundation of the system was upgraded to ensuring state-of-the-art feature extraction.

- **Model Upgrade**: Migrated from the legacy `MobileFaceNet` (0.99 MB) to the modern `MobileNetV3` (InsightFace compliant). This generic model provides significantly better separation between identities.
- **Mandatory 5-Point Alignment**: Implemented strict alignment logic. The model input is _never_ just a raw crop. We detect 5 landmarks (eyes, nose, mouth) and use `CGAffineTransform` (Similarity Transform) to warp the face into a canonical, upright frontal view before embedding.
- **L2 Normalization**: All embeddings are strictly L2 unique-normalized before comparison. This ensures that the Dot Product equals Cosine Similarity, making thresholding (0.4) consistent and mathematically valid.

## 2. Input Pipeline & Color Space

We discovered and fixed critical data integrity issues in the image pipeline that were silently degrading accuracy.

- **Coordinate System Fix**: Rewrote the alignment logic using `CIContext` (Bottom-Left origin) instead of mixed UIKit/Vision coordinates. This resolved issues where registration photos were internally "upside down" or crops focused on the chin/neck instead of the face.
- **Direct Buffer Pass (BGRA Integrity)**:
  - **Problem**: Converting `CVPixelBuffer` -> `UIImage` -> `CGImage` -> `Model` often caused silent color channel swapping (ARGB vs BGRA), confusing the model.
  - **Fix**: Modified `FaceEmbedder` and `FaceRecognitionService` to pass the `CVPixelBuffer` **directly** from the camera/alignment step to the CoreML model. This guarantees the model receives the exact pixel data (BGRA) it was trained for.

## 3. Robustness & Generalization

To handle "In-the-wild" variations (angles, verified expressions) without burdening the user.

- **Test Time Augmentation (TTA)**:
  - **Logic**: During Single-Shot Registration, the system generates **two embeddings**: one for the original image and one for a horizontally flipped (mirrored) version.
  - **Averaging**: The two vectors are averaged and re-normalized.
  - **Benefit**: This enforces symmetry in the latent space, making the model significantly more robust to slight head turns (profile views) during scanning, mimicking the internal behavior of libraries like `face_recognition` (dlib).

## 4. Real-time Stability (AR)

To solve "flickering" and "jitter" which caused the bounding box to shake and the identity to toggle between "Match" and "Unknown".

- **Global Throttling**: The entire Vision+ML pipeline is throttled to run at **2 FPS (0.5s interval)**. This stops the UI from reacting frantically to noise and gives the heavy ML model time to run without checking up main thread resources.
- **Aggressive Box Smoothing**: Implemented `FaceBoxSmoother` with a heavy smoothing factor (`alpha = 0.12`). This applies an Exponential Moving Average to the bounding box, making it appear "heavy" and stable on screen.
- **Hysteresis (Sticky Matching)**:
  - **Logic**: Once a person is identified, the system enters a "Sticky" state. It requires **4 consecutive failed frames** (approx 2.0 seconds) to drop the match back to "Unknown".
  - **Benefit**: Eliminates the "flicker" where a known face momentarily drops to "Unknown" due to a single blurry frame or bad light.

## Summary Checklist

- Model: MobileNetV3 (CoreML)
- Alignment: 5-Point Landmark Warping
- Coordinates: CIContext (BL) Corrected
- Input: Direct CVPixelBuffer (BGRA)
- Robustness: Horizontal Flip TTA
- Stability: 2 FPS Throttle + Hysteresis + EMA Smoothing
