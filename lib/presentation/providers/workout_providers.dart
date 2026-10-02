import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_keys.dart';
import '../../core/utils/fitness_calc.dart';
import '../../data/models/user_settings.dart';
import '../../data/models/workout_model.dart';
import 'app_providers.dart';

/// Full workout catalogue.
final allWorkoutsProvider = FutureProvider<List<Workout>>((ref) {
  return ref.watch(workoutRepositoryProvider).getAllWorkouts();
});

/// Weekly plan: weekday (1 = Monday) -> workout id or 'rest'.
class ScheduleNotifier extends AsyncNotifier<Map<int, String>> {
  @override
  Future<Map<int, String>> build() => ref.watch(settingsRepositoryProvider).loadSchedule();

  Future<void> setDay(int weekday, String workoutId) async {
    await ref.read(settingsRepositoryProvider).saveScheduleDay(weekday, workoutId);
    final current = Map<int, String>.from(state.value ?? const {});
    current[weekday] = workoutId;
    state = AsyncValue.data(current);
  }
}

final scheduleProvider =
    AsyncNotifierProvider<ScheduleNotifier, Map<int, String>>(ScheduleNotifier.new);

/// Workout planned for today (null on rest days or while loading).
final todaysWorkoutProvider = Provider<AsyncValue<Workout?>>((ref) {
  final schedule = ref.watch(scheduleProvider);
  final workouts = ref.watch(allWorkoutsProvider);
  if (schedule.isLoading || workouts.isLoading) return const AsyncValue.loading();
  final id = schedule.value?[DateTime.now().weekday] ?? 'rest';
  final list = workouts.value ?? const <Workout>[];
  for (final w in list) {
    if (w.id == id) return AsyncValue.data(w);
  }
  return const AsyncValue.data(null);
});

final recentSessionsProvider = FutureProvider<List<WorkoutSession>>((ref) {
  return ref.watch(workoutRepositoryProvider).completedSessions(limit: 100);
});

final weekSessionsProvider = FutureProvider<List<WorkoutSession>>((ref) {
  return ref
      .watch(workoutRepositoryProvider)
      .completedSessions(since: DateKeys.startOfWeek(DateTime.now()));
});

final sessionSetsProvider = FutureProvider.family<List<LoggedSet>, String>((ref, sessionId) {
  return ref.watch(workoutRepositoryProvider).setsForSession(sessionId);
});

final personalRecordsProvider = FutureProvider<List<PersonalRecord>>((ref) {
  return ref.watch(workoutRepositoryProvider).personalRecords();
});

final oneRepMaxTrendProvider =
    FutureProvider.family<List<MapEntry<DateTime, double>>, String>((ref, exerciseId) {
  return ref.watch(workoutRepositoryProvider).oneRepMaxTrend(exerciseId);
});

/// Live state of an in-progress workout session.
class ActiveWorkoutState {
  final String sessionId;
  final Workout workout;
  final Map<String, List<WorkoutSetLog>> setLogs; // WorkoutExercise.id -> sets
  final int currentExerciseIndex;
  final DateTime startedAt;
  final Duration pausedTotal;
  final DateTime? pausedAt;
  final DateTime? restEndsAt;
  final int restTotalSeconds;

  const ActiveWorkoutState({
    required this.sessionId,
    required this.workout,
    required this.setLogs,
    required this.startedAt,
    this.currentExerciseIndex = 0,
    this.pausedTotal = Duration.zero,
    this.pausedAt,
    this.restEndsAt,
    this.restTotalSeconds = 0,
  });

  bool get isPaused => pausedAt != null;
  bool get isResting => restEndsAt != null;

  int elapsedSeconds(DateTime now) {
    final end = pausedAt ?? now;
    final secs = end.difference(startedAt).inSeconds - pausedTotal.inSeconds;
    return secs < 0 ? 0 : secs;
  }

  int restRemaining(DateTime now) {
    final end = restEndsAt;
    if (end == null) return 0;
    final r = end.difference(now).inMilliseconds;
    return r <= 0 ? 0 : (r / 1000).ceil();
  }

  WorkoutExercise get currentExercise {
    final i = currentExerciseIndex.clamp(0, workout.exercises.length - 1);
    return workout.exercises[i];
  }

  List<WorkoutSetLog> setsFor(WorkoutExercise we) => setLogs[we.id] ?? const [];

  bool isExerciseDone(WorkoutExercise we) {
    final sets = setsFor(we);
    return sets.isNotEmpty && sets.every((s) => s.isCompleted);
  }

  int get completedSets =>
      setLogs.values.fold(0, (sum, list) => sum + list.where((s) => s.isCompleted).length);

  int get totalSets => setLogs.values.fold(0, (sum, list) => sum + list.length);

  double get volumeKg => setLogs.values.fold(
        0.0,
        (sum, list) => sum + list.where((s) => s.isCompleted).fold(0.0, (a, s) => a + s.volume),
      );

  int get exercisesDone => workout.exercises.where(isExerciseDone).length;

  ActiveWorkoutState copyWith({
    Map<String, List<WorkoutSetLog>>? setLogs,
    int? currentExerciseIndex,
    Duration? pausedTotal,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    DateTime? restEndsAt,
    bool clearRest = false,
    int? restTotalSeconds,
  }) {
    return ActiveWorkoutState(
      sessionId: sessionId,
      workout: workout,
      setLogs: setLogs ?? this.setLogs,
      startedAt: startedAt,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      pausedTotal: pausedTotal ?? this.pausedTotal,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      restEndsAt: clearRest ? null : (restEndsAt ?? this.restEndsAt),
      restTotalSeconds: restTotalSeconds ?? this.restTotalSeconds,
    );
  }
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState?> {
  @override
  ActiveWorkoutState? build() => null;

  double _defaultWeight(Exercise ex) {
    if (!ex.usesWeight) return 0;
    switch (ex.equipment) {
      case 'Barbell':
        return 20;
      case 'Dumbbells':
        return 10;
      case 'Kettlebell':
        return 12;
      default:
        return 20;
    }
  }

  /// Starts [workout], or keeps the current session if it is the same workout.
  Future<void> start(Workout workout) async {
    final current = state;
    if (current != null && current.workout.id == workout.id) return;
    if (current != null) await discard();

    final repo = ref.read(workoutRepositoryProvider);
    final sessionId = await repo.startSession(workout);
    final logs = <String, List<WorkoutSetLog>>{};
    for (final we in workout.exercises) {
      final last = await repo.lastSetFor(we.exercise.id);
      final target = FitnessCalc.parseLeadingInt(we.targetReps, fallback: we.exercise.isTimed ? 30 : 8);
      final weight = we.exercise.usesWeight ? (last?.weightKg ?? _defaultWeight(we.exercise)) : 0.0;
      logs[we.id] = List.generate(
        we.targetSets,
        (i) => WorkoutSetLog(
          id: '${sessionId}_${we.id}_$i',
          exerciseId: we.exercise.id,
          setNumber: i + 1,
          weightKg: weight,
          reps: target,
          rpe: we.targetRpe ?? 8.0,
        ),
      );
    }
    state = ActiveWorkoutState(
      sessionId: sessionId,
      workout: workout,
      setLogs: logs,
      startedAt: DateTime.now(),
    );
  }

  WorkoutExercise? _we(String weId) {
    final s = state;
    if (s == null) return null;
    for (final we in s.workout.exercises) {
      if (we.id == weId) return we;
    }
    return null;
  }

  void selectExercise(int index) {
    final s = state;
    if (s == null || index < 0 || index >= s.workout.exercises.length) return;
    state = s.copyWith(currentExerciseIndex: index);
  }

  /// Marks the set complete, starts the rest timer and advances when done.
  void completeSet(String weId, int setIndex) {
    final s = state;
    final we = _we(weId);
    if (s == null || we == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(s.setLogs);
    final sets = List<WorkoutSetLog>.from(logs[weId] ?? const []);
    if (setIndex < 0 || setIndex >= sets.length) return;

    final updated = sets[setIndex].copyWith(isCompleted: true);
    sets[setIndex] = updated;
    logs[weId] = sets;
    ref.read(workoutRepositoryProvider).upsertSet(s.sessionId, updated);

    var nextIndex = s.currentExerciseIndex;
    if (sets.every((x) => x.isCompleted)) {
      final exercises = s.workout.exercises;
      for (var step = 1; step <= exercises.length; step++) {
        final candidate = (s.currentExerciseIndex + step) % exercises.length;
        final cs = logs[exercises[candidate].id] ?? const [];
        if (cs.any((x) => !x.isCompleted)) {
          nextIndex = candidate;
          break;
        }
      }
    }

    final allDone = logs.values.every((list) => list.every((x) => x.isCompleted));
    final rest = we.restSeconds;
    state = s.copyWith(
      setLogs: logs,
      currentExerciseIndex: nextIndex,
      restEndsAt: (!allDone && rest > 0) ? DateTime.now().add(Duration(seconds: rest)) : null,
      clearRest: allDone || rest <= 0,
      restTotalSeconds: rest,
    );
  }

  void uncompleteSet(String weId, int setIndex) {
    final s = state;
    if (s == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(s.setLogs);
    final sets = List<WorkoutSetLog>.from(logs[weId] ?? const []);
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets[setIndex] = sets[setIndex].copyWith(isCompleted: false);
    logs[weId] = sets;
    ref.read(workoutRepositoryProvider).deleteSet(sets[setIndex].id);
    state = s.copyWith(setLogs: logs);
  }

  /// Updates weight/reps; weight changes carry over to later unfinished sets.
  void updateSet(String weId, int setIndex, {double? weightKg, int? reps}) {
    final s = state;
    if (s == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(s.setLogs);
    final sets = List<WorkoutSetLog>.from(logs[weId] ?? const []);
    if (setIndex < 0 || setIndex >= sets.length) return;
    final w = weightKg == null ? null : (weightKg < 0 ? 0.0 : weightKg);
    final r = reps == null ? null : (reps < 0 ? 0 : reps);
    sets[setIndex] = sets[setIndex].copyWith(weightKg: w, reps: r);
    if (w != null) {
      for (var i = setIndex + 1; i < sets.length; i++) {
        if (!sets[i].isCompleted) sets[i] = sets[i].copyWith(weightKg: w);
      }
    }
    logs[weId] = sets;
    if (sets[setIndex].isCompleted) {
      ref.read(workoutRepositoryProvider).upsertSet(s.sessionId, sets[setIndex]);
    }
    state = s.copyWith(setLogs: logs);
  }

  void addSet(String weId) {
    final s = state;
    if (s == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(s.setLogs);
    final sets = List<WorkoutSetLog>.from(logs[weId] ?? const []);
    if (sets.isEmpty) return;
    final last = sets.last;
    sets.add(WorkoutSetLog(
      id: '${s.sessionId}_${weId}_${sets.length}_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: last.exerciseId,
      setNumber: sets.length + 1,
      weightKg: last.weightKg,
      reps: last.reps,
      rpe: last.rpe,
    ));
    logs[weId] = sets;
    state = s.copyWith(setLogs: logs);
  }

  void removeLastSet(String weId) {
    final s = state;
    if (s == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(s.setLogs);
    final sets = List<WorkoutSetLog>.from(logs[weId] ?? const []);
    if (sets.length <= 1 || sets.last.isCompleted) return;
    sets.removeLast();
    logs[weId] = sets;
    state = s.copyWith(setLogs: logs);
  }

  void skipRest() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(clearRest: true);
  }

  void addRest(int seconds) {
    final s = state;
    final end = s?.restEndsAt;
    if (s == null || end == null) return;
    state = s.copyWith(
      restEndsAt: end.add(Duration(seconds: seconds)),
      restTotalSeconds: s.restTotalSeconds + seconds,
    );
  }

  void togglePause() {
    final s = state;
    if (s == null) return;
    final pausedAt = s.pausedAt;
    if (pausedAt != null) {
      final pausedFor = DateTime.now().difference(pausedAt);
      final rest = s.restEndsAt;
      state = s.copyWith(
        pausedTotal: s.pausedTotal + pausedFor,
        clearPausedAt: true,
        restEndsAt: rest?.add(pausedFor),
      );
    } else {
      state = s.copyWith(pausedAt: DateTime.now());
    }
  }

  /// Saves the session and returns a summary (null if nothing was logged).
  Future<WorkoutSummary?> finish(UserSettings settings) async {
    final s = state;
    if (s == null) return null;
    final repo = ref.read(workoutRepositoryProvider);
    if (s.completedSets == 0) {
      await repo.deleteSession(s.sessionId);
      state = null;
      return null;
    }

    final previousBest = {
      for (final pr in await repo.personalRecords(excludeSessionId: s.sessionId))
        pr.exerciseId: pr.estimatedOneRepMax,
    };
    final newRecords = <String>[];
    for (final we in s.workout.exercises) {
      if (!we.exercise.usesWeight) continue;
      final best = s
          .setsFor(we)
          .where((x) => x.isCompleted && x.weightKg > 0)
          .fold<double>(0, (m, x) {
        final e = FitnessCalc.epley1Rm(x.weightKg, x.reps);
        return e > m ? e : m;
      });
      final prev = previousBest[we.exercise.id];
      if (prev != null && best > prev + 0.01 && !newRecords.contains(we.exercise.name)) {
        newRecords.add(we.exercise.name);
      }
    }

    final duration = s.elapsedSeconds(DateTime.now());
    final kcal = FitnessCalc.metKcal(
      FitnessCalc.metForCategory(s.workout.category),
      settings.weightKg,
      duration,
    );
    final session = await repo.finishSession(
      sessionId: s.sessionId,
      durationSeconds: duration,
      caloriesBurned: kcal,
    );
    state = null;
    ref.invalidate(recentSessionsProvider);
    ref.invalidate(weekSessionsProvider);
    ref.invalidate(personalRecordsProvider);
    ref.invalidate(oneRepMaxTrendProvider);
    return WorkoutSummary(
      session: session,
      newRecords: newRecords,
      xpEarned: 100 + session.setsCompleted * 5,
    );
  }

  Future<void> discard() async {
    final s = state;
    if (s == null) return;
    state = null;
    await ref.read(workoutRepositoryProvider).deleteSession(s.sessionId);
  }
}

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>(ActiveWorkoutNotifier.new);
