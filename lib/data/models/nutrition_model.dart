/// Models for nutrition, food items, and daily macro targets.
class NutritionItem {
  final String id;
  final String name;
  final String brand;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String mealType; // Breakfast, Lunch, Dinner, Snack

  const NutritionItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.mealType,
  });

  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  /// Default meal slot for the current time of day.
  static String mealTypeForNow() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Breakfast';
    if (h < 16) return 'Lunch';
    if (h < 19) return 'Snack';
    return 'Dinner';
  }

  /// Returns a copy scaled by [servings] with a fresh id and meal slot.
  NutritionItem scaled(double servings, {required String id, required String mealType}) {
    return NutritionItem(
      id: id,
      name: name,
      brand: brand,
      servingSize: servingSize * servings,
      servingUnit: servingUnit,
      calories: calories * servings,
      proteinGrams: proteinGrams * servings,
      carbsGrams: carbsGrams * servings,
      fatGrams: fatGrams * servings,
      mealType: mealType,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'servingSize': servingSize,
        'servingUnit': servingUnit,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'mealType': mealType,
      };

  factory NutritionItem.fromMap(Map<String, dynamic> map) {
    return NutritionItem(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String? ?? '',
      servingSize: (map['servingSize'] as num?)?.toDouble() ?? 100.0,
      servingUnit: map['servingUnit'] as String? ?? 'g',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (map['fatGrams'] as num?)?.toDouble() ?? 0.0,
      mealType: map['mealType'] as String? ?? 'Snack',
    );
  }
}

class MacroTargets {
  final double targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;

  const MacroTargets({
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
  });
}
