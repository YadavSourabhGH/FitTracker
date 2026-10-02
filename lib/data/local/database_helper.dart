import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'workout_seed_data.dart';

/// SQLite database manager for offline-first FitTrackr storage.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  /// Overridable for tests (e.g. `inMemoryDatabasePath`).
  static String? pathOverride;

  static const int schemaVersion = 2;

  DatabaseHelper._init();

  Future<Database> get database async {
    final existing = _database;
    if (existing != null && existing.isOpen) return existing;
    final db = await _initDB('fittrackr_v1.db');
    _database = db;
    return db;
  }

  Future<Database> _initDB(String fileName) async {
    final path = pathOverride ?? join(await getDatabasesPath(), fileName);
    return openDatabase(
      path,
      version: schemaVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createCatalogTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        estimatedMinutes INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        muscleGroup TEXT NOT NULL,
        secondaryMuscles TEXT,
        equipment TEXT,
        mechanicsType TEXT,
        trackingType TEXT NOT NULL DEFAULT 'weight_reps',
        setupInstructions TEXT,
        executionInstructions TEXT,
        commonMistakes TEXT,
        defaultRestSeconds INTEGER DEFAULT 90
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_exercises (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        sortOrder INTEGER NOT NULL,
        targetSets INTEGER NOT NULL,
        targetReps TEXT NOT NULL,
        targetRpe REAL,
        restSeconds INTEGER DEFAULT 90,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createV2Tables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hourly_steps (
        dateString TEXT NOT NULL,
        hour INTEGER NOT NULL,
        steps INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (dateString, hour)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS water_logs (
        dateString TEXT PRIMARY KEY,
        glasses INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS weight_logs (
        dateString TEXT PRIMARY KEY,
        weightKg REAL NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_nutrition_date ON nutrition_logs (dateString)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_setlogs_session ON workout_set_logs (sessionId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_setlogs_exercise ON workout_set_logs (exerciseId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_start ON workout_sessions (startTime)');
  }

  Future<void> _createDB(Database db, int version) async {
    await _createCatalogTables(db);

    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        workoutId TEXT,
        title TEXT,
        category TEXT,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationSeconds INTEGER DEFAULT 0,
        totalVolumeKg REAL DEFAULT 0.0,
        setsCompleted INTEGER DEFAULT 0,
        caloriesBurned REAL DEFAULT 0.0,
        isCompleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_set_logs (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        reps INTEGER NOT NULL,
        rpe REAL DEFAULT 8.0,
        isCompleted INTEGER DEFAULT 0,
        loggedAt TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_steps (
        dateString TEXT PRIMARY KEY,
        stepCount INTEGER DEFAULT 0,
        distanceMeters REAL DEFAULT 0.0,
        activeCalories REAL DEFAULT 0.0,
        source TEXT NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE nutrition_logs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        servingSize REAL NOT NULL,
        servingUnit TEXT NOT NULL,
        calories REAL NOT NULL,
        proteinGrams REAL NOT NULL,
        carbsGrams REAL NOT NULL,
        fatGrams REAL NOT NULL,
        mealType TEXT NOT NULL,
        dateString TEXT NOT NULL
      )
    ''');

    await _createV2Tables(db);
    await WorkoutSeedData.seed(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Session metadata columns.
      for (final col in const [
        'title TEXT',
        'category TEXT',
        'durationSeconds INTEGER DEFAULT 0',
        'setsCompleted INTEGER DEFAULT 0',
        'caloriesBurned REAL DEFAULT 0.0',
      ]) {
        try {
          await db.execute('ALTER TABLE workout_sessions ADD COLUMN $col');
        } catch (_) {
          // Column already exists.
        }
      }
      // Rebuild the read-only workout catalogue with the expanded library.
      await db.execute('DROP TABLE IF EXISTS workout_exercises');
      await db.execute('DROP TABLE IF EXISTS exercises');
      await db.execute('DROP TABLE IF EXISTS workouts');
      await _createCatalogTables(db);
      await _createV2Tables(db);
      await WorkoutSeedData.seed(db);
      // Legacy sessions were never finalised with titles.
      await db.execute(
        "UPDATE workout_sessions SET title = 'Workout' WHERE title IS NULL",
      );
    }
  }

  /// Deletes every user-generated record while keeping the workout catalogue.
  Future<void> clearUserData() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in const [
        'workout_set_logs',
        'workout_sessions',
        'daily_steps',
        'hourly_steps',
        'nutrition_logs',
        'water_logs',
        'weight_logs',
      ]) {
        await txn.delete(table);
      }
    });
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null && db.isOpen) await db.close();
  }
}
