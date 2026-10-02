import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/health_snapshot.dart';

enum HealthConnectState { unavailable, needsInstall, available }

/// Read-only bridge to Android Health Connect (Samsung Health, Google Fit,
/// Wear OS and other apps sync into it).
class HealthConnectService {
  HealthConnectService._();
  static final HealthConnectService instance = HealthConnectService._();

  final Health _health = Health();
  bool _configured = false;

  static const List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.BLOOD_OXYGEN,
  ];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<HealthConnectState> getState() async {
    if (defaultTargetPlatform != TargetPlatform.android) return HealthConnectState.unavailable;
    try {
      await _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      switch (status) {
        case HealthConnectSdkStatus.sdkAvailable:
          return HealthConnectState.available;
        case HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired:
          return HealthConnectState.needsInstall;
        default:
          return HealthConnectState.unavailable;
      }
    } catch (e) {
      debugPrint('Health Connect status failed: $e');
      return HealthConnectState.unavailable;
    }
  }

  Future<void> installOrUpdate() async {
    try {
      await _ensureConfigured();
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint('Health Connect install failed: $e');
    }
  }

  Future<bool> hasPermissions() async {
    try {
      if (await getState() != HealthConnectState.available) return false;
      final granted = await _health.hasPermissions(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );
      return granted ?? false;
    } catch (e) {
      debugPrint('Health Connect permission check failed: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (await getState() != HealthConnectState.available) return false;
      return await _health.requestAuthorization(
        types,
        permissions: types.map((_) => HealthDataAccess.READ).toList(),
      );
    } catch (e) {
      debugPrint('Health Connect authorization failed: $e');
      return false;
    }
  }

  /// Total steps from Health Connect between [start] and [end] (null on failure).
  Future<int?> stepsBetween(DateTime start, DateTime end) async {
    try {
      if (!await hasPermissions()) return null;
      return await _health.getTotalStepsInInterval(start, end);
    } catch (e) {
      debugPrint('Health Connect steps failed: $e');
      return null;
    }
  }

  /// Daily totals for each day in [days] (local midnight keys).
  Future<Map<DateTime, int>> dailySteps(List<DateTime> days) async {
    final result = <DateTime, int>{};
    if (!await hasPermissions()) return result;
    for (final day in days) {
      final start = DateTime(day.year, day.month, day.day);
      final end = DateTime(day.year, day.month, day.day + 1);
      final now = DateTime.now();
      try {
        final steps = await _health.getTotalStepsInInterval(start, end.isAfter(now) ? now : end);
        if (steps != null) result[start] = steps;
      } catch (_) {}
    }
    return result;
  }

  Future<HealthSnapshot> readVitals() async {
    try {
      if (!await hasPermissions()) return HealthSnapshot.empty();
      final now = DateTime.now();
      final points = await _health.getHealthDataFromTypes(
        types: const [
          HealthDataType.HEART_RATE,
          HealthDataType.SLEEP_SESSION,
          HealthDataType.BLOOD_OXYGEN,
        ],
        startTime: now.subtract(const Duration(hours: 36)),
        endTime: now,
      );

      final hr = points.where((p) => p.type == HealthDataType.HEART_RATE).toList()
        ..sort((a, b) => a.dateTo.compareTo(b.dateTo));
      final todayStart = DateTime(now.year, now.month, now.day);
      final hrToday = hr.where((p) => p.dateFrom.isAfter(todayStart)).toList();

      int? latestHr;
      int? avgHr;
      if (hr.isNotEmpty) latestHr = _num(hr.last)?.round();
      if (hrToday.isNotEmpty) {
        final values = hrToday.map(_num).whereType<double>().toList();
        if (values.isNotEmpty) {
          avgHr = (values.reduce((a, b) => a + b) / values.length).round();
        }
      }

      // Sleep sessions that ended since yesterday noon (last night).
      final sleepCutoff = todayStart.subtract(const Duration(hours: 12));
      final sleep = points.where(
        (p) => p.type == HealthDataType.SLEEP_SESSION && p.dateTo.isAfter(sleepCutoff),
      );
      int? sleepMinutes;
      for (final s in sleep) {
        final mins = s.dateTo.difference(s.dateFrom).inMinutes;
        sleepMinutes = (sleepMinutes ?? 0) + (mins > 0 ? mins : 0);
      }

      final spo2 = points.where((p) => p.type == HealthDataType.BLOOD_OXYGEN).toList()
        ..sort((a, b) => a.dateTo.compareTo(b.dateTo));
      double? spo2Value;
      if (spo2.isNotEmpty) {
        final v = _num(spo2.last);
        if (v != null) spo2Value = v <= 1.0 ? v * 100 : v;
      }

      return HealthSnapshot(
        latestHeartRate: latestHr,
        avgHeartRate: avgHr,
        sleepMinutes: (sleepMinutes ?? 0) > 0 ? sleepMinutes : null,
        spo2Percent: spo2Value,
        fetchedAt: now,
      );
    } catch (e) {
      debugPrint('Health Connect vitals failed: $e');
      return HealthSnapshot.empty();
    }
  }

  double? _num(HealthDataPoint p) {
    final v = p.value;
    if (v is NumericHealthValue) return v.numericValue.toDouble();
    return null;
  }
}
