/// Data models for Workouts, Exercises, and Live Sets.
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

  int get estimatedCalories => estimatedMinutes * 7;

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
      description: map['description'] as String,
      category: map['category'] as String,
      difficulty: map['difficulty'] as String,
      estimatedMinutes: map['estimatedMinutes'] as int? ?? 45,
      exercises: ex ?? const [],
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String secondaryMuscles;
  final String equipment;
  final String mechanicsType;
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
    required this.setupInstructions,
    required this.executionInstructions,
    required this.commonMistakes,
    this.defaultRestSeconds = 90,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'secondaryMuscles': secondaryMuscles,
    'equipment': equipment,
    'mechanicsType': mechanicsType,
    'setupInstructions': setupInstructions,
    'executionInstructions': executionInstructions,
    'commonMistakes': commonMistakes,
    'defaultRestSeconds': defaultRestSeconds,
  };

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      secondaryMuscles: map['secondaryMuscles'] as String? ?? '',
      equipment: map['equipment'] as String? ?? 'Barbell',
      mechanicsType: map['mechanicsType'] as String? ?? 'compound',
      setupInstructions: map['setupInstructions'] as String? ?? '',
      executionInstructions: map['executionInstructions'] as String? ?? '',
      commonMistakes: map['commonMistakes'] as String? ?? '',
      defaultRestSeconds: map['defaultRestSeconds'] as int? ?? 90,
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
}

class WorkoutSetLog {
  final String id;
  final String exerciseId;
  final int setNumber;
  double weightKg;
  int reps;
  double rpe;
  bool isCompleted;

  WorkoutSetLog({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.rpe = 8.0,
    this.isCompleted = false,
  });
}
