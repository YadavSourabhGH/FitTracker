/// Model for evidence-based diet and sports nutrition suggestions.
class DietSuggestion {
  final String id;
  final String title;
  final String category; // 'Muscle Gain', 'Fat Loss', 'Recovery', 'Energy'
  final String recommendation;
  final String timing; // 'Morning', 'Pre-Workout', 'Post-Workout', 'Night'
  final List<String> foods;
  final String iconName;

  const DietSuggestion({
    required this.id,
    required this.title,
    required this.category,
    required this.recommendation,
    required this.timing,
    required this.foods,
    required this.iconName,
  });
}
