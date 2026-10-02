# FitTrackr App Icon, Vector Art, Typography & Animation Asset Specification

**Document Version:** 1.0.0-PROD  
**Target Platform:** Android 15 Adaptive Icons, Dynamic Themed Icons & Flutter Assets  
**Primary Icon Asset:** `assets/branding/app_icon.png`  

---

## 1. App Icon Concept & Visual Architecture

The FitTrackr app icon embodies high-performance athletic technology. It combines three core fitness symbols into a singular geometric glyph:
1. **The Dynamic Runner:** Represents movement, cardio, and step telemetry.
2. **The Electrocardiogram Pulse:** Represents biometrics, heart rate, and cardiovascular vitality.
3. **The Athletic Track Loop:** Represents structured workouts, consistency, and daily habits.

### Rendered Master Visual Reference

![FitTrackr Master Icon](/Users/sourabhyadav/.gemini/antigravity-ide/brain/b35fe463-4492-4391-b5e5-a8afb0891f22/fittrackr_app_icon_1790768303371.jpg)

---

## 2. Android Adaptive & Themed Icon Specifications

Android 8.0+ requires **Adaptive Icons** ($108 \times 108\text{ dp}$ with a $72\text{ dp}$ safe zone mask). Android 13+ introduces **Themed/Monochrome Icons** that tint dynamically with the user's Material You wallpaper colors.

### 2.1 Directory Structure & Density Buckets
```
android/app/src/main/res/
├── mipmap-anydpi-v26/
│   ├── ic_launcher.xml
│   └── ic_launcher_round.xml
├── mipmap-mdpi/       # 48x48 px (legacy) / 108x108 px (adaptive)
├── mipmap-hdpi/       # 72x72 px / 162x162 px
├── mipmap-xhdpi/      # 96x96 px / 216x216 px
├── mipmap-xxhdpi/     # 144x144 px / 324x324 px
├── mipmap-xxxhdpi/    # 192x192 px / 432x432 px
└── drawable/
    ├── ic_launcher_background.xml
    ├── ic_launcher_foreground.xml
    └── ic_launcher_monochrome.xml
```

### 2.2 `mipmap-anydpi-v26/ic_launcher.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
```

### 2.3 `drawable/ic_launcher_background.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <!-- Deep obsidian athletic dark base -->
    <solid android:color="#0A0C0F" />
</shape>
```

### 2.4 Android 13+ Monochrome Vector (`drawable/ic_launcher_monochrome.xml`)
Single-color vector silhouette used by Android OS for Material You dynamic theming.

---

## 3. Android 12+ Splash Screen Specification

Utilizes `androidx.core:core-splashscreen:1.0.1` to ensure instantaneous cold boot without white flashes:

```xml
<!-- android/app/src/main/res/values/styles.xml -->
<resources>
    <style name="Theme.FitTrackr.Starting" parent="Theme.SplashScreen">
        <item name="windowSplashScreenBackground">#0A0C0F</item>
        <item name="windowSplashScreenAnimatedIcon">@drawable/splash_icon_animated</item>
        <item name="windowSplashScreenAnimationDuration">600</item>
        <item name="postSplashScreenTheme">@style/Theme.FitTrackr</item>
    </style>
</resources>
```

---

## 4. Typography Asset Manifest (`pubspec.yaml`)

FitTrackr utilizes **Plus Jakarta Sans** for UI legibility and **JetBrains Mono** for fixed-width telemetry:

```yaml
flutter:
  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700

    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

---

## 5. Micro-Interactions & Animation Library Manifest

FitTrackr integrates **Rive** (`rive: ^0.13.0`) for interactive vector state machines and **Lottie** (`lottie: ^3.1.0`) for lightweight celebratory bursts:

| Asset Name | Format | Trigger Event | Description |
| :--- | :--- | :--- | :--- |
| `assets/animations/set_check.riv` | Rive | User taps checkbox on completed set | Interactive checkmark draw with kinetic lime spark ripple |
| `assets/animations/rest_timer_pulse.riv` | Rive | Rest countdown timer active | Continuous ambient breathing ring shifting color at $T-10\text{s}$ |
| `assets/animations/goal_confetti.json` | Lottie | Step count crosses 10,000 | Subtle neon-lime confetti burst across the top app bar |
| `assets/animations/heart_sync.json` | Lottie | Pull-to-refresh Health Connect | Smooth rotational pulse wave indicating biometric sync |

---

## 6. Vector Iconography Mapping (`phosphor_flutter`)

| Action / Entity | Phosphor Icon Constant | Visual Meaning |
| :--- | :--- | :--- |
| Dashboard / Home | `PhosphorIconsRegular.gauge` | Central telemetry cockpit |
| Workout Plans | `PhosphorIconsRegular.barbell` | Strength training programs |
| Step Counter | `PhosphorIconsRegular.sneakerMove` | Locomotion & walking metrics |
| Analytics / Progress | `PhosphorIconsRegular.chartLineUp` | Longitudinal progression |
| Diet / Nutrition | `PhosphorIconsRegular.forkKnife` | Macronutrient fuel |
| Health Connect Active | `PhosphorIconsFill.heartbeat` | Two-way Samsung / Health sync |
| Rest Timer | `PhosphorIconsRegular.timer` | Interval recovery clock |
| Plate Calculator | `PhosphorIconsRegular.disc` | Barbell plate loading visualizer |

---

## v1.1 icon set

The launcher icon was redrawn to match the in-app coral brand: a white flame inside an activity ring on a coral gradient.

| Asset | Location |
|---|---|
| Source SVGs | `assets/branding/source/*.svg` |
| 1024 px master | `assets/branding/app_icon.png` |
| Play Store 512 px | `assets/branding/play_store_icon_512.png` |
| Legacy + round launcher PNGs | `android/app/src/main/res/mipmap-*/ic_launcher(_round).png` |
| Adaptive layers (foreground, background, monochrome) | `android/app/src/main/res/mipmap-*/ic_launcher_*.png`, `mipmap-anydpi-v26/*.xml` |
| Notification icon | `android/app/src/main/res/drawable-*/ic_stat_notify.png` |
| Splash logo | `android/app/src/main/res/drawable-nodpi/splash_logo.png` |
