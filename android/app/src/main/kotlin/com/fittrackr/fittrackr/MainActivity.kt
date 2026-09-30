package com.fittrackr.fittrackr

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fittrackr.app/health_connect"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openSamsungHealth" -> {
                    try {
                        val launchIntent = packageManager.getLaunchIntentForPackage("com.sec.android.app.shealth")
                        if (launchIntent != null) {
                            startActivity(launchIntent)
                            result.success(true)
                        } else {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=com.sec.android.app.shealth"))
                            startActivity(intent)
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        result.error("LAUNCH_ERROR", e.message, null)
                    }
                }
                "openHealthConnectSettings" -> {
                    try {
                        val intent = Intent("androidx.health.ACTION_HEALTH_CONNECT_SETTINGS")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=com.google.android.apps.healthdata"))
                            startActivity(intent)
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("SETTINGS_ERROR", ex.message, null)
                        }
                    }
                }
                "getSdkStatus" -> {
                    val isSamsungHealthInstalled = try {
                        packageManager.getPackageInfo("com.sec.android.app.shealth", 0)
                        true
                    } catch (_: PackageManager.NameNotFoundException) {
                        false
                    }
                    result.success(if (isSamsungHealthInstalled) 1 else 3)
                }
                "checkPermissions" -> {
                    result.success(true)
                }
                "readDailySummary" -> {
                    val map = HashMap<String, Any>()
                    map["steps"] = 0
                    map["distanceMeters"] = 0.0
                    map["activeCalories"] = 0.0
                    result.success(map)
                }
                else -> result.notImplemented()
            }
        }
    }
}
