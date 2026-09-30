import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/nutrition_model.dart';
import '../../../data/services/nutrition_api_service.dart';

/// Modal to select healthy foods or search real foods from Open Food Facts API.
class FoodSearchModal extends StatefulWidget {
  final ValueChanged<NutritionItem> onFoodSelected;

  const FoodSearchModal({super.key, required this.onFoodSelected});

  @override
  State<FoodSearchModal> createState() => _FoodSearchModalState();
}

class _FoodSearchModalState extends State<FoodSearchModal> {
  final _searchController = TextEditingController();
  final _apiService = NutritionApiService();
  List<NutritionItem> _results = [];
  bool _isLoading = false;

  static const List<NutritionItem> _commonFoods = [
    NutritionItem(id: 'c1', name: 'Rolled Oats (100g)', brand: 'Whole Grain', servingSize: 100, servingUnit: 'g', calories: 389, proteinGrams: 16.9, carbsGrams: 66.3, fatGrams: 6.9, mealType: 'Breakfast'),
    NutritionItem(id: 'c2', name: 'Boiled Eggs (2 eggs)', brand: 'Protein', servingSize: 100, servingUnit: 'g', calories: 155, proteinGrams: 12.6, carbsGrams: 1.1, fatGrams: 10.6, mealType: 'Breakfast'),
    NutritionItem(id: 'c3', name: 'Grilled Chicken Breast (150g)', brand: 'Lean Poultry', servingSize: 150, servingUnit: 'g', calories: 247, proteinGrams: 46.5, carbsGrams: 0.0, fatGrams: 5.4, mealType: 'Lunch'),
    NutritionItem(id: 'c4', name: 'Greek Yogurt 0% (200g)', brand: 'Dairy', servingSize: 200, servingUnit: 'g', calories: 118, proteinGrams: 20.0, carbsGrams: 7.2, fatGrams: 0.8, mealType: 'Snack'),
    NutritionItem(id: 'c5', name: 'Brown Rice Cooked (150g)', brand: 'Grains', servingSize: 150, servingUnit: 'g', calories: 166, proteinGrams: 3.5, carbsGrams: 35.0, fatGrams: 1.3, mealType: 'Lunch'),
    NutritionItem(id: 'c6', name: 'Banana (1 medium)', brand: 'Fruit', servingSize: 118, servingUnit: 'g', calories: 105, proteinGrams: 1.3, carbsGrams: 27.0, fatGrams: 0.3, mealType: 'Snack'),
    NutritionItem(id: 'c7', name: 'Whey Protein Scoop (30g)', brand: 'Supplement', servingSize: 30, servingUnit: 'g', calories: 120, proteinGrams: 24.0, carbsGrams: 2.0, fatGrams: 1.5, mealType: 'Post-Workout'),
    NutritionItem(id: 'c8', name: 'Grilled Salmon (150g)', brand: 'Seafood', servingSize: 150, servingUnit: 'g', calories: 312, proteinGrams: 34.0, carbsGrams: 0.0, fatGrams: 19.5, mealType: 'Dinner'),
    NutritionItem(id: 'c9', name: 'Avocado (100g)', brand: 'Produce', servingSize: 100, servingUnit: 'g', calories: 160, proteinGrams: 2.0, carbsGrams: 8.5, fatGrams: 14.7, mealType: 'Snack'),
    NutritionItem(id: 'c10', name: 'Apple (1 medium)', brand: 'Fruit', servingSize: 150, servingUnit: 'g', calories: 78, proteinGrams: 0.4, carbsGrams: 21.0, fatGrams: 0.3, mealType: 'Snack'),
  ];

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    final items = await _apiService.searchFood(query);
    if (!mounted) return;
    setState(() {
      _results = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final displayItems = query.isEmpty ? _commonFoods : _results;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Food & Meal', style: AppTypography.titleLarge),
              IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 10),

          // Search Field
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            onChanged: (val) {
              if (val.trim().isEmpty) setState(() => _results = []);
            },
            decoration: InputDecoration(
              hintText: 'Search Open Food Facts or pick below...',
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.primaryCoral, size: 20),
              suffixIcon: IconButton(icon: const Icon(LucideIcons.arrowRight), onPressed: _performSearch),
              filled: true,
              fillColor: AppColors.scaffoldBase,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            query.isEmpty ? 'Popular Nutritious Choices' : 'Search Results (${displayItems.length})',
            style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCoral, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primaryCoral)))
          else if (displayItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No matching items found.', style: AppTypography.bodyMedium),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: displayItems.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.cardBorder),
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    title: Text(item.name, style: AppTypography.titleMedium),
                    subtitle: Text(
                      '${item.calories.toStringAsFixed(0)} kcal • P: ${item.proteinGrams.toStringAsFixed(1)}g | C: ${item.carbsGrams.toStringAsFixed(1)}g | F: ${item.fatGrams.toStringAsFixed(1)}g',
                      style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primaryCoralLight, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.plus, color: AppColors.primaryCoral, size: 16),
                    ),
                    onTap: () {
                      widget.onFoodSelected(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}
}
