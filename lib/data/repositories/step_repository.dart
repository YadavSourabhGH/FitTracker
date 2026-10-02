import 'package:sqflite/sqflite.dart';
import '../../core/utils/date_keys.dart';
import '../local/database_helper.dart';
import '../models/step_record_model.dart';

/// Persists daily step totals and hourly distribution.
class StepRepository {
  final DatabaseHelper _dbHelper;

  StepRepository({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<DailyStepRecord?> getDay(String dateString) async {
    final db = await _dbHelper.database;
    final rows = await db.query('daily_steps', where: 'dateString = ?', whereArgs: [dateString]);
    if (rows.isEmpty) return null;
    return DailyStepRecord.fromMap(rows.first);
  }

  Future<void> saveDay(DailyStepRecord record) async {
    final db = await _dbHelper.database;
    await db.insert('daily_steps', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Adds [delta] steps to the bucket for [hour] of [dateString].
  Future<void> addHourly(String dateString, int hour, int delta) async {
    if (delta <= 0) return;
    final db = await _dbHelper.database;
    await db.rawInsert('''
      INSERT INTO hourly_steps (dateString, hour, steps) VALUES (?, ?, ?)
      ON CONFLICT(dateString, hour) DO UPDATE SET steps = steps + excluded.steps
    ''', [dateString, hour, delta]);
  }

  Future<List<HourlyStepBucket>> getHourly(String dateString) async {
    final db = await _dbHelper.database;
    final rows = await db.query('hourly_steps', where: 'dateString = ?', whereArgs: [dateString]);
    final byHour = <int, int>{
      for (final r in rows) (r['hour'] as num).toInt(): (r['steps'] as num).toInt(),
    };
    return List.generate(24, (h) => HourlyStepBucket(hour: h, steps: byHour[h] ?? 0));
  }

  /// Records for each of the last [days] days (oldest first), zero-filled.
  Future<List<DailyStepRecord>> history(int days) async {
    final keys = DateKeys.lastNDays(days);
    final db = await _dbHelper.database;
    final rows = await db.query(
      'daily_steps',
      where: 'dateString >= ? AND dateString <= ?',
      whereArgs: [keys.first, keys.last],
    );
    final map = {for (final r in rows) r['dateString'] as String: DailyStepRecord.fromMap(r)};
    return keys.map((k) => map[k] ?? DailyStepRecord.empty(k)).toList();
  }

  Future<List<DailyStepRecord>> allDays() async {
    final db = await _dbHelper.database;
    final rows = await db.query('daily_steps', orderBy: 'dateString ASC');
    return rows.map(DailyStepRecord.fromMap).toList();
  }

  /// Consecutive days ending yesterday whose step count reached [goal].
  Future<int> streakEndingYesterday(int goal) async {
    if (goal <= 0) return 0;
    final records = await history(400);
    final byDay = {for (final r in records) r.dateString: r.stepCount};
    var streak = 0;
    var cursor = DateKeys.shift(DateKeys.today(), -1);
    while ((byDay[cursor] ?? 0) >= goal) {
      streak++;
      cursor = DateKeys.shift(cursor, -1);
    }
    return streak;
  }

  static int longestStreak(List<DailyStepRecord> sorted, int goal) {
    if (goal <= 0) return 0;
    var best = 0;
    var run = 0;
    String? prev;
    for (final r in sorted) {
      final hit = r.stepCount >= goal;
      if (hit && prev != null && DateKeys.shift(prev, 1) == r.dateString && run > 0) {
        run++;
      } else if (hit) {
        run = 1;
      } else {
        run = 0;
      }
      if (run > best) best = run;
      prev = r.dateString;
    }
    return best;
  }
}
