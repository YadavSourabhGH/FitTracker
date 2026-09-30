import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_model.dart';
import '../../data/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

/// Provider fetching all pre-made and custom workouts
final allWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getAllWorkouts();
});

/// State of an active workout session being tracked
class ActiveWorkoutState {
  final String sessionId;
  final Workout workout;
  final Map<String, List<WorkoutSetLog>> setLogs; // exerciseId -> list of sets
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final bool isResting;
  final int restSecondsRemaining;

  const ActiveWorkoutState({
    required this.sessionId,
    required this.workout,
    required this.setLogs,
    this.currentExerciseIndex = 0,
    this.elapsedSeconds = 0,
    this.isResting = false,
    this.restSecondsRemaining = 0,
  });

  ActiveWorkoutState copyWith({
    Map<String, List<WorkoutSetLog>>? setLogs,
    int? currentExerciseIndex,
    int? elapsedSeconds,
    bool? isResting,
    int? restSecondsRemaining,
  }) {
    return ActiveWorkoutState(
      sessionId: sessionId,
      workout: workout,
      setLogs: setLogs ?? this.setLogs,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isResting: isResting ?? this.isResting,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
    );
  }
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState?> {
  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);

  @override
  ActiveWorkoutState? build() => null;

  void selectExercise(int index) {
    if (state != null && index >= 0 && index < state!.workout.exercises.length) {
      state = state!.copyWith(currentExerciseIndex: index);
    }
  }

  void clearSession() {
    state = null;
  }

  void dismissRest() {
    if (state != null) {
      state = state!.copyWith(isResting: false);
    }
  }

  Future<void> startWorkout(Workout workout) async {
    final sessionId = await _repo.startSession(workout.id);
    final initialLogs = <String, List<WorkoutSetLog>>{};

    for (final we in workout.exercises) {
      initialLogs[we.exercise.id] = List.generate(
        we.targetSets,
        (index) => WorkoutSetLog(
          id: '${sessionId}_${we.exercise.id}_$index',
          exerciseId: we.exercise.id,
          setNumber: index + 1,
          weightKg: 60.0,
          reps: 8,
          rpe: we.targetRpe ?? 8.0,
        ),
      );
    }

    state = ActiveWorkoutState(
      sessionId: sessionId,
      workout: workout,
      setLogs: initialLogs,
    );
  }

  void toggleSetComplete(String exerciseId, int setIndex) {
    if (state == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(state!.setLogs);
    final exerciseSets = List<WorkoutSetLog>.from(logs[exerciseId] ?? []);

    if (setIndex < exerciseSets.length) {
      final targetSet = exerciseSets[setIndex];
      targetSet.isCompleted = !targetSet.isCompleted;

      // Save to SQLite
      if (targetSet.isCompleted) {
        _repo.logSet(state!.sessionId, targetSet);
      }

      state = state!.copyWith(
        setLogs: logs,
        isResting: targetSet.isCompleted,
        restSecondsRemaining: targetSet.isCompleted ? 90 : 0,
      );
    }
  }

  void updateSetWeightReps(String exerciseId, int setIndex, double weight, int reps) {
    if (state == null) return;
    final logs = Map<String, List<WorkoutSetLog>>.from(state!.setLogs);
    final exerciseSets = logs[exerciseId];
    if (exerciseSets != null && setIndex < exerciseSets.length) {
      exerciseSets[setIndex].weightKg = weight;
      exerciseSets[setIndex].reps = reps;
      state = state!.copyWith(setLogs: logs);
    }
  }

  Future<double> finishWorkout() async {
    if (state == null) return 0.0;
    final volume = await _repo.finishSession(state!.sessionId);
    state = null;
    return volume;
  }
}

final activeWorkoutProvider = NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>(ActiveWorkoutNotifier.new);
