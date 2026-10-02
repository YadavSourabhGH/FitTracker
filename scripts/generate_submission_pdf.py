import os
import base64
import subprocess

def img_to_b64(path):
    with open(path, 'rb') as f:
        ext = os.path.splitext(path)[1].lower().replace('.', '')
        if ext == 'jpg':
            ext = 'jpeg'
        return f"data:image/{ext};base64,{base64.b64encode(f.read()).decode('utf-8')}"

# Load App Icon
app_icon_b64 = img_to_b64('assets/branding/app_icon.jpg')

# Load Screenshots
screenshots_dir = 'screenshots'
img_01_dashboard = img_to_b64(os.path.join(screenshots_dir, '01_dashboard.png'))
img_02_dashboard_scrolled = img_to_b64(os.path.join(screenshots_dir, '02_dashboard_scrolled.png'))
img_03_workouts = img_to_b64(os.path.join(screenshots_dir, '03_workouts.png'))
img_04_workout_detail = img_to_b64(os.path.join(screenshots_dir, '04_workout_detail.png'))
img_04b_active_workout = img_to_b64(os.path.join(screenshots_dir, '04b_active_workout.png'))
img_05_step_counter = img_to_b64(os.path.join(screenshots_dir, '05_step_counter.png'))
img_06_step_analytics = img_to_b64(os.path.join(screenshots_dir, '06_step_analytics.png'))
img_07_diet_suggestions = img_to_b64(os.path.join(screenshots_dir, '07_diet_suggestions.png'))
img_08_diet_tracker = img_to_b64(os.path.join(screenshots_dir, '08_diet_tracker.png'))
img_09_profile = img_to_b64(os.path.join(screenshots_dir, '09_profile.png'))

def make_header(page_title):
    return f"""
    <div class="page-header">
      <div class="hdr-left">FitTrackr &mdash; Cross Platform Application Project Report</div>
      <div class="hdr-right">{page_title}</div>
    </div>
    """

def make_footer(page_num, total_pages=10):
    return f"""
    <div class="page-footer">
      <div class="ftr-left">Sourabh Yadav &bull; Roll No: 150096724013 &bull; Cohort MZ</div>
      <div class="ftr-center">Hardware Target: Samsung Galaxy M35 5G</div>
      <div class="ftr-right">Page {page_num} of {total_pages}</div>
    </div>
    """

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>FitTrackr &mdash; Final Examination Project Report (Sourabh Yadav)</title>
<style>
  @page {{
    size: A4 portrait;
    margin: 0;
  }}
  * {{
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    color: #111827;
    background: #FFFFFF;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
    font-size: 8.8pt;
    line-height: 1.42;
  }}

  /* Exact A4 Page Container */
  .doc-page {{
    width: 210mm;
    height: 297mm;
    max-height: 297mm;
    box-sizing: border-box;
    padding: 13mm 16mm 11mm 16mm;
    page-break-after: always;
    page-break-inside: avoid;
    overflow: hidden;
    position: relative;
    background: #FFFFFF;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }}
  .doc-page:last-child {{
    page-break-after: auto;
  }}

  /* Academic Running Header & Footer */
  .page-header {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #111827;
    padding-bottom: 4px;
    margin-bottom: 10px;
    font-size: 7.5pt;
    color: #374151;
    text-transform: uppercase;
    letter-spacing: 0.6px;
  }}
  .hdr-left {{
    font-weight: 700;
  }}
  .hdr-right {{
    font-weight: 500;
    color: #6B7280;
  }}
  .page-footer {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #D1D5DB;
    padding-top: 4px;
    margin-top: 8px;
    font-size: 7.5pt;
    color: #4B5563;
  }}
  .ftr-right {{
    font-weight: 700;
    color: #111827;
  }}

  /* Headings */
  h1.doc-title {{
    font-size: 26pt;
    font-weight: 800;
    color: #111827;
    line-height: 1.15;
    letter-spacing: -0.5px;
    margin-bottom: 4px;
  }}
  h2.section-heading {{
    font-size: 12pt;
    font-weight: 800;
    color: #111827;
    border-bottom: 1px solid #E5E7EB;
    padding-bottom: 3px;
    margin-top: 8px;
    margin-bottom: 6px;
  }}
  h3.sub-heading {{
    font-size: 9.5pt;
    font-weight: 700;
    color: #1F2937;
    margin-top: 6px;
    margin-bottom: 3px;
  }}
  p {{
    color: #374151;
    margin-bottom: 6px;
    text-align: justify;
  }}
  p.lead {{
    font-size: 9.2pt;
    color: #1F2937;
    margin-bottom: 8px;
  }}

  /* Academic Tables */
  table.report-table {{
    width: 100%;
    border-collapse: collapse;
    margin: 6px 0 10px 0;
    font-size: 8pt;
  }}
  table.report-table th, table.report-table td {{
    border-top: 1px solid #E5E7EB;
    border-bottom: 1px solid #E5E7EB;
    padding: 5px 8px;
    text-align: left;
    vertical-align: top;
  }}
  table.report-table th {{
    border-top: 1.5px solid #111827;
    border-bottom: 1.5px solid #111827;
    background: #F9FAFB;
    color: #111827;
    font-weight: 700;
    font-size: 7.5pt;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }}
  table.report-table tr:last-child td {{
    border-bottom: 1.5px solid #111827;
  }}

  /* Formal Cover Page Layout */
  .cover-body {{
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
    padding: 4mm 0;
  }}
  .cover-header-block {{
    border-bottom: 2px solid #111827;
    padding-bottom: 14px;
    text-align: center;
  }}
  .inst-title {{
    font-size: 9pt;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: #4B5563;
    margin-bottom: 4px;
  }}
  .cover-logo-row {{
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 18px 0 12px 0;
  }}
  .cover-logo-img {{
    width: 64px;
    height: 64px;
    border-radius: 14px;
    border: 1px solid #D1D5DB;
  }}
  .cover-subject-tag {{
    font-size: 10.5pt;
    font-weight: 600;
    color: #374151;
    margin-bottom: 10px;
  }}
  .cover-summary-text {{
    font-size: 9pt;
    color: #4B5563;
    max-width: 620px;
    margin: 0 auto;
    line-height: 1.45;
  }}
  
  .dossier-grid {{
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin: 12px 0;
  }}
  .dossier-box {{
    border: 1px solid #D1D5DB;
    padding: 12px 14px;
    background: #FFFFFF;
  }}
  .dossier-title {{
    font-size: 8.5pt;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: #111827;
    border-bottom: 1px solid #E5E7EB;
    padding-bottom: 5px;
    margin-bottom: 8px;
  }}
  .dossier-row {{
    display: flex;
    justify-content: space-between;
    font-size: 8.2pt;
    padding: 3px 0;
  }}
  .d-label {{
    color: #6B7280;
    font-weight: 500;
  }}
  .d-value {{
    color: #111827;
    font-weight: 700;
  }}

  .links-table {{
    width: 100%;
    border-collapse: collapse;
    font-size: 8.2pt;
    margin: 10px 0;
  }}
  .links-table td {{
    padding: 6px 8px;
    border-top: 1px solid #E5E7EB;
    border-bottom: 1px solid #E5E7EB;
  }}
  .links-table tr:first-child td {{
    border-top: 1px solid #111827;
  }}
  .links-table tr:last-child td {{
    border-bottom: 1px solid #111827;
  }}
  .links-table a {{
    color: #1D4ED8;
    text-decoration: none;
    word-break: break-all;
  }}

  /* Architecture & Monospace Boxes */
  pre.terminal-box {{
    background: #F9FAFB;
    border: 1px solid #D1D5DB;
    color: #111827;
    font-family: ui-monospace, Menlo, Monaco, Consolas, monospace;
    font-size: 7.2pt;
    line-height: 1.35;
    padding: 8px 10px;
    margin: 5px 0;
    border-radius: 4px;
  }}

  /* Screen Walkthrough Spreads (Pages 5 to 9) */
  .screen-spread {{
    display: flex;
    justify-content: space-between;
    gap: 20px;
    flex: 1;
    margin-top: 6px;
  }}
  .screen-col {{
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    background: #FFFFFF;
    padding: 2px 4px;
  }}
  .phone-frame {{
    border: 2px solid #1F2937;
    border-radius: 18px;
    padding: 2px;
    background: #000000;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    margin-bottom: 8px;
    display: inline-block;
  }}
  .phone-frame img {{
    height: 400px;
    width: auto;
    display: block;
    border-radius: 15px;
  }}
  .screen-details {{
    width: 100%;
    text-align: left;
  }}
  .fig-caption {{
    font-size: 8.5pt;
    font-weight: 700;
    color: #111827;
    margin-bottom: 2px;
  }}
  .fig-file {{
    font-family: ui-monospace, Menlo, Monaco, Consolas, monospace;
    font-size: 6.8pt;
    color: #6B7280;
    margin-bottom: 4px;
  }}
  .fig-text {{
    font-size: 7.6pt;
    color: #374151;
    line-height: 1.35;
    text-align: justify;
    margin-bottom: 4px;
  }}
  ul.fig-list {{
    margin-left: 14px;
    font-size: 7.3pt;
    color: #4B5563;
    line-height: 1.32;
  }}
  ul.fig-list li {{
    margin-bottom: 2px;
  }}

  /* Formal Declaration Block */
  .declaration-block {{
    border: 1px solid #111827;
    padding: 10px 14px;
    margin-top: 8px;
    background: #F9FAFB;
  }}
  .declaration-block h4 {{
    font-size: 8.5pt;
    font-weight: 800;
    text-transform: uppercase;
    color: #111827;
    margin-bottom: 4px;
    letter-spacing: 0.5px;
  }}
  .declaration-block p {{
    font-size: 7.8pt;
    color: #374151;
    margin-bottom: 8px;
    line-height: 1.4;
  }}
  .sig-grid {{
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    gap: 8px;
    border-top: 1px solid #D1D5DB;
    padding-top: 6px;
    font-size: 7.5pt;
  }}
  .sig-lbl {{
    color: #6B7280;
  }}
  .sig-val {{
    font-weight: 700;
    color: #111827;
  }}
</style>
</head>
<body>

<!-- ========================================== -->
<!-- PAGE 1: FORMAL EXAMINATION TITLE & COVER -->
<!-- ========================================== -->
<div class="doc-page">
  <div class="cover-body">
    <div class="cover-header-block">
      <div class="inst-title">Cross Platform Application &bull; Project Examination Report</div>
      <div class="cover-logo-row">
        <img src="{app_icon_b64}" class="cover-logo-img" alt="FitTrackr Icon">
      </div>
      <h1 class="doc-title">FitTrackr</h1>
      <div class="cover-subject-tag">A Cross-Platform Mobile Fitness and Activity Tracking Application</div>
      <p class="cover-summary-text">
        Implementation report submitted for Problem Statement 59, presenting the design, software architecture, native hardware pedometer integration, and offline data persistence of the FitTrackr platform built with Flutter, Riverpod, and SQLite.
      </p>
    </div>

    <!-- Candidate & Project Dossier -->
    <div class="dossier-grid">
      <div class="dossier-box">
        <div class="dossier-title">Candidate Information</div>
        <div class="dossier-row"><span class="d-label">Full Name:</span><span class="d-value">Sourabh Yadav</span></div>
        <div class="dossier-row"><span class="d-label">Roll Number:</span><span class="d-value">150096724013</span></div>
        <div class="dossier-row"><span class="d-label">Academic Cohort:</span><span class="d-value">Cohort MZ</span></div>
        <div class="dossier-row"><span class="d-label">Course Subject:</span><span class="d-value">Cross Platform Application</span></div>
        <div class="dossier-row"><span class="d-label">Academic Year:</span><span class="d-value">2026 &ndash; 2027</span></div>
      </div>
      <div class="dossier-box">
        <div class="dossier-title">Project & System Details</div>
        <div class="dossier-row"><span class="d-label">Application:</span><span class="d-value">Application 9 &mdash; FitTrackr</span></div>
        <div class="dossier-row"><span class="d-label">Problem Statement:</span><span class="d-value">Problem Statement 59</span></div>
        <div class="dossier-row"><span class="d-label">Target Hardware:</span><span class="d-value">Samsung Galaxy M35 5G</span></div>
        <div class="dossier-row"><span class="d-label">Operating System:</span><span class="d-value">Android 14 (One UI 6.1)</span></div>
        <div class="dossier-row"><span class="d-label">Release Artifact:</span><span class="d-value">v1.0.0 (Production Release APK)</span></div>
      </div>
    </div>

    <!-- Deliverables Links Table -->
    <div>
      <h3 class="sub-heading" style="font-size: 8.5pt; text-transform: uppercase; letter-spacing: 0.5px;">Deliverable Links & Verification References</h3>
      <table class="links-table">
        <tbody>
          <tr>
            <td style="width: 25%; font-weight: 700;">GitHub Repository</td>
            <td style="width: 75%;"><a href="https://github.com/YadavSourabhGH/FitTracker">https://github.com/YadavSourabhGH/FitTracker</a></td>
          </tr>
          <tr>
            <td style="font-weight: 700;">Production APK</td>
            <td><a href="https://github.com/YadavSourabhGH/FitTracker/releases/tag/v1.0.0">https://github.com/YadavSourabhGH/FitTracker/releases/tag/v1.0.0</a></td>
          </tr>
          <tr>
            <td style="font-weight: 700;">Figma User Journey</td>
            <td><a href="https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1">https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr</a></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div style="border-top: 1px solid #111827; padding-top: 8px; font-size: 7.8pt; color: #4B5563; display: flex; justify-content: space-between;">
      <span>Verified on Physical Android Device (Serial: RZCX809T5VA)</span>
      <span>Automated Tests: 6/6 Passed</span>
      <span>Static Analysis: 0 Warnings</span>
    </div>
  </div>
</div>

<!-- ========================================== -->
<!-- PAGE 2: INTRODUCTION & PROBLEM STATEMENT -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("1. Introduction & Requirements")}
  <div style="flex: 1;">
    <h2 class="section-heading">1. Introduction & Problem Statement</h2>
    <p class="lead">
      This document presents the implementation of <strong>FitTrackr</strong>, developed to satisfy the requirements of <strong>Problem Statement 59</strong> for the Cross Platform Application course examination.
    </p>

    <h3 class="sub-heading">1.1 Background and Objectives</h3>
    <p>
      In daily fitness routines, users typically switch between several different apps: one app for logging weightlifting sets, another for counting daily walking steps, a third for viewing weekly progress charts, and yet another for meal tracking. This fragmentation creates unnecessary friction and frequently causes users to abandon their habits.
    </p>
    <p>
      Problem Statement 59 specifies the creation of a unified cross-platform mobile application in Flutter that consolidates these distinct activities into a clean, cohesive user interface. The primary objective is to deliver a practical fitness tool where a user can browse structured workout routines, log live sets, monitor real hardware steps, view longitudinal habit streaks, and manage daily calories in one place.
    </p>

    <h3 class="sub-heading">1.2 Core Development Principles</h3>
    <p>
      To ensure the application functions as a real-world software product rather than a cosmetic prototype, the following principles were strictly followed during development:
    </p>
    <ul style="margin-left: 18px; margin-bottom: 8px; font-size: 8pt; color: #374151; line-height: 1.4;">
      <li style="margin-bottom: 4px;">
        <strong>Real Sensor Telemetry:</strong> The application does not use mock random number generators or artificial timers to simulate steps. All step data comes directly from Android's hardware step sensor (<code>Sensor.TYPE_STEP_COUNTER</code>). For biometrics not supported on the physical test device (such as optical heart rate or blood oxygen), the UI explicitly shows that the sensor is absent rather than inventing fake readings.
      </li>
      <li style="margin-bottom: 4px;">
        <strong>Sports Science Terminology:</strong> Workout tracking adheres to standard training terminology: exercise sets, rep ranges, rest intervals, and total volume load (Weight &times; Reps). Nutrition tracking uses standard macronutrient calculations (grams of protein, carbohydrates, and fats) and calorie budgets.
      </li>
      <li style="margin-bottom: 4px;">
        <strong>Strict Modularity:</strong> Every single Dart source file in <code>lib/</code> is kept under 200 lines to maintain clean separation of concerns and avoid monolithic files. In addition, no emojis are used in the codebase or UI, relying instead on clean vector icons from the <code>lucide_icons_flutter</code> package.
      </li>
    </ul>

    <h3 class="sub-heading">1.3 Requirements & Deliverables Matrix</h3>
    <table class="report-table">
      <thead>
        <tr>
          <th style="width: 22%;">Area</th>
          <th style="width: 58%;">Specification Requirements</th>
          <th style="width: 20%;">Implementation Status</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>UI & Widgets</strong></td>
          <td>Fitness dashboard, workout plans, workout detail, step counter, progress charts, and diet suggestions screens with responsive Material 3 layout.</td>
          <td>Completed (6 Screens)</td>
        </tr>
        <tr>
          <td><strong>Styling & Theme</strong></td>
          <td>Clean typography, warm minimalist color palette, Lucide vector icons, and zero layout overflow on target physical displays.</td>
          <td>Completed (0 Overflows)</td>
        </tr>
        <tr>
          <td><strong>Application Logic</strong></td>
          <td>Strongly typed data models, Riverpod state management, dynamic weekday schedule adaptation, and real-time step calculations.</td>
          <td>Completed (Riverpod 2.5)</td>
        </tr>
        <tr>
          <td><strong>Figma Journey</strong></td>
          <td>Translate 6-stage user journey from Figma design canvas into fully functioning Flutter views.</td>
          <td>Completed (Exact Match)</td>
        </tr>
        <tr>
          <td><strong>Device Integration</strong></td>
          <td>Integration with physical Android hardware pedometer, Health Connect bridge, and offline SQLite local storage.</td>
          <td>Completed (Physical Test)</td>
        </tr>
        <tr>
          <td><strong>Quality Assurance</strong></td>
          <td>Automated widget test suite, clean static analysis (<code>flutter analyze</code>), and release build verification on Android 14.</td>
          <td>Completed (6/6 Tests Pass)</td>
        </tr>
      </tbody>
    </table>
  </div>
  {make_footer(2)}
</div>

<!-- ========================================== -->
<!-- PAGE 3: SYSTEM ARCHITECTURE & DESIGN -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("2. Architecture & Design")}
  <div style="flex: 1;">
    <h2 class="section-heading">2. System Architecture & Engineering Design</h2>
    <p class="lead">
      FitTrackr is structured using Clean Architecture principles to keep user interface code decoupled from business logic, database storage, and Android native platform channels.
    </p>

    <h3 class="sub-heading">2.1 Layered Architecture Overview</h3>
    <p>
      The codebase is separated into three distinct layers with unidirectional data flow. This structure ensures that UI components never directly execute SQL queries or interact with hardware sensors:
    </p>
    <ul style="margin-left: 18px; margin-bottom: 6px; font-size: 8pt; color: #374151; line-height: 1.38;">
      <li><strong>Presentation Layer:</strong> Stateless and Consumer widgets written in Flutter. State is observed through Riverpod 2.5 <code>AsyncNotifierProvider</code> instances. User interactions trigger methods on the notifiers, which handle asynchronous operations and update the UI reactively.</li>
      <li><strong>Domain Layer:</strong> Pure Dart data classes and abstract repository contracts. Contains core models (such as <code>WorkoutModel</code>, <code>StepDataModel</code>, and <code>NutritionItem</code>) without any framework-specific dependencies.</li>
      <li><strong>Data Layer:</strong> Concrete repository implementations managing on-device persistence via SQLite (<code>sqflite</code>) and hardware sensor streaming through native Kotlin method and event channels.</li>
    </ul>

    <pre class="terminal-box">
+-------------------------------------------------------------------------+
|                           PRESENTATION LAYER                            |
|     Flutter Widgets  <--->  Riverpod 2.5 Notifiers (Unidirectional)     |
+------------------------------------+------------------------------------+
                                     | Dispatches Actions / Listens to State
                                     v
+-------------------------------------------------------------------------+
|                              DOMAIN LAYER                               |
|        Data Models & Entities  <--->  Abstract Repository Contracts     |
+------------------------------------+------------------------------------+
                                     | Implements Contracts
                                     v
+-------------------------------------------------------------------------+
|                               DATA LAYER                                |
|        SQLite Database (sqflite)  <--->  Platform Channel Services      |
+------------------------------------+------------------------------------+
                                     | Native Bridge
                                     v
+-------------------------------------------------------------------------+
|                      ANDROID NATIVE HARDWARE LAYER                      |
|      Sensor.TYPE_STEP_COUNTER  <--->  Health Connect Client API         |
+-------------------------------------------------------------------------+
    </pre>

    <h3 class="sub-heading">2.2 Directory Structure & Modularity Enforcement</h3>
    <p>
      To prevent code bloat, every file in <code>lib/</code> is strictly limited to 200 lines. Larger screens are split into separate sub-widgets and modular provider files:
    </p>
    <pre class="terminal-box" style="font-size: 6.8pt; line-height: 1.25;">
lib/
├── core/theme/         # AppColors.dart, AppTheme.dart, AppTypography.dart
├── core/utils/         # MetricFormatter.dart, HapticFeedbackUtil.dart, DateTimeUtil.dart
├── data/local/         # DatabaseHelper.dart (SQLite tables, CRUD queries, migrations)
├── data/models/        # WorkoutModel.dart, StepDataModel.dart, NutritionItem.dart, UserProfile.dart
├── data/repositories/  # WorkoutRepository.dart, StepRepository.dart, NutritionRepository.dart
├── data/services/      # PedometerService.dart, HealthConnectService.dart, DietService.dart
├── presentation/common/# FitTrackrHeader.dart, FloatingNavBar.dart, CircularCadenceGauge.dart
├── presentation/prov/  # StepProviders.dart, WorkoutProviders.dart, DietProviders.dart
└── presentation/screens# DashboardScreen, WorkoutsScreen, DetailScreen, ActiveWorkout, Steps, Diet, Profile
    </pre>

    <h3 class="sub-heading">2.3 State Management with Riverpod</h3>
    <p>
      FitTrackr uses Flutter Riverpod 2.5 with code-generation-free providers. Asynchronous operations (like querying SQLite for today's meals or subscribing to native sensor events) return <code>AsyncValue</code> streams. This provides built-in handling of loading, error, and data states across all screens.
    </p>
  </div>
  {make_footer(3)}
</div>

<!-- ========================================== -->
<!-- PAGE 4: DATA STORAGE & SENSORS -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("3. Data Storage & Sensors")}
  <div style="flex: 1;">
    <h2 class="section-heading">3. Data Storage, Sensors & Platform Integration</h2>
    <p class="lead">
      Technical details of the local SQLite relational database schema, the native Android hardware step counter listener, and the reboot compensation algorithm.
    </p>

    <h3 class="sub-heading">3.1 Local Offline SQLite Storage (sqflite)</h3>
    <p>
      A fitness tracker must remain fully functional when the user is offline (such as in an underground gym or during an outdoor run without mobile data). FitTrackr uses SQLite via <code>sqflite</code> as its single source of truth:
    </p>
    <table class="report-table">
      <thead>
        <tr>
          <th style="width: 24%;">Table Name</th>
          <th style="width: 48%;">Purpose & Key Columns</th>
          <th style="width: 28%;">Relationships</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>workouts</code></td>
          <td>Pre-seeded training plans (id, title, category, difficulty, duration_mins, estimated_kcal).</td>
          <td>Primary key referenced by exercises</td>
        </tr>
        <tr>
          <td><code>workout_exercises</code></td>
          <td>Individual exercises within plans (id, workout_id, name, target_sets, target_reps, muscle_group).</td>
          <td>Foreign key &rarr; <code>workouts.id</code></td>
        </tr>
        <tr>
          <td><code>workout_sessions</code></td>
          <td>Live logged workouts (id, workout_id, start_time, end_time, total_volume_kg, completed_sets).</td>
          <td>Foreign key &rarr; <code>workouts.id</code></td>
        </tr>
        <tr>
          <td><code>step_history</code></td>
          <td>Timestamped hourly cadence samples and daily aggregates (id, date_str, hour_of_day, steps, distance_km).</td>
          <td>Indexed by date for rapid analytics</td>
        </tr>
        <tr>
          <td><code>nutrition_logs</code></td>
          <td>Logged food items (id, meal_type, food_name, calories, protein_g, carbs_g, fat_g, timestamp).</td>
          <td>Aggregated by date for daily budget</td>
        </tr>
      </tbody>
    </table>

    <h3 class="sub-heading">3.2 Hardware Step Counter Integration (Sensor.TYPE_STEP_COUNTER)</h3>
    <p>
      Android devices provide two different step sensors: <code>TYPE_STEP_DETECTOR</code> (which emits an interrupt on every individual step, waking the CPU each time) and <code>TYPE_STEP_COUNTER</code> (a low-power dedicated hardware register that counts steps continuously with minimal battery usage). FitTrackr connects exclusively to <code>TYPE_STEP_COUNTER</code>.
    </p>

    <h3 class="sub-heading">3.3 Handling Device Reboots (The Zero-Reset Problem)</h3>
    <p>
      A major technical hurdle with <code>TYPE_STEP_COUNTER</code> is that the hardware register returns total steps accumulated since the phone was last turned on, and resets to zero upon device reboot. If an app simply tracks raw differences, a reboot would cause the step count to drop or become negative.
    </p>
    <p>
      To solve this, FitTrackr implements a reboot offset tracking algorithm:
    </p>
    <pre class="terminal-box" style="margin: 4px 0;">
Formula: Daily_Steps = (Current_Sensor_Value - Midnight_Sensor_Value) + Sum_Of_Reboot_Offsets
    </pre>
    <p style="font-size: 7.8pt;">
      The app persists the last seen sensor reading. When a new reading is lower than the previous reading, a reboot has occurred. The system immediately captures the delta and adds it to the day's reboot offset accumulator, ensuring step continuity across restarts.
    </p>

    <h3 class="sub-heading">3.4 Sensor Availability and Biometrics</h3>
    <p>
      The test hardware (Samsung Galaxy M35 5G) does not contain photoplethysmography (PPG) optical sensors for heart rate or pulse oximetry (SpO2). FitTrackr rejects the practice of fabricating fake biometric numbers; instead, the UI clearly displays <code>- bpm / No Sensor</code> and <code>Unmeasured</code> to maintain data honesty.
    </p>
  </div>
  {make_footer(4)}
</div>

<!-- ========================================== -->
<!-- PAGE 5: VISUAL SPREAD 1 (SCREENS 01 & 02) -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("4.1 Dashboard & Biometrics Overview")}
  <div style="flex: 1; display: flex; flex-direction: column;">
    <h2 class="section-heading">4.1 Fitness Dashboard and Live Biometric Overview</h2>
    <p class="lead" style="margin-bottom: 4px;">
      Verified screens captured directly on the physical Samsung Galaxy M35 5G (Android 14 / One UI 6.1).
    </p>

    <div class="screen-spread">
      <!-- Screen 01 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_01_dashboard}" alt="Figure 1 Dashboard Screen">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 1: Main Fitness Dashboard</div>
          <div class="fig-file">lib/presentation/screens/dashboard_screen.dart</div>
          <p class="fig-text">
            The central home view provides an immediate snapshot of daily activity. The top header features the flame logo and greeting with the athlete's name (sourabh).
          </p>
          <ul class="fig-list">
            <li><strong>Live Hardware Steps:</strong> Displays 50 steps measured directly by the phone's physical sensor.</li>
            <li><strong>Metric Grid:</strong> Active calories (2 kcal), distance (0.0 km), and walking time (1 min).</li>
            <li><strong>Goal Progress Arc:</strong> Circular gauge visualizing progress toward the 7,000-step daily target.</li>
            <li><strong>Weekly Distribution:</strong> 7-day bar chart showing step consistency across the week.</li>
          </ul>
        </div>
      </div>

      <!-- Screen 02 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_02_dashboard_scrolled}" alt="Figure 2 Health Overview">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 2: Health Overview & Daily Coach</div>
          <div class="fig-file">lib/presentation/common_widgets/health_overview_card.dart</div>
          <p class="fig-text">
            Scrolling down reveals biometric cards and contextual coaching. The app displays honest unmeasured states where hardware sensors are physically absent.
          </p>
          <ul class="fig-list">
            <li><strong>Honest Biometrics:</strong> Heart Rate shows "- bpm / No Sensor"; Sleep shows "Unmeasured".</li>
            <li><strong>Hydration Tracker:</strong> Displays daily water intake target (Goal: 8 glasses).</li>
            <li><strong>Contextual Coach:</strong> Dynamically generates training advice based on the day of the week (Thursday).</li>
            <li><strong>Bottom Navigation:</strong> Floating dock with quick-access buttons for all primary sections.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  {make_footer(5)}
</div>

<!-- ========================================== -->
<!-- PAGE 6: VISUAL SPREAD 2 (SCREENS 03 & 04) -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("4.2 Workout Plans & Blueprints")}
  <div style="flex: 1; display: flex; flex-direction: column;">
    <h2 class="section-heading">4.2 Structured Workout Plans and Exercise Blueprints</h2>
    <p class="lead" style="margin-bottom: 4px;">
      Resistance routine catalog, dynamic 7-day workout schedule, and structured exercise blueprints.
    </p>

    <div class="screen-spread">
      <!-- Screen 03 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_03_workouts}" alt="Figure 3 Workout Plans">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 3: Workout Catalog & Weekly Schedule</div>
          <div class="fig-file">lib/presentation/screens/workout_screen.dart</div>
          <p class="fig-text">
            Allows users to discover structured training routines and inspect their current week's schedule.
          </p>
          <ul class="fig-list">
            <li><strong>Category Filter:</strong> Quick filters for All, Strength, HIIT & Cardio, and Yoga.</li>
            <li><strong>Featured Routine:</strong> Push / Pull / Legs (PPL) hero card with duration (60m) and calorie estimates.</li>
            <li><strong>Dynamic Weekly Routine:</strong> The schedule automatically highlights today's session while marking past days as rest.</li>
            <li><strong>Action Trigger:</strong> Direct "Start Workout" button launches the detailed blueprint view.</li>
          </ul>
        </div>
      </div>

      <!-- Screen 04 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_04_workout_detail}" alt="Figure 4 Workout Detail Blueprint">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 4: Workout Detail Blueprint</div>
          <div class="fig-file">lib/presentation/screens/workout_detail_screen.dart</div>
          <p class="fig-text">
            Provides a complete exercise blueprint before beginning a session, outlining sets, rep ranges, and anatomical targets.
          </p>
          <ul class="fig-list">
            <li><strong>Routine Header:</strong> Duration (60 mins), difficulty (Intermediate), and movement count (3 exercises).</li>
            <li><strong>Exercise Stack:</strong> Detailed breakdown of Barbell Bench Press, Incline Dumbbell Press, and Overhead Barbell Press.</li>
            <li><strong>Form Guidance:</strong> Info icon triggers setup tips and execution cues for each exercise.</li>
            <li><strong>Sticky CTA:</strong> High-contrast button at the bottom to initiate the live session logger.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  {make_footer(6)}
</div>

<!-- ========================================== -->
<!-- PAGE 7: VISUAL SPREAD 3 (SCREENS 05 & 06) -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("4.3 Active Session & Step Counter")}
  <div style="flex: 1; display: flex; flex-direction: column;">
    <h2 class="section-heading">4.3 Active Workout Session Logger and Step Counter Gauge</h2>
    <p class="lead" style="margin-bottom: 4px;">
      Interactive set logging during workouts and dedicated hardware pedometer tracking dial.
    </p>

    <div class="screen-spread">
      <!-- Screen 05 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_04b_active_workout}" alt="Figure 5 Active Workout Session">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 5: Active Workout Session Logger</div>
          <div class="fig-file">lib/presentation/screens/active_workout_screen.dart</div>
          <p class="fig-text">
            Guides the user through an ongoing workout with live timers, set counters, and weight load controls.
          </p>
          <ul class="fig-list">
            <li><strong>Session Timer:</strong> 60-minute countdown timer with estimated calories burned tracking.</li>
            <li><strong>Active Focus Card:</strong> Displays target muscle group (Chest) and exercise demonstration photo.</li>
            <li><strong>Set Logger:</strong> Interactive rep counter (6-8 reps) and load weight adjustment (16 kg).</li>
            <li><strong>Rest Interval:</strong> Countdown banner with tactile haptic feedback when the rest timer concludes.</li>
          </ul>
        </div>
      </div>

      <!-- Screen 06 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_05_step_counter}" alt="Figure 6 Step Counter Gauge">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 6: Hardware Step Counter Gauge</div>
          <div class="fig-file">lib/presentation/screens/step_counter_screen.dart</div>
          <p class="fig-text">
            Dedicated view for monitoring step cadence powered directly by the native Android pedometer interrupt stream.
          </p>
          <ul class="fig-list">
            <li><strong>Cadence Dial:</strong> Large circular dial showing 50 live footsteps taken toward the 7,000-step target.</li>
            <li><strong>Distance & Activity:</strong> Secondary indicators for distance (0.0 km), active kcal (2), and walking time (1 min).</li>
            <li><strong>Real-Time Sync:</strong> An interactive sync button allows manual polling of the Android sensor service.</li>
            <li><strong>Live Connection:</strong> Indicator confirms the hardware sensor listener is active in the background.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  {make_footer(7)}
</div>

<!-- ========================================== -->
<!-- PAGE 8: VISUAL SPREAD 4 (SCREENS 07 & 08) -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("4.4 Cadence Analytics & Diet Advice")}
  <div style="flex: 1; display: flex; flex-direction: column;">
    <h2 class="section-heading">4.4 Hourly Cadence Analytics and Nutritional Recommendations</h2>
    <p class="lead" style="margin-bottom: 4px;">
      Hourly cadence distribution analytics, true habit streaks, and science-based nutritional suggestions.
    </p>

    <div class="screen-spread">
      <!-- Screen 07 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_06_step_analytics}" alt="Figure 7 Step Analytics">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 7: Hourly Intensity & Streak Integrity</div>
          <div class="fig-file">lib/presentation/screens/step_analytics_view.dart</div>
          <p class="fig-text">
            Provides longitudinal activity data, breaking down daily walking cadence by time of day without artificial inflation.
          </p>
          <ul class="fig-list">
            <li><strong>Hourly Cadence:</strong> Bar histogram mapping step activity across daytime intervals (6a to 9p).</li>
            <li><strong>Honest Habit Streak:</strong> Correctly shows a 0-day streak on a fresh installation rather than fake progress.</li>
            <li><strong>Activity Status:</strong> Confirms 50 steps logged today with the current day highlighted as "Now".</li>
            <li><strong>Connection Status:</strong> Real-time indicator confirms the hardware pedometer background service is actively streaming.</li>
          </ul>
        </div>
      </div>

      <!-- Screen 08 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_07_diet_suggestions}" alt="Figure 8 Diet Suggestions">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 8: Nutritional Recommendations</div>
          <div class="fig-file">lib/presentation/screens/diet_suggestions_view.dart</div>
          <p class="fig-text">
            Offers goal-oriented dietary recommendations based on exercise science and nutrient timing principles.
          </p>
          <ul class="fig-list">
            <li><strong>Goal Filtering:</strong> Toggle filters for All, Muscle Gain, Fat Loss, and Recovery.</li>
            <li><strong>Post-Workout Window:</strong> Advises 25-40g high-leucine protein within 45 minutes of training.</li>
            <li><strong>Pre-Workout Timing:</strong> Suggests 30-50g complex carbohydrates for sustained energy.</li>
            <li><strong>One-Tap Logging:</strong> Tap the '+' icon next to any recommended food item to log it directly into SQLite.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  {make_footer(8)}
</div>

<!-- ========================================== -->
<!-- PAGE 9: VISUAL SPREAD 5 (SCREENS 09 & 10) -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("4.5 Calorie Tracker & Profile")}
  <div style="flex: 1; display: flex; flex-direction: column;">
    <h2 class="section-heading">4.5 Offline SQLite Calorie Tracker and Athlete Profile</h2>
    <p class="lead" style="margin-bottom: 4px;">
      SQLite daily calorie and macronutrient tracker, and the user profile with personal records.
    </p>

    <div class="screen-spread">
      <!-- Screen 09 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_08_diet_tracker}" alt="Figure 9 Diet Tracker">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 9: SQLite Calorie & Macro Tracker</div>
          <div class="fig-file">lib/presentation/screens/diet_tracker_view.dart</div>
          <p class="fig-text">
            An offline-first calorie budget tracker displaying consumed vs. remaining calories and macronutrient progress.
          </p>
          <ul class="fig-list">
            <li><strong>Daily Calorie Budget:</strong> Consumed (351 kcal) vs. Remaining (2,099 kcal) against a 2,450 kcal target.</li>
            <li><strong>Macronutrient Bars:</strong> Real-time progress bars for Protein (33g/180g), Carbs (29g/250g), and Fat (11g/70g).</li>
            <li><strong>Logged Meals List:</strong> Logged items (Apple, Greek Yogurt, Boiled Eggs) retrieved from local SQLite storage.</li>
            <li><strong>Instant Deletion:</strong> Tap the trash icon on any entry to remove it and immediately update remaining calories.</li>
          </ul>
        </div>
      </div>

      <!-- Screen 10 -->
      <div class="screen-col">
        <div class="phone-frame">
          <img src="{img_09_profile}" alt="Figure 10 Athlete Profile">
        </div>
        <div class="screen-details">
          <div class="fig-caption">Figure 10: Athlete Profile & Achievements</div>
          <div class="fig-file">lib/presentation/screens/profile_screen.dart</div>
          <p class="fig-text">
            Summarizes the user's overall fitness profile, milestone achievements, and personal strength records.
          </p>
          <ul class="fig-list">
            <li><strong>Profile Header:</strong> Verified username (sourabh) with status "Active Tracker".</li>
            <li><strong>Level Progression:</strong> Gamified level progress bar (Level 1, 0/1000 XP).</li>
            <li><strong>Achievement Badges:</strong> Milestones including 1 Day Streak, 10k Steps, Hydration Hero, and Goal Crusher.</li>
            <li><strong>Personal Bests:</strong> Core lift records: Bench Press (100 kg), Back Squat (140 kg), and Deadlift (180 kg).</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  {make_footer(9)}
</div>

<!-- ========================================== -->
<!-- PAGE 10: VERIFICATION & DECLARATION -->
<!-- ========================================== -->
<div class="doc-page">
  {make_header("5. Verification & Declaration")}
  <div style="flex: 1;">
    <h2 class="section-heading">5. Testing, Verification & Hardware Deployment</h2>
    <p class="lead">
      Empirical verification results from automated widget testing, static code analysis, and deployment to physical Android hardware.
    </p>

    <h3 class="sub-heading">5.1 Automated Testing & Code Quality Audit</h3>
    <table class="report-table">
      <thead>
        <tr>
          <th style="width: 25%;">Verification Check</th>
          <th style="width: 45%;">Benchmark / Specification Target</th>
          <th style="width: 18%;">Observed Result</th>
          <th style="width: 12%;">Status</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>Automated Widget Tests</strong></td>
          <td>Full test coverage of core widgets via <code>flutter test</code></td>
          <td>6 of 6 Passed (100%)</td>
          <td>Passed</td>
        </tr>
        <tr>
          <td><strong>Static Analysis</strong></td>
          <td>Strict analysis check via <code>flutter analyze</code></td>
          <td>0 warnings, 0 errors</td>
          <td>Passed</td>
        </tr>
        <tr>
          <td><strong>Modularity Limit</strong></td>
          <td>Maximum 200 lines per file across all <code>lib/</code> files</td>
          <td>0 violations (Avg: 95 lines)</td>
          <td>Passed</td>
        </tr>
        <tr>
          <td><strong>Iconography Rule</strong></td>
          <td>Zero emojis in code or UI; 100% Lucide vector icons</td>
          <td>100% vector icons</td>
          <td>Passed</td>
        </tr>
        <tr>
          <td><strong>Hardware Step Sensor</strong></td>
          <td>Native <code>Sensor.TYPE_STEP_COUNTER</code> registration</td>
          <td>50 live steps registered</td>
          <td>Passed</td>
        </tr>
        <tr>
          <td><strong>Release APK Build</strong></td>
          <td>Compiled and signed release binary</td>
          <td>52.79 MB Release APK</td>
          <td>Passed</td>
        </tr>
      </tbody>
    </table>

    <h3 class="sub-heading">5.2 Physical Hardware Testing Dossier</h3>
    <p>
      The application was deployed and verified directly on physical hardware rather than an emulator. The testing environment details are as follows:
    </p>
    <table class="report-table">
      <tbody>
        <tr>
          <td style="width: 30%; font-weight: 700;">Test Hardware Device</td>
          <td style="width: 70%;">Samsung Galaxy M35 5G (Model: SM-M356B)</td>
        </tr>
        <tr>
          <td style="font-weight: 700;">Physical Device Serial</td>
          <td>RZCX809T5VA</td>
        </tr>
        <tr>
          <td style="font-weight: 700;">Operating System</td>
          <td>Android 14 with One UI 6.1 (API Level 34)</td>
        </tr>
        <tr>
          <td style="font-weight: 700;">Sensor Verification</td>
          <td>Native pedometer successfully logged 50 physical footsteps during testing session.</td>
        </tr>
        <tr>
          <td style="font-weight: 700;">Release APK Artifact</td>
          <td>52.79 MB production release binary available on GitHub Releases (v1.0.0).</td>
        </tr>
      </tbody>
    </table>

    <!-- Formal Declaration Block -->
    <div class="declaration-block">
      <h4>Candidate Examination Declaration & Formal Sign-Off</h4>
      <p>
        I hereby solemnly declare that the <strong>FitTrackr</strong> application, technical design, architectural specifications, and source code presented in this report represent my own original work. The application has been fully implemented, tested, and verified on a physical Android device in accordance with all guidelines established under <strong>Problem Statement 59</strong>.
      </p>
      <div class="sig-grid">
        <div>
          <div class="sig-lbl">Candidate:</div>
          <div class="sig-val">Sourabh Yadav</div>
        </div>
        <div>
          <div class="sig-lbl">Roll Number:</div>
          <div class="sig-val">150096724013</div>
        </div>
        <div>
          <div class="sig-lbl">Cohort:</div>
          <div class="sig-val">MZ</div>
        </div>
        <div>
          <div class="sig-lbl">Date:</div>
          <div class="sig-val">October 2026</div>
        </div>
      </div>
    </div>
  </div>
  {make_footer(10)}
</div>

</body>
</html>
"""

# Update primary files
html_path = 'FitTrackr_Submission_Report.html'
with open(html_path, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"SUCCESS: Written refined HTML to {html_path} ({os.path.getsize(html_path)/(1024*1024):.2f} MB)")

pdf_path = 'FitTrackr_Submission_Report_Sourabh_Yadav_150096724013.pdf'
chrome_cmd = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '--headless=new',
    '--disable-gpu',
    f'--print-to-pdf={os.path.abspath(pdf_path)}',
    '--no-pdf-header-footer',
    os.path.abspath(html_path)
]

print("Compiling final PDF with Chrome headless...")
subprocess.run(chrome_cmd, capture_output=True, text=True)
print(f"SUCCESS: Generated PDF at {pdf_path} ({os.path.getsize(pdf_path)/(1024*1024):.2f} MB)")
