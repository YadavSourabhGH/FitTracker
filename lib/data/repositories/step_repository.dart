import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/step_record_model.dart';
import '../services/health_connect_service.dart';
import '../services/pedometer_service.dart';

/// Repository synchronizing and caching step records between Health Connect and Hardware Sensor.
class StepRepository {
  final DatabaseHelper _dbHelper;
  final HealthConnectService _healthConnectService;
  final PedometerService _pedometerService;

  StepRepository({
    DatabaseHelper? dbHelper,
    HealthConnectService? healthConnectService,
    PedometerService? pedometerService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _healthConnectService = healthConnectService ?? HealthConnectService(),
        _pedometerService = pedometerService ?? PedometerService();

  /// Gets today's step count, checking Health Connect first, then falling back to sensor
  Future<DailyStepRecord> getTodaySteps() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final db = await _dbHelper.database;

    // Check if Health Connect has fresh data
    final healthRecord = await _healthConnectService.readTodayRecord();
    if (healthRecord != null && healthRecord.stepCount > 0) {
      await saveDailyStepRecord(healthRecord);
      return healthRecord;
    }

    // Check cached SQLite record
    final rows = await db.query(
      'daily_steps',
      where: 'dateString = ?',
      whereArgs: [today],
    );

    final sensorSteps = _pedometerService.currentStepsToday;

    if (rows.isNotEmpty) {
      final cached = DailyStepRecord.fromMap(rows.first);
      if (sensorSteps > cached.stepCount) {
        final updated = DailyStepRecord(
          dateString: today,
          stepCount: sensorSteps,
          distanceMeters: sensorSteps * 0.762,
          activeCalories: sensorSteps * 0.04,
          source: 'HARDWARE_SENSOR',
          syncedAt: DateTime.now(),
        );
        await saveDailyStepRecord(updated);
        return updated;
      }
      return cached;
    }

    final fallbackRecord = DailyStepRecord(
      dateString: today,
      stepCount: sensorSteps,
      distanceMeters: sensorSteps * 0.762,
      activeCalories: sensorSteps * 0.04,
      source: 'HARDWARE_SENSOR',
      syncedAt: DateTime.now(),
    );

    await saveDailyStepRecord(fallbackRecord);
    return fallbackRecord;
  }

  /// Saves or updates daily step record
  Future<void> saveDailyStepRecord(DailyStepRecord record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_steps',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches last 7 days of step history
  Future<List<DailyStepRecord>> getLast7Days() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'daily_steps',
      orderBy: 'dateString DESC',
      limit: 7,
    );
    return rows.map((r) => DailyStepRecord.fromMap(r)).toList();
  }
}
