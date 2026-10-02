import '../../core/utils/fitness_calc.dart';
import 'nutrition_model.dart';

/// Primary training goal used for calorie targets.
enum FitnessGoal { lose, maintain, gain }

extension FitnessGoalX on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.lose:
        return 'Lose fat';
      case FitnessGoal.maintain:
        return 'Maintain';
      case FitnessGoal.gain:
        return 'Build muscle';
    }
  }

  int get calorieAdjustment {
    switch (this) {
      case FitnessGoal.lose:
        return -500;
      case FitnessGoal.maintain:
        return 0;
      case FitnessGoal.gain:
        return 300;
    }
  }
}

/// Activity multipliers used for TDEE.
class ActivityLevel {
  final String id;
  final String label;
  final String description;
  final double multiplier;

  const ActivityLevel(this.id, this.label, this.description, this.multiplier);

  static const all = [
    ActivityLevel('sedentary', 'Sedentary', 'Desk job, little exercise', 1.2),
    ActivityLevel('light', 'Lightly active', 'Exercise 1-3 days/week', 1.375),
    ActivityLevel('moderate', 'Moderately active', 'Exercise 3-5 days/week', 1.55),
    ActivityLevel('very', 'Very active', 'Hard exercise 6-7 days/week', 1.725),
  ];

  static ActivityLevel byId(String id) =>
      all.firstWhere((a) => a.id == id, orElse: () => all[1]);
}

/// Athlete profile, goals and preferences persisted in SharedPreferences.
class UserSettings {
  final String name;
  final String sex; // 'male' | 'female'
  final int age;
  final double heightCm;
  final double weightKg;
  final int stepGoal;
  final int waterGoalGlasses;
  final FitnessGoal goal;
  final String activityLevelId;
  final DateTime memberSince;
  final bool healthConnectEnabled;
  final bool workoutReminderEnabled;
  final int workoutReminderHour;
  final int workoutReminderMinute;
  final bool waterReminderEnabled;
  final bool stepNudgeEnabled;

  const UserSettings({
    required this.name,
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.stepGoal,
    required this.waterGoalGlasses,
    required this.goal,
    required this.activityLevelId,
    required this.memberSince,
    this.healthConnectEnabled = false,
    this.workoutReminderEnabled = false,
    this.workoutReminderHour = 18,
    this.workoutReminderMinute = 0,
    this.waterReminderEnabled = false,
    this.stepNudgeEnabled = false,
  });

  factory UserSettings.defaults() => UserSettings(
        name: 'Athlete',
        sex: 'male',
        age: 25,
        heightCm: 170,
        weightKg: 70,
        stepGoal: 8000,
        waterGoalGlasses: 8,
        goal: FitnessGoal.maintain,
        activityLevelId: 'light',
        memberSince: DateTime.now(),
      );

  bool get isMale => sex != 'female';
  String get firstName => name.trim().isEmpty ? 'Athlete' : name.trim().split(' ').first;
  ActivityLevel get activityLevel => ActivityLevel.byId(activityLevelId);

  double get bmr => FitnessCalc.bmr(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        isMale: isMale,
      );

  double get tdee => bmr * activityLevel.multiplier;

  double get calorieTarget {
    final target = tdee + goal.calorieAdjustment;
    final floor = isMale ? 1500.0 : 1200.0;
    return target < floor ? floor : target;
  }

  double get bmi => FitnessCalc.bmi(weightKg, heightCm);

  MacroTargets get macroTargets {
    final kcal = calorieTarget;
    final proteinPerKg = goal == FitnessGoal.maintain ? 1.6 : 2.0;
    final protein = weightKg * proteinPerKg;
    final fat = (kcal * 0.25) / 9.0;
    final carbsKcal = kcal - protein * 4 - fat * 9;
    final carbs = carbsKcal > 0 ? carbsKcal / 4.0 : 0.0;
    return MacroTargets(
      targetCalories: kcal,
      targetProteinGrams: protein,
      targetCarbsGrams: carbs,
      targetFatGrams: fat,
    );
  }

  double distanceMetersFor(int steps) => FitnessCalc.distanceMeters(steps, heightCm);
  double kcalFor(int steps) => FitnessCalc.walkingKcal(steps, heightCm, weightKg);

  UserSettings copyWith({
    String? name,
    String? sex,
    int? age,
    double? heightCm,
    double? weightKg,
    int? stepGoal,
    int? waterGoalGlasses,
    FitnessGoal? goal,
    String? activityLevelId,
    DateTime? memberSince,
    bool? healthConnectEnabled,
    bool? workoutReminderEnabled,
    int? workoutReminderHour,
    int? workoutReminderMinute,
    bool? waterReminderEnabled,
    bool? stepNudgeEnabled,
  }) {
    return UserSettings(
      name: name ?? this.name,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      stepGoal: stepGoal ?? this.stepGoal,
      waterGoalGlasses: waterGoalGlasses ?? this.waterGoalGlasses,
      goal: goal ?? this.goal,
      activityLevelId: activityLevelId ?? this.activityLevelId,
      memberSince: memberSince ?? this.memberSince,
      healthConnectEnabled: healthConnectEnabled ?? this.healthConnectEnabled,
      workoutReminderEnabled: workoutReminderEnabled ?? this.workoutReminderEnabled,
      workoutReminderHour: workoutReminderHour ?? this.workoutReminderHour,
      workoutReminderMinute: workoutReminderMinute ?? this.workoutReminderMinute,
      waterReminderEnabled: waterReminderEnabled ?? this.waterReminderEnabled,
      stepNudgeEnabled: stepNudgeEnabled ?? this.stepNudgeEnabled,
    );
  }
}
