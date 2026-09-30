# FitTrackr Native Health Integration Guide: Health Connect, Samsung Health & Hardware Sensors

**Document Version:** 1.0.0-PROD  
**Target:** Android 14/15 Native + Android 9-13 Backward Compatibility  
**Primary Integration:** AndroidX Health Connect (`androidx.health.connect:connect-client:1.1.0-alpha11`)  
**OEM Interop:** Samsung Health via Health Connect Sync Bus  
**Hardware Fallback:** Android `Sensor.TYPE_STEP_COUNTER` with Boot-Delta Accounting  

---

## 1. System Integration Architecture

FitTrackr uses an adaptive **Tri-Tier Health Data Pipeline** to ensure that real steps, active energy, and distance are captured across all Android device manufacturers:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        FITTRACKR FLUTTER ENGINE                        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ MethodChannel ("com.fittrackr.app/health")
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      NATIVE KOTLIN ROUTING LAYER                       │
│                     (HealthIntegrationCoordinator)                     │
└───────────┬───────────────────────────────────────────────┬────────────┘
            │ (Tier 1: Preferred)                           │ (Tier 2: Fallback)
            ▼                                               ▼
┌───────────────────────────────┐               ┌────────────────────────┐
│   ANDROID HEALTH CONNECT SDK  │               │ HARDWARE PEDOMETER SVC │
│ (androidx.health.connect)     │               │ (Sensor.TYPE_STEP_CTR) │
└───────────┬───────────────────┘               └───────────┬────────────┘
            │                                               │
      ┌─────┴───────────────────────┐                       │
      ▼                             ▼                       ▼
┌──────────────┐           ┌──────────────────┐    ┌─────────────────┐
│ Google Fit / │           │  SAMSUNG HEALTH  │    │ Direct Onboard  │
│ Pixel Watch  │           │ (Galaxy Watch &  │    │ Accelerometer / │
│              │           │  Samsung Phone)  │    │ Step Chip       │
└──────────────┘           └──────────────────┘    └─────────────────┘
```

---

## 2. Samsung Health Connection Architecture

### 2.1 How FitTrackr Syncs with Samsung Health
On Samsung devices running One UI (Galaxy S series, Z Fold/Flip, Galaxy Watch 4/5/6/7):
1. **Official Mechanism:** Samsung Health natively synchronizes all pedometer, exercise, and biometric records to **Android Health Connect** (supported since Samsung Health v6.24).
2. **User Experience:** When FitTrackr detects a Samsung device, it presents a branded button: **"Connect Samsung Health"**. 
3. **Data Flow:** Tapping this opens the Health Connect permissions dialog where Samsung Health is already listed as an authorized data source. Granting FitTrackr read access instantly pulls all steps logged by Samsung Galaxy phones and Galaxy Watches.

### 2.2 Samsung Health Package Detection (`SamsungHealthDetector.kt`)
```kotlin
package com.fittrackr.app.health

import android.content.Context
import android.content.pm.PackageManager

object SamsungHealthDetector {
    private const val SAMSUNG_HEALTH_PACKAGE = "com.sec.android.app.shealth"

    fun isSamsungHealthInstalled(context: Context): Boolean {
        return try {
            context.packageManager.getPackageInfo(SAMSUNG_HEALTH_PACKAGE, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}
```

---

## 3. AndroidManifest Configuration & Security Requirements

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.fittrackr.app">

    <!-- Step Tracking & Hardware Sensor Permissions -->
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_HEALTH" />

    <!-- Health Connect Specific Permissions (Android 14+ Built-in & Android 9-13 App) -->
    <uses-permission android:name="android.permission.health.READ_STEPS" />
    <uses-permission android:name="android.permission.health.WRITE_STEPS" />
    <uses-permission android:name="android.permission.health.READ_DISTANCE" />
    <uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED" />
    <uses-permission android:name="android.permission.health.READ_HEART_RATE" />

    <!-- Query Intent Filter to Discover Health Connect Package -->
    <queries>
        <package android:name="com.google.android.apps.healthdata" />
        <package android:name="com.sec.android.app.shealth" />
        <intent>
            <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
        </intent>
    </queries>

    <application
        android:name=".FitTrackrApplication"
        android:icon="@mipmap/ic_launcher"
        android:label="FitTrackr">

        <!-- Activity to Handle Health Connect Permission Rationale -->
        <activity
            android:name=".health.HealthPermissionsRationaleActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
            </intent-filter>
        </activity>

        <!-- Privacy Policy Activity required by Health Connect Policy -->
        <activity-alias
            android:name="ViewPermissionUsageActivity"
            android:targetActivity=".MainActivity"
            android:exported="true"
            android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
            <intent-filter>
                <action android:name="android.intent.action.VIEW_PERMISSION_USAGE" />
                <category android:name="android.intent.category.HEALTH_PERMISSIONS" />
            </intent-filter>
        </activity-alias>

        <!-- Hardware Step Counter Foreground Service -->
        <service
            android:name=".health.StepTrackingForegroundService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="health" />

    </application>
</manifest>
```

---

## 4. Complete Native Health Connect Manager (`HealthConnectManager.kt`)

```kotlin
package com.fittrackr.app.health

import android.content.Context
import androidx.activity.result.contract.ActivityResultContract
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.*
import androidx.health.connect.client.request.AggregateGroupByPeriodRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Instant
import java.time.LocalDate
import java.time.Period
import java.time.ZoneId

class HealthConnectManager(private val context: Context) {

    val healthConnectClient by lazy {
        if (isAvailable()) HealthConnectClient.getOrCreate(context) else null
    }

    // Health Connect Permissions Set
    val requiredPermissions = setOf(
        HealthPermission.getReadPermission(StepsRecord::class),
        HealthPermission.getWritePermission(StepsRecord::class),
        HealthPermission.getReadPermission(DistanceRecord::class),
        HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
        HealthPermission.getReadPermission(HeartRateRecord::class)
    )

    fun isAvailable(): Boolean {
        val status = HealthConnectClient.getSdkStatus(context)
        return status == HealthConnectClient.SDK_AVAILABLE
    }

    suspend fun hasAllPermissions(): Boolean {
        val client = healthConnectClient ?: return false
        val granted = client.permissionController.getGrantedPermissions()
        return granted.containsAll(requiredPermissions)
    }

    fun createPermissionContract(): ActivityResultContract<Set<String>, Set<String>> {
        return PermissionController.createRequestPermissionResultContract()
    }

    /**
     * Reads real step records grouped by day or hourly buckets.
     */
    suspend fun readDailySteps(date: LocalDate): Long {
        val client = healthConnectClient ?: return 0L
        val startTime = date.atStartOfDay(ZoneId.systemDefault()).toInstant()
        val endTime = date.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant()

        val response = client.readRecords(
            ReadRecordsRequest(
                recordType = StepsRecord::class,
                timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
            )
        )
        return response.records.sumOf { it.count }
    }

    /**
     * Reads active calories burned for the given date.
     */
    suspend fun readActiveCalories(date: LocalDate): Double {
        val client = healthConnectClient ?: return 0.0
        val startTime = date.atStartOfDay(ZoneId.systemDefault()).toInstant()
        val endTime = date.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant()

        val response = client.readRecords(
            ReadRecordsRequest(
                recordType = ActiveCaloriesBurnedRecord::class,
                timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
            )
        )
        return response.records.sumOf { it.energy.inKilocalories }
    }
}
```

---

## 5. Hardware Step Counter Fallback (`StepSensorManager.kt`)

When Health Connect is not present, FitTrackr registers directly with Android's `SensorManager` to read the hardware pedometer chip.

### 5.1 System Reboot Delta Compensation Algorithm
Because `Sensor.TYPE_STEP_COUNTER` counts the steps since last phone reboot:
1. When the phone reboots, the sensor resets to `0`.
2. The manager detects reboot if `current_raw_steps < last_raw_steps`.
3. It accumulates a `reboot_offset` to guarantee continuity across system restarts.

```kotlin
package com.fittrackr.app.health

import android.content.Context
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import java.time.LocalDate

class StepSensorManager(private val context: Context) : SensorEventListener {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    private val prefs: SharedPreferences = context.getSharedPreferences("fittrackr_sensor_prefs", Context.MODE_PRIVATE)

    interface StepListener {
        fun onStepUpdate(dailySteps: Int, cadence: Int)
    }

    private var listener: StepListener? = null
    private var lastStepTimestamp = 0L

    fun startListening(listener: StepListener) {
        this.listener = listener
        stepSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
    }

    fun stopListening() {
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            val totalRawSteps = event.values[0].toInt()
            val todayKey = LocalDate.now().toString()

            val savedDate = prefs.getString("active_date", "") ?: ""
            var baseMidnightSteps = prefs.getInt("base_steps_$todayKey", -1)
            var rebootOffset = prefs.getInt("reboot_offset_$todayKey", 0)
            val lastRecordedRaw = prefs.getInt("last_raw_steps", totalRawSteps)

            // Detect Reboot
            if (totalRawSteps < lastRecordedRaw) {
                // Device rebooted: sensor reset to 0
                rebootOffset += lastRecordedRaw
                prefs.edit().putInt("reboot_offset_$todayKey", rebootOffset).apply()
            }

            if (savedDate != todayKey || baseMidnightSteps == -1) {
                // New Day initial snapshot
                baseMidnightSteps = totalRawSteps
                rebootOffset = 0
                prefs.edit()
                    .putString("active_date", todayKey)
                    .putInt("base_steps_$todayKey", baseMidnightSteps)
                    .putInt("reboot_offset_$todayKey", 0)
                    .apply()
            }

            prefs.edit().putInt("last_raw_steps", totalRawSteps).apply()

            val netDailySteps = (totalRawSteps + rebootOffset) - baseMidnightSteps
            
            // Calculate instant cadence (steps per minute)
            val now = System.currentTimeMillis()
            val cadence = if (lastStepTimestamp > 0 && now > lastStepTimestamp) {
                val deltaSec = (now - lastStepTimestamp) / 1000.0
                if (deltaSec > 0 && deltaSec < 5) (60.0 / deltaSec).toInt() else 0
            } else 0
            lastStepTimestamp = now

            listener?.onStepUpdate(if (netDailySteps >= 0) netDailySteps else 0, cadence)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
```

---

## 6. Background Synchronization via AndroidX WorkManager

A periodic job (`HealthSyncWorker.kt`) runs every 4 hours with battery and network constraints:
* Reads incremental Health Connect records.
* Writes aggregated step counts and calories to the local Drift SQLite database.
* Emits a broadcast to Flutter's Riverpod provider to update the widget tree.
