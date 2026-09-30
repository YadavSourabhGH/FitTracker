import '../models/diet_suggestion_model.dart';

/// Service delivering goal-based sports nutrition and meal suggestions.
class DietSuggestionService {
  static const List<DietSuggestion> suggestions = [
    DietSuggestion(
      id: 'ds_1',
      title: 'Post-Workout Anabolic Window',
      category: 'Muscle Gain',
      timing: 'Post-Workout',
      recommendation: 'Target 25-40g high-leucine protein within 45 minutes of training to stimulate muscle protein synthesis.',
      foods: ['Whey Isolate', 'Grilled Chicken Breast', 'Greek Yogurt', 'Egg Whites'],
      iconName: 'dumbbell',
    ),
    DietSuggestion(
      id: 'ds_2',
      title: 'Pre-Workout Glycogen Top-Up',
      category: 'Energy',
      timing: 'Pre-Workout',
      recommendation: 'Consume 30-50g clean low-glycemic complex carbohydrates 60-90 minutes before lifting for sustained stamina.',
      foods: ['Rolled Oats', 'Ripe Banana', 'Whole Wheat Toast with Honey', 'Rice Cakes'],
      iconName: 'zap',
    ),
    DietSuggestion(
      id: 'ds_3',
      title: 'High-Volume Calorie Deficit',
      category: 'Fat Loss',
      timing: 'Lunch',
      recommendation: 'Fill 50% of your plate with fibrous green vegetables to induce satiety while staying under calorie targets.',
      foods: ['Steamed Broccoli', 'Spinach Salad', 'Zucchini Noodles', 'Cauliflower Rice'],
      iconName: 'scale',
    ),
    DietSuggestion(
      id: 'ds_4',
      title: 'Slow-Release Nocturnal Recovery',
      category: 'Recovery',
      timing: 'Night',
      recommendation: 'Micellar casein or dairy proteins release amino acids over 7 hours to prevent sleep-phase catabolism.',
      foods: ['Cottage Cheese', 'Casein Shake', '0% Greek Yogurt with Almonds'],
      iconName: 'moon',
    ),
    DietSuggestion(
      id: 'ds_5',
      title: 'Optimal Cellular Hydration',
      category: 'Recovery',
      timing: 'Morning',
      recommendation: 'Drink 500ml water with a pinch of pink salt immediately upon waking to restore overnight fluid loss.',
      foods: ['Filtered Water', 'Electrolyte Water', 'Coconut Water'],
      iconName: 'droplets',
    ),
  ];

  List<DietSuggestion> getByCategory(String category) {
    if (category == 'All') return suggestions;
    return suggestions.where((s) => s.category == category).toList();
  }
}
