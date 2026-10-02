/// Achievement badge derived from real logged data.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final double progress; // 0..1
  final String progressLabel;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.progress,
    required this.progressLabel,
  });

  bool get isUnlocked => progress >= 1.0;
}

/// Aggregate lifetime statistics computed from the local database.
class UserStats {
  final int totalWorkouts;
  final int totalSets;
  final double totalVolumeKg;
  final int totalWorkoutSeconds;
  final int bestStepDay;
  final int totalSteps;
  final int daysGoalHit;
  final int longestStreak;
  final int mealsLogged;
  final int waterGoalDays;
  final List<bool> weekActive; // Monday..Sunday of the current week
  final int workoutsThisWeek;

  const UserStats({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.totalWorkoutSeconds,
    required this.bestStepDay,
    required this.totalSteps,
    required this.daysGoalHit,
    required this.longestStreak,
    required this.mealsLogged,
    required this.waterGoalDays,
    required this.weekActive,
    required this.workoutsThisWeek,
  });

  static const empty = UserStats(
    totalWorkouts: 0,
    totalSets: 0,
    totalVolumeKg: 0,
    totalWorkoutSeconds: 0,
    bestStepDay: 0,
    totalSteps: 0,
    daysGoalHit: 0,
    longestStreak: 0,
    mealsLogged: 0,
    waterGoalDays: 0,
    weekActive: [false, false, false, false, false, false, false],
    workoutsThisWeek: 0,
  );

  /// Experience points derived from real activity.
  int get xp =>
      totalWorkouts * 100 + totalSets * 5 + daysGoalHit * 50 + mealsLogged * 5 + waterGoalDays * 20;

  int get level => 1 + xp ~/ 1000;
  int get xpIntoLevel => xp % 1000;
}
