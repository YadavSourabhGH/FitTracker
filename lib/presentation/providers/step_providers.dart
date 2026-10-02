import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/date_keys.dart';
import '../../core/utils/fitness_calc.dart';
import '../../data/models/health_snapshot.dart';
import '../../data/models/step_record_model.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/step_repository.dart';
import '../../data/services/health_connect_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/pedometer_service.dart';
import 'app_providers.dart';

final pedometerServiceProvider = Provider<PedometerService>((ref) {
  final service = PedometerService();
  ref.onDispose(service.dispose);
  return service;
});

final healthConnectServiceProvider =
    Provider<HealthConnectService>((ref) => HealthConnectService.instance);

/// Live state of today's activity.
class TodayStepState {
  final int stepCount;
  final int goalSteps;
  final double distanceMeters;
  final double activeCalories;
  final int activeMinutes;
  final int streakDays;
  final String source;
  final SensorStatus sensorStatus;
  final bool healthConnectSynced;
  final DateTime? lastSync;

  const TodayStepState({
    required this.stepCount,
    required this.goalSteps,
    required this.distanceMeters,
    required this.activeCalories,
    required this.activeMinutes,
    required this.streakDays,
    required this.source,
    required this.sensorStatus,
    required this.healthConnectSynced,
    this.lastSync,
  });

  double get progressPercentage {
    if (goalSteps <= 0) return 0.0;
    final pct = (stepCount / goalSteps) * 100;
    return pct > 100 ? 100.0 : pct;
  }

  int get remainingSteps {
    final diff = goalSteps - stepCount;
    return diff > 0 ? diff : 0;
  }

  bool get goalReached => stepCount >= goalSteps && goalSteps > 0;

  String get sourceLabel {
    switch (source) {
      case 'HEALTH_CONNECT':
        return 'Health Connect';
      case 'HARDWARE_SENSOR':
        return 'Phone sensor';
      default:
        return 'No data yet';
    }
  }
}

class TodayStepNotifier extends AsyncNotifier<TodayStepState> {
  StreamSubscription<StepUpdate>? _sub;
  StreamSubscription<SensorStatus>? _statusSub;
  late String _day;
  int _sensorSteps = 0;
  int _storedSteps = 0;
  int? _hcSteps;
  int _streakBeforeToday = 0;
  int _pendingHourly = 0;
  DateTime _lastFlush = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _lastSync;
  SensorStatus _sensorStatus = SensorStatus.initializing;

  late StepRepository _repo;
  TodayStepState? _latest;

  @override
  Future<TodayStepState> build() async {
    final settings = ref.watch(settingsProvider);
    final pedometer = ref.watch(pedometerServiceProvider);
    final repo = ref.watch(stepRepositoryProvider);
    _repo = repo;

    _day = DateKeys.today();
    _hcSteps = null;
    final stored = await repo.getDay(_day);
    _storedSteps = stored != null && stored.source != 'NONE' ? stored.stepCount : 0;
    _streakBeforeToday = await repo.streakEndingYesterday(settings.stepGoal);

    _sensorStatus = await pedometer.initialize(requestPermission: false);
    _sensorSteps = pedometer.stepsToday;

    await _sub?.cancel();
    await _statusSub?.cancel();
    _sub = pedometer.updates.listen(_onUpdate);
    _statusSub = pedometer.statusStream.listen((s) {
      _sensorStatus = s;
      _emit();
    });
    ref.onDispose(() {
      _flush(force: true);
      _sub?.cancel();
      _statusSub?.cancel();
    });

    if (settings.healthConnectEnabled) {
      unawaited(_syncHealthConnect(backfill: true));
    }
    final initial = _compose(settings);
    _latest = initial;
    return initial;
  }

  TodayStepState _compose(UserSettings s) {
    var steps = _storedSteps;
    var source = _storedSteps > 0 ? 'HARDWARE_SENSOR' : 'NONE';
    if (_sensorSteps >= steps && _sensorSteps > 0) {
      steps = _sensorSteps;
      source = 'HARDWARE_SENSOR';
    }
    final hc = _hcSteps;
    if (hc != null && hc >= steps && hc > 0) {
      steps = hc;
      source = 'HEALTH_CONNECT';
    }
    return TodayStepState(
      stepCount: steps,
      goalSteps: s.stepGoal,
      distanceMeters: s.distanceMetersFor(steps),
      activeCalories: s.kcalFor(steps),
      activeMinutes: FitnessCalc.activeMinutes(steps),
      streakDays: _streakBeforeToday + (steps >= s.stepGoal && s.stepGoal > 0 ? 1 : 0),
      source: source,
      sensorStatus: _sensorStatus,
      healthConnectSynced: hc != null,
      lastSync: _lastSync,
    );
  }

  void _emit() {
    if (!ref.mounted) return;
    final current = _latest;
    final next = _compose(ref.read(settingsProvider));
    _latest = next;
    state = AsyncValue.data(next);
    if (current != null && !current.goalReached && next.goalReached) {
      unawaited(_notifyGoal(next));
    }
  }

  Future<void> _notifyGoal(TodayStepState s) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'goal_notified_$_day';
    if (prefs.getBool(key) ?? false) return;
    await prefs.setBool(key, true);
    await NotificationService.instance.showNow(
      1,
      'Step goal reached',
      'You hit ${s.goalSteps} steps today. Streak: ${s.streakDays} day(s).',
    );
  }

  void _onUpdate(StepUpdate u) {
    if (!ref.mounted) return;
    if (u.dateKey != _day) {
      _flush(force: true);
      ref.invalidateSelf();
      return;
    }
    _sensorSteps = u.stepsToday;
    _pendingHourly += u.delta;
    _emit();
    _flush();
  }

  /// Persists the day's total and hourly buckets at most every 15 seconds.
  void _flush({bool force = false}) {
    final now = DateTime.now();
    if (!force && now.difference(_lastFlush).inSeconds < 15) return;
    _lastFlush = now;
    final current = _latest;
    final delta = _pendingHourly;
    _pendingHourly = 0;
    if (delta > 0) unawaited(_repo.addHourly(_day, now.hour, delta));
    if (current != null && current.stepCount > 0) {
      unawaited(_repo.saveDay(DailyStepRecord(
        dateString: _day,
        stepCount: current.stepCount,
        distanceMeters: current.distanceMeters,
        activeCalories: current.activeCalories,
        source: current.source,
        syncedAt: now,
      )));
    }
  }

  Future<void> _syncHealthConnect({bool backfill = false}) async {
    final hc = ref.read(healthConnectServiceProvider);
    final now = DateTime.now();
    final steps = await hc.stepsBetween(DateTime(now.year, now.month, now.day), now);
    if (!ref.mounted) return;
    if (steps != null) {
      _hcSteps = steps;
      _lastSync = DateTime.now();
      _emit();
      _flush(force: true);
    }
    if (backfill && steps != null) {
      final days = List.generate(
        7,
        (i) => DateTime(now.year, now.month, now.day - (i + 1)),
      );
      final daily = await hc.dailySteps(days);
      final settings = ref.read(settingsProvider);
      for (final entry in daily.entries) {
        final key = DateKeys.of(entry.key);
        final existing = await _repo.getDay(key);
        if (existing == null || entry.value > existing.stepCount) {
          await _repo.saveDay(DailyStepRecord(
            dateString: key,
            stepCount: entry.value,
            distanceMeters: settings.distanceMetersFor(entry.value),
            activeCalories: settings.kcalFor(entry.value),
            source: 'HEALTH_CONNECT',
            syncedAt: DateTime.now(),
          ));
        }
      }
      if (ref.mounted && daily.isNotEmpty) {
        _streakBeforeToday = await _repo.streakEndingYesterday(settings.stepGoal);
        _emit();
        ref.invalidate(stepHistoryProvider);
        ref.invalidate(dayStepRecordProvider);
      }
    }
  }

  /// Manual refresh: re-reads the sensor and Health Connect.
  Future<void> refresh() async {
    final settings = ref.read(settingsProvider);
    final pedometer = ref.read(pedometerServiceProvider);
    _sensorStatus = await pedometer.initialize(requestPermission: false);
    _sensorSteps = pedometer.stepsToday > _sensorSteps ? pedometer.stepsToday : _sensorSteps;
    if (DateKeys.today() != _day) {
      ref.invalidateSelf();
      return;
    }
    if (settings.healthConnectEnabled) {
      await _syncHealthConnect(backfill: true);
    }
    _emit();
    ref.invalidate(healthSnapshotProvider);
  }

  /// Asks for the activity-recognition permission, then restarts tracking.
  Future<SensorStatus> requestSensorPermission() async {
    final pedometer = ref.read(pedometerServiceProvider);
    final status = await pedometer.initialize(requestPermission: true);
    _sensorStatus = status;
    if (ref.mounted) _emit();
    return status;
  }
}

final todayStepProvider =
    AsyncNotifierProvider<TodayStepNotifier, TodayStepState>(TodayStepNotifier.new);

/// Last [days] days of stored step totals, oldest first.
final stepHistoryProvider = FutureProvider.family<List<DailyStepRecord>, int>((ref, days) {
  return ref.watch(stepRepositoryProvider).history(days);
});

final dayStepRecordProvider = FutureProvider.family<DailyStepRecord, String>((ref, day) async {
  final record = await ref.watch(stepRepositoryProvider).getDay(day);
  return record ?? DailyStepRecord.empty(day);
});

final hourlyStepsProvider = FutureProvider.family<List<HourlyStepBucket>, String>((ref, day) {
  return ref.watch(stepRepositoryProvider).getHourly(day);
});

/// Heart rate, sleep and SpO2 from Health Connect (empty when not connected).
final healthSnapshotProvider = FutureProvider<HealthSnapshot>((ref) async {
  final enabled = ref.watch(settingsProvider.select((s) => s.healthConnectEnabled));
  if (!enabled) return HealthSnapshot.empty();
  return ref.watch(healthConnectServiceProvider).readVitals();
});

final healthConnectStateProvider = FutureProvider<HealthConnectState>((ref) {
  return ref.watch(healthConnectServiceProvider).getState();
});

final healthConnectPermissionProvider = FutureProvider<bool>((ref) {
  return ref.watch(healthConnectServiceProvider).hasPermissions();
});
