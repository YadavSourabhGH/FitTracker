/// Standard sports-science formulas used across the app.
class FitnessCalc {
  FitnessCalc._();

  /// Mifflin-St Jeor basal metabolic rate (kcal/day).
  static double bmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return isMale ? base + 5 : base - 161;
  }

  /// Walking stride length estimate from height (metres).
  static double strideMeters(double heightCm) {
    final stride = heightCm * 0.415 / 100.0;
    return stride.clamp(0.5, 1.0);
  }

  static double distanceMeters(int steps, double heightCm) => steps * strideMeters(heightCm);

  /// Walking energy estimate: ~0.57 kcal per kg per km at a normal pace.
  static double walkingKcal(int steps, double heightCm, double weightKg) {
    final km = distanceMeters(steps, heightCm) / 1000.0;
    return km * weightKg * 0.57;
  }

  /// Minutes of walking implied by a step count at ~100 steps/min.
  static int activeMinutes(int steps) => steps <= 0 ? 0 : (steps / 100).ceil();

  /// MET-based energy expenditure (kcal).
  static double metKcal(double met, double weightKg, int seconds) =>
      met * weightKg * (seconds / 3600.0);

  /// Approximate MET values by workout category (Compendium of Physical Activities).
  static double metForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'hiit':
        return 8.0;
      case 'cardio':
        return 7.0;
      case 'mobility':
        return 2.5;
      case 'hypertrophy':
      case 'strength':
      default:
        return 5.0;
    }
  }

  /// Epley one-repetition maximum estimate.
  static double epley1Rm(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30.0);
  }

  /// Parses the first integer in a target like "6-8", "10" or "30s".
  static int parseLeadingInt(String text, {int fallback = 8}) {
    final match = RegExp(r'\d+').firstMatch(text);
    if (match == null) return fallback;
    return int.tryParse(match.group(0)!) ?? fallback;
  }

  static double bmi(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final m = heightCm / 100.0;
    return weightKg / (m * m);
  }

  static String bmiCategory(double bmi) {
    if (bmi <= 0) return '-';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
