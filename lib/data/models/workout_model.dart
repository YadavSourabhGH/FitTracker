/// Data models for workouts, exercises, live sets and completed sessions.
class Workout {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int estimatedMinutes;
  final List<WorkoutExercise> exercises;

  const Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    this.exercises = const [],
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.targetSets);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'estimatedMinutes': estimatedMinutes,
      };

  factory Workout.fromMap(Map<String, dynamic> map, [List<WorkoutExercise>? ex]) {
    return Workout(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Strength',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 45,
      exercises: ex ?? const [],
    );
  }
}

/// How an exercise's sets are measured.
enum TrackingType { weightReps, reps, time }

TrackingType trackingTypeFrom(String? raw) {
  switch (raw) {
    case 'reps':
      return TrackingType.reps;
    case 'time':
      return TrackingType.time;
    default:
      return TrackingType.weightReps;
  }
}

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String secondaryMuscles;
  final String equipment;
  final String mechanicsType;
  final TrackingType trackingType;
  final String setupInstructions;
  final String executionInstructions;
  final String commonMistakes;
  final int defaultRestSeconds;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.secondaryMuscles,
    required this.equipment,
    required this.mechanicsType,
    this.trackingType = TrackingType.weightReps,
    required this.setupInstructions,
    required this.executionInstructions,
    required this.commonMistakes,
    this.defaultRestSeconds = 90,
  });

  bool get usesWeight => trackingType == TrackingType.weightReps;
  bool get isTimed => trackingType == TrackingType.time;

  factory Exercise.fromMap(Map<String, dynamic> map, {String idKey = 'id'}) {
    return Exercise(
      id: map[idKey] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String? ?? '',
      secondaryMuscles: map['secondaryMuscles'] as String? ?? '',
      equipment: map['equipment'] as String? ?? 'Bodyweight',
      mechanicsType: map['mechanicsType'] as String? ?? 'compound',
      trackingType: trackingTypeFrom(map['trackingType'] as String?),
      setupInstructions: map['setupInstructions'] as String? ?? '',
      executionInstructions: map['executionInstructions'] as String? ?? '',
      commonMistakes: map['commonMistakes'] as String? ?? '',
      defaultRestSeconds: (map['defaultRestSeconds'] as num?)?.toInt() ?? 90,
    );
  }
}

class WorkoutExercise {
  final String id;
  final String workoutId;
  final Exercise exercise;
  final int sortOrder;
  final int targetSets;
  final String targetReps;
  final double? targetRpe;
  final int restSeconds;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exercise,
    required this.sortOrder,
    required this.targetSets,
    required this.targetReps,
    this.targetRpe,
    required this.restSeconds,
  });

  /// Human readable target, e.g. "3 x 8-10" or "3 x 30s".
  String get targetLabel {
    if (exercise.isTimed) {
      final t = targetReps.endsWith('s') ? targetReps : '${targetReps}s';
      return '$targetSets x $t';
    }
    return '$targetSets x $targetReps';
  }
}

/// A single set inside an active session (immutable).
class WorkoutSetLog {
  final String id;
  final String exerciseId;
  final int setNumber;
  final double weightKg;
  final int reps; // seconds for timed exercises
  final double rpe;
  final bool isCompleted;

  const WorkoutSetLog({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.rpe = 8.0,
    this.isCompleted = false,
  });

  double get volume => weightKg * reps;

  WorkoutSetLog copyWith({double? weightKg, int? reps, double? rpe, bool? isCompleted}) {
    return WorkoutSetLog(
      id: id,
      exerciseId: exerciseId,
      setNumber: setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// A completed (or in-progress) workout session persisted in SQLite.
class WorkoutSession {
  final String id;
  final String? workoutId;
  final String title;
  final String category;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double totalVolumeKg;
  final int setsCompleted;
  final double caloriesBurned;
  final bool isCompleted;

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.title,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.setsCompleted,
    required this.caloriesBurned,
    required this.isCompleted,
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    final start = DateTime.tryParse(map['startTime'] as String? ?? '') ?? DateTime.now();
    final endRaw = map['endTime'] as String?;
    return WorkoutSession(
      id: map['id'] as String,
      workoutId: map['workoutId'] as String?,
      title: map['title'] as String? ?? 'Workout',
      category: map['category'] as String? ?? 'Strength',
      startTime: start,
      endTime: endRaw == null ? null : DateTime.tryParse(endRaw),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0,
      setsCompleted: (map['setsCompleted'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0,
      isCompleted: ((map['isCompleted'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

/// A logged set joined with its exercise name (history views).
class LoggedSet {
  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final double weightKg;
  final int reps;
  final TrackingType trackingType;

  const LoggedSet({
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    required this.trackingType,
  });
}

/// Best lift per exercise, computed from logged sets.
class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double bestWeightKg;
  final int repsAtBest;
  final double estimatedOneRepMax;
  final DateTime achievedAt;

  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.bestWeightKg,
    required this.repsAtBest,
    required this.estimatedOneRepMax,
    required this.achievedAt,
  });
}

/// Result returned after finishing an active session.
class WorkoutSummary {
  final WorkoutSession session;
  final List<String> newRecords; // exercise names with a new best e1RM
  final int xpEarned;

  const WorkoutSummary({
    required this.session,
    required this.newRecords,
    required this.xpEarned,
  });
}
