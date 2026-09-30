import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/nutrition_model.dart';
import '../../../data/repositories/nutrition_repository.dart';
import 'food_search_modal.dart';
import 'widgets/daily_calorie_card.dart';
import 'widgets/diet_suggestions_view.dart';

/// Screen managing daily calories, macronutrient splits, logged meals, and diet suggestions.
class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final _repository = NutritionRepository();
  List<NutritionItem> _loggedFoods = [];
  int _selectedTab = 0; // 0: Track Meals, 1: Diet Suggestions
  bool _isLoading = true;

  String get _today => DateTime.now().toIso8601String().substring(0, 10);
  double get totalCalories => _loggedFoods.fold(0, (sum, i) => sum + i.calories);
  double get totalProtein => _loggedFoods.fold(0, (sum, i) => sum + i.proteinGrams);
  double get totalCarbs => _loggedFoods.fold(0, (sum, i) => sum + i.carbsGrams);
  double get totalFat => _loggedFoods.fold(0, (sum, i) => sum + i.fatGrams);

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await _repository.getLoggedMeals(_today);
    if (mounted) setState(() { _loggedFoods = meals; _isLoading = false; });
  }

  void _addFood(NutritionItem food) async {
    final item = NutritionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: food.name,
      brand: food.brand,
      servingSize: food.servingSize,
      servingUnit: food.servingUnit,
      calories: food.calories,
      proteinGrams: food.proteinGrams,
      carbsGrams: food.carbsGrams,
      fatGrams: food.fatGrams,
      mealType: food.mealType,
    );
    await _repository.addMeal(item, _today);
    _loadMeals();
  }

  void _openSearch([String? initialQuery]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodSearchModal(onFoodSelected: _addFood),
    );
  }

  @override
  Widget build(BuildContext context) {
    const targetCalories = 2450.0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      appBar: AppBar(title: Text('Nutrition & Diet', style: AppTypography.headlineMedium)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Row(children: [_tabBtn(0, 'Track Meals', LucideIcons.utensils), _tabBtn(1, 'Diet Suggestions', LucideIcons.sparkles)]),
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 0) ...[
              DailyCalorieCard(
                targetCalories: targetCalories,
                totalCalories: totalCalories,
                totalProtein: totalProtein,
                totalCarbs: totalCarbs,
                totalFat: totalFat,
              ),
              const SizedBox(height: 16),
              _buildMealsHeader(),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primaryCoral)))
              else if (_loggedFoods.isEmpty)
                _emptyState()
              else
                ..._loggedFoods.map((f) => _foodTile(f)),
            ] else ...[
              DietSuggestionsView(onAddFoodQuery: (food) => _openSearch(food)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealsHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Logged Meals', style: AppTypography.titleLarge),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(minimumSize: const Size(110, 36), padding: const EdgeInsets.symmetric(horizontal: 12)),
        onPressed: () => _openSearch(),
        icon: const Icon(LucideIcons.plus, size: 14),
        label: Text('Add Food', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
      ),
    ]);
  }

  Widget _tabBtn(int idx, String title, IconData icon) {
    final isSel = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSel ? AppColors.primaryCoral : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: isSel ? Colors.white : AppColors.textBody),
            const SizedBox(width: 6),
            Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 13, color: isSel ? Colors.white : AppColors.textHeadline)),
          ]),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: AppTheme.cardDecoration,
      child: Column(children: [
        const Icon(LucideIcons.utensilsCrossed, color: AppColors.primaryCoral, size: 28),
        const SizedBox(height: 10),
        Text('No meals logged today', style: AppTypography.titleMedium),
        const SizedBox(height: 4),
        Text('Pick healthy fitness foods or search Open Food Facts.', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () => _openSearch(), icon: const Icon(LucideIcons.plus, size: 14), label: const Text('Log First Meal')),
      ]),
    );
  }

  Widget _foodTile(NutritionItem f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.name, style: AppTypography.titleMedium),
          Text('${f.mealType} • ${f.calories.toInt()} kcal', style: AppTypography.bodyMedium.copyWith(fontSize: 11)),
        ])),
        Text('P: ${f.proteinGrams.toInt()}g | C: ${f.carbsGrams.toInt()}g', style: AppTypography.monoNumber(fontSize: 11)),
        IconButton(icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textMuted), onPressed: () async {
          await _repository.deleteMeal(f.id);
          _loadMeals();
        }),
      ]),
    );
  }
}
