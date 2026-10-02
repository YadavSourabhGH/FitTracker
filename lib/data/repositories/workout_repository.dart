import 'package:sqflite/sqflite.dart';
import '../../core/utils/fitness_calc.dart';
import '../local/database_helper.dart';
import '../models/workout_model.dart';

/// Workouts catalogue, live sessions and training history in SQLite.
class WorkoutRepository {
  final DatabaseHelper _dbHelper;

  WorkoutRepository({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Workout>> getAllWorkouts() async {
    final db = await _dbHelper.database;
    final workoutRows = await db.query('workouts', orderBy: 'rowid ASC');
    final workouts = <Workout>[];
    for (final row in workoutRows) {
      final exercises = await getWorkoutExercises(row['id'] as String);
      workouts.add(Workout.fromMap(row, exercises));
    }
    return workouts;
  }

  Future<Workout?> getWorkout(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Workout.fromMap(rows.first, await getWorkoutExercises(id));
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(String workoutId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT we.id AS weId, we.workoutId, we.exerciseId, we.sortOrder, we.targetSets,
             we.targetReps, we.targetRpe, we.restSeconds,
             e.id, e.name, e.muscleGroup, e.secondaryMuscles, e.equipment, e.mechanicsType,
             e.trackingType, e.setupInstructions, e.executionInstructions, e.commonMistakes,
             e.defaultRestSeconds
      FROM workout_exercises we
      JOIN exercises e ON we.exerciseId = e.id
      WHERE we.workoutId = ?
      ORDER BY we.sortOrder ASC
    ''', [workoutId]);

    return rows.map((r) {
      return WorkoutExercise(
        id: r['weId'] as String,
        workoutId: r['workoutId'] as String,
        exercise: Exercise.fromMap(r),
        sortOrder: (r['sortOrder'] as num).toInt(),
        targetSets: (r['targetSets'] as num).toInt(),
        targetReps: r['targetReps'] as String,
        targetRpe: (r['targetRpe'] as num?)?.toDouble(),
        restSeconds: (r['restSeconds'] as num?)?.toInt() ?? 90,
      );
    }).toList();
  }

  Future<String> startSession(Workout workout) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final sessionId = 'sess_${now.microsecondsSinceEpoch}';
    await db.insert('workout_sessions', {
      'id': sessionId,
      'workoutId': workout.id,
      'title': workout.title,
      'category': workout.category,
      'startTime': now.toIso8601String(),
      'isCompleted': 0,
      'totalVolumeKg': 0.0,
    });
    return sessionId;
  }

  Future<void> upsertSet(String sessionId, WorkoutSetLog setLog) async {
    final db = await _dbHelper.database;
    await db.insert(
      'workout_set_logs',
      {
        'id': setLog.id,
        'sessionId': sessionId,
        'exerciseId': setLog.exerciseId,
        'setNumber': setLog.setNumber,
        'weightKg': setLog.weightKg,
        'reps': setLog.reps,
        'rpe': setLog.rpe,
        'isCompleted': setLog.isCompleted ? 1 : 0,
        'loggedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSet(String setId) async {
    final db = await _dbHelper.database;
    await db.delete('workout_set_logs', where: 'id = ?', whereArgs: [setId]);
  }

  /// Finalises a session; returns the stored session.
  Future<WorkoutSession> finishSession({
    required String sessionId,
    required int durationSeconds,
    required double caloriesBurned,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'workout_set_logs',
      where: 'sessionId = ? AND isCompleted = 1',
      whereArgs: [sessionId],
    );
    var totalVolume = 0.0;
    for (final r in rows) {
      totalVolume += (r['weightKg'] as num).toDouble() * (r['reps'] as num).toInt();
    }
    await db.update(
      'workout_sessions',
      {
        'endTime': DateTime.now().toIso8601String(),
        'durationSeconds': durationSeconds,
        'totalVolumeKg': totalVolume,
        'setsCompleted': rows.length,
        'caloriesBurned': caloriesBurned,
        'isCompleted': 1,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    final updated = await db.query('workout_sessions', where: 'id = ?', whereArgs: [sessionId]);
    return WorkoutSession.fromMap(updated.first);
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await _dbHelper.database;
    await db.delete('workout_set_logs', where: 'sessionId = ?', whereArgs: [sessionId]);
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  /// Removes abandoned, never-finished sessions older than [age].
  Future<void> purgeAbandoned({Duration age = const Duration(hours: 12)}) async {
    final db = await _dbHelper.database;
    final cutoff = DateTime.now().subtract(age).toIso8601String();
    final stale = await db.query(
      'workout_sessions',
      columns: ['id'],
      where: 'isCompleted = 0 AND startTime < ?',
      whereArgs: [cutoff],
    );
    for (final r in stale) {
      await deleteSession(r['id'] as String);
    }
  }

  Future<List<WorkoutSession>> completedSessions({int? limit, DateTime? since}) async {
    final db = await _dbHelper.database;
    final where = StringBuffer('isCompleted = 1');
    final args = <Object>[];
    if (since != null) {
      where.write(' AND startTime >= ?');
      args.add(since.toIso8601String());
    }
    final rows = await db.query(
      'workout_sessions',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'startTime DESC',
      limit: limit,
    );
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<List<LoggedSet>> setsForSession(String sessionId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT l.exerciseId, l.setNumber, l.weightKg, l.reps, e.name, e.trackingType
      FROM workout_set_logs l
      LEFT JOIN exercises e ON e.id = l.exerciseId
      WHERE l.sessionId = ? AND l.isCompleted = 1
      ORDER BY l.loggedAt ASC
    ''', [sessionId]);
    return rows
        .map((r) => LoggedSet(
              exerciseId: r['exerciseId'] as String,
              exerciseName: r['name'] as String? ?? 'Exercise',
              setNumber: (r['setNumber'] as num).toInt(),
              weightKg: (r['weightKg'] as num).toDouble(),
              reps: (r['reps'] as num).toInt(),
              trackingType: trackingTypeFrom(r['trackingType'] as String?),
            ))
        .toList();
  }

  /// Most recent completed set for an exercise (to prefill weight/reps).
  Future<WorkoutSetLog?> lastSetFor(String exerciseId, {String? excludeSessionId}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'workout_set_logs',
      where: excludeSessionId == null
          ? 'exerciseId = ? AND isCompleted = 1'
          : 'exerciseId = ? AND isCompleted = 1 AND sessionId != ?',
      whereArgs: excludeSessionId == null ? [exerciseId] : [exerciseId, excludeSessionId],
      orderBy: 'loggedAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return WorkoutSetLog(
      id: r['id'] as String,
      exerciseId: exerciseId,
      setNumber: (r['setNumber'] as num).toInt(),
      weightKg: (r['weightKg'] as num).toDouble(),
      reps: (r['reps'] as num).toInt(),
      isCompleted: true,
    );
  }

  /// Best estimated 1RM per weighted exercise.
  Future<List<PersonalRecord>> personalRecords({String? excludeSessionId}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT l.exerciseId, l.weightKg, l.reps, l.loggedAt, e.name
      FROM workout_set_logs l
      JOIN exercises e ON e.id = l.exerciseId
      JOIN workout_sessions s ON s.id = l.sessionId
      WHERE l.isCompleted = 1 AND l.weightKg > 0 AND e.trackingType = 'weight_reps'
        AND s.isCompleted = 1 ${excludeSessionId == null ? '' : 'AND l.sessionId != ?'}
    ''', excludeSessionId == null ? [] : [excludeSessionId]);

    final best = <String, PersonalRecord>{};
    for (final r in rows) {
      final id = r['exerciseId'] as String;
      final w = (r['weightKg'] as num).toDouble();
      final reps = (r['reps'] as num).toInt();
      final e1rm = FitnessCalc.epley1Rm(w, reps);
      final current = best[id];
      if (current == null || e1rm > current.estimatedOneRepMax) {
        best[id] = PersonalRecord(
          exerciseId: id,
          exerciseName: r['name'] as String,
          bestWeightKg: w,
          repsAtBest: reps,
          estimatedOneRepMax: e1rm,
          achievedAt: DateTime.tryParse(r['loggedAt'] as String? ?? '') ?? DateTime.now(),
        );
      }
    }
    final list = best.values.toList()
      ..sort((a, b) => b.estimatedOneRepMax.compareTo(a.estimatedOneRepMax));
    return list;
  }

  /// Best e1RM per day for one exercise (oldest first) for trend charts.
  Future<List<MapEntry<DateTime, double>>> oneRepMaxTrend(String exerciseId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT l.weightKg, l.reps, s.startTime
      FROM workout_set_logs l
      JOIN workout_sessions s ON s.id = l.sessionId
      WHERE l.exerciseId = ? AND l.isCompleted = 1 AND s.isCompleted = 1 AND l.weightKg > 0
      ORDER BY s.startTime ASC
    ''', [exerciseId]);
    final byDay = <String, MapEntry<DateTime, double>>{};
    for (final r in rows) {
      final t = DateTime.tryParse(r['startTime'] as String? ?? '') ?? DateTime.now();
      final key = '${t.year}-${t.month}-${t.day}';
      final v = FitnessCalc.epley1Rm((r['weightKg'] as num).toDouble(), (r['reps'] as num).toInt());
      final cur = byDay[key];
      if (cur == null || v > cur.value) {
        byDay[key] = MapEntry(DateTime(t.year, t.month, t.day), v);
      }
    }
    return byDay.values.toList();
  }

  Future<Map<String, int>> totals() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('''
      SELECT COUNT(*) AS workouts,
             COALESCE(SUM(setsCompleted), 0) AS sets,
             COALESCE(SUM(totalVolumeKg), 0) AS volume,
             COALESCE(SUM(durationSeconds), 0) AS seconds
      FROM workout_sessions WHERE isCompleted = 1
    ''');
    final r = res.first;
    return {
      'workouts': (r['workouts'] as num?)?.toInt() ?? 0,
      'sets': (r['sets'] as num?)?.toInt() ?? 0,
      'volume': (r['volume'] as num?)?.round() ?? 0,
      'seconds': (r['seconds'] as num?)?.toInt() ?? 0,
    };
  }
}
