import 'package:flutter/services.dart';
import '../models/step_record_model.dart';

/// Service connecting to Android Health Connect and Samsung Health.
class HealthConnectService {
  static const _channel = MethodChannel('com.fittrackr.app/health_connect');

  /// Returns 1 for Available, 2 for Needs Update, 3 for Unavailable
  Future<int> getSdkStatus() async {
    try {
      final status = await _channel.invokeMethod<int>('getSdkStatus');
      return status ?? 3;
    } catch (_) {
      return 3; // Unavailable or running on emulator
    }
  }

  /// Checks if Health Connect permissions are granted
  Future<bool> checkPermissions() async {
    try {
      final granted = await _channel.invokeMethod<bool>('checkPermissions');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests Health Connect read permissions for Steps, Distance, Calories, Heart Rate
  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Reads today's synced steps, distance, and calories from Health Connect
  Future<DailyStepRecord?> readTodayRecord() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final endOfDay = now.millisecondsSinceEpoch;

      final result = await _channel.invokeMethod<Map>('readDailySummary', {
        'startTime': startOfDay,
        'endTime': endOfDay,
      });

      if (result == null) return null;

      return DailyStepRecord(
        dateString: now.toIso8601String().substring(0, 10),
        stepCount: (result['steps'] as int?) ?? 0,
        distanceMeters: (result['distanceMeters'] as num?)?.toDouble() ?? 0.0,
        activeCalories: (result['activeCalories'] as num?)?.toDouble() ?? 0.0,
        source: 'HEALTH_CONNECT',
        syncedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Opens Health Connect system settings
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openHealthConnectSettings');
    } catch (_) {}
  }
}
