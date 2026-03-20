## **Why This Topic Matters**

Music is a huge industry where success can feel unpredictable. Understanding what drives song popularity has value for artists, producers, and platforms like Spotify or Apple Music. If measurable features like tempo or loudness strongly influenced popularity, creators could optimize songs for success.

We wanted to test whether data itself can explain something as complex and human-driven as music preference. This makes the project both practically relevant and interesting.

---

## **Data Overview and Challenges**

We used a cleaned music dataset containing song-level features such as tempo, duration, loudness, artist name, and popularity (`song.hotttnesss`).

* Final dataset: **4214 songs, 31 features**
* Popularity ranges from **0 to 1**

### Key Issues:

* A large number of songs had exact popularity values of 0, which likely represent missing data rather than true low popularity → these were removed.
* Some variables (like artist popularity or listener behavior) were **not included**, limiting explanatory power.
* Popularity itself is a **noisy and subjective metric**, influenced by external factors like marketing, trends, and platform algorithms.

---

## **Statistical Decisions and Reasoning**

### 1. **Bayesian Framework**

We chose a Bayesian approach because:

* It provides **full posterior distributions** instead of point estimates
* It allows us to **incorporate prior knowledge**
* It gives more interpretable uncertainty through **credible intervals**

---

### 2. **Model Choices**

#### **Question 1: Linear Regression**

* Used a **Bayesian multiple linear regression**
* Outcome: song popularity
* Predictors: tempo, duration, loudness
* Chosen for simplicity and interpretability as a baseline model

---

#### **Question 2: Interaction Model**

* Added an **interaction term (loudness × year)**
* Purpose: test whether the effect of loudness changes over time

---

#### **Question 3: Hierarchical Model**

* Used a **random intercept model by artist**
* Purpose: separate:

  * **Within-artist variation** (differences between songs)
  * **Between-artist variation** (differences across artists)

---

### 3. **Prior Selection**

We used **weakly informative priors**:

* Coefficients: `Normal(0, 2.5)`
  → assumes no extreme effects but allows flexibility
* Intercept:

  * `Normal(0,1)` (Q1)
  * `Normal(0.5,1)` (Q3, since popularity is centered near 0.5)
* Variance terms: `Exponential(1)`
  → ensures positivity and avoids extreme variance estimates

**Why:** These priors regularize the model while letting the data dominate.

---

## **Key Results**

### **Question 1: Song Features**

* **Tempo & duration:** no meaningful effect
* **Loudness:** small positive effect
* Overall: **very low predictive power**

Conclusion: Basic audio features alone do **not** explain popularity.

---

### **Question 2: Loudness Over Time**

* Interaction effect was **near zero**
* Lines were **nearly parallel across years**

Conclusion: The relationship between loudness and popularity has **remained stable over time**

---

### **Question 3: Artist Effects**

* Between-artist variance ≈ **0.129**
* Within-artist variance ≈ **0.113**
* ~**53% of variation** explained by artist identity

Conclusion:
**Who makes the song matters more than the song’s features**

---

## **Who Benefits From These Results**

* **Music platforms (Spotify, Apple Music):**
  Improve recommendation systems by emphasizing artist-level effects

* **Artists & producers:**
  Understand that branding and audience matter more than tweaking audio features

* **Data scientists:**
  Demonstrates the importance of **hierarchical modeling** and missing variables

---

## **Limitations**

* Missing key predictors:

  * Artist popularity / follower count
  * Marketing and promotion
  * Genre and cultural trends
* Popularity metric may be **imperfect or noisy**
* Model assumes **linear relationships**
* Q1 model is **too simple** to capture complex interactions

---

## **Future Work (Unlimited Resources)**

If we had unlimited time and data, we would:

* Incorporate **artist-level features**:

  * Social media presence
  * Historical popularity trends

* Add **listener behavior data**:

  * Streams, skips, playlists

* Include **genre and contextual features**:

  * Mood, lyrics, release timing

* Build **more advanced models**:

  * Nonlinear models (e.g., Gaussian processes, neural networks)
  * Full hierarchical models combining song + artist + time

---

## **Final Takeaway**

Song popularity is **not driven by simple audio features**.
Instead, it is largely influenced by **artist identity and external factors**, highlighting the complexity of human preferences and the limits of purely feature-based models.
