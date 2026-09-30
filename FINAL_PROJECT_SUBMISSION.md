# FitTrackr — Final Project Submission Report

## Cross Platform Application Examination Submission

---

### Student Information
* **Full Name:** Sourabh Yadav
* **Cohort:** MZ
* **Roll Number:** 150096724013
* **Subject:** Cross Platform Application
* **Application Name:** Application Name 9 : FitTrackr
* **Problem Statement:** Problem Statement 59

---

### Key Project Links
1. **GitHub Repository:**  
   [https://github.com/YadavSourabhGH/FitTracker](https://github.com/YadavSourabhGH/FitTracker)
2. **Latest Production APK Release (GitHub Releases):**  
   [https://github.com/YadavSourabhGH/FitTracker/releases/tag/v1.0.0](https://github.com/YadavSourabhGH/FitTracker/releases/tag/v1.0.0)
3. **Figma UI/UX Design & User Journey Canvas:**  
   [https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1](https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1)

---

## Executive Summary & Problem Statement

### Problem Statement 59
> *Fitness users need to organize workouts, monitor daily steps, understand progress, and access diet suggestions. FitTrackr will consolidate these activities into a Flutter-based fitness tracking interface.*

### Project Overview
**FitTrackr** is an athletic-grade mobile fitness platform built using Flutter and Dart. It delivers a comprehensive user journey spanning workout discovery and live set tracking, real-time hardware pedometer telemetry, longitudinal progress analytics, and SQLite-backed nutritional tracking. 

Unlike typical prototype applications that rely on synthetic or fake mock data, **FitTrackr enforces a strict 100% real data invariant**:
* Real steps are measured live via Android’s native `Sensor.TYPE_STEP_COUNTER` hardware interrupt stream.
* Absent sensors (e.g. optical PPG heart rate or SpO2) display honest unmeasured state markers (`-`, `No Sensor`, `Unmeasured`) rather than fake numbers.
* Daily schedules dynamically adapt to the actual day of the week (`DateTime.now().weekday`).
* All user food logs, calories, and macronutrients persist in a local offline-first SQLite database (`sqflite`).

---

## Deliverables & Objectives Matrix

| Objective / Deliverable | Status | Implementation Details in FitTrackr |
|---|:---:|---|
| **Figma Design Journey** | **Completed** | Full multi-screen flow mapped in Figma: Dashboard $\rightarrow$ Workout Plan $\rightarrow$ Active Workout $\rightarrow$ Steps $\rightarrow$ Progress $\rightarrow$ Diet Suggestions. [View Figma](https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1). |
| **UI & Widgets** | **Completed** | Cards, Lists, ProgressIndicators, Arc gauges, Charts, Tabs, Category Filters, and custom convex floating navigation dock. |
| **Styling & Theming** | **Completed** | Material 3 design system with custom Warm Minimalist palette (`AppColors.primaryCoral`, `AppColors.charcoalCard`), clear activity states, Lucide vector icons, and responsive layouts. |
| **Dart/Flutter Logic** | **Completed** | Strongly typed models (`WorkoutModel`, `StepDataModel`, `NutritionItem`, `UserProfileModel`), Riverpod state management, dynamic streak logic, and real-time step calculations. |
| **Integration** | **Completed** | Android Hardware Pedometer (`ACTIVITY_RECOGNITION`), Android Health Connect bridge, and offline-first SQLite database (`sqflite`). |
| **Responsive Prototype** | **Completed** | Fully verified and deployed to physical hardware (Samsung Galaxy M35 5G, Android 14). Zero yellow/black overflow stripes. |
| **Code Modularity** | **Completed** | Every single Dart file in `lib/` is strictly under **200 lines**. Zero emojis in code or UI labels. |
| **Automated Testing** | **Completed** | 6/6 widget tests passing (100% pass rate). `flutter analyze` passes with 0 issues. |

---

## Complete User Journey & Screen Gallery

### 1. Fitness Dashboard
* **Screen Reference:** `screenshots/01_dashboard.png`
* **Features:**
  * Top branding header with left-aligned **FitTrackr** flame logo and native profile icon button.
  * Live greeting with real athlete name (`sourabh`) and current live step count.
  * Quick metric grid: Live Steps, Active Kcal, Distance (km), and Active Time (minutes).
  * Goal Progress Card with animated circular step completion arc and 7-day distribution bars.

### 2. Health Overview & AI Coach Insight
* **Screen Reference:** `screenshots/02_dashboard_scrolled.png`
* **Features:**
  * Health Overview row displaying honest telemetry cards (`Heart Rate: - bpm, No Sensor`, `Sleep: Unmeasured`, `Hydration: Goal 8`, `SpO2: -`).
  * Dynamic Coach Insight banner with sparkling AI icon, contextually generating coaching advice based on the actual weekday and recorded step progress.

### 3. Workout Plans & 7-Day Routine Schedule
* **Screen Reference:** `screenshots/03_workouts.png`
* **Features:**
  * Category filter chips: **All**, **Strength**, **HIIT & Cardio**, and **Yoga & Flexibility**.
  * Featured Hero Workout Plan card (`Push / Pull / Legs (PPL)`).
  * Full 7-Day Routine Schedule (Monday to Sunday) highlighting today's scheduled focus as "Today's Focus • Ready to start", past days as "Rest", and upcoming routines appropriately.

### 4. Structured Workout Detail & Exercise Blueprint
* **Screen Reference:** `screenshots/04_workout_detail.png`
* **Features:**
  * Comprehensive routine breakdown including target duration, difficulty level, and total exercises.
  * Multi-exercise list with target sets, rep ranges, and anatomical muscle focus (Barbell Bench Press, Incline Dumbbell Press, Overhead Barbell Press).

### 5. Interactive Workout Tracking Session
* **Screen Reference:** `screenshots/04b_active_workout.png`
* **Features:**
  * Active set tracking with dynamic exercise progress bar (e.g. Exercise 1 of 3, 0% Complete).
  * Live session timer, remaining duration, and estimated calories burned.
  * Interactive Set Logger allowing the athlete to increment/decrement reps, adjust load weight (kg), and trigger rest interval countdowns with haptic feedback.

### 6. Hardware Step Counter & Live Telemetry Gauge
* **Screen Reference:** `screenshots/05_step_counter.png`
* **Features:**
  * Large circular hero step gauge displaying real-time hardware pedometer sensor steps.
  * Secondary metric ribbon: Distance covered, active calories burned, elapsed walking time, and floor count.
  * Real-time sync button triggering Android hardware sensor event listener.

### 7. Hourly Intensity Analytics & Habit Streak Integrity
* **Screen Reference:** `screenshots/06_step_analytics.png`
* **Features:**
  * Live hourly cadence bar chart mapping activity intervals across the day (6a, 8a, 10a, 12p, 1p, 3p, 5p, 7p, 9p).
  * True step streak card indicating honest progress (`0 Day Streak` or active streak), today marked as `Now`, and true activity logged indicator.

### 8. Nutrition & Diet Suggestions
* **Screen Reference:** `screenshots/07_diet_suggestions.png`
* **Features:**
  * Filterable diet recommendation categories: **Muscle Gain**, **Fat Loss**, **Recovery**, and **Pre/Post-Workout**.
  * Detailed nutrition cards outlining science-based nutrient timing (e.g. Post-Workout Anabolic Window: 25-40g high-leucine protein).
  * Interactive healthy food chips with `+` icon for one-tap meal logging.

### 9. SQLite Calorie & Macro Meal Tracker
* **Screen Reference:** `screenshots/08_diet_tracker.png`
* **Features:**
  * Daily Calorie Card displaying consumed vs. remaining target calories (Target: 2,450 kcal).
  * Visual progress bars for daily macronutrients: Protein (g), Carbohydrates (g), and Fats (g).
  * Logged meals list powered by SQLite with instant item deletion and live calorie recalculation.

### 10. Athlete Profile & Achievements
* **Screen Reference:** `screenshots/09_profile.png`
* **Features:**
  * Verified athlete profile badge with athlete name (`sourabh`).
  * Gamified level & experience progression (Level 1, 0/1000 XP).
  * 7-day habit activity ring accurately reflecting daily goal fulfillment.
  * Milestone achievement badges (1 Day Streak, 10k Steps, Hydration Hero, Goal Crusher).
  * Personal best strength records (Bench Press, Back Squat, Deadlift).

---

## Technology Stack & Architecture

* **Framework:** Flutter 3.24+ / Dart 3.5+
* **Architecture:** Clean Architecture (Presentation, Domain, Data)
* **State Management:** Flutter Riverpod 2.5
* **Local Database:** SQLite via `sqflite` (Offline-first persistence)
* **Sensor Integration:** Native Android Pedometer (`Sensor.TYPE_STEP_COUNTER`) & Health Connect Bridge
* **Typography & Icons:** Inter / Outfit fonts with `lucide_icons_flutter` vector pack
* **Target Platforms:** Android 14+ (API 34, tested on Samsung One UI 6.1)

---

## Physical Hardware Verification

* **Device:** Samsung Galaxy M35 5G (`SM-M356B`)
* **Device Serial:** `RZCX809T5VA`
* **Operating System:** Android 14 (One UI 6.1)
* **Sensor Verification:** Real-time step counter verified live with physical device movement (50 live steps registered).
* **Test Results:** 6/6 Widget Tests Passed (`100%`). 0 Static Analysis Warnings (`flutter analyze`).
* **APK Builds:**
  * Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
  * Production Release APK: `build/app/outputs/flutter-apk/app-release.apk` (55.4 MB)

---
*Submitted for Cross Platform Application Examination by Sourabh Yadav (Roll No: 150096724013, Cohort: MZ).*
