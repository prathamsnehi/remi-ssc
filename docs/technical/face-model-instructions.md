# ✅ Face Embedding Input Checklist (READ THIS LIKE A CONTRACT)

If **any one** of these is wrong, embeddings will be bad.

---

## 1️⃣ Face detection & cropping (NON-NEGOTIABLE)

### ✔️ Detect a face first

- Use **Vision / MediaPipe / MLKit**
- Do **NOT** feed full photos to the embedding model

### ✔️ Crop **tightly but not too tightly**

- Include:
- - Entire face
  - Forehead
  - Chin
  - Both cheeks
- Typical margin: **10–20% padding** around bounding box

❌ Too tight → expression sensitivity❌ Too loose → background noise

---

## 2️⃣ Face alignment (THIS IS HUGE)

**Faces must be aligned.**

### ✔️ Align based on landmarks

- Eyes should be:
- - Horizontally level
  - At consistent vertical position
- Nose centered

Most models assume **upright, frontal faces**.

If you skip alignment:

- Same person → different embeddings
- Especially with head tilt / rotation

---

## 3️⃣ Orientation (iOS GOTCHA ⚠️)

### ✔️ Normalize orientation BEFORE cropping

- Convert image to:
- Then detect & crop

If you crop first and rotate later → landmarks shift → broken alignment

**Rule:**

>

---

## 4️⃣ Color space & channel order (VERY COMMON FAILURE)

### ✔️ Color space

- **RGB**
- **NOT** BGR
- **NOT** BGRA

### ✔️ Channel order

```javascript
[R, G, B];
```

📱 iOS camera output:

```javascript
BGRA;
```

You **must** reorder channels.

If this is wrong:

- Same image ≠ same embedding
- Cosine similarity collapses

---

## 5️⃣ Input size (MUST MATCH MODEL)

### Common sizes:

| Model            | Input Size |
| ---------------- | ---------- |
| FaceNet          | 160 × 160  |
| MobileFaceNet    | 112 × 112  |
| ArcFace variants | 112 × 112  |
| MixFaceNets      | 112 × 112  |

### ✔️ Resize AFTER crop & alignment

- Use **bilinear** interpolation
- Preserve aspect ratio until final resize

❌ Stretching face → identity distortion

---

## 6️⃣ Pixel value normalization (CRITICAL)

### Check your model’s expected format

### Most common:

#### **FaceNet**

```javascript
RGB [0–255]
→ (x - 127.5) / 128.0
→ range ≈ [-1, 1]

```

#### **MobileFaceNet / ArcFace**

```javascript
RGB [0–255]
→ x / 255.0
→ then (x - 0.5) / 0.5

```

🚨 If normalization is wrong:

- Cosine distance becomes meaningless

---

## 7️⃣ Data type & precision

### ✔️ Input type

- Float32 (most models)
- Some TFLite quantized models accept Uint8

### ✔️ Match exactly

If model expects:

```javascript
float32;
```

Do NOT feed:

```javascript
uint8;
```

(CoreML usually handles this, but verify.)

---

## 8️⃣ Lighting & exposure (SOFT REQUIREMENT)

Models are robust, but:

- Avoid extreme shadows
- Avoid blown highlights
- Face should be evenly lit

❌ Harsh lighting = embedding drift

---

## 9️⃣ Expression & pose tolerance (WHAT TO EXPECT)

Most mobile-size models tolerate:

- Neutral → smile
- Small head rotations (< 20°)
- Glasses (usually OK)

They struggle with:

- Profile faces
- Mouth wide open
- Extreme tilt

This is **normal**, not a bug.

---

## 🔟 Embedding post-processing (DO THIS)

### ✔️ L2 normalize embeddings

```javascript
embedding = embedding / ||embedding||

```

Even if model “kind of works” without this — **DO IT**.

---

## 1️⃣1️⃣ Similarity metric (FINAL STEP)

### ✔️ Use cosine similarity

```javascript
cos_sim = dot(a, b);
```

### Typical thresholds (after L2 norm):

| Result           | Cosine Similarity |
| ---------------- | ----------------- |
| Same person      | > 0.75–0.85       |
| Different people | < 0.6             |

(Exact value depends on model.)

---

# 🔥 Sanity Tests (MANDATORY)

### Test 1: Same image twice

```javascript
cosine similarity ≥ 0.999

```

### Test 2: Same person, different photo

```javascript
cosine similarity ≥ 0.8

```

### Test 3: Different people

```javascript
cosine similarity ≤ 0.6

```

If **Test 1 fails**, your pipeline is broken.

---

# 🧠 The Golden Rule

>
