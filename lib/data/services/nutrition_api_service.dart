import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_model.dart';

/// Food search against the Open Food Facts public database.
class NutritionApiService {
  static const _searchBaseUrl = 'https://world.openfoodfacts.org/cgi/search.pl';
  static const _headers = {'User-Agent': 'FitTrackr/1.1 (Android; open-source fitness app)'};

  final http.Client _client;

  NutritionApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns per-100 g items. Throws on network failure so the UI can show it.
  Future<List<NutritionItem>> searchFood(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.parse(_searchBaseUrl).replace(queryParameters: {
      'search_terms': q,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '25',
      'fields': 'code,product_name,brands,nutriments',
    });

    final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Food database returned ${response.statusCode}');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    final products = (data is Map ? data['products'] : null) as List<dynamic>? ?? [];
    final seen = <String>{};
    final items = <NutritionItem>[];
    for (final raw in products) {
      if (raw is! Map) continue;
      final name = (raw['product_name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final nutriments = raw['nutriments'] is Map ? raw['nutriments'] as Map : const {};
      final kcal = _num(nutriments['energy-kcal_100g']) ?? _kjToKcal(_num(nutriments['energy_100g']));
      if (kcal == null || kcal <= 0) continue;
      final brand = (raw['brands'] ?? '').toString().split(',').first.trim();
      final key = '${name.toLowerCase()}|${brand.toLowerCase()}';
      if (!seen.add(key)) continue;
      items.add(NutritionItem(
        id: 'off_${raw['code'] ?? items.length}',
        name: name,
        brand: brand,
        servingSize: 100,
        servingUnit: 'g',
        calories: kcal,
        proteinGrams: _num(nutriments['proteins_100g']) ?? 0.0,
        carbsGrams: _num(nutriments['carbohydrates_100g']) ?? 0.0,
        fatGrams: _num(nutriments['fat_100g']) ?? 0.0,
        mealType: 'Snack',
      ));
    }
    return items;
  }

  static double? _num(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static double? _kjToKcal(double? kj) => kj == null ? null : kj / 4.184;
}
