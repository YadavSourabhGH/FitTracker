import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/step_record_model.dart';
import '../../data/repositories/step_repository.dart';
import '../../data/services/pedometer_service.dart';

final pedometerServiceProvider = Provider<PedometerService>((ref) {
  final service = PedometerService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final stepRepositoryProvider = Provider<StepRepository>((ref) {
  final pedometer = ref.watch(pedometerServiceProvider);
  return StepRepository(pedometerService: pedometer);
});

/// Live step state representing today's real step count, distance, kcal, and cadence
class TodayStepState {
  final int stepCount;
  final int goalSteps;
  final double distanceMeters;
  final double activeCalories;
  final int activeMinutes;
  final int streakDays;
  final String source;
  final bool isSyncing;

  const TodayStepState({
    required this.stepCount,
    this.goalSteps = 10000,
    required this.distanceMeters,
    required this.activeCalories,
    this.activeMinutes = 0,
    this.streakDays = 0,
    required this.source,
    this.isSyncing = false,
  });

  double get progressPercentage {
    if (goalSteps == 0) return 0.0;
    final pct = (stepCount / goalSteps) * 100;
    return pct > 100 ? 100.0 : pct;
  }

  int get remainingSteps {
    final diff = goalSteps - stepCount;
    return diff > 0 ? diff : 0;
  }
}

class TodayStepNotifier extends AsyncNotifier<TodayStepState> {
  StreamSubscription<int>? _streamSub;

  @override
  Future<TodayStepState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt('user_step_goal') ?? 10000;
    final weight = prefs.getDouble('user_weight') ?? 70.0;
    final streak = prefs.getInt('user_streak') ?? 0;

    final repo = ref.watch(stepRepositoryProvider);
    final pedometer = ref.watch(pedometerServiceProvider);
    final record = await repo.getTodaySteps();

    _streamSub?.cancel();
    _streamSub = pedometer.stepStream.listen((liveSteps) {
      if (liveSteps >= 0) {
        _onLiveSteps(liveSteps, goal, weight, streak, repo);
      }
    });
    ref.onDispose(() => _streamSub?.cancel());

    final steps = record.stepCount;
    return TodayStepState(
      stepCount: steps,
      goalSteps: goal,
      distanceMeters: steps * 0.762,
      activeCalories: steps * 0.04 * (weight / 70.0),
      activeMinutes: steps > 0 ? (steps / 100).ceil() : 0,
      streakDays: streak,
      source: record.source,
    );
  }

  void _onLiveSteps(int steps, int goal, double weight, int streak, StepRepository repo) {
    final dist = steps * 0.762;
    final kcal = steps * 0.04 * (weight / 70.0);
    final mins = steps > 0 ? (steps / 100).ceil() : 0;

    state = AsyncValue.data(TodayStepState(
      stepCount: steps,
      goalSteps: goal,
      distanceMeters: dist,
      activeCalories: kcal,
      activeMinutes: mins,
      streakDays: streak,
      source: 'HARDWARE_SENSOR',
    ));

    final today = DateTime.now().toIso8601String().substring(0, 10);
    repo.saveDailyStepRecord(DailyStepRecord(
      dateString: today,
      stepCount: steps,
      distanceMeters: dist,
      activeCalories: kcal,
      source: 'HARDWARE_SENSOR',
      syncedAt: DateTime.now(),
    ));
  }

  Future<void> syncHealthConnect() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      final goal = prefs.getInt('user_step_goal') ?? 10000;
      final weight = prefs.getDouble('user_weight') ?? 70.0;
      final streak = prefs.getInt('user_streak') ?? 0;

      final repo = ref.read(stepRepositoryProvider);
      final record = await repo.getTodaySteps();
      final steps = record.stepCount;

      return TodayStepState(
        stepCount: steps,
        goalSteps: goal,
        distanceMeters: steps * 0.762,
        activeCalories: steps * 0.04 * (weight / 70.0),
        activeMinutes: steps > 0 ? (steps / 100).ceil() : 0,
        streakDays: streak,
        source: record.source,
      );
    });
  }
}

final todayStepProvider = AsyncNotifierProvider<TodayStepNotifier, TodayStepState>(TodayStepNotifier.new);
