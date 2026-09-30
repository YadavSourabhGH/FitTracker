import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'workout_seed_data.dart';

/// SQLite Database Manager for offline-first FitTrackr storage.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fittrackr_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Workouts Table
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

    // Exercises Table
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        muscleGroup TEXT NOT NULL,
        secondaryMuscles TEXT,
        equipment TEXT,
        mechanicsType TEXT,
        setupInstructions TEXT,
        executionInstructions TEXT,
        commonMistakes TEXT,
        defaultRestSeconds INTEGER DEFAULT 90
      )
    ''');

    // Workout Exercises join table
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
        FOREIGN KEY (exerciseId) REFERENCES exercises (id)
      )
    ''');

    // Workout Sessions Table
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        workoutId TEXT,
        startTime TEXT NOT NULL,
        endTime TEXT,
        totalVolumeKg REAL DEFAULT 0.0,
        isCompleted INTEGER DEFAULT 0
      )
    ''');

    // Set Logs Table
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

    // Daily Steps Table
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

    // Nutrition Logs Table
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

    // Seed default pre-made workouts and exercises
    await WorkoutSeedData.seed(db);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
