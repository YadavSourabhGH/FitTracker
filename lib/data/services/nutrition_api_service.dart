import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_model.dart';

/// Real Nutrition API Service querying Open Food Facts database.
class NutritionApiService {
  static const _searchBaseUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  /// Searches for verified food products by query name
  Future<List<NutritionItem>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(_searchBaseUrl).replace(queryParameters: {
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '15',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List<dynamic>? ?? [];

        return products.map((item) {
          final nutriments = item['nutriments'] as Map<String, dynamic>? ?? {};
          return NutritionItem(
            id: item['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: item['product_name']?.toString() ?? 'Unknown Food',
            brand: item['brands']?.toString() ?? '',
            servingSize: 100.0,
            servingUnit: 'g',
            calories: (nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? 
                      ((nutriments['energy-kcal'] as num?)?.toDouble() ?? 0.0),
            proteinGrams: (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0.0,
            carbsGrams: (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0,
            fatGrams: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0.0,
            mealType: 'snack',
          );
        }).where((item) => item.name.isNotEmpty && item.calories > 0).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
