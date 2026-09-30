import os
import base64
import subprocess

def img_to_b64(path):
    with open(path, 'rb') as f:
        return f"data:image/png;base64,{base64.b64encode(f.read()).decode('utf-8')}"

screenshots_dir = 'screenshots'
img_dashboard = img_to_b64(os.path.join(screenshots_dir, '01_dashboard.png'))
img_dashboard_scrolled = img_to_b64(os.path.join(screenshots_dir, '02_dashboard_scrolled.png'))
img_workouts = img_to_b64(os.path.join(screenshots_dir, '03_workouts.png'))
img_workout_detail = img_to_b64(os.path.join(screenshots_dir, '04_workout_detail.png'))
img_active_workout = img_to_b64(os.path.join(screenshots_dir, '04b_active_workout.png'))
img_step_counter = img_to_b64(os.path.join(screenshots_dir, '05_step_counter.png'))
img_step_analytics = img_to_b64(os.path.join(screenshots_dir, '06_step_analytics.png'))
img_diet_suggestions = img_to_b64(os.path.join(screenshots_dir, '07_diet_suggestions.png'))
img_diet_tracker = img_to_b64(os.path.join(screenshots_dir, '08_diet_tracker.png'))
img_profile = img_to_b64(os.path.join(screenshots_dir, '09_profile.png'))

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>FitTrackr — Final Project Submission Report</title>
<style>
  @page {{
    size: A4;
    margin: 12mm 14mm 12mm 14mm;
  }}
  * {{
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: #241E1A;
    background: #FFFFFF;
    line-height: 1.4;
    font-size: 10pt;
  }}
  .page-break {{
    page-break-before: always;
  }}
  
  /* Cover Page */
  .cover-page {{
    padding: 30px 10px;
    text-align: center;
    height: 94vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }}
  .badge-header {{
    display: inline-block;
    background: #FFF1EC;
    color: #FF5F25;
    border: 1px solid #FFD3C4;
    padding: 5px 14px;
    border-radius: 16px;
    font-weight: 700;
    font-size: 10pt;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    margin-bottom: 16px;
  }}
  .cover-title {{
    font-size: 34pt;
    font-weight: 900;
    color: #FF5F25;
    letter-spacing: -1px;
    margin-bottom: 6px;
  }}
  .cover-subtitle {{
    font-size: 15pt;
    font-weight: 600;
    color: #554A44;
    margin-bottom: 16px;
  }}
  .cover-meta-card {{
    background: #FAF7F5;
    border: 1.5px solid #EFE8E2;
    border-radius: 14px;
    padding: 20px 24px;
    text-align: left;
    margin: 10px auto;
    max-width: 580px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.03);
  }}
  .meta-row {{
    display: flex;
    justify-content: space-between;
    padding: 6px 0;
    border-bottom: 1px solid #EAE3DE;
    font-size: 10.5pt;
  }}
  .meta-row:last-child {{
    border-bottom: none;
  }}
  .meta-label {{
    font-weight: 700;
    color: #7A6F68;
  }}
  .meta-val {{
    font-weight: 800;
    color: #1A1513;
  }}
  .links-box {{
    background: #FFF6F3;
    border: 1.5px dashed #FF8559;
    border-radius: 12px;
    padding: 14px 18px;
    text-align: left;
    max-width: 580px;
    margin: 10px auto;
  }}
  .links-box h4 {{
    color: #FF5F25;
    font-size: 11pt;
    margin-bottom: 6px;
  }}
  .link-item {{
    font-size: 9pt;
    margin: 3px 0;
    word-break: break-all;
  }}
  .link-item strong {{
    color: #241E1A;
  }}
  .link-item a {{
    color: #0366D6;
    text-decoration: none;
  }}
  
  /* Section Styles */
  h2.section-title {{
    font-size: 14pt;
    font-weight: 800;
    color: #1A1513;
    border-bottom: 2px solid #FF5F25;
    padding-bottom: 4px;
    margin-top: 10px;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
  }}
  h2.section-title span {{
    color: #FF5F25;
    margin-right: 6px;
  }}
  h3.subsection-title {{
    font-size: 11pt;
    font-weight: 700;
    color: #332B26;
    margin-top: 6px;
    margin-bottom: 4px;
  }}
  p {{
    margin-bottom: 6px;
    color: #423933;
    font-size: 9.5pt;
    line-height: 1.35;
  }}
  
  /* Tables */
  table.data-table {{
    width: 100%;
    border-collapse: collapse;
    margin: 6px 0 10px 0;
    font-size: 8.5pt;
  }}
  table.data-table th, table.data-table td {{
    border: 1px solid #E2DDD9;
    padding: 5px 8px;
    text-align: left;
  }}
  table.data-table th {{
    background: #FAF7F5;
    color: #1A1513;
    font-weight: 700;
  }}
  table.data-table tr:nth-child(even) {{
    background: #FCFBFA;
  }}
  .status-tag {{
    display: inline-block;
    background: #E6F8ED;
    color: #0E8038;
    padding: 1px 6px;
    border-radius: 4px;
    font-weight: 700;
    font-size: 7.5pt;
  }}
  
  /* Screenshot Gallery Grid */
  .gallery-grid {{
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-top: 8px;
  }}
  .screen-card {{
    background: #FAF7F5;
    border: 1px solid #E8E2DD;
    border-radius: 10px;
    padding: 8px;
    text-align: center;
  }}
  .screen-card img {{
    width: 100%;
    max-width: 210px;
    height: auto;
    border-radius: 8px;
    border: 1px solid #D8CFC8;
    box-shadow: 0 3px 8px rgba(0,0,0,0.05);
  }}
  .screen-caption {{
    margin-top: 6px;
    font-size: 9pt;
    font-weight: 700;
    color: #1A1513;
  }}
  .screen-subtext {{
    font-size: 8pt;
    color: #6B6058;
    margin-top: 1px;
  }}
  
  /* Feature List */
  ul.feat-list {{
    margin-left: 18px;
    margin-bottom: 8px;
    font-size: 9pt;
    color: #423933;
    line-height: 1.35;
  }}
  ul.feat-list li {{
    margin-bottom: 3px;
  }}
  
  /* Architecture Box */
  .arch-box {{
    background: #F4F1EE;
    border-left: 3.5px solid #FF5F25;
    padding: 8px 12px;
    border-radius: 0 6px 6px 0;
    margin: 6px 0 10px 0;
    font-size: 8pt;
    font-family: Menlo, Monaco, Consolas, monospace;
    line-height: 1.25;
  }}
</style>
</head>
<body>

<!-- PAGE 1: COVER PAGE -->
<div class="cover-page">
  <div>
    <div class="badge-header">Cross Platform Application — Examination Project Report</div>
    <h1 class="cover-title">FitTrackr</h1>
    <h3 class="cover-subtitle">Athletic-Grade Mobile Fitness & Activity Tracking Interface</h3>
    <p style="max-width: 580px; margin: 0 auto; color: #63564F; font-size: 10.5pt;">
      Consolidating structured workouts, real hardware pedometer step tracking, longitudinal progress analytics, and local SQLite nutrition logging into an athletic Material 3 interface.
    </p>
  </div>

  <div class="cover-meta-card">
    <div class="meta-row">
      <span class="meta-label">Student Name:</span>
      <span class="meta-val">Sourabh Yadav</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Roll Number:</span>
      <span class="meta-val">150096724013</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Cohort:</span>
      <span class="meta-val">MZ</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Subject:</span>
      <span class="meta-val">Cross Platform Application</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Application Name:</span>
      <span class="meta-val">Application Name 9 : FitTrackr</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Problem Statement:</span>
      <span class="meta-val">Problem Statement 59</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Hardware Deployment:</span>
      <span class="meta-val">Samsung Galaxy M35 5G (Android 14)</span>
    </div>
  </div>

  <div class="links-box">
    <h4>Official Project & Deliverable Links</h4>
    <div class="link-item">
      <strong>GitHub Code Repository:</strong><br>
      <a href="https://github.com/YadavSourabhGH/FitTracker">https://github.com/YadavSourabhGH/FitTracker</a>
    </div>
    <div class="link-item">
      <strong>Production APK Release (Direct Download):</strong><br>
      <a href="https://github.com/YadavSourabhGH/FitTracker/releases/tag/v1.0.0">https://github.com/YadavSourabhGH/FitTracker/releases/tag/v1.0.0</a>
    </div>
    <div class="link-item">
      <strong>Figma Design Journey:</strong><br>
      <a href="https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1">https://www.figma.com/design/CvAN8r31C30rYkGJ2VwJEt/FitTrackr?node-id=0-1&t=mEPQM2RSgdkH4C2Y-1</a>
    </div>
  </div>

  <div style="font-size: 8.5pt; color: #8A7E76; margin-top: 6px;">
    Submission Date: October 2026 • Verified on Physical Android Device (RZCX809T5VA)
  </div>
</div>

<!-- PAGE 2: PROBLEM STATEMENT & DELIVERABLES -->
<div class="page-break"></div>

<h2 class="section-title"><span>01</span> Problem Statement & Deliverables Analysis</h2>

<h3 class="subsection-title">Problem Statement 59</h3>
<p>
  <em>Fitness users need to organize workouts, monitor daily steps, understand progress, and access diet suggestions. FitTrackr will consolidate these activities into a Flutter-based fitness tracking interface.</em>
</p>

<table class="data-table">
  <thead>
    <tr>
      <th style="width: 22%;">Area</th>
      <th style="width: 60%;">Specification Requirements</th>
      <th style="width: 18%;">Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>UI / Widgets</strong></td>
      <td>Fitness dashboard, workout plans, workout detail, step counter, progress charts, and diet suggestions screens. Cards, Lists, ProgressIndicators, Charts, Tabs, Filters, and Navigation components.</td>
      <td><span class="status-tag">Completed</span></td>
    </tr>
    <tr>
      <td><strong>Styling / Theming</strong></td>
      <td>Material 3 theme with fitness information hierarchy, clear activity/progress states, readable typography, spacing, Lucide icons, and responsive layouts.</td>
      <td><span class="status-tag">Completed</span></td>
    </tr>
    <tr>
      <td><strong>Dart / Flutter Logic</strong></td>
      <td>Models for workouts, steps, progress, and diet suggestions; workout completion tracking, step aggregation, progress calculations, chart data preparation, Riverpod state handling, and navigation.</td>
      <td><span class="status-tag">Completed</span></td>
    </tr>
    <tr>
      <td><strong>Figma Journey</strong></td>
      <td>Translate user journey: Dashboard &rarr; Workout Plan &rarr; Workout Tracking &rarr; Steps &rarr; Progress Charts &rarr; Diet Suggestions.</td>
      <td><span class="status-tag">Completed</span></td>
    </tr>
    <tr>
      <td><strong>Device Integration</strong></td>
      <td>Hardware pedometer step sensor (<code>Sensor.TYPE_STEP_COUNTER</code>), Health Connect bridge, and offline-first SQLite database (<code>sqflite</code>).</td>
      <td><span class="status-tag">Completed</span></td>
    </tr>
    <tr>
      <td><strong>Data Invariant</strong></td>
      <td>100% real data; zero fake/simulated numbers. Honest state indicators (<code>- bpm</code>, <code>No Sensor</code>, <code>Unmeasured</code>) for absent hardware.</td>
      <td><span class="status-tag">Completed</span></td>
    </tr>
  </tbody>
</table>

<h2 class="section-title"><span>02</span> Technical Architecture & Engineering Constraints</h2>

<p>
  FitTrackr follows <strong>Clean Architecture</strong> principles, decoupling presentation, business logic, and local data persistence:
</p>

<ul class="feat-list">
  <li><strong>Presentation Layer:</strong> Modular, highly focused widgets. Every single Dart file in <code>lib/</code> is strictly <strong>&le; 200 lines</strong> (0 violations). Zero emojis in code or UI labels.</li>
  <li><strong>State Management:</strong> Powered by <strong>Flutter Riverpod 2.5</strong> with asynchronous notifier providers (<code>AsyncNotifierProvider</code>) handling hardware event streams and database updates.</li>
  <li><strong>Local Persistence:</strong> Offline-first SQLite database (<code>sqflite</code>) with custom schemas for <code>nutrition_logs</code>, daily calorie totals, workout plans, and step history.</li>
  <li><strong>Live Sensor Integration:</strong> Direct Android Hardware Pedometer listener with automatic zero-delta compensation and Health Connect sync capabilities.</li>
  <li><strong>Automated Quality Assurance:</strong> 100% widget test pass rate (6/6 passing tests) and 0 static analysis warnings (<code>flutter analyze</code>).</li>
</ul>

<div class="arch-box">
Project Architecture Tree (100% Modular &lt; 200 Lines)
lib/
├── core/theme/         (AppColors, AppTheme, AppTypography)
├── core/utils/         (MetricFormatter, HapticFeedbackUtil, DateTimeUtil)
├── data/local/         (DatabaseHelper, WorkoutSeedData)
├── data/models/        (WorkoutModel, StepDataModel, NutritionItem, UserProfileModel)
├── data/repositories/  (NutritionRepository, StepRepository, WorkoutRepository, ProfileRepository)
├── data/services/      (PedometerService, HealthConnectService, DietSuggestionService)
├── presentation/common_widgets/ (FitTrackrHeader, FloatingNavBar, CircularGauge)
├── presentation/providers/      (StepProviders, WorkoutProviders, DietProviders, ProfileProviders)
└── presentation/screens/        (Dashboard, Workouts, Steps, Diet, Profile, Onboarding)
</div>

<!-- PAGE 3: SCREENSHOT GALLERY - PART 1 -->
<div class="page-break"></div>

<h2 class="section-title"><span>03</span> Visual Gallery — Screens 1 to 4</h2>
<p>Screenshots captured live on physical hardware (Samsung Galaxy M35 5G, Android 14):</p>

<div class="gallery-grid">
  <div class="screen-card">
    <img src="{img_dashboard}" alt="01 Dashboard">
    <div class="screen-caption">01. Fitness Dashboard</div>
    <div class="screen-subtext">Flush left FitTrackr header, real live steps (50), active Kcal, distance, and animated step goal arc.</div>
  </div>
  <div class="screen-card">
    <img src="{img_dashboard_scrolled}" alt="02 Health and Coach">
    <div class="screen-caption">02. Health Overview & AI Coach</div>
    <div class="screen-subtext">Honest sensor telemetry (- bpm, No Sensor, Unmeasured), dynamic Thursday Coach Insight.</div>
  </div>
  <div class="screen-card">
    <img src="{img_workouts}" alt="03 Workouts">
    <div class="screen-caption">03. Workout Plans & Schedule</div>
    <div class="screen-subtext">Category chips (Strength, HIIT, Yoga), Hero PPL plan, and dynamic 7-day schedule highlighting today.</div>
  </div>
  <div class="screen-card">
    <img src="{img_workout_detail}" alt="04 Workout Detail">
    <div class="screen-caption">04. Workout Detail Blueprint</div>
    <div class="screen-subtext">Multi-set exercise blueprint with target sets, rep ranges, muscle activation cues, and session trigger.</div>
  </div>
</div>

<!-- PAGE 4: SCREENSHOT GALLERY - PART 2 -->
<div class="page-break"></div>

<h2 class="section-title"><span>04</span> Visual Gallery — Screens 5 to 8</h2>

<div class="gallery-grid">
  <div class="screen-card">
    <img src="{img_active_workout}" alt="04b Active Workout">
    <div class="screen-caption">05. Interactive Workout Session</div>
    <div class="screen-subtext">Live session countdown timer, interactive set & rep logger, weight load adjustment, and rest interval banner.</div>
  </div>
  <div class="screen-card">
    <img src="{img_step_counter}" alt="05 Step Counter">
    <div class="screen-caption">06. Hardware Step Counter Gauge</div>
    <div class="screen-subtext">Large circular cadence dial, real hardware pedometer steps, distance, active minutes, and sync button.</div>
  </div>
  <div class="screen-card">
    <img src="{img_step_analytics}" alt="06 Step Analytics">
    <div class="screen-caption">07. Hourly Intensity & Streak Integrity</div>
    <div class="screen-subtext">Real-time hourly cadence distribution chart and true day streak verification without synthetic data.</div>
  </div>
  <div class="screen-card">
    <img src="{img_diet_suggestions}" alt="07 Diet Suggestions">
    <div class="screen-caption">08. Nutritional Recommendations</div>
    <div class="screen-subtext">Goal-based nutrition recommendations (Muscle Gain, Fat Loss, Recovery) with one-tap food addition chips.</div>
  </div>
</div>

<!-- PAGE 5: SCREENSHOT GALLERY - PART 3 & VERIFICATION -->
<div class="page-break"></div>

<h2 class="section-title"><span>05</span> Visual Gallery — Screens 9 & 10</h2>

<div class="gallery-grid" style="margin-bottom: 12px;">
  <div class="screen-card">
    <img src="{img_diet_tracker}" alt="08 Diet Tracker">
    <div class="screen-caption">09. SQLite Calorie & Macro Tracker</div>
    <div class="screen-subtext">Daily calorie budget (Consumed vs. Remaining), Protein/Carb/Fat progress bars, and SQLite meal logging.</div>
  </div>
  <div class="screen-card">
    <img src="{img_profile}" alt="09 Profile">
    <div class="screen-caption">10. Athlete Profile & Achievements</div>
    <div class="screen-subtext">Verified athlete name (sourabh), 7-day habit dots, level progression, and unlockable achievement badges.</div>
  </div>
</div>

<h2 class="section-title"><span>06</span> Verification & Examination Checklist</h2>

<table class="data-table">
  <thead>
    <tr>
      <th>Verification Item</th>
      <th>Specification Metric</th>
      <th>Observed Result</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Static Analysis</strong></td>
      <td><code>flutter analyze</code></td>
      <td>0 warnings, 0 lints, 0 errors</td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
    <tr>
      <td><strong>Automated Tests</strong></td>
      <td><code>flutter test</code></td>
      <td>6 of 6 widget tests passed (100%)</td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
    <tr>
      <td><strong>File Line Limit</strong></td>
      <td>Max 200 lines per file</td>
      <td>0 files exceed 200 lines in <code>lib/</code></td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
    <tr>
      <td><strong>Zero Emojis</strong></td>
      <td>0 emojis in codebase</td>
      <td>100% replaced by Lucide vector icons</td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
    <tr>
      <td><strong>Hardware Sensor</strong></td>
      <td>Native Android Pedometer</td>
      <td>50 real hardware steps registered live</td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
    <tr>
      <td><strong>APK Build</strong></td>
      <td>Production Release APK</td>
      <td>52.79 MB APK deployed to GitHub Releases</td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
    <tr>
      <td><strong>Figma Match</strong></td>
      <td>6-screen full flow translation</td>
      <td>Exact Material 3 fidelity & palette</td>
      <td><span class="status-tag">PASS</span></td>
    </tr>
  </tbody>
</table>

<div style="margin-top: 10px; padding: 10px 14px; background: #FAF7F5; border: 1.5px solid #E2DDD9; border-radius: 10px; text-align: center;">
  <p style="font-weight: 700; color: #1A1513; margin-bottom: 2px; font-size: 9.5pt;">Candidate Sign-Off</p>
  <p style="font-size: 8.5pt; color: #554A44; margin: 0;">
    I certify that the FitTrackr application, documentation, and source code submitted herein are completely functional, verified on physical Android hardware, and adhere strictly to all guidelines of Problem Statement 59.
  </p>
  <p style="margin-top: 4px; font-weight: 800; color: #FF5F25; font-size: 9.5pt;">
    Sourabh Yadav • Roll No: 150096724013 • Cohort: MZ • Cross Platform Application
  </p>
</div>

</body>
</html>
"""

html_path = 'FitTrackr_Submission_Report.html'
with open(html_path, 'w', encoding='utf-8') as f:
    f.write(html_content)

pdf_path = 'FitTrackr_Submission_Report_Sourabh_Yadav_150096724013.pdf'
chrome_cmd = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '--headless',
    '--disable-gpu',
    f'--print-to-pdf={os.path.abspath(pdf_path)}',
    '--no-pdf-header-footer',
    os.path.abspath(html_path)
]

subprocess.run(chrome_cmd, capture_output=True, text=True)
print(f"SUCCESS: Generated PDF at {pdf_path} ({os.path.getsize(pdf_path)/(1024*1024):.2f} MB)")
