# FitTrackr (Application Name 9 — Problem Statement 59)

[![Platform](https://img.shields.io/badge/Platform-Flutter%20%7C%20Android-02569B?logo=flutter)](https://flutter.dev)
[![Figma](https://img.shields.io/badge/Figma-Design%20Prototype-F24E1E?logo=figma)](https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1)
[![GitHub Release](https://img.shields.io/badge/Release-v1.0.0%20APK-2ea44f?logo=github)](https://github.com/YadavSourabhGH/FitTracker/releases/latest)
[![Tests](https://img.shields.io/badge/Tests-100%25%20Passing-brightgreen)](https://github.com/YadavSourabhGH/FitTracker)
[![Data Integrity](https://img.shields.io/badge/Data%20Integrity-100%25%20Real%20Hardware%20Sensors-orange)](https://github.com/YadavSourabhGH/FitTracker)

> **FitTrackr** is an athletic-grade, offline-first native mobile fitness application developed in Flutter. Built to solve **Problem Statement 59**, it consolidates daily step tracking, structured workout execution, progress analytics, and nutritional meal logging into an intuitive, high-contrast Material 3 interface backed by real device hardware sensors and local SQLite persistence.

---

## Academic Submission Details

| Field | Details |
|---|---|
| **Student Name** | **Sourabh Yadav** |
| **Cohort** | **MZ** |
| **Roll Number** | **150096724013** |
| **Subject** | **Cross Platform Application** |
| **Application Name** | **FitTrackr** (Application Name 9) |
| **Problem Statement** | **Problem Statement 59** |
| **Figma Journey** | [Figma Design Canvas](https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1) |
| **GitHub Repository** | [https://github.com/YadavSourabhGH/FitTracker](https://github.com/YadavSourabhGH/FitTracker) |
| **Latest APK Release** | [FitTrackr v1.0.0 Release (APK)](https://github.com/YadavSourabhGH/FitTracker/releases/latest) |

---

## Problem Statement 59 Overview

### Problem Statement
Fitness users need to organize workouts, monitor daily steps, understand progress, and access diet suggestions. FitTrackr consolidates these activities into a Flutter-based fitness tracking interface.

### Objectives
* **UI/Widgets**: Build fitness dashboard, workout plans, workout detail, step counter, progress charts, and diet suggestions screens. Utilize Cards, Lists, ProgressIndicators, Charts, Tabs, Filters, and custom floating navigation dock.
* **Styling/Theming**: Apply Material 3 with a fitness-oriented information hierarchy, clear activity/progress states, readable typography, spacing, Lucide icons, and responsive dashboard layouts.
* **Dart/Flutter Logic**: Create models for workouts, steps, progress, and diet suggestions; implement workout completion, step totals, progress calculations, chart data preparation, state handling via Riverpod, and navigation.
* **Figma**: Design and translate the complete user journey from:
  $$\text{Fitness Dashboard} \longrightarrow \text{Workout Plan} \longrightarrow \text{Workout Tracking} \longrightarrow \text{Steps} \longrightarrow \text{Progress Charts} \longrightarrow \text{Diet Suggestions}$$

### Outcomes & Deliverables
* **Functional Flutter Prototype**: Demonstrating the complete end-to-end fitness workflow on physical Android hardware (Samsung Galaxy M35 5G).
* **Maintainable Architecture**: Every Dart file in `lib/` strictly adheres to $\le 200$ lines, zero emojis, and clean separation of Presentation, Domain, and Data layers.
* **100% Real Data Invariant**: Zero fake/simulated numbers. Step counts bind directly to `Sensor.TYPE_STEP_COUNTER` via Android Pedometer. Missing hardware metrics honestly display unmeasured indicators (`-`, `No Sensor`, `Unmeasured`) instead of hardcoded numbers.
* **Local Persistence**: SQLite database (`sqflite`) for offline logging of custom meal items, macro distribution, and workout completion history.

---

## App Screens & Visual Gallery

| 01. Dashboard Overview | 02. Health & AI Coach | 03. Workout Plans & Schedule |
|:---:|:---:|:---:|
| <img src="screenshots/01_dashboard.png" width="260" alt="Dashboard" /> | <img src="screenshots/02_dashboard_scrolled.png" width="260" alt="Health & Coach" /> | <img src="screenshots/03_workouts.png" width="260" alt="Workouts" /> |
| *Real-time step counter, daily metric cards, Goal progress arc* | *Honest telemetry markers (`- bpm`, `No Sensor`), Dynamic Thursday Coach Insight* | *Dynamic 7-day routine highlighting today's workout and category chips* |

| 04. Workout Detail | 04b. Interactive Workout Session | 05. Step Counter Gauge |
|:---:|:---:|:---:|
| <img src="screenshots/04_workout_detail.png" width="260" alt="Workout Detail" /> | <img src="screenshots/04b_active_workout.png" width="260" alt="Active Workout" /> | <img src="screenshots/05_step_counter.png" width="260" alt="Step Counter" /> |
| *Exercise breakdown with target sets, reps, muscle focus, and duration* | *Interactive set tracker with rest timer, live effort logger, and biomechanical cues* | *Live cadence dial, real hardware steps, active distance, and energy expenditure* |

| 06. Hourly Intensity Analytics | 07. Diet Suggestions | 08. SQLite Meal Tracker |
|:---:|:---:|:---:|
| <img src="screenshots/06_step_analytics.png" width="260" alt="Step Analytics" /> | <img src="screenshots/07_diet_suggestions.png" width="260" alt="Diet Suggestions" /> | <img src="screenshots/08_diet_tracker.png" width="260" alt="Diet Tracker" /> |
| *Dynamic hourly distribution chart and true day streak verification* | *Goal-based nutrition recommendations with responsive food chips* | *Daily calorie consumption, live macro breakdown (Protein, Carbs, Fat) & SQLite persistence* |

| 09. Athlete Profile & Achievements |
|:---:|
| <img src="screenshots/09_profile.png" width="260" alt="Athlete Profile" /> |
| *Verified athlete profile, true 7-day activity dots, level progression, and unlockable achievements* |

---

## Core Features & Implementation

### 1. Real Hardware Step Counter & Telemetry
* Integrates directly with Android's native hardware step sensor (`android.permission.ACTIVITY_RECOGNITION`).
* Live cadence display calculates real-time energy expenditure (Kcal) and distance (km) without simulated increments.
* When hardware sensors are absent on the device (e.g., optical SpO2 or PPG heart rate), the app cleanly presents honest state markers (`-`, `No Sensor`, `Unmeasured`).

### 2. Structured Workout Plans & Active Session Logger
* Categorized workout routines: **Strength**, **HIIT & Cardio**, and **Yoga & Flexibility**.
* Dynamic 7-day routine schedule automatically binds to `DateTime.now().weekday`, highlighting the current day's focus while marking past days as completed/rest and upcoming days accordingly.
* Full-screen active session tracker with real-time countdown timer, set-by-set weight/rep logger, and audio-haptic feedback.

### 3. Nutrition & Diet suggestions with SQLite Persistence
* Dual-tabbed nutrition hub:
  1. **Track Meals**: Real-time calorie budget (Consumed vs. Remaining) with dynamic progress bars for Protein, Carbohydrates, and Fats. Fully backed by local SQLite database (`nutrition_logs` table) with instant item insertion and deletion.
  2. **Diet Suggestions**: Goal-oriented suggestions for Muscle Gain, Fat Loss, and Recovery. Clicking any recommended food automatically queries the database and allows instant logging.

### 4. Athlete Profile & Milestone Achievements
* Athlete profile dynamically displays the user's name, XP progression, and personal lifting bests.
* 7-day habit ring accurately highlights today's activity status without artificial streak inflation.
* Hexagonal achievement badges for milestone recognition (10k Steps, Hydration Hero, Goal Crusher).

---

## Project Structure & Clean Architecture

Every single Dart file in `lib/` is strictly under **200 lines** of clean, decoupled code:

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # Coral, Slate, Charcoal tokens
│   │   ├── app_theme.dart             # Material 3 Theme config
│   │   └── app_typography.dart        # Inter / Outfit typography hierarchy
│   └── utils/
│       ├── date_time_util.dart        # Dynamic weekday and date formatters
│       ├── haptic_feedback_util.dart  # Native touch feedback
│       └── metric_formatter.dart      # Standard metric unit formatting
├── data/
│   ├── local/
│   │   └── database_helper.dart       # SQLite database initialization & migrations
│   ├── models/
│   │   ├── diet_suggestion_model.dart # Meal & nutritional recommendation models
│   │   ├── nutrition_item_model.dart  # Food and macronutrient data structure
│   │   ├── step_data_model.dart       # Pedometer cadence & daily goal models
│   │   ├── user_profile_model.dart    # Athlete level, streak, & achievement models
│   │   └── workout_model.dart         # Workout program & exercise models
│   └── repositories/
│       ├── nutrition_repository.dart  # SQLite CRUD for meals & calories
│       ├── profile_repository.dart    # User profile & goal state repository
│       ├── step_repository.dart       # Hardware pedometer stream & daily totals
│       └── workout_repository.dart    # Pre-seeded scientifically verified routines
└── presentation/
    ├── common_widgets/
    │   ├── fittrackr_header.dart      # Flush left-aligned header with user avatar
    │   └── floating_nav_bar.dart      # Floating pill dock with center action button
    ├── providers/
    │   ├── diet_providers.dart        # Nutrition & meal Riverpod providers
    │   ├── profile_providers.dart     # Athlete profile Riverpod providers
    │   ├── step_providers.dart        # Real-time hardware step Riverpod providers
    │   └── workout_providers.dart     # Workout tracking Riverpod providers
    └── screens/
        ├── dashboard/                 # Home dashboard screen & metric grids
        ├── diet/                      # Calorie tracker & diet suggestion views
        ├── insights/                  # Telemetry charts & coach insight banners
        ├── profile/                   # Athlete profile & achievement badges
        ├── steps/                     # Step telemetry screen & hourly intensity charts
        └── workouts/                  # Workout plan selector & active exercise session
```

---

## Verification & Quality Assurance

* **Flutter Static Analysis**: `flutter analyze` passes with **0 warnings / 0 errors**.
* **Automated Unit & Widget Tests**: `flutter test` executes with **100% pass rate (6/6 passing)**.
* **Strict Architecture Constraints**:
  - File Line Limit: $\le 200$ lines per file across all 40+ Dart files.
  - Zero Emojis: 0 emojis in code or UI labels; all visual symbols use `lucide_icons_flutter`.
* **Hardware Verified**: Tested and verified live on physical Android device:
  - **Device**: Samsung Galaxy M35 5G (`SM-M356B`)
  - **OS**: Android 14 (One UI 6.1)
  - **Hardware Sensor**: `Sensor.TYPE_STEP_COUNTER` live hardware interrupts.

---

## Installation & Setup Instructions

### Prerequisites
* Flutter SDK (3.24.0 or later)
* Android SDK 34 / Android Studio
* Java JDK 17 / 21

### Step 1: Clone the Repository
```bash
git clone https://github.com/YadavSourabhGH/FitTracker.git
cd FitTracker
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run Automated Tests
```bash
flutter test
```

### Step 4: Run on Connected Device
```bash
flutter run
```

### Step 5: Build Production Release APK
```bash
flutter build apk --release
```
The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Important Links

* **Figma Design Link**: [https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1](https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1)
* **GitHub Repository**: [https://github.com/YadavSourabhGH/FitTracker](https://github.com/YadavSourabhGH/FitTracker)
* **Latest GitHub Release (APK)**: [https://github.com/YadavSourabhGH/FitTracker/releases/latest](https://github.com/YadavSourabhGH/FitTracker/releases/latest)

---
*FitTrackr — Developed by Sourabh Yadav (Roll No: 150096724013, Cohort: MZ) for Cross Platform Application.*
