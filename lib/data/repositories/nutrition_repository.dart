import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/nutrition_model.dart';

/// Offline-first SQLite persistence of logged nutrition items.
class NutritionRepository {
  final DatabaseHelper _dbHelper;

  NutritionRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<NutritionItem>> getLoggedMeals(String dateString) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'nutrition_logs',
      where: 'dateString = ?',
      whereArgs: [dateString],
      orderBy: 'rowid ASC',
    );
    return rows.map(NutritionItem.fromMap).toList();
  }

  Future<void> addMeal(NutritionItem item, String dateString) async {
    final db = await _dbHelper.database;
    final map = item.toMap();
    map['dateString'] = dateString;
    await db.insert('nutrition_logs', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMeal(String id) async {
    final db = await _dbHelper.database;
    await db.delete('nutrition_logs', where: 'id = ?', whereArgs: [id]);
  }

  /// Most recently logged distinct foods (single-serving values), for offline quick add.
  Future<List<NutritionItem>> recentFoods({int limit = 12}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT * FROM nutrition_logs
      WHERE rowid IN (SELECT MAX(rowid) FROM nutrition_logs GROUP BY name)
      ORDER BY rowid DESC
      LIMIT ?
    ''', [limit]);
    return rows.map(NutritionItem.fromMap).toList();
  }

  /// Daily calorie totals for the given day keys.
  Future<Map<String, double>> calorieTotals(List<String> days) async {
    if (days.isEmpty) return {};
    final db = await _dbHelper.database;
    final placeholders = List.filled(days.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT dateString, SUM(calories) AS kcal FROM nutrition_logs '
      'WHERE dateString IN ($placeholders) GROUP BY dateString',
      days,
    );
    return {
      for (final r in rows) r['dateString'] as String: (r['kcal'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<int> mealsLogged() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM nutrition_logs');
    return (res.first['c'] as num?)?.toInt() ?? 0;
  }
}
