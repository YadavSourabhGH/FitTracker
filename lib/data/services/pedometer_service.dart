import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/date_keys.dart';

enum SensorStatus { initializing, active, permissionDenied, unavailable }

/// A step update: today's total and the delta since the previous event.
class StepUpdate {
  final String dateKey;
  final int stepsToday;
  final int delta;
  final DateTime at;

  const StepUpdate(this.dateKey, this.stepsToday, this.delta, this.at);
}

/// Hardware pedometer reading Android `Sensor.TYPE_STEP_COUNTER`.
///
/// The counter is cumulative since boot. Today's steps are
/// `offset + (raw - base)` where `base` is the raw value at the start of the
/// day (or at install) and `offset` accumulates steps from before a reboot.
class PedometerService {
  StreamSubscription<StepCount>? _sub;
  final _controller = StreamController<StepUpdate>.broadcast();
  final _statusController = StreamController<SensorStatus>.broadcast();

  SensorStatus _status = SensorStatus.initializing;
  SharedPreferences? _prefs;
  String? _day;
  int _base = 0;
  int _offset = 0;
  int _lastRaw = -1;
  int _stepsToday = 0;
  bool _initialized = false;

  Stream<StepUpdate> get updates => _controller.stream;
  Stream<SensorStatus> get statusStream => _statusController.stream;
  SensorStatus get status => _status;
  int get stepsToday => _day == DateKeys.today() ? _stepsToday : 0;

  void _setStatus(SensorStatus s) {
    _status = s;
    if (!_statusController.isClosed) _statusController.add(s);
  }

  /// Requests ACTIVITY_RECOGNITION and starts listening. Safe to call repeatedly.
  Future<SensorStatus> initialize({bool requestPermission = true}) async {
    if (_initialized && _status == SensorStatus.active) return _status;
    try {
      var perm = await Permission.activityRecognition.status;
      if (!perm.isGranted && requestPermission) {
        perm = await Permission.activityRecognition.request();
      }
      if (!perm.isGranted) {
        _setStatus(SensorStatus.permissionDenied);
        return _status;
      }
      _prefs = await SharedPreferences.getInstance();
      _lastRaw = _prefs!.getInt('steps_last_raw') ?? -1;
      await _sub?.cancel();
      _sub = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (Object e) {
          debugPrint('Pedometer error: $e');
          _setStatus(SensorStatus.unavailable);
        },
        cancelOnError: false,
      );
      _initialized = true;
      _setStatus(SensorStatus.active);
    } catch (e) {
      debugPrint('Pedometer init failed: $e');
      _setStatus(SensorStatus.unavailable);
    }
    return _status;
  }

  void _loadDay(String day, int raw) {
    final prefs = _prefs!;
    _day = day;
    final storedBase = prefs.getInt('steps_base_$day');
    _offset = prefs.getInt('steps_offset_$day') ?? 0;
    if (storedBase != null) {
      _base = storedBase;
    } else {
      // First reading of a new day. If the counter kept running since the
      // last reading we saw, start from that reading (steps since then are
      // attributed to today); otherwise start from now.
      final lastDay = prefs.getString('steps_last_day');
      final carry = lastDay != null && lastDay != day && _lastRaw >= 0 && raw >= _lastRaw;
      _base = carry ? _lastRaw : raw;
      _offset = 0;
      prefs.setInt('steps_base_$day', _base);
      prefs.setInt('steps_offset_$day', _offset);
      _cleanupOldKeys(day);
    }
  }

  void _cleanupOldKeys(String today) {
    final prefs = _prefs!;
    final cutoff = DateKeys.shift(today, -3);
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith('steps_base_') || key.startsWith('steps_offset_')) {
        final day = key.substring(key.lastIndexOf('_') + 1);
        if (day.compareTo(cutoff) < 0) prefs.remove(key);
      }
    }
  }

  void _onStepCount(StepCount event) {
    final prefs = _prefs;
    if (prefs == null) return;
    final raw = event.steps;
    final today = DateKeys.today();
    final previous = prefs.getString('steps_reported_day') == today
        ? (prefs.getInt('steps_reported_value') ?? 0)
        : 0;

    if (_day != today) {
      _loadDay(today, raw);
    }

    // Reboot detected: counter restarted from zero.
    if (_lastRaw >= 0 && raw < _lastRaw && raw < _base) {
      final carried = _lastRaw - _base;
      _offset = _offset + (carried > 0 ? carried : 0);
      _base = 0;
      prefs.setInt('steps_base_$today', _base);
      prefs.setInt('steps_offset_$today', _offset);
    } else if (raw < _base) {
      _base = raw;
      prefs.setInt('steps_base_$today', _base);
    }

    _lastRaw = raw;
    prefs.setInt('steps_last_raw', raw);
    prefs.setString('steps_last_day', today);

    final steps = _offset + (raw - _base);
    _stepsToday = steps < 0 ? 0 : steps;
    final delta = _stepsToday - previous;
    prefs.setString('steps_reported_day', today);
    prefs.setInt('steps_reported_value', _stepsToday);
    if (!_controller.isClosed) {
      _controller.add(StepUpdate(today, _stepsToday, delta > 0 ? delta : 0, DateTime.now()));
    }
  }

  Future<bool> openSettings() => openAppSettings();

  void dispose() {
    _sub?.cancel();
    _controller.close();
    _statusController.close();
  }
}
