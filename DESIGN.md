# FitTrackr Design System & Figma UI/UX Specification

**Document Version:** 1.0.0-PROD  
**Design Paradigm:** Athletic High-Performance Material 3  
**Supported Modes:** OLED True Dark (Default) & High-Contrast Light  
**Typography Core:** Plus Jakarta Sans (Headings/Body) + JetBrains Mono (Telemetry/Numerics)  
**Iconography:** Phosphor Icons & Material Symbols  
**Micro-Interactions & Motion:** Rive & Lottie Runtimes  

---

## 1. Visual Identity & Brand Concept

FitTrackr's visual identity balances **athletic intensity** with **clinical telemetry precision**. It rejects generic pastel gym aesthetics in favor of a sleek, high-contrast, technical interface engineered for rapid scanning in low-light gym settings or bright outdoor daylight.

### App Icon Asset Reference
The production-ready app icon has been generated and positioned at:
`assets/branding/app_icon.jpg`

![FitTrackr App Icon](/Users/sourabhyadav/.gemini/antigravity-ide/brain/b35fe463-4492-4391-b5e5-a8afb0891f22/fittrackr_app_icon_1790768303371.jpg)

*Visual Archetype:* A neon kinetic glyph merging a runner in motion, an electrocardiogram pulse, and a track loop, set against an obsidian carbon backdrop.

---

## 2. Color System & Dual-Theme Architecture

FitTrackr features a dual-theme architecture:
1. **Flagship Warm Minimalist (Primary Light Theme):** Matches the user-provided flagship design reference, using a warm sand/cream canvas (`#FAF7F2`), crisp elevated white containers (`#FFFFFF`), ambient diffuse shadows, and energetic Coral Tangerine accents (`#FF5E3A`).
2. **Athletic OLED Dark Mode (Gym / Low-Light):** High-contrast true-black obsidian canvas (`#0A0C0F`) with kinetic lime and cyan accents.

### 2.1 Flagship Warm Minimalist Theme (Primary - UI Reference Standard)

| Token Name | Hex Code | HSL / RGB | Semantic Role & UI Placement |
| :--- | :--- | :--- | :--- |
| `scaffold-base` | `#FAF7F2` | `38°, 33%, 97%` | Warm light canvas backdrop (zero glare, natural warmth) |
| `card-surface` | `#FFFFFF` | `0°, 0%, 100%` | Pure white elevated cards, goal progress container |
| `card-border` | `#F0ECE4` | `38°, 25%, 92%` | Ultra-subtle hairline card border (1px) |
| `primary-coral` | `#FF5E3A` | `11°, 100%, 61%` | Hero accent: Circular progress ring, FAB button, active tab |
| `primary-coral-soft` | `#FFF0EB` | `15°, 100%, 96%` | Pastel icon containers (Steps, Kcal, Distance, Active Time) |
| `accent-green` | `#22C55E` | `142°, 71%, 45%`| "On Track" status capsule, normal SpO2 badge |
| `accent-green-soft` | `#DCFCE7` | `142°, 85%, 93%`| Background container for green status badges |
| `accent-blue` | `#0284C7` | `199°, 89%, 40%`| Water hydration icon & 75% hydration progress ring |
| `accent-blue-soft` | `#E0F2FE` | `204°, 94%, 94%`| Hydration card icon container |
| `accent-purple` | `#9333EA` | `271°, 81%, 56%`| Sleep telemetry icon & "Goal Crusher" achievement badge |
| `accent-purple-soft`| `#F3E8FF` | `270°, 100%, 96%`| Sleep card icon container |
| `accent-pink` | `#FF4D6D` | `349°, 100%, 65%`| Heart rate BPM icon & pulse graph |
| `accent-pink-soft` | `#FFEBF0` | `348°, 100%, 96%`| Heart rate icon container |
| `text-primary` | `#1E252D` | `213°, 20%, 15%` | Primary high-contrast typography, metrics, headers |
| `text-secondary` | `#6B7280` | `220°, 9%, 46%` | Secondary descriptions, subheadings, inactive day names |
| `text-muted` | `#9CA3AF` | `218°, 11%, 65%` | Timestamp metadata, disabled labels, units |

### 2.2 Athletic OLED Dark Mode (Secondary Companion Theme)

| Token Name | Hex Code | Semantic Role |
| :--- | :--- | :--- |
| `surface-base` | `#0A0C0F` | Ultra-deep OLED background |
| `surface-card` | `#14181F` | Primary container cards |
| `surface-stroke` | `#2A323F` | 1px precision dividers |
| `primary-kinetic-lime` | `#CCFF00` | Energy accent for dark mode |
| `telemetry-cyan` | `#00F0FF` | Steps & distance metrics |
| `metabolic-crimson` | `#FF334B` | Calories & heart rate |

---

## 3. Typography Hierarchy

### 3.1 Font Families
1. **Primary Family (UI & Headings):** `Plus Jakarta Sans` (Google Fonts)
   * Geometric, modern, highly legible with wide aperture at small mobile sizes.
2. **Numeric & Telemetry Family:** `JetBrains Mono` or `Roboto Mono`
   * Monospaced numerals prevent horizontal layout shifts when step counts or rest timers tick in real time.

### 3.2 Material 3 Type Scale Specifications

```
Display Large    | 57sp / 64dp line-height | Bold (700)      | Active Step Count
Headline Large   | 32sp / 40dp line-height | SemiBold (600)  | Screen Titles (Dashboard, Workout)
Headline Medium  | 28sp / 36dp line-height | SemiBold (600)  | Exercise Names (Barbell Bench Press)
Title Large      | 22sp / 28dp line-height | Medium (500)    | Section Headers, Plan Titles
Title Medium     | 16sp / 24dp line-height | SemiBold (600)  | Set Numbers, Macro Group Names
Body Large       | 16sp / 24dp line-height | Regular (400)   | Exercise Form Cues, Descriptions
Body Medium      | 14sp / 20dp line-height | Regular (400)   | Metadata, Secondary Descriptions
Label Large      | 14sp / 20dp line-height | SemiBold (600)  | Button Labels, Tab Items
Label Medium     | 12sp / 16dp line-height | Medium (500)    | Muscle Tags, Difficulty Badges
Label Small      | 11sp / 16dp line-height | Bold (700)      | Mono Metric Units (KG, REPS, KCAL)
```

---

## 4. Spacing, Elevation & Geometry

* **Baseline Grid:** 4dp spatial scale.
* **Component Padding Standards:**
  * Screen horizontal margins: `16dp` (compact phones) / `20dp` (standard 6.7" displays).
  * Card interior padding: `16dp` vertical, `16dp` horizontal.
  * Card-to-card vertical gap: `12dp`.
  * Group vertical gap: `24dp`.
* **Corner Radius Radii:**
  * Action Chips / Pills: `999dp` (Full capsule).
  * Standard Cards & Metric Tiles: `16dp`.
  * Bottom Sheet Drawers: `28dp` top-left & top-right.
  * Checkboxes & Text Fields: `10dp`.
* **Elevation & Outlines:**
  * Zero drop-shadows in Dark Mode (rely on `1px solid var(--surface-stroke)` and surface luminance shifting).
  * High-visibility glowing borders on active items (`1.5px solid var(--primary-kinetic-lime)`).

---

## 5. Iconography & Micro-Animations

### 5.1 Icon System
FitTrackr uses `phosphor_flutter` (or `lucide_icons`) with a 24dp bounding box and consistent 2.0px stroke weight.

| Intent | Icon Identifier | Style |
| :--- | :--- | :--- |
| Fitness Dashboard | `PhosphorIconsRegular.gauge` | Regular / Fill on Active |
| Workouts / Barbell | `PhosphorIconsRegular.barbell` | Regular / Fill on Active |
| Step Counter | `PhosphorIconsRegular.sneakerMove` | Regular / Fill on Active |
| Progress Charts | `PhosphorIconsRegular.chartLineUp` | Regular / Fill on Active |
| Diet & Macros | `PhosphorIconsRegular.forkKnife` | Regular / Fill on Active |
| Health Connect Sync| `PhosphorIconsRegular.heartbeat` | Regular (Animated rotation on sync)|
| Set Completed | `PhosphorIconsBold.check` | Bold, Kinetic Lime Fill |
| Rest Timer | `PhosphorIconsRegular.timer` | Regular, Nutritional Amber |

### 5.2 Animated Motion & Micro-Interactions (Rive / Lottie)
1. **Set Completion Ripple (`set_complete.riv` / Lottie):**
   * Upon tapping the set checkmark, a quick 350ms particle burst expands outward with kinetic lime sparks, accompanied by a sharp haptic impulse (`HapticFeedback.mediumImpact()`).
2. **Rest Countdown Ring (`rest_pulse.json`):**
   * A pulsing ambient glow around the floating rest bar that gently breathes every 2 seconds, turning amber at $T-10\text{s}$ and pulsing urgently at $T-3\text{s}$.
3. **Step Goal Reached Burst (`goal_reached.riv`):**
   * Smooth vector confetti and dual-arc completion glow when today's step count crosses 10,000 steps.
4. **Health Connect Sync Spinner:**
   * A 360-degree smooth rotational vector glyph indicating asynchronous Health Connect read/write reconciliation.

---

## 6. Detailed Screen-by-Screen Figma Layout Specifications

### Screen 1: Insights & Telemetry Dashboard (`InsightsScreen`) — UI Reference Master
Matches the left mockup screen in the UI reference:
```
+-------------------------------------------------------+
|  [Avatar]  Great job, Rabbi 👋             [Calendar] |
|            You're 12% more active this week.          |
|                                        [This Week ⌵]  |
+-------------------------------------------------------+
|  QUICK METRICS GRID (4 TILES)                         |
|  +---------+  +---------+  +---------+  +---------+   |
|  |  (👟)   |  |  (🔥)   |  |  (📍)   |  |  (🕒)   |   |
|  | Steps   |  | Kcal    |  | Dist    |  | Active  |   |
|  | 64,240  |  | 2,420   |  | 48.6 km |  | 6h 45m  |   |
|  |last week|  |last week|  |last week|  |last week|   |
|  +---------+  +---------+  +---------+  +---------+   |
+-------------------------------------------------------+
|  GOAL PROGRESS (ELEVATED WHITE CARD)        Edit goal |
|  +-------------------------------------------------+  |
|  |   +-------+   step Goal                         |  |
|  |  /  82%    \  8,240/10,000 steps                |  |
|  |  \ (Coral) /  [On Track: 🟢]  (👟) 1,760 Left   |  |
|  |   +-------+   [🔥 6 Day Streak]                 |  |
|  |                                                 |  |
|  |   Sun   Mon   Tue   Wed   Thu   Fri   Sat       |  |
|  |  (60%) (70%) (50%) (55%) [97%] (70%) (80%)      |  |
|  |                          Solid                  |  |
|  |                          Coral                  |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
|  HEALTH OVERVIEW                              View All|
|  +---------+  +---------+  +---------+  +---------+   |
|  |  (❤️)   |  |  (🌙)   |  |  (💧)   |  |  (🫁)   |   |
|  | 78 bpm  |  | 7h 30m  |  | 8 Glass |  | 98%     |   |
|  |HeartRate|  |Avg.Sleep|  |Hydration|  |SpO2 Norm|   |
|  +---------+  +---------+  +---------+  +---------+   |
+-------------------------------------------------------+
|  FLOATING BOTTOM NAV: [Home] [Activity] (+) [Insights*] [Profile] |
+-------------------------------------------------------+
```

### Screen 2: Athlete Profile & Achievements (`ProfileScreen`) — UI Reference Master
Matches the right mockup screen in the UI reference:
```
+-------------------------------------------------------+
|  [⚙ Settings]            Profile         [Share] [🔔] |
+-------------------------------------------------------+
|  ATHLETE PROFILE CARD                                 |
|  +-------------------------------------------------+  |
|  |  [Avatar with Peach Halo & Edit Pencil Badge]   |  |
|  |  M, Rabbi rezwan [✔ Verified Badge]             |  |
|  |  Improving every day.                           |  |
|  |  📍 New York, USA                           ♂   |  |
|  +-------------------------------------------------+  |
|  |  (👑) Active Member Since Jan 2024              |  |
|  |  [Level 12 Hexagon]  3,200 / 5,000 XP  [====--] |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
|  GOAL OVERVIEW CARD                         Edit goal |
|  +-------------------------------------------------+  |
|  |  🔥 6             Move      Exercise   Hydration |  |
|  |  Day Streak       82% (🔥)   70% (👟)   75% (💧) |  |
|  |  S M T W T F S   (Coral)    (Green)    (Blue)    |  |
|  |  •••••••                                        |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
|  ACHIEVEMENTS                                 View All|
|  +-------------------------------------------------+  |
|  |  [⬡ 6 Days] [⬡ 10k] [⬡ Hydration] [⬡ Goal] [⬡ 🔒]|  |
|  |   Streak     Steps    Hero         Crusher 2 Wks|  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
|  PERSONAL BESTS (PRs)                         View All|
|  - Bench Press: 100 kg • Squat: 140 kg • Deadlift: 180 kg|
+-------------------------------------------------------+
|  FLOATING BOTTOM NAV: [Home] [Activity] (+) [Insights] [Profile*]|
+-------------------------------------------------------+
```

### Screen 3: Workout Plans & Catalog (`WorkoutPlansScreen`)
* **Tabs:** `Active Plan` | `Pre-Made Programs` | `Custom`
* **Filter Row:** `[All]` `[Strength]` `[Hypertrophy]` `[Full Body]` `[Cardio]`
* **Plan Card Specification:**
  * Header: Title ("Push / Pull / Legs Hypertrophy"), Badge ("Intermediate • 6 Days/Wk").
  * Muscle Map: Visual tag chips (`Chest`, `Shoulders`, `Triceps`).
  * Expansion Tile: Reveals Day 1 (Push A), Day 2 (Pull A), Day 3 (Legs A), Rest, etc.
  * Action: "Set as Active Plan" or "Inspect Exercises".

### Screen 4: Workout Detail & Session Overview (`WorkoutDetailScreen`)
* **Header:** Workout title, target duration, target volume estimate, and equipment needed.
* **Exercise List Items:**
  * Left: Ordered index circle (`1`, `2`, `3`).
  * Center: Exercise title (`Barbell Incline Bench Press`), Target schema (`4 sets x 8-10 reps • RPE 8`), Target muscles (`Upper Pectorals, Anterior Deltoids`).
  * Right: Chevron / expandable info button opening biomechanical form cues drawer.
* **Sticky Bottom Bar:** Large primary button in Coral: `[ START WORKOUT SESSION ]`.

### Screen 5: Active Workout Tracking (`ActiveWorkoutScreen`)
* High-contrast card-based workout logging with instant set completion, RPE ratings, previous session weight hints, and floating rest timer.
* Set rows feature checkboxes that trigger kinetic ripple animations upon completion.

### Screen 6: Step Telemetry & Health Connect (`StepsScreen`)
* **Header:** Date navigator (`< Yesterday | Today | Tomorrow >`).
* **Visual Ring:** 280dp diameter dual-arc gauge with real step counter.
* **Live Telemetry Tiles:**
  * Tile 1: Current Cadence (e.g. `118 steps/min` - brisk walk).
  * Tile 2: Walking Distance (`7.42 km`).
  * Tile 3: Active Burn (`412 kcal`).
  * Tile 4: Sync Provider (`Samsung Health via Health Connect`).
* **Hourly Bar Distribution:** 24-column bar chart showing exact step distribution throughout the day.

### Screen 7: Progress Analytics & Charts (`ProgressScreen`)
* **Time Range Selector:** `[ 7D ]` `[ 30D ]` `[ 90D ]` `[ 1Y ]` `[ All ]`
* **Chart 1: Tonnage Progression (fl_chart):**
  * Bar chart representing cumulative kilograms lifted per week.
* **Chart 2: Estimated 1RM Strength Curve:**
  * Smooth bezier spline curve tracing calculated 1-rep maximum for chosen compound lift.
* **Chart 3: Step Consistency Heatmap:**
  * 7x5 or 7x12 matrix with gradient intensity from deep surface to vibrant coral.

### Screen 8: Diet & Macronutrient Guidance (`DietScreen`)
```
+-------------------------------------------------------+
|  Daily Nutrition Overview           Target: 2,450 kcal|
+-------------------------------------------------------+
|  CALORIES CONSUMED: 1,820 kcal  |  REMAINING: 630 kcal |
+-------------------------------------------------------+
|  PROTEIN:  155g / 180g (86%)  ==================--    |
|  CARBS:    190g / 250g (76%)  ================----    |
|  FAT:       52g /  70g (74%)  ===============-----    |
+-------------------------------------------------------+
|  LOGGED MEALS                                         |
|  + Breakfast (580 kcal)                   [ + Add ]   |
|    - 3 Large Eggs (210 kcal, 18g P)                   |
|    - 80g Rolled Oats with Milk (370 kcal, 14g P)      |
|  + Lunch (740 kcal)                       [ + Add ]   |
|    - 200g Grilled Chicken Breast (330 kcal, 62g P)    |
|    - 150g Brown Rice & Greens (410 kcal, 8g P)        |
|  + Post-Workout (500 kcal)                [ + Add ]   |
+-------------------------------------------------------+
|  [ BUTTON: SCAN BARCODE / SEARCH USDA DATABASE ]      |
+-------------------------------------------------------+
```

---

## 7. Accessibility (A11y) & Haptic Engineering

1. **Touch Target Sizing:** Every interactive button, checkbox, and navigation tab maintains a minimum bounding box of $48 \times 48\text{ dp}$ per Material 3 guidelines.
2. **Dynamic Type Support:** All text elements respond to Android system font scaling without overlapping or truncating core numeric telemetry.
3. **Contrast Compliance:** All text tokens achieve a minimum contrast ratio of `7:1` against their respective container backgrounds (WCAG AAA).
4. **Haptic Feedback Mapping:**
   * Set Completion: `HapticFeedbackType.mediumImpact`
   * Rest Timer Finished: `HapticFeedbackType.heavyImpact` (dual pulse)
   * Weight/Rep Increment: `HapticFeedbackType.lightImpact`
   * PR Milestone Achieved: `HapticFeedbackType.vibrate` pattern
