import '../local/database_helper.dart';
import '../models/workout_model.dart';

/// Repository managing workouts, exercises, and active sessions in SQLite.
class WorkoutRepository {
  final DatabaseHelper _dbHelper;

  WorkoutRepository({DatabaseHelper? dbHelper}) 
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fetches all pre-made and custom workouts
  Future<List<Workout>> getAllWorkouts() async {
    final db = await _dbHelper.database;
    final workoutRows = await db.query('workouts');

    final workouts = <Workout>[];
    for (final row in workoutRows) {
      final wId = row['id'] as String;
      final exercises = await getWorkoutExercises(wId);
      workouts.add(Workout.fromMap(row, exercises));
    }
    return workouts;
  }

  /// Fetches exercises configured for a workout
  Future<List<WorkoutExercise>> getWorkoutExercises(String workoutId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT we.*, e.name, e.muscleGroup, e.secondaryMuscles, e.equipment, 
             e.mechanicsType, e.setupInstructions, e.executionInstructions, 
             e.commonMistakes, e.defaultRestSeconds
      FROM workout_exercises we
      JOIN exercises e ON we.exerciseId = e.id
      WHERE we.workoutId = ?
      ORDER BY we.sortOrder ASC
    ''', [workoutId]);

    return rows.map((r) {
      return WorkoutExercise(
        id: r['id'] as String,
        workoutId: r['workoutId'] as String,
        exercise: Exercise.fromMap(r),
        sortOrder: r['sortOrder'] as int,
        targetSets: r['targetSets'] as int,
        targetReps: r['targetReps'] as String,
        targetRpe: (r['targetRpe'] as num?)?.toDouble(),
        restSeconds: r['restSeconds'] as int? ?? 90,
      );
    }).toList();
  }

  /// Creates a new workout session in SQLite
  Future<String> startSession(String workoutId) async {
    final db = await _dbHelper.database;
    final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('workout_sessions', {
      'id': sessionId,
      'workoutId': workoutId,
      'startTime': DateTime.now().toIso8601String(),
      'isCompleted': 0,
      'totalVolumeKg': 0.0,
    });
    return sessionId;
  }

  /// Logs a completed set
  Future<void> logSet(String sessionId, WorkoutSetLog setLog) async {
    final db = await _dbHelper.database;
    await db.insert('workout_set_logs', {
      'id': setLog.id,
      'sessionId': sessionId,
      'exerciseId': setLog.exerciseId,
      'setNumber': setLog.setNumber,
      'weightKg': setLog.weightKg,
      'reps': setLog.reps,
      'rpe': setLog.rpe,
      'isCompleted': setLog.isCompleted ? 1 : 0,
      'loggedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Finalizes an active workout session and computes total volume
  Future<double> finishSession(String sessionId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'workout_set_logs',
      where: 'sessionId = ? AND isCompleted = 1',
      whereArgs: [sessionId],
    );

    double totalVolume = 0.0;
    for (final r in rows) {
      final weight = (r['weightKg'] as num).toDouble();
      final reps = r['reps'] as int;
      totalVolume += (weight * reps);
    }

    await db.update(
      'workout_sessions',
      {
        'endTime': DateTime.now().toIso8601String(),
        'totalVolumeKg': totalVolume,
        'isCompleted': 1,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    return totalVolume;
  }
}
