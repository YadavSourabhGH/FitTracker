import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/nutrition_model.dart';

/// Repository for offline-first SQLite persistence of logged nutrition items.
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
      orderBy: 'rowid DESC',
    );
    return rows.map((r) => NutritionItem.fromMap(r)).toList();
  }

  Future<void> addMeal(NutritionItem item, String dateString) async {
    final db = await _dbHelper.database;
    final map = item.toMap();
    map['dateString'] = dateString;
    await db.insert(
      'nutrition_logs',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMeal(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'nutrition_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
