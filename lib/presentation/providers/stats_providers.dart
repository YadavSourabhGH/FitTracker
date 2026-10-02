import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_keys.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/step_repository.dart';
import 'app_providers.dart';
import 'step_providers.dart';

/// Lifetime statistics computed from the local database.
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final settings = ref.watch(settingsProvider);
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final stepRepo = ref.watch(stepRepositoryProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  final hydrationRepo = ref.watch(hydrationRepositoryProvider);
  final liveToday = ref.read(todayStepProvider).value?.stepCount ?? 0;

  final totals = await workoutRepo.totals();
  final days = await stepRepo.allDays();
  final today = DateKeys.today();
  final byDay = {for (final d in days) d.dateString: d.stepCount};
  if (liveToday > (byDay[today] ?? 0)) byDay[today] = liveToday;

  var best = 0;
  var total = 0;
  var goalDays = 0;
  for (final v in byDay.values) {
    if (v > best) best = v;
    total += v;
    if (v >= settings.stepGoal && settings.stepGoal > 0) goalDays++;
  }

  final weekStart = DateKeys.startOfWeek(DateTime.now());
  final weekSessions = await workoutRepo.completedSessions(since: weekStart);
  final workoutDays = weekSessions.map((s) => DateKeys.of(s.startTime)).toSet();
  final weekActive = List.generate(7, (i) {
    final key = DateKeys.of(DateTime(weekStart.year, weekStart.month, weekStart.day + i));
    return (byDay[key] ?? 0) >= settings.stepGoal || workoutDays.contains(key);
  });

  final sortedDays = days.toList()..sort((a, b) => a.dateString.compareTo(b.dateString));

  return UserStats(
    totalWorkouts: totals['workouts'] ?? 0,
    totalSets: totals['sets'] ?? 0,
    totalVolumeKg: (totals['volume'] ?? 0).toDouble(),
    totalWorkoutSeconds: totals['seconds'] ?? 0,
    bestStepDay: best,
    totalSteps: total,
    daysGoalHit: goalDays,
    longestStreak: StepRepository.longestStreak(sortedDays, settings.stepGoal),
    mealsLogged: await nutritionRepo.mealsLogged(),
    waterGoalDays: await hydrationRepo.daysGoalReached(settings.waterGoalGlasses),
    weekActive: weekActive,
    workoutsThisWeek: weekSessions.length,
  );
});

Achievement _a(String id, String title, String desc, String icon, num value, num target, String unit) {
  final p = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0).toDouble();
  final shown = value > target ? target : value;
  return Achievement(
    id: id,
    title: title,
    description: desc,
    iconName: icon,
    progress: p,
    progressLabel: '${shown.round()} / ${target.round()} $unit',
  );
}

/// Achievement badges derived from [userStatsProvider].
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final s = await ref.watch(userStatsProvider.future);
  return [
    _a('first_workout', 'First Workout', 'Complete your first workout session.', 'dumbbell', s.totalWorkouts, 1, 'workouts'),
    _a('steps_10k', '10K Day', 'Walk 10,000 steps in a single day.', 'footprints', s.bestStepDay, 10000, 'steps'),
    _a('streak_7', 'Week Warrior', 'Hit your step goal 7 days in a row.', 'flame', s.longestStreak, 7, 'days'),
    _a('hydration', 'Hydration Hero', 'Reach your water goal on 7 days.', 'droplets', s.waterGoalDays, 7, 'days'),
    _a('ten_workouts', 'Dedicated', 'Complete 10 workouts.', 'target', s.totalWorkouts, 10, 'workouts'),
    _a('meals_25', 'Mindful Eater', 'Log 25 meals.', 'apple', s.mealsLogged, 25, 'meals'),
    _a('volume_10t', '10 Tonne Club', 'Lift a total volume of 10,000 kg.', 'award', s.totalVolumeKg, 10000, 'kg'),
    _a('streak_30', 'Unstoppable', 'Hit your step goal 30 days in a row.', 'crown', s.longestStreak, 30, 'days'),
    _a('fifty_workouts', 'Iron Habit', 'Complete 50 workouts.', 'trophy', s.totalWorkouts, 50, 'workouts'),
    _a('million_steps', 'Globetrotter', 'Walk 1,000,000 total steps.', 'mapPin', s.totalSteps, 1000000, 'steps'),
  ];
});
