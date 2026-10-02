import '../models/nutrition_model.dart';

/// Common foods with nutrient values per stated serving, based on USDA
/// FoodData Central reference values. Available offline.
class FoodCatalog {
  FoodCatalog._();

  static NutritionItem _f(String id, String name, String group, double size, String unit, double kcal,
          double p, double c, double f) =>
      NutritionItem(
        id: id,
        name: name,
        brand: group,
        servingSize: size,
        servingUnit: unit,
        calories: kcal,
        proteinGrams: p,
        carbsGrams: c,
        fatGrams: f,
        mealType: 'Snack',
      );

  static final List<NutritionItem> foods = [
    _f('c_oats', 'Rolled oats, dry', 'Grains', 40, 'g', 152, 5.3, 27.2, 2.6),
    _f('c_egg', 'Whole egg, boiled', 'Protein', 50, 'g', 78, 6.3, 0.6, 5.3),
    _f('c_egg_white', 'Egg whites', 'Protein', 100, 'g', 52, 10.9, 0.7, 0.2),
    _f('c_chicken', 'Chicken breast, cooked', 'Protein', 150, 'g', 248, 46.5, 0, 5.4),
    _f('c_paneer', 'Paneer', 'Dairy', 100, 'g', 265, 18.3, 1.2, 20.8),
    _f('c_tofu', 'Tofu, firm', 'Protein', 100, 'g', 144, 17.3, 2.8, 8.7),
    _f('c_salmon', 'Salmon, cooked', 'Seafood', 150, 'g', 309, 33.0, 0, 18.5),
    _f('c_yogurt', 'Greek yogurt, plain non-fat', 'Dairy', 170, 'g', 100, 17.3, 6.1, 0.7),
    _f('c_milk', 'Milk, whole', 'Dairy', 250, 'ml', 153, 7.9, 12.0, 8.1),
    _f('c_curd', 'Curd / plain yogurt, whole milk', 'Dairy', 150, 'g', 92, 5.2, 7.0, 4.9),
    _f('c_whey', 'Whey protein, 1 scoop', 'Supplement', 30, 'g', 120, 24.0, 3.0, 1.5),
    _f('c_rice', 'White rice, cooked', 'Grains', 150, 'g', 195, 4.0, 42.3, 0.4),
    _f('c_brown_rice', 'Brown rice, cooked', 'Grains', 150, 'g', 185, 4.1, 38.4, 1.5),
    _f('c_chapati', 'Chapati / roti, 1 medium', 'Grains', 40, 'g', 119, 3.1, 18.4, 3.7),
    _f('c_bread', 'Whole wheat bread, 1 slice', 'Grains', 32, 'g', 81, 4.0, 13.7, 1.1),
    _f('c_dal', 'Lentils (dal), cooked', 'Legumes', 150, 'g', 174, 13.5, 30.1, 0.6),
    _f('c_chickpeas', 'Chickpeas, cooked', 'Legumes', 150, 'g', 246, 13.3, 41.1, 3.9),
    _f('c_rajma', 'Kidney beans (rajma), cooked', 'Legumes', 150, 'g', 191, 13.0, 34.2, 0.8),
    _f('c_potato', 'Potato, boiled', 'Vegetables', 150, 'g', 131, 2.8, 30.2, 0.2),
    _f('c_sweet_potato', 'Sweet potato, baked', 'Vegetables', 150, 'g', 135, 3.0, 31.1, 0.2),
    _f('c_broccoli', 'Broccoli, steamed', 'Vegetables', 100, 'g', 35, 2.4, 7.2, 0.4),
    _f('c_spinach', 'Spinach, cooked', 'Vegetables', 100, 'g', 23, 3.0, 3.8, 0.3),
    _f('c_banana', 'Banana, 1 medium', 'Fruit', 118, 'g', 105, 1.3, 27.0, 0.4),
    _f('c_apple', 'Apple, 1 medium', 'Fruit', 182, 'g', 95, 0.5, 25.1, 0.3),
    _f('c_orange', 'Orange, 1 medium', 'Fruit', 131, 'g', 62, 1.2, 15.4, 0.2),
    _f('c_mango', 'Mango, sliced', 'Fruit', 165, 'g', 99, 1.4, 24.7, 0.6),
    _f('c_almonds', 'Almonds', 'Nuts', 28, 'g', 164, 6.0, 6.1, 14.2),
    _f('c_peanut_butter', 'Peanut butter, 2 tbsp', 'Nuts', 32, 'g', 188, 8.0, 6.3, 16.1),
    _f('c_peanuts', 'Peanuts, roasted', 'Nuts', 28, 'g', 166, 6.7, 6.0, 14.1),
    _f('c_avocado', 'Avocado', 'Fruit', 100, 'g', 160, 2.0, 8.5, 14.7),
    _f('c_olive_oil', 'Olive oil, 1 tbsp', 'Fats', 13.5, 'ml', 119, 0, 0, 13.5),
    _f('c_ghee', 'Ghee, 1 tsp', 'Fats', 5, 'g', 45, 0, 0, 5.0),
    _f('c_cottage', 'Cottage cheese, low-fat', 'Dairy', 100, 'g', 81, 10.5, 4.1, 2.3),
    _f('c_tuna', 'Tuna, canned in water', 'Seafood', 100, 'g', 116, 25.5, 0, 0.8),
  ];

  static List<NutritionItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return foods;
    final words = q.split(RegExp(r'\s+'));
    return foods
        .where((f) => words.every((w) => f.name.toLowerCase().contains(w) || f.brand.toLowerCase().contains(w)))
        .toList();
  }
}
