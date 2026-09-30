# FitTrackr UI Reference Specification & Component Reverse-Engineering

**Document Version:** 1.0.0-PROD  
**Source:** User-Provided Flagship UI Design Reference (Insights & Profile Screens)  
**Design Archetype:** Warm Minimalist Neumorphic Material 3  
**Base Canvas:** Soft Warm Cream (`#FAF7F2`)  
**Card Surfaces:** Pure Elevated White (`#FFFFFF`) with Ambient Diffuse Shadows  
**Hero Accent:** Vibrant Coral Tangerine (`#FF5E3A`)  

---

## 1. Visual Anatomy & Screen Breakdown

The user-provided UI reference establishes two flagship screens that define the visual standard for the entire FitTrackr application:
1. **Screen A (Left): "Insights" (Telemetry Dashboard)**
2. **Screen B (Right): "Profile & Achievements" (Athlete Identity & Goals)**

```
┌──────────────────────────────────────┐     ┌──────────────────────────────────────┐
│  [Avatar] Great job, Rabbi 👋        │     │  [⚙]          Profile       [🔗] [🔔] │
│  You're 12% more active this week.   │     │                                      │
│  [This Week ⌵]                       │     │  [User Card with Avatar & Halo Glow] │
├──────────────────────────────────────┤     │  M, Rabbi rezwan [✔]                 │
│  QUICK METRICS GRID (4 TILES)        │     │  Improving every day.                │
│  [Steps]  [Kcal]  [Dist]  [Active]   │     │  📍 New York, USA                ♂   │
├──────────────────────────────────────┤     ├──────────────────────────────────────┤
│  GOAL PROGRESS (ELEVATED CARD)       │     │  ACTIVE MEMBER & LEVEL TILE          │
│  (82% Coral Arc)  step Goal          │     │  Active Member Since Jan 2024 [Crown]│
│                   8,240/10,000 steps │     │  Level 12 • 3,200/5,000 XP [Hexagon] │
│  [On Track: 🟢]   [1,760 steps Left] │     ├──────────────────────────────────────┤
│  [6 Day Streak 🔥]                   │     │  GOAL OVERVIEW CARD                  │
│  WEEKDAY BUBBLES: S M T W T F S      │     │  [🔥 6 Day Streak] [Goal Overview]   │
├──────────────────────────────────────┤     │  S M T W T F S     82%  70%  75%     │
│  HEALTH OVERVIEW (4 TILES)           │     │  •••••••           Move Exer Hydr    │
│  [Heart: 78] [Sleep: 7.5h]           │     ├──────────────────────────────────────┤
│  [Water: 8g] [SpO2: 98%]             │     │  ACHIEVEMENTS (HEXAGONAL BADGES)     │
├──────────────────────────────────────┤     │  [🔥6d] [👟10k] [💧Hydr] [🎯Goal] [🔒]│
│  BOTTOM NAV WITH FLOATING '+' FAB    │     ├──────────────────────────────────────┤
│  [Home] [Activity] (+) [Insights][Me]│     │  BOTTOM NAV WITH FLOATING '+' FAB    │
└──────────────────────────────────────┘     └──────────────────────────────────────┘
```

---

## 2. Precise Color Tokens & Shadow System

### 2.1 Color Tokens

| Token Name | Hex Value | Purpose |
| :--- | :--- | :--- |
| `scaffold-background` | `#FAF7F2` | Warm cream/sand canvas background |
| `card-surface` | `#FFFFFF` | Crisp pure white containers |
| `primary-coral` | `#FF5E3A` | Hero accent, active tabs, progress rings, FAB button |
| `primary-coral-light` | `#FFF0EB` | Light peach container for metric icon backgrounds |
| `accent-green` | `#22C55E` | "On Track" badge, positive deltas, SpO2 normal status |
| `accent-green-light` | `#DCFCE7` | Background container for green badges |
| `accent-blue` | `#0284C7` | Hydration icon, water tracking progress ring |
| `accent-blue-light` | `#E0F2FE` | Background container for hydration tiles |
| `accent-purple` | `#9333EA` | Sleep tracking icon, Goal Crusher badge |
| `accent-purple-light` | `#F3E8FF` | Background container for sleep tiles |
| `accent-pink` | `#FF4D6D` | Heart rate pulse icon |
| `accent-pink-light` | `#FFEBF0` | Background container for heart rate tiles |
| `text-headline` | `#1E252D` | Charcoal deep text for maximum clarity |
| `text-body` | `#6B7280` | Neutral gray for secondary descriptions and labels |
| `text-muted` | `#9CA3AF` | Light gray for dates, units, and inactive items |
| `border-subtle` | `#F0ECE4` | Hairline border for cards and dividers |

### 2.2 Elevation & Shadow Token
* **Primary Card Shadow:**
  ```css
  box-shadow: 0px 10px 30px rgba(0, 0, 0, 0.035), 0px 2px 8px rgba(0, 0, 0, 0.02);
  border-radius: 24px;
  ```
* **Floating Action Button (FAB) Glow:**
  ```css
  box-shadow: 0px 10px 25px rgba(255, 94, 58, 0.40);
  ```
* **Avatar Halo Glow:**
  ```css
  box-shadow: 0px 8px 24px rgba(255, 122, 69, 0.25);
  ```

---

## 3. Component-by-Component Specifications

### 3.1 Quick Metrics Grid (`QuickMetricsGrid`)
Four equal-width square/rectangular rounded tiles displaying current telemetry:
* **Dimensions:** Height: `100dp`, Width: Flexible (4-column row with `8dp` horizontal gap).
* **Card Style:** White background (`#FFFFFF`), `16dp` border radius, subtle border `#F0ECE4`.
* **Icon Pill:** `36 × 36dp` circle, light peach fill (`#FFF0EB`), center icon in primary coral (`#FF5E3A`).
* **Content:**
  * Top: Icon + Label (e.g. `Steps`, `Kcal Burn`, `Distance`, `Active T.`) in 11sp Medium text `#6B7280`.
  * Middle: Bold Value (e.g. `64,240`, `2,420`, `48.6`, `6h 45m`) in 16sp Bold text `#1E252D` (JetBrains Mono tabular).
  * Bottom: Subtitle (`last week` or `today`) in 10sp Regular text `#9CA3AF`.

---

### 3.2 Goal Progress Card (`GoalProgressCard`)
The centerpiece of the telemetry dashboard:
* **Card Container:** White background, `24dp` border radius, `18dp` internal padding.
* **Header:**
  * Left: Title `"Goal Progress"` (16sp SemiBold `#1E252D`).
  * Right: Action Link `"Edit goal"` (13sp Medium `#FF5E3A`).
* **Gauge & Progress Row:**
  * **Circular Progress Indicator:**
    * Diameter: `96dp`, Stroke Width: `10dp`.
    * Background Track: `#F3EFEA`.
    * Progress Arc: `#FF5E3A` with smooth rounded stroke cap (`StrokeCap.round`).
    * Center Label: `"82%"` (18sp Bold `#1E252D`).
  * **Metric Details Column:**
    * Title: `"step Goal"` (12sp Medium `#6B7280`).
    * Value: `"8,240/10,000 steps"` (16sp Bold `#1E252D`).
    * Badges Row:
      * **"On Track" Capsule:** `#DCFCE7` fill, `4dp` vertical / `10dp` horizontal padding, `11sp` SemiBold text in `#16A34A`.
      * **"1,760 steps Left" Capsule:** Shoe icon, `#FFF0EB` fill, `11sp` Medium text `#FF5E3A`.
      * **"6 Day Streak" Pill:** Flame icon, `#FFF0EB` fill, `11sp` Bold text `#FF5E3A`.
* **7-Day Weekday Selector Row:**
  * Horizontal row of 7 circular bubbles (`Sun`, `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`).
  * Each bubble contains:
    * Weekday label: `Sun` (11sp Regular `#6B7280`).
    * Completion circle: `34dp` circle.
    * Inactive/Past Days: White fill with thin border `#E5E7EB`, percentage text (e.g. `60%`, `70%`, `55%`).
    * Active/Selected Day (e.g. `Thu`): Solid Coral fill (`#FF5E3A`), white bold text (`97%`), soft coral drop shadow.

---

### 3.3 Health Overview Row (`HealthOverviewRow`)
Horizontal scroll or 4-tile row tracking holistic biometrics:
1. **Heart Rate:** Pink heart icon (`#FF4D6D` in `#FFEBF0`), `78 bpm`, subtitle `"Heart Rate"`.
2. **Sleep:** Purple moon icon (`#9333EA` in `#F3E8FF`), `7h 30m`, subtitle `"Avg. sleep"`.
3. **Hydration:** Blue water droplet (`#0284C7` in `#E0F2FE`), `8 Glasses`, subtitle `"Hydration"`.
4. **SpO2:** Green lungs icon (`#16A34A` in `#DCFCE7`), `98%`, subtitle `"SpO2 Normal"`.

---

### 3.4 Bottom Navigation Bar with Floating Center Action Button
* **Dock Architecture:**
  * Height: `72dp` (plus safe area padding).
  * Surface: Pure white `#FFFFFF` with top edge radius `28dp` and subtle ambient shadow.
* **Items (5 Slots):**
  1. `Home` (Phosphor `house`)
  2. `Activity` (Phosphor `sneakerMove` or `barbell`)
  3. `[ Center Floating '+' Action Button ]`
  4. `Insights` (Phosphor `chartLineUp`, Active Coral `#FF5E3A`)
  5. `Profile` (Phosphor `user`)
* **Center Floating Action Button (FAB):**
  * Diameter: `58dp`.
  * Placement: Elevated `-20dp` above navigation bar plane.
  * Background: Linear Gradient from `#FF7043` to `#FF5722`.
  * Icon: White `+` (26dp stroke width).
  * Tap Action: Opens Quick Sheet:
    * 🏋️ **"Start Workout"**
    * 🥗 **"Log Meal / Barcode"**
    * 💧 **"Log Water (250ml)"**
    * 🔄 **"Sync Health Connect"**

---

### 3.5 Profile Screen Architecture

1. **Top Bar:** Settings gear (`gear`), Title `"Profile"`, Share (`shareNetwork`), Bell (`bell`).
2. **User Profile Card:**
   * Outer avatar circle (`88dp` diameter) with soft radial peach halo glow.
   * Edit pencil floating badge at bottom-right of avatar (`#FF5E3A` circle with white pencil).
   * Athlete Name: `"M, Rabbi rezwan"` + Verified Orange Checkmark badge (`sealCheck`).
   * Bio: `"Improving every day."`.
   * Location Pill: `"📍 New York, USA"`.
   * Biological Gender Symbol: `"♂"` / `"♀"` (used for BMR Mifflin-St Jeor calculation).
3. **Active Member & Level Card:**
   * Left: Crown icon + `"Active Member Since Jan 2024"`.
   * Right: Hexagonal Level Badge + `"Level 12 • 3,200/5,000 XP"` with smooth horizontal progress bar.
4. **Goal Overview Multi-Metric Card:**
   * Left: `"6 Day Streak"` with prominent flame icon and 7-dot weekday status (`S M T W T F S`).
   * Right: Three concentric or adjacent progress rings:
     * **Move:** `82%` (Flame icon, Coral)
     * **Exercise:** `70%` (Figure icon, Mint Green)
     * **Hydration:** `75%` (Droplet icon, Sky Blue)
5. **Achievements Section:**
   * Section Header: `"Achievements"` with `"View All"` link.
   * Row of 5 Hexagonal Badges:
     1. `6 Days Streak` (Orange flame glyph)
     2. `10k Steps` (Green athletic shoe glyph)
     3. `Hydration Hero` (Blue water droplet glyph)
     4. `Goal Crusher` (Purple target glyph)
     5. `2 Weeks Streak` (Locked gray padlock glyph `#9CA3AF`)
6. **Personal Bests Card:**
   * Section Header: `"Personal Bests"` with `"View All"` link.
   * Displays all-time 1RM PRs (e.g., Bench Press: 100 kg, Squat: 140 kg, Deadlift: 180 kg).

---

## 4. Flutter Widget Code Mapping

```dart
// Core theme data mapping the reference UI
class FitTrackrTheme {
  static const Color scaffoldBg = Color(0xFFFAF7F2);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color primaryCoral = Color(0xFFFF5E3A);
  static const Color primaryCoralLight = Color(0xFFFFF0EB);
  static const Color textHeadline = Color(0xFF1E252D);
  static const Color textBody = Color(0xFF6B7280);
  
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardSurface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFF0ECE4), width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x09000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );
}
```
