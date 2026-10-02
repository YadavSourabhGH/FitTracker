import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';

/// Daily water intake (glasses of 250 ml) and body-weight log.
class HydrationRepository {
  final DatabaseHelper _dbHelper;

  HydrationRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> getGlasses(String dateString) async {
    final db = await _dbHelper.database;
    final rows = await db.query('water_logs', where: 'dateString = ?', whereArgs: [dateString]);
    if (rows.isEmpty) return 0;
    return (rows.first['glasses'] as num?)?.toInt() ?? 0;
  }

  Future<void> setGlasses(String dateString, int glasses) async {
    final db = await _dbHelper.database;
    await db.insert(
      'water_logs',
      {'dateString': dateString, 'glasses': glasses < 0 ? 0 : glasses},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> daysGoalReached(int goal) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM water_logs WHERE glasses >= ?', [goal]);
    return (res.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<void> logWeight(String dateString, double weightKg) async {
    final db = await _dbHelper.database;
    await db.insert(
      'weight_logs',
      {'dateString': dateString, 'weightKg': weightKg},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Weight entries ordered oldest first.
  Future<List<MapEntry<String, double>>> weightHistory({int limit = 90}) async {
    final db = await _dbHelper.database;
    final rows = await db.query('weight_logs', orderBy: 'dateString DESC', limit: limit);
    final list = rows
        .map((r) => MapEntry(r['dateString'] as String, (r['weightKg'] as num).toDouble()))
        .toList();
    return list.reversed.toList();
  }
}
